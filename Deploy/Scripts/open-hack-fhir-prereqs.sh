# Creates Resource Group and Key Vault
environmentName="<ENVVIRONMENT_NAME>"
environmentLocation="<ENVIRONMENT_LOCATION>"
primarySubscription="<PRIMARY_SUBSCRIPTION>"
resourceGroupName=${environmentName}
keyvaultname="${environmentName}-ts"

# Create resource group
echo "Creating Resource Group."
az group create -n $resourceGroupName -l $environmentLocation
echo "Resource Group ${resourceGroupName} created."

# Create Resource Group for SMART on FHIR apps, since Linux Container apps cannot live in a resource group with windows apps
echo "Creating Resource Group for SMAR on FHIR apps."
az group create -n "${resourceGroupName}-sof" -l $environmentLocation
echo "Resource Group ${resourceGroupName}-sof created."

# Create Key Vault
echo "Creating Key Vault."
az keyvault create --name $keyvaultname --resource-group $resourceGroupName --location $environmentLocation
echo "Key Vault ${keyvaultname} created."