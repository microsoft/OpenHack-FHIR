#!/bin/bash
# This script creates Resource Group and Key Vault in Primary Subscription
echo "Set Variables"

# Parameters.txt file is in the same path as this file
. parameters.txt

#echo "$environmentName"
#echo "$environmentLocation"
#echo "$primarySubscription"

resourceGroupName=${environmentName}
keyvaultname="${environmentName}-ts"

echo "Variables Set"

# Set account to primary subscription where resources will be built
az account set -s $primarySubscription

# Create resource group
echo "Creating Resource Group."
az group create -n $resourceGroupName -l $environmentLocation
echo "Resource Group ${resourceGroupName} created."

# Create Resource Group for SMART on FHIR apps, since Linux Container apps cannot live in a resource group with windows apps
echo "Creating Resource Group for SMART on FHIR apps."
az group create -n "${resourceGroupName}-sof" -l $environmentLocation
echo "Resource Group ${resourceGroupName}-sof created."

# Create Key Vault
echo "Creating Key Vault."
az keyvault create --name $keyvaultname --resource-group $resourceGroupName --location $environmentLocation
echo "Key Vault ${keyvaultname} created."