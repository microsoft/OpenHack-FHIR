# This script assumes the account executing it has privileges to both subscriptions.
# And has the necessary Azure AD privileges in the secondary Subscription's AD tenant to create/manage App Registrations.

environmentName="<ENVVIRONMENT_NAME>"
primarySubscription="<PRIMARY_SUBSCRIPTION>"
secondarySubscription="<SECONDAY_SUBSCRIPTION>"
keyvaultname="${environmentName}-ts"

# FHIR API App
fhirAppId=$(az ad app create --display-name $environmentName --identifier-uris $environmentName --app-roles '[{"allowedMemberTypes": ["User","Application"],"description": "globalAdmin","displayName": "globalAdmin","isEnabled": "true","value": "globalAdmin"}]' --query appId -o tsv)

# az account set -s $secondarySubscription
# az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-client-id" --value $fhirAppId
# az account set -s $primarySubscription


# Confidential Client
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


# Service Client
serviceClientAppId=$(az ad app create --display-name ${environmentName}-service-client --native-app --reply-urls "https://www.getpostman.com/oauth2/callback" --query appId -o tsv)

az ad sp create --id $serviceClientAppId
serviceClientAppSecret=$(az ad app credential reset --id $serviceClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $serviceClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $serviceClientAppId --api 00000003-0000-0000-c000-000000000000


# Public Client
publicClientAppId=$(az ad app create --display-name ${environmentName}-public-client --native-app true --reply-urls "https://www.getpostman.com/oauth2/callback" --query appId -o tsv)

az ad sp create --id $publicClientAppId
publicClientAppSecret=$(az ad app credential reset --id $publicClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $publicClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $publicClientAppId --api 00000003-0000-0000-c000-000000000000
