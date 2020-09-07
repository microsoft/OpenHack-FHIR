# Challenge03 - Export and Anonymize FHIR data

## Scenario
You’ve got the core functionality of your new FHIR-based “hub” all set up! Congratulations!!

Moving data between systems is great, but you’ve yet to provide real BUSINESS value. That changes now as a business unit has come to you with a need to utilize your aggregated data to analyze several COVID-related data points in the hopes of identifying potential outbreaks early.

At this point, the team has an existing system set up for their data experiments so they just need a snapshot export of your FHIR-based data. As a health care provider we need to take special care to annonomize all data, afterall we don't want to accidentally create a HIPPA violation. The business unit feels confident they can accomplish quite a bit with anonymized data (and that makes the privacy team happy).

First, you will need to bulk export the data from Azure API for FHIR into Azure Blob Storage. You’ll validate that this is working by checking for the files loaded into the Azure Blob Storage using the Azure Portal. Then you'll download and use the FHIR Data tools to manually anonomize them.  Finally you'll automate this process by setting up an Azure Data Factory pipeline to deidentify and store that data into Azure Data Lake. You’ll validate that this is working through the Azure portal.

## Reference Architecture
<center><img src="../images/challenge03-architecture.png" width="450"></center>

* **Azure Logic App**:
   * is triggered by a timer, 1:00 AM UTC is the default
   * calls **FHIR service** with GET $export call to export data into **Blob Storage**
   * runs an Until loop in 5 minute interval checking for the Bulk Export $export to finish. The frequency is adjustable inside the **Logic App**.
   * sends the $export storage location information to **Azure Data Factory**
* **FHIR server**:
   * pushes bulk export to preset storage location. This Storage Account ({ENVIRONMENTNAME}export) was created in [Challenge01](../Challenge01-AzureAPIforFHIR/ReadMe.md).
* **Azure Data Factory**:
   * calls **Azure Batch** with the storage location information
   * **Azure Batch** performs the deidentification with the FHIR Tools for Anonymization
   * put the deidentified data in **Azure Data Lake Gen2**

## To complete this challenge successfully, you will perform the following tasks.

* **Bulk Export FHIR data**: Logic app bulk exports FHIR data into Blob Storage
* **Anonymize FHIR data**: Logic app runs Data Factory pipeline which calls Azure Batch for deidentifying the data and stores in Azure Data Lake
* **Validate data load**. You will validate the data using the Azure Portal.

## Before you start

* Make sure you have completed the pre-work covered in the previous challenge: [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

* Make sure you have completed [Challenge01 - Azure API for FHIR: Generate, Ingest and Store synthetic data into Azure API for FHIR](./Challenge01-AzureAPIforFHIR/ReadMe.md).

## Getting Started

## Task #1: Setup
* Enable Export
   If you deployed Azure API for FHIR in [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md) with EnableExport $false, then follow the instructions here for attaching the FHIR service to the storage account. <https://docs.microsoft.com/en-us/azure/healthcare-apis/configure-export-data>

* Clone this repo
   ```powershell
   git clone https://github.com/Microsoft/health-architectures
   ```

* Update Parameters file
   * Navigate to health-architectures/FHIR/FHIRExportwithAnonymization folder. 
   * Open the ./Assets/arm_template_parameters.json file in your perferred json editor. 
   * Replace FHIR URL for the Azure API for FHIR Server typically https://{name}azurehealthcareapis.com
   * Replace Client ID for the Service Client. You can get this from Secret in Key Vault deployed in [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md).
   * Replace Client Secret for the Service Client. You can get this from Secret in Key Vault deployed in [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md).
   * Replace Storage Account ({ENVIRONMENTNAME}export) to store the data when exported from FHIR server.

   ```json
   {
       "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
       "contentVersion": "1.0.0.0",
       "parameters": {
           "fhirserver-url": {
               "value": "<<FHIR SERVER URL>>",
               "metadata": {
                   "description":"https://<myfhir>.azurehealthcareapis.com  WARNING: make sure to remove the forward slash / after .com
                   If you are using the FHIR Proxy enter the fhir proxy url."
               }
           },
           "fhirserver-clientid": {
               "value": "<<FHIR SERVER CLIENT ID>>"
           },
           "fhirserver-clientSecret": {
               "value": "<<FHIR SERVER CLIENT SECRET>>"
           },
           "fhirauth-tenantid": {
               "value": "",
               "metadata": {
                   "description": "Supply only if FHIR authenication and the deployment subscription are not in the same tenant. If you are unsure leave "" or remove entire segment"
               }
           },
           "IntegrationStorageAccount":{
               "value": "",
               "metadata":{
                   "description": "If the FHIR integration has already been setup with a storage account, then add the name of the storage account here. Otherwise a new storage account will be created."
               }
           }
       }
   }
   ```

   Save & close the parameters file.

## Task #2: Deploy to Bulk Export and Anonymize FHIR data

* Open **PowerShell** and navigate to this directiory
   ```powershell
   cd health-architectures/FHIRExportQuickStart
    ```

* **Connect** to Azure
    ```powershell
    Connect-AzAccount
    ```

* **Get** subscriptions for this account
    ```powershell
    Get-AzSubscription
    ```

* **Select** the right subscription
    ```powershell
    Select-AzSubscription -SubscriptionId "<SubscriptionId>"
    ```

* Create the PowerShell variables required by the template and **Deploy** the pipeline
   ```powershell
   $EnvironmentName = "<NAME HERE>" #The name must be lowercase, begin with a letter, end with a letter or digit, and not contain hyphens.
   $EnvironmentLocation = "<LOCATION HERE>" #optional input. The default is eastus2

   ./deployFHIRExportwithAnonymization.ps1 -EnviromentName $EnvironmentName -EnvironmentLocation $EnvironmentLocation #Environment Location is optional
   ```

   This deployment process may take 5 minutes or more to complete.

## Task #3: Validate data load
* Locate the name of the storage account from the deployment. The default is the Environment Name with 'stg' appended to the end.
* To check your data simply download the file and verify the data is deidentifiied!

## Congratulations! You have successfully completed Challenge03!

## Help, I'm Stuck!
Below are some common setup issues that you might run into with possible resolution. If your error/issue is not here and you need assistance, please let your coach know.

* Common Azure Batch errors:
   * Azure Batch is not enabled in the subscription
   * Azure Batch already deployed the max number of time in a subscription

* If you would like to adjust the start time or run interval, open the Logic App in the deployed resource group. The first step called 'Recurrence' is where the timer is stored.

***

[Go to Challenge04 - IoT Connector for FHIR: Ingest and Persist device data from IoT Central](../Challenge04-IoTFHIRConnector/ReadMe.md)

## References
* [HIPPA Safe Harbor Method](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)
* [HL7 bulk export](https://hl7.org/Fhir/uv/bulkdata/export/index.html)
* [FHIR Tools for Anonymization](https://github.com/microsoft/FHIR-Tools-for-Anonymization)