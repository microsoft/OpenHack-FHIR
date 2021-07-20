#!/bin/bash
# This script assumes the account executing it has privileges to both subscriptions...
# And has the necessary Azure AD privileges in the secondary Subscription's AD tenant to create/manage App Registrations.
# If using a separately created Azure AD tenant that has no subscriptions, you must loging using 'az login --allow-no-subscriptions'.

echo "Set Variables - START"

# Parameters.txt file is in the same path as this file
. parameters.txt

echo "$environmentName"
echo "$primarySubscription"
echo "$secondarySubscription"
echo "$aadDomain"
echo "$adminPwd"

userNamePrefix="${environmentName}-"
userId="${userNamePrefix}admin"
adminUserUpn="${userId}@${aadDomain}"

keyvaultname="${environmentName}-ts"
echo "Set Variables - END"

# Set account to secondary subscription/tenant where app registrrations will be built
az account set -s $secondarySubscription
secondarySubscriptionId=$(az account show --query id -o tsv)
if [[ "$secondarySubscription" != "$secondarySubscriptionId" ]];
then
    echo "Failed to set secondary subscription! Exiting."
    exit 1
fi
echo "Account set to Secondary Subscription/Tenant"

# Create admin user
echo "Create Admin user"
adminUserObjectId=$(az ad user create --display-name $adminUserUpn --password $adminPwd --user-principal-name $adminUserUpn --force-change-password-next-login false --query objectId -o tsv)
echo "Admin user created"

# FHIR API App
echo "FHIR API App Registraiton - START"
fhirServiceUrl="https://${environmentName}.azurehealthcareapis.com"
fhirAppId=$(az ad app create --display-name $fhirServiceUrl --identifier-uris $fhirServiceUrl --app-roles '[{"allowedMemberTypes": ["User","Application"],"description": "globalAdmin","displayName": "globalAdmin","isEnabled": "true","value": "globalAdmin"}]' --query appId -o tsv)
sleep 30
fhirAppServicePrincipalObjectId=$(az ad sp create --id $fhirAppId --query objectId -o tsv)
fhirApiPermissionId=$(az ad app show --id $fhirAppId --query "[oauth2Permissions[?value=='user_impersonation'].id]" -o tsv)
fhirAppGlobalAdminRoleObjectId=$(az ad app show --id $fhirAppId --query "[appRoles[?value=='globalAdmin'].id]" -o tsv)

echo "FHIR API App Registraiton - END"
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
az ad app permission grant --id $confidentialClientId --api $fhirAppId
echo "Confidential Client App Registraiton - END"

# Service Client
echo "Service Client App Registraiton - START"
serviceClientAppId=$(az ad app create --display-name ${environmentName}-service-client --identifier-uris https://${environmentName}-service-client --reply-urls "https://www.getpostman.com/oauth2/callback" --query appId -o tsv)
sleep 90
az ad sp create --id $serviceClientAppId
serviceClientAppSecret=$(az ad app credential reset --id $serviceClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $serviceClientAppId \
    --api $fhirAppId \
    --api-permissions $fhirAppGlobalAdminRoleObjectId=Role
az ad app permission admin-consent --id $serviceClientAppId

az ad app permission add \
    --id $serviceClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope

az ad app permission add \
    --id $serviceClientAppId \
    --api $fhirAppId \
    --api-permissions $fhirApiPermissionId=Scope
echo "Service Client App Registraiton - END"

# Public Client
echo "Public Client App Registraiton - START"
# Establish redirect urls
# This section can most likeyly be written more efficiently regarding the encoded string cleanup.  Passable for now.
# Intent is to 1) remove trailing '=', 2) replace all '/' with '_', and 3) replace all '+' with '-'.
webAppSuffix="azurewebsites.net"
growthChartName="${environmentName}growth"

growthChartUrl1=$(echo -n "https://${growthChartName}.${webAppSuffix}" | base64)
while [[ $growthChartUrl1 = *"=" ]]
do growthChartUrl1=${growthChartUrl1/%=}
done
growthChartUrl1=${growthChartUrl1//"/"/"_"}
growthChartUrl1=${growthChartUrl1//"+"/"-"}

growthChartUrl2=$(echo -n "https://${growthChartName}.${webAppSuffix}/" | base64)
while [[ $growthChartUrl2 = *"=" ]]
do growthChartUrl2=${growthChartUrl2/%=}
done
growthChartUrl2=${growthChartUrl2//"/"/"_"}
growthChartUrl2=${growthChartUrl2//"+"/"-"}

growthChartUrl3=$(echo -n "https://${growthChartName}.${webAppSuffix}/index.html" | base64)
while [[ $growthChartUrl3 = *"=" ]]
do growthChartUrl3=${growthChartUrl3/%=}
done
growthChartUrl3=${growthChartUrl3//"/"/"_"}
growthChartUrl3=${growthChartUrl3//"+"/"-"}

medicationsName="${environmentName}meds"
medicationsUrl1=$(echo -n "https://${medicationsName}.${webAppSuffix}" | base64)
while [[ $medicationsUrl1 = *"=" ]]
do medicationsUrl1=${medicationsUrl1/%=}
done
medicationsUrl1=${medicationsUrl1//"/"/"_"}
medicationsUrl1=${medicationsUrl1//"+"/"-"}

medicationsUrl2=$(echo -n "https://${medicationsName}.${webAppSuffix}/" | base64)
while [[ $medicationsUrl2 = *"=" ]]
do medicationsUrl2=${medicationsUrl2/%=}
done
medicationsUrl2=${medicationsUrl2//"/"/"_"}
medicationsUrl2=${medicationsUrl2//"+"/"-"}

medicationsUrl3=$(echo -n "https://${medicationsName}.${webAppSuffix}/index.html" | base64)
while [[ $medicationsUrl3 = *"=" ]]
do medicationsUrl3=${medicationsUrl3/%=}
done
medicationsUrl3=${medicationsUrl3//"/"/"_"}
medicationsUrl3=${medicationsUrl3//"+"/"-"}

publicClientRedirectUrls="$fhirServiceUrl/AadSmartOnFhirProxy/callback/$growthChartUrl1
    $fhirServiceUrl/AadSmartOnFhirProxy/callback/$growthChartUrl2
    $fhirServiceUrl/AadSmartOnFhirProxy/callback/$growthChartUrl3
    $fhirServiceUrl/AadSmartOnFhirProxy/callback/$medicationsUrl1
    $fhirServiceUrl/AadSmartOnFhirProxy/callback/$medicationsUrl2
    $fhirServiceUrl/AadSmartOnFhirProxy/callback/$medicationsUrl3
    https://www.getpostman.com/oauth2/callback"

publicClientAppId=$(az ad app create --display-name ${environmentName}-public-client --native-app true --reply-urls $publicClientRedirectUrls --query appId -o tsv)
sleep 90
az ad sp create --id $publicClientAppId
publicClientAppSecret=$(az ad app credential reset --id $publicClientAppId --credential-description "client-secret" --query password -o tsv)

az ad app permission add \
    --id $publicClientAppId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id $publicClientAppId --api 00000003-0000-0000-c000-000000000000

az ad app permission add \
    --id $publicClientAppId \
    --api $fhirAppId \
    --api-permissions $fhirApiPermissionId=Scope
az ad app permission grant --id $publicClientAppId --api $fhirAppId
echo "Public Client App Registraiton - END"

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