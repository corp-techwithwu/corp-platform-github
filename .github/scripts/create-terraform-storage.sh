set -euo pipefail

SUBSCRIPTION_ID="${1:-${AZURE_SUBSCRIPTION_ID:-}}"
STATE_RG_NAME="${2:-rg-terraform-state-prod}"
STATE_SA_NAME="${3:-stcorpghasstateprod}"
STATE_CONTAINER_NAME="${4:-tfstate}"
STATE_LOCATION="${5:-eastus}"

: "${SUBSCRIPTION_ID:?SUBSCRIPTION_ID is empty}"
: "${AZURE_TENANT_ID:?AZURE_TENANT_ID is empty}"
: "${AZURE_CLIENT_ID:?AZURE_CLIENT_ID is empty}"

echo "Expected subscription: $SUBSCRIPTION_ID"
echo "Expected tenant:       $AZURE_TENANT_ID"
echo "Expected client id:    $AZURE_CLIENT_ID"

echo "== Effective CLI context =="
az account show --output json

echo "== Subscriptions visible to THIS workflow identity =="
az account list --all --refresh \
  --query '[].{id:id,name:name,tenant:tenantId,state:state}' \
  --output table

echo "== Hard-check target subscription =="
az account show --subscription "$SUBSCRIPTION_ID" --output json

echo "== Hard-check RG is really in target subscription =="
RG_JSON=$(az group show \
  --name "$STATE_RG_NAME" \
  --subscription "$SUBSCRIPTION_ID" \
  --output json)

echo "$RG_JSON"

RG_ID=$(echo "$RG_JSON" | jq -r '.id')
EXPECTED_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${STATE_RG_NAME}"

if [[ "${RG_ID,,}" != "${EXPECTED_ID,,}" ]]; then
  echo "::error::RG exists, but not in the intended subscription. Got: $RG_ID"
  exit 1
fi

echo "RG confirmed in target subscription: $RG_ID"

echo "== Check subscription-level IAM visibility =="
az role assignment list \
  --assignee "$AZURE_CLIENT_ID" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --all \
  --output table || true

echo "== Check Microsoft.Storage provider =="
az provider show \
  --namespace Microsoft.Storage \
  --subscription "$SUBSCRIPTION_ID" \
  --query '{namespace:namespace,state:registrationState}' \
  --output table