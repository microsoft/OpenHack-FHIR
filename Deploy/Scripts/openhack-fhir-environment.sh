#!/bin/bash
# This script deploys resources in Primary Subscription using fhir-server and fhir-server-samples templates
# Set variables
echo "Set Variables - START"

# Parameters.txt file is in the same path as this file
. parameters.txt

echo "$environmentName"
echo "$primarySubscription"
echo "$secondarySubscription"
echo "$fhirApiLocation"
echo "$sqlAdminPassword"
echo "$aadAuthority"

fhirVersion="R4"
resourceGroupName=${environmentName}
keyvaultname="${environmentName}-ts"

sourceRepository="https://github.com/Microsoft/fhir-server-samples"
githubRawBaseUrl="https://raw.githubusercontent.com/Microsoft/fhir-server-samples"
sourceRevision="master"
templateFile="https://raw.githubusercontent.com/microsoft/fhir-server-samples/master/deploy/templates/azuredeploy-sandbox.json"
sandboxTemplate="${githubRawBaseUrl}/${sourceRevision}/deploy/templates/azuredeploy-sandbox.json"
dashboardJSTemplate="${githubRawBaseUrl}/${sourceRevision}/deploy/templates/azuredeploy-fhirdashboard-js.json"
importerTemplate="${githubRawBaseUrl}/${sourceRevision}/deploy/templates/azuredeploy-importer.json"

fhirServerTemplateUrl="https://raw.githubusercontent.com/Microsoft/fhir-server/master/samples/templates/default-azuredeploy.json"

deploySource=true
usePaaS=true
enableExport=false

currentUserObjectId=$(az ad signed-in-user show --query objectId -o tsv)
echo "Set Variables - END"

# Set account to primary subscription where Key Vault exists
az account set -s $primarySubscription
echo "Account set to Primary Subscription"

confidentialClientId=$(az keyvault secret show --name "${environmentName}-confidential-client-id" --vault-name $keyvaultname --query "value" -o tsv)
confidentialClientSecret=$(az keyvault secret show --name "${environmentName}-confidential-client-secret" --vault-name $keyvaultname --query "value" -o tsv)
serviceClientId=$(az keyvault secret show --name "${environmentName}-service-client-id" --vault-name $keyvaultname --query "value" -o tsv)
serviceClientSecret=$(az keyvault secret show --name "${environmentName}-service-client-secret" --vault-name $keyvaultname --query "value" -o tsv)
publicClientId=$(az keyvault secret show --name "${environmentName}-public-client-id" --vault-name $keyvaultname --query "value" -o tsv)
dashboardUserUpn=$(az keyvault secret show --name "${environmentName}-admin-upn" --vault-name $keyvaultname --query "value" -o tsv)
dashboardUserPassword=$(az keyvault secret show --name "${environmentName}-admin-password" --vault-name $keyvaultname --query "value" -o tsv)

echo "Key Vault values acquired."

# Set account to secondary subsciption/tenant where app registrations exists
az account set -s $secondarySubscription
echo "Account set to Secondary Subscription"
# Get the object Id of the service principal for the service client app registration
serviceClientObjectId=$(az ad sp show  --id $serviceClientId --query objectId -o tsv)
dashboardUserOid=$(az ad user show --id $dashboardUserUpn --query objectId --out tsv)
echo "ObjectIds acquired"

accessPolicies="[{'objectId':'$currentUserObjectId'},{'objectId':'$serviceClientObjectId'},{'objectId':'$dashboardUserOid'}]"
echo "Access Policies defined"
# Set account to primary subscription where resources will be created
az account set -s $primarySubscription
echo "Account set to Primary Subscription"

echo
echo
echo "resourceGroupName  = $resourceGroupName "
echo "sandboxTemplate = $sandboxTemplate"
echo "environmentName = $environmentName"
echo "fhirApiLocation = $fhirApiLocation"
echo "fhirServerTemplateUrl = $fhirServerTemplateUrl"
echo "fhirVersion = $fhirVersion"
echo "sqlAdminPassword = $sqlAdminPassword"
echo "aadAuthority = $aadAuthority"
echo "confidentialClientId = $confidentialClientId"
echo "confidentialClientSecret = $confidentialClientSecret"
echo "serviceClientId = $serviceClientId"
echo "serviceClientSecret = $serviceClientSecret"
echo "publicClientId = $publicClientId"
echo "dashboardJSTemplate = $dashboardJSTemplate"
echo "importerTemplate = $importerTemplate"
echo "sourceRepository = $sourceRepository"
echo "sourceRevision = $sourceRevision"
echo "deploySource = $deploySource"
echo "usePaaS = $usePaaS"
echo "accessPolicies = $accessPolicies"
echo "enableExport = $enableExport"
echo
echo "currentUserObjectId = $currentUserObjectId"
echo "serviceClientObjectId = $serviceClientObjectId"
echo "dashboardUserOid = $dashboardUserOid"
echo "Execute deployment"

az deployment group create \
    --name $resourceGroupName \
    --resource-group $resourceGroupName \
    --template-uri $sandboxTemplate \
    --parameters environmentName=$environmentName \
        fhirApiLocation=$fhirApiLocation \
        fhirServerTemplateUrl=$fhirServerTemplateUrl \
        fhirVersion=$fhirVersion \
        sqlAdminPassword=$sqlAdminPassword \
        aadAuthority=$aadAuthority \
        aadDashboardClientId=$confidentialClientId \
        aadDashboardClientSecret=$confidentialClientSecret \
        aadServiceClientId=$serviceClientId \
        aadServiceClientSecret=$serviceClientSecret \
        smartAppClientId=$publicClientId \
        fhirDashboardJSTemplateUrl=$dashboardJSTemplate \
        fhirImporterTemplateUrl=$importerTemplate \
        fhirDashboardRepositoryUrl=$sourceRepository \
        fhirDashboardRepositoryBranch=$sourceRevision \
        deployDashboardSourceCode=$deploySoure \
        usePaaS=$usePaaS \
        accessPolicies=$accessPolicies \
        enableExport=$enableExport

echo "Deployment complete"