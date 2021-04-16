# This script assumes the account executing it has privileges to both subscriptions...
# And has the necessary Azure AD privileges in the secondary Subscription's AD tenant to create/manage App Registrations.
# If using a separately created Azure AD tenant that has no subscriptions, you must loging using 'az login --allow-no-subscriptions'.

echo "Set Variables - START"
environmentName="<ENVVIRONMENT_NAME>"
primarySubscription="<PRIMARY_SUBSCRIPTION_ID>"
secondarySubscription="<SECONDARY_SUBSCRIPTION_ID>"		# This is Secondary Tenant ID
aadDomain="<AZURE_AD_DOMAIN_FOR_APP_REGISTRATIONS>"    # Azure AD domain name (ex: contoso.com)
adminPwd="<ADMIN_PASSWORD>"

userNamePrefix="${environmentName}-"
userId="${userNamePrefix}admin"
adminUserUpn="${userId}@${aadDomain}"

keyvaultname="${environmentName}-ts"
echo "Set Variables - END"

# Set account to secondary subscription/tenant where app registrrations will be built
az account set -s $secondarySubscription
echo "Account set to Secondary Subscription/Tenant"

# Create admin user
az ad user create --display-name $adminUserUpn --password $adminPwd --user-principal-name $adminUserUpn --force-change-password-next-login false
echo "Admin user created"

# FHIR API App
echo "FHIR API App Registraiton - START"
fhirServiceUrl="https://${environmentName}.azurehealthcareapis.com"
fhirAppId=$(az ad app create --display-name $fhirServiceUrl --identifier-uris $fhirServiceUrl --app-roles '[{"allowedMemberTypes": ["User","Application"],"description": "globalAdmin","displayName": "globalAdmin","isEnabled": "true","value": "globalAdmin"}]' --query appId -o tsv)
sleep 30
fhirAppServicePrincipalObjectId=$(az ad sp create --id $fhirAppId --query objectId -o tsv)
fhirApiPermissionId=$(az ad app show --id $fhirAppId --query "[oauth2Permissions[?value=='user_impersonation'].id] | [0] | [0] " -o tsv)
echo "FHIR API App Registraiton - END"

# Apply global admin privileges to the admin user for the FHIR API"
# ??

# Confidential Client
echo "Confidential Client App Registraiton - START"
confidentialClientName="${environmentName}-confidential-client"

confidentialAppUri="https://${environmentName}-confidential-client"
replyUrls="https://${environmentName}dash.azurewebsites.net/.auth/login/aad/callback"
confidentialClientId=$(az ad app create --display-name $confidentialClientName --identifier-uris $confidentialAppUri --reply-urls $replyUrls --query appId -o tsv) 
sleep 30
az ad sp create --id $confidentialClientId
confidentialClientAppSecret=$(az ad app credential reset --id $confidentialClientId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $confidentialClientId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $confidentialClientId --api 00000003-0000-0000-c000-000000000000

az ad app permission add \
    --id $confidentialClientId \
    --api $fhirAppId \
    --api-permissions $fhirApiPermissionId=Scope
#az ad app permission grant --id $confidentialClientId --api $fhirAppId
echo "Confidential Client App Registraiton - END"

# Service Client
echo "Service Client App Registraiton - START"
serviceClientAppId=$(az ad app create --display-name ${environmentName}-service-client --native-app --reply-urls "https://www.getpostman.com/oauth2/callback" --query appId -o tsv)
sleep 90
az ad sp create --id $serviceClientAppId
serviceClientAppSecret=$(az ad app credential reset --id $serviceClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $serviceClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $serviceClientAppId --api 00000003-0000-0000-c000-000000000000

az ad app permission add \
    --id $serviceClientAppId \
    --api $fhirAppId \
    --api-permissions $fhirApiPermissionId=Scope
#az ad app permission grant --id $confidentialClientId --api $fhirAppId
echo "Service Client App Registraiton - END"

# Public Client
echo "Public Client App Registraiton - START"
publicClientAppId=$(az ad app create --display-name ${environmentName}-public-client --native-app true --reply-urls "https://www.getpostman.com/oauth2/callback" --query appId -o tsv)
sleep 90
az ad sp create --id $publicClientAppId
publicClientAppSecret=$(az ad app credential reset --id $publicClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $publicClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $publicClientAppId --api 00000003-0000-0000-c000-000000000000
echo "Public Client App Registraiton - END"

az ad app permission add \
    --id $publicClientAppId \
    --api $fhirAppId \
    --api-permissions $fhirApiPermissionId=Scope
#az ad app permission grant --id $confidentialClientId --api $fhirAppId

# Save variables to Key Vault located in primary subscription
echo "Switch to Primary Subscription"
az account set -s $primarySubscription
echo "Set Key Vault Secrets - START"
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-admin-upn" --value $adminUserUpn
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-admin-password" --value $adminPwd
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-confidential-client-id" --value $confidentialClientId
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-confidential-client-secret" --value $confidentialClientAppSecret
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-service-client-id" --value $serviceClientAppId
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-service-client-secret" --value $serviceClientAppSecret
az keyvault secret set --vault-name $keyvaultname --subscription $primarySubscription --name "${environmentName}-public-client-id" --value $publicClientAppId
echo "Set Key Vault Secrets - END"
az account set -s $secondarySubscription