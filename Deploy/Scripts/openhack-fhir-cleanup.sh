#!/bin/bash
# This script cleans up resources and Azure AD App Registrations created for the OpenHack.

echo "Set Variables"

# Parameters.txt file is in the same path as this file
. parameters.txt

resourceGroupName=${environmentName}
sofResourceGroupName="${resourceGroupName}-sof"
keyvaultname="${environmentName}-ts"

confidentialClientId=""
serviceClientId=""
publicClientId=""
dashboardUserUpn=""

echo "$environmentName"
echo "$primarySubscription"
echo "$secondarySubscription"
echo "$resourceGroupName"
echo "$sofResourceGroupName"
echo "$keyvaultname"

echo "Variables Set"
# Set account to primary subscription where Key Vault exists
az account set -s $primarySubscription
echo "Account set to Primary Subscription"

echo "Acquire client IDs from Key Vault."
if [ ! -z $(az keyvault list -o tsv --query "[?name == '$keyvaultname'].name") ]
then
    confidentialClientId=$(az keyvault secret show --name "${environmentName}-confidential-client-id" --vault-name $keyvaultname --query "value" -o tsv)
    serviceClientId=$(az keyvault secret show --name "${environmentName}-service-client-id" --vault-name $keyvaultname --query "value" -o tsv)
    publicClientId=$(az keyvault secret show --name "${environmentName}-public-client-id" --vault-name $keyvaultname --query "value" -o tsv)
    dashboardUserUpn=$(az keyvault secret show --name "${environmentName}-admin-upn" --vault-name $keyvaultname --query "value" -o tsv)
    echo "Key Vault values acquired."
else
    echo "Key Vault did not exist."
fi

# Set account to secondary subscription/tenant where app registrrations will be built
az account set -s $secondarySubscription
echo "Account set to Secondary Subscription/Tenant"

echo "Acquire FHIR API App Registration clientId."
fhirApiClientId=$(az ad app list --display-name "https://${environmentName}.azurehealthcareapis.com" --query "[0].appId" -o tsv)
echo "FHIR API App Registration clientId acquired."

echo "Delete Azure AD App Registrations - START"
if [ ! -z $confidentialClientId ]
then
    az ad app delete --id $confidentialClientId
fi

if [ ! -z $serviceClientId ]
then
    az ad app delete --id $serviceClientId
fi

if [ ! -z $publicClientId ]
then
    az ad app delete --id $publicClientId
fi

if [ ! -z $fhirApiClientId ]
then
    az ad app delete --id $fhirApiClientId
fi
echo "Delete Azure AD App Registrations - END"

# Set account to primary subscription where resources exists
az account set -s $primarySubscription
echo "Account set to Primary Subscription"

echo "Delete Resource Groups - START"
if $(az group exists --name $resourceGroupName)
then
    az group delete --name $resourceGroupName --yes
else
    echo "Resource Group does not exist!"
fi

if $(az group exists --name $sofResourceGroupName)
then
    az group delete --name $sofResourceGroupName --yes
else
    echo "Resource Group does not exist!"
fi
echo "Delete Resource Groups - END"

echo "NOTE: Dashboard Admin User was not deleted and will need to be deleted manually."
