terraform {
  required_version = ">= 1.7"

  required_providers {
    azuread = { source = "hashicorp/azuread",   version = "~> 3.0" }
    azurerm = { source = "hashicorp/azurerm",   version = "~> 4.0" }
    github  = { source = "integrations/github", version = "~> 6.0" }
    time    = { source = "hashicorp/time",      version = "~> 0.12" }
  }

  # 面试加分: remote state
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate-prod"
  #   storage_account_name = "sttfstate<yourname>"
  #   container_name       = "tfstate"
  #   key                  = "azure-oidc-bootstrap.tfstate"
  # }
}

provider "azuread" {}
provider "azurerm" { features {} }
provider "github"  { owner = var.github_org }

###############################################################################
# 3. Entra ID 侧: App Registration + Service Principal
###############################################################################

data "azuread_client_config" "current" {}

resource "azuread_application" "this" {
  for_each     = local.sps
  display_name = each.key
  notes        = "Owner: ${each.value.owner_team} | ${each.value.purpose} | Managed by Terraform"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "this" {
  for_each  = local.sps
  client_id = azuread_application.this[each.key].client_id
  owners    = [data.azuread_client_config.current.object_id]

  # 企业租户常开 "User assignment required", 关掉让工作流能用
  app_role_assignment_required = false
}

###############################################################################
# 4. RBAC: scope 直接吃 CSV 里的完整 ARM ID + 可选 ABAC
###############################################################################

resource "azurerm_role_assignment" "this" {
  for_each = local.rbac_map

  scope                = each.value.scope_ref
  role_definition_name = each.value.role_definition_name
  principal_id         = azuread_service_principal.this[each.value.sp_name].object_id
  principal_type       = each.value.principal_type

  # 动态 ABAC: 只有 condition_mode == "exclude_privileged" 才注入
  condition_version = each.value.condition_mode == "exclude_privileged" ? "2.0" : null
  condition         = each.value.condition_mode == "exclude_privileged" ? local.exclude_privileged_condition : null

  # 刚建完 SP 立刻赋权会撞 AAD→ARM 复制延迟
  skip_service_principal_aad_check = true

  # description 在 azurerm 4.x 支持; 老版本删掉这行
  description = each.value.description
}

# RBAC 传播缓冲: 下游 (业务 repo 第一次跑) 依赖它, 避免 60s 内的 403
resource "time_sleep" "rbac_propagation" {
  depends_on      = [azurerm_role_assignment.this]
  create_duration = "60s"
}

###############################################################################
# 5. Federated Credential —— Immutable ID subject
#
#   environment 类型:
#     repo:<ORG>@<ORG_ID>/<REPO>@<REPO_ID>:environment:<ENV>
#   pull_request 类型:
#     repo:<ORG>@<ORG_ID>/<REPO>@<REPO_ID>:pull_request
#
#   ★ 用 repo_id (数字) 而非 repo 名 → 防 repo 改名 / repojacking
#   ★ 引用 github_repository.this → Terraform 自动把建 repo 排在前
###############################################################################

resource "azuread_application_federated_identity_credential" "this" {
  for_each = local.fic_map

  application_id = azuread_application.this[each.value.sp_name].id
  display_name   = "gh-${each.value.repo_name}-${each.value.environment}"
  description    = "OIDC trust for ${each.value.repo_name} / ${each.value.environment} (managed by Terraform)"
  issuer         = "https://token.actions.githubusercontent.com"
  audiences      = ["api://AzureADTokenExchange"]

  subject = each.value.subject_type == "pull_request"
    ? "repo:${var.github_org}@${data.github_organization.this.id}/${each.value.repo_name}@${github_repository.this[each.value.repo_name].repo_id}:pull_request"
    : "repo:${var.github_org}@${data.github_organization.this.id}/${each.value.repo_name}@${github_repository.this[each.value.repo_name].repo_id}:environment:${each.value.environment}"
}

###############################################################################
# 6. (可选) 把三个变量回写到 GitHub Environment Variables
#    这样业务 repo 连 secrets/vars 都不用手填 —— 全自动闭环
###############################################################################

locals {
  # 每个 (repo, environment) 组合对应一个 SP: 目前 CSV 里 bootstrap 覆盖全部
  env_var_targets = {
    for k, r in local.fic_map : k => r
    if r.subject_type == "environment"
  }
}

resource "github_actions_environment_variable" "tenant_id" {
  for_each = local.env_var_targets

  repository    = each.value.repo_name
  environment   = each.value.environment
  variable_name = "AZURE_TENANT_ID"
  value         = data.azuread_client_config.current.tenant_id
}

resource "github_actions_environment_variable" "client_id" {
  for_each = local.env_var_targets

  repository    = each.value.repo_name
  environment   = each.value.environment
  variable_name = "AZURE_CLIENT_ID"
  value         = azuread_application.this[each.value.sp_name].client_id
}

resource "github_actions_environment_variable" "subscription_id" {
  for_each = local.env_var_targets

  repository    = each.value.repo_name
  environment   = each.value.environment
  variable_name = "AZURE_SUBSCRIPTION_ID"
  # 从 rbac.csv 里挑这个 SP 的第一个 subscription scope 作为默认值
  value = try(
    element([
      for r in local.rbac : r.scope_ref
      if r.sp_name == each.value.sp_name && r.scope_type == "subscription"
    ], 0),
    "SET-ME" # bootstrap 本身没有 subscription scope, 手动填或改成从 tfvars 传
  )

  depends_on = [time_sleep.rbac_propagation]
}
