export AZURE_SUBSCRIPTION_ID=6b80b8d5-aef4-4952-8558-1f1b168f47a6
export AZURE_CLIENT_ID=f7d97ef1-807c-4855-908a-ead05fbb18a0
export AZURE_TENANT_ID=da528e4a-a122-4392-b5c8-370e74e0236d

# OIDC 方式登录（模拟 GitHub Actions）
az login --service-principal -u $AZURE_CLIENT_ID --tenant $AZURE_TENANT_ID --federated-token "$TOKEN"
# 或者用 secret：az login --service-principal -u $AZURE_CLIENT_ID -p $CLIENT_SECRET --tenant $AZURE_TENANT_ID