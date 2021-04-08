# Set variables
echo "Set variables"
environmentName="rjmtesthack"
resourceGroupName=${environmentName}
#templateFile="../Templates/azuredeploy-sandbox.json"
templateFile="https://raw.githubusercontent.com/microsoft/fhir-server-samples/master/deploy/templates/azuredeploy-sandbox.json"
fhirApiLocation="eastus"
fhirServerTemplateUrl="https://raw.githubusercontent.com/Microsoft/fhir-server/master/samples/templates/default-azuredeploy.json"
fhirVersion="R4"
sqlAdminPassword="Password@001"
aadAuthority="https://login.microsoftonline.com/robmckenna.net"
confidentialClientId="fdebc220-c88c-49f9-82ce-83fa001190eb"
confidentialClientSecret="xnsN7mP0rhz9uH_4jRk~zzVFc_rw._wU1y"
serviceClientId="f09dc0d1-4d07-479a-9c4d-f80dfbef3855"
serviceClientSecret="fn~OxBwSI90~n~.ji4_do1Q4Kq4Y6A-wEr"
publicClientId="f7366fd9-6597-4f53-997e-9d00ffe98051"

#sourceRepository = "https://github.com/Microsoft/fhir-server-samples"
sourceRepository="https://raw.githubusercontent.com/Microsoft/fhir-server-samples"
#githubRawBaseUrl = $sourceRepository.Replace("github.com","raw.githubusercontent.com").TrimEnd('/')
githubRawBaseUrl=$sourceRepository
sourceRevision="master"

sandboxTemplate="${githubRawBaseUrl}/${sourceRevision}/deploy/templates/azuredeploy-sandbox.json"
dashboardJSTemplate="${githubRawBaseUrl}/${sourceRevision}/deploy/templates/azuredeploy-fhirdashboard-js.json"
importerTemplate="${githubRawBaseUrl}/${sourceRevision}/deploy/templates/azuredeploy-importer.json"

deploySource=true
usePaaS=true

currentUserObjectId=4000afc8-2724-4c69-913f-ea6a172ddb7b
serviceClientObjectId=5a391036-37a3-428b-8eb5-61495acf1bd6
dashboardUserOid=adec7ed6-188b-4d45-9cbd-6c708db2ee33
echo "currentUserObjectId = $currentUserObjectId"
echo "serviceClientObjectId = $serviceClientObjectId"
echo "dashboardUserOid = $dashboardUserOid"

accessPolicies="[{'objectId':'$currentUserObjectId'},{'objectId':'$serviceClientObjectId'},{'objectId':'$dashboardUserOid'}]"

enableExport=false
echo "Variables set"

echo
echo
echo "templateFile = $templateFile"
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
echo
echo "Execute deployment"

#az deployment group validate --resource-group $resourceGroupName --template-uri $sandboxTemplate --parameters environmentName=$environmentName fhirApiLocation=$fhirApiLocation fhirServerTemplateUrl=$fhirServerTemplateUrl fhirVersion=$fhirVersion sqlAdminPassword=$sqlAdminPassword aadAuthority=$aadAuthority aadDashboardClientId=$confidentialClientId aadDashboardClientSecret=$confidentialClientSecret aadServiceClientId=$serviceClientId aadServiceClientSecret=$serviceClientSecret smartAppClientId=$publicClientId fhirDashboardJSTemplateUrl=$dashboardJSTemplate fhirImporterTemplateUrl=$importerTemplate fhirDashboardRepositoryUrl=$sourceRepository fhirDashboardRepositoryBranch=$sourceRevision deployDashboardSourceCode=$deploySoure usePaaS=$usePaaS accessPolicies=$accessPolicies enableExport=$enableExport\

#az deployment group validate --resource-group $resourceGroupName --template-uri $sandboxTemplate --parameters environmentName=$environmentName fhirApiLocation=$fhirApiLocation fhirServerTemplateUrl=$fhirServerTemplateUrl fhirVersion=$fhirVersion sqlAdminPassword=$sqlAdminPassword aadAuthority=$aadAuthority aadDashboardClientId=$confidentialClientId aadDashboardClientSecret=$confidentialClientSecret aadServiceClientId=$serviceClientId aadServiceClientSecret=$serviceClientSecret smartAppClientId=$publicClientId fhirDashboardJSTemplateUrl=$dashboardJSTemplate fhirImporterTemplateUrl=$importerTemplate fhirDashboardRepositoryUrl=$sourceRepository fhirDashboardRepositoryBranch=$sourceRevision deployDashboardSourceCode=$deploySoure usePaaS=$usePaaS #accessPolicies=$accessPolicies enableExport=$enableExport

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
        accessPolicies=$accessPolicies
        enableExport=$enableExport

echo "Deployment complete"