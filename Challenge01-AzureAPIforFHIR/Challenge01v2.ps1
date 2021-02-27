##########################################################
####                   Challenge #1                   ####
##########################################################

## THIS SCRIPT IS STILL UNDER DEVELOPMENT. DO NOT RUN IT, IT WILL NOT WORK.

Write-Host "This script is still under development, it is likely unstable and will probably break things. Exit now, or press any key to continue." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


### Set Global Variables

$SubscriptionId = Read-Host -Prompt "Input the primary subscription ID"
$TenantId = Read-Host -Prompt "Input the primary tenant ID"
$secondTenant = Read-Host -Prompt "Input the secondary tenant ID"
$myenv = Read-Host -Prompt "Input a name for your environment, it must be 12 characters or less"
## $myenv must be 12 characters or less.

$rg2 = $myenv + "-sof"
#Do not edit this.
#Still needed?

##########################################################
### Login to Azure AD Tenants
##########################################################

<# Login to Primary Tenant and Sub
Write-host "Login to the Primary Tenant and Subscription (popup login prompt)." -ForegroundColor Yellow
Login-AzAccount
Set-AzContext -TenantId $TenantId -SubscriptionId $SubscriptionId
#> 
az login --tenant $TenantId
az account set --subscription $SubscriptionId

<#
## Login to secondary Tenant
Write-host "Login to the Secondary Tenant (popup login prompt)." -ForegroundColor Yellow
Connect-AzureAd -TenantDomain $secondTenant
#> 

az login --tenant $secondTenant


##########################################################
### Task #1
##########################################################

<# FHIR Server Samples
wget https://github.com/microsoft/OpenHack-FHIR/blob/main/Scripts/fhir-server-samples.zip?raw=true -OutFile fhir-server-samples.zip
Expand-Archive -LiteralPath fhir-server-samples.zip -DestinationPath .
Set-Location fhir-server-samples/deploy/scripts
## Note, I'ved tried calling the environment setup script by full path to get rid of these change directory commands but it throws a ton of errors because the script calls other scripts that it assumes are in the same directory.

## Deploy Environment 
Write-host "Deploying your environment, this could take 15-20 minutes..." -ForegroundColor Green
.\Create-FhirServerSamplesEnvironment.ps1 -EnvironmentName $myenv -EnvironmentLocation eastus -UsePaaS $true -EnableExport $true
#>