# This script assumes the account executing it has privileges to both subscriptions.
# And has the necessary Azure AD privileges in the secondary Subscription's AD tenant to create/manage App Registrations.

echo "Set Variables"
environmentName="<ENVVIRONMENT_NAME>"
primarySubscription="<PRIMARY_SUBSCRIPTION>"
secondarySubscription="<SECONDAY_SUBSCRIPTION>"
aadDomain="<AZURE_AD_DOMAIN_FOR_APP_REGISTRATIONS>"    # Azure AD domain name
adminPwd="<ADMIN_PASSWORD>"

userNamePrefix="${environmentName}-"
userId="${userNamePrefix}admin"
userUpn="${userId}@${aadDomain}"
keyvaultname="${environmentName}-ts"
echo "Variables Set"

# Set account to secondary subscription/tenant where app registrrations will be built
az account set -s $secondarySubscription
echo "Account set to Seconday Subscription/Tenant"

# FHIR API App
fhirAppId=$(az ad app create --display-name $environmentName --identifier-uris $environmentName --app-roles '[{"allowedMemberTypes": ["User","Application"],"description": "globalAdmin","displayName": "globalAdmin","isEnabled": "true","value": "globalAdmin"}]' --query appId -o tsv)

# Confidential Client
echo "Create Confidential Client App Registraiton"
confidentialAppUri="https://${environmentName}-confidential-client"
replyUrls="https://${environmentName}dash.azurewebsites.net/.auth/login/aad/callback"
confidentialClientId=$(az ad app create --display-name ${environmentName}-confidential-client --identifier-uris $confidentialAppUri --reply-urls $replyUrls --query appId -o tsv) 

az ad sp create --id $confidentialClientId

confidentialClientAppSecret=$(az ad app credential reset --id $confidentialClientId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $confidentialClientId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $confidentialClientId --api 00000003-0000-0000-c000-000000000000

echo "Created Confidential Client App Registraiton"

# Service Client
echo "Create Service Client App Registraiton"
serviceClientAppId=$(az ad app create --display-name ${environmentName}-service-client --native-app --reply-urls "https://www.getpostman.com/oauth2/callback" --query appId -o tsv)

az ad sp create --id $serviceClientAppId
serviceClientAppSecret=$(az ad app credential reset --id $serviceClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $serviceClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $serviceClientAppId --api 00000003-0000-0000-c000-000000000000

echo "Created Service Client App Registraiton"

# Public Client
echo "Create Public Client App Registraiton"
publicClientAppId=$(az ad app create --display-name ${environmentName}-public-client --native-app true --reply-urls "https://www.getpostman.com/oauth2/callback" --query appId -o tsv)

az ad sp create --id $publicClientAppId
publicClientAppSecret=$(az ad app credential reset --id $publicClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $publicClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $publicClientAppId --api 00000003-0000-0000-c000-000000000000

echo "Created Public Client App Registraiton"


# Save variables to Key Vault located in primary subscription
echo "Switch to Primary Subscription"
az account set -s $primarySubscription
echo "Set Key Vault Secrets"
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-admin-upn" --value $userUpn
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-admin-password" --value $adminPwd
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-confidential-client-id" --value $confidentialClientId
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-confidential-client-secret" --value $confidentialClientAppSecret
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-service-client-id" --value $serviceClientAppId
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-service-client-secret" --value $serviceClientAppSecret
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-public-client-id" --value $publicClientAppId
echo "Key Vault Secrets Set"
az account set -s $secondarySubscription