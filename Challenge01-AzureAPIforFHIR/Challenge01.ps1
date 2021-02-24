##########################################################
####                   Challenge #1                   ####
##########################################################


$SubscriptionId = Read-Host -Prompt "Input the primary subscription ID"
$TenantId = Read-Host -Prompt "Input the primary tenant ID"
$secondTenant = Read-Host -Prompt "Input the secondary tenant ID"
$myenv = Read-Host -Prompt "Input a name for your environment, it must be 12 characters or less"
## $myenv must be 12 characters or less.

$workingFolder = Read-Host -Prompt "Input your working folder, eg. C:\fhirautomation"

$rg2 = $myenv + "-sof"
#Do not edit this.

$showAppsAndUsersInSecondTenant ="Connect-AzureAd -TenantDomain $secondTenant; Get-AzureADApplication -All:$true; Get-AzureADUser -searchstring $myenv"
$generateDeleteEverything ="Connect-AzureAd -TenantDomain $secondTenant; Remove-AzResourceGroup -Name $myenv -Force; Remove-AzResourceGroup -Name $rg2 -Force; Remove-AzureADApplication -All:$true; Remove-AzureADUser -searchstring $myenv"
## The above commands are assuming you're using an empty tenant for the app registrations and users, DO NOT USE THIS AS-IS IN ANY OTHER ENVIRONMENT.

Write-Host "After this script is complete, you can run lines 6-18 to clean out the environment. Press any key to acknowledge this information." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "Lastly, this script will prompt you for authentication multiple times including once where you will need to visit microsoft.com/devicelogin, this will be addressed in future versions. Press any key to acknowledge this information." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

##########################################################
##########################################################

## Login to Primary Tenant and Sub
Write-host "Login to the Primary Tenant and Subscription (popup login prompt)." -ForegroundColor Yellow
Login-AzAccount
Set-AzContext -TenantId $TenantId -SubscriptionId $SubscriptionId

## Login to secondary Tenant
Write-host "Login to the Secondary Tenant (popup login prompt)." -ForegroundColor Yellow
Connect-AzureAd -TenantDomain $secondTenant

##########################################################
####                   Task #1                        ####
##########################################################

Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass

## Download FHIR Deployment Scripts
Write-host "Downloading and extracting the FHIR deployment scripts..."
wget https://github.com/microsoft/OpenHack-FHIR/blob/main/Scripts/fhir-server-samples.zip?raw=true -OutFile fhir-server-samples.zip
Expand-Archive -LiteralPath fhir-server-samples.zip -DestinationPath .
Set-Location fhir-server-samples/deploy/scripts
## Note, I'ved tried calling the environment setup script by full path to get rid of these change directory commands but it throws a ton of errors because the script calls other scripts that it assumes are in the same directory.

## Deploy Environment 
Write-host "Deploying your environment, this could take 15-20 minutes..." -ForegroundColor Green
.\Create-FhirServerSamplesEnvironment.ps1 -EnvironmentName $myenv -EnvironmentLocation eastus -UsePaaS $true -EnableExport $true

### Need to Add deployment validation here

##########################################################
####                   Task #2                        ####
##########################################################

## These stay so you don't need to update them.
$storageAccountName = $myenv + "impsa"
$storageContainerName = "fhirimport"

Set-Location $workingFolder

## Download Sample FHIR Data
Write-host "Downloading and extracting FHIR sample data..."
Wget https://github.com/microsoft/OpenHack-FHIR/blob/main/Synthea/fhir.zip?raw=true -OutFile fhir.zip
Expand-Archive -LiteralPath fhir.zip -DestinationPath .
wget https://aka.ms/downloadazcopy-v10-windows -outfile azcopy.zip

## Download AzCopy
Write-host "Downloading AzCopy..."
Expand-Archive -LiteralPath azcopy.zip -DestinationPath .
gci -recurse azcopy.exe | cp -Destination .

## Upload Sample FHIR Data
Write-host "Uploading sample FHIR data to be processed..."
Write-Host "Look at the output below, you need to authenticate on behalf of AzCopy." -ForegroundColor Red -BackgroundColor Yellow

.\azcopy.exe login
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $myenv -AccountName $storageAccountName).Value[0]
$destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$containerSASURI = New-AzStorageContainerSASToken -Context $destinationContext -ExpiryTime(get-date).AddSeconds(3600) -FullUri -Name $storageContainerName -Permission rw
.\azcopy.exe copy fhir $containerSASURI --recursive

## Validate data in container
$importStorageContext = (Get-AzStorageAccount -ResourceGroupName $myenv -AccountName $storageAccountName).Context
write-host "The number of blobs left in the container is:" (Get-AzStorageBlob -Container $storageContainerName -Context $importStorageContext).count
write-host "Now that this script is complete for Challenge01, you can run lines 6-18 in this script to clean out the environment." -ForegroundColor Green
write-host "If you want to throw caution to the wind, you could also just copy/paste the generated code below." -ForegroundColor Yellow
write-host "$generateDeleteEverything" -ForegroundColor Red
## Add Loop here to check for count of blobs in container, continue when empty.

Set-Location $workingFolder
