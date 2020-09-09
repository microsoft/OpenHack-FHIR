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
   * Add value for fhirserver-url. This is Azure API for FHIR Server URL, typically https://{name}azurehealthcareapis.com
   * Add value for fhirserver-clientid. This is Confidential Client ID. You can get this from Secret in Key Vault deployed in [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md).
   * Add value for fhirserver-clientSecret. This is Confidential Client Secret. You can get this from Secret in Key Vault deployed in [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md).
   * Add value for fhirauth-tenantid. This is SecondaryAD Tenant ID. You can get this from [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md).
   * Add value for IntegrationStorageAccount. This is created in [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md) typically {ENVIRONMENTNAME}export.
   * Save & close the parameters file.

* Replace Template file
   * Replace ./Assets/**arm_template_part2.json** file with [this](/arm_template_part2.json)

* Optional Setup:
The FHIR Export with Anonymization uses the default settings in the Anonymization toolset. If you would like other settings please follow theses steps prior to deployment:
   * Find and copy the zip file ./Assets/AdfApplication.zip to a new temporary location
   * Unzip the file
   * In the unzipped folder locate the file called configuration-sample.json
   * Open the file and make your setting adjustments. Configuration file settings can be found [here]( https://github.com/microsoft/FHIR-Tools-for-Anonymization#configuration-file-format)
   * Save your configuration changes.
   * Zip the folder backup. Make sure the zipped folder is the same name 'AdfApplication.zip'.
   * Replace the zip file in the Assets folder with the new zip file.

## Task #2: Deploy to Bulk Export and Anonymize FHIR data

* Open **PowerShell** and navigate to this directiory
   ```powershell
   cd health-architectures\FHIR\FHIRExportwithAnonymization
    ```

* **Connect to Secondary AD** and authenticate
    ```powershell
    Connect-AzureAd -TenantDomain **{yourname}fhirad.onmicrosoft.com**
    ```

* **Deploy** the pipeline and enter {ENVIRONMENTNAME} when prompted. EnvironmentLocation is eastus by default.
   ```powershell
   ./deployFHIRExportwithAnonymization.ps1 
   ```

   This deployment process may take 5 minutes or more to complete.

* The following resources in resource group {ENVIRONMENTNAME} will be created:
   <center><img src="../images/challenge02-fhirhackan-resources.png" width="550"></center>

   * Azure Data Factory {ENVIRONMENTNAME}adf
   * Batch Account {ENVIRONMENTNAME}batch
   * Key Vault {ENVIRONMENTNAME}kv
   * Logic App {ENVIRONMENTNAME}la
   * Storage Account {ENVIRONMENTNAME}stg
   * Storage Account {ENVIRONMENTNAME}dlg2

* Configure export setting and set up the storage account
   * Navigate to Azure API for FHIR service and select Identity blade. Make sure the status to On will enable managed identity in Azure API for FHIR Service.
   * Navigate to Access Control (IAM) blade in Storage Account {ENVIRONMENTNAME}stg and select Add Role Assignments. Add role Storage Blob Data Contributor to Azure API for FHIR service created in [Challenge01](./Challenge01-AzureAPIforFHIR/ReadMe.md).
   * Navigate to Integration blade in Azure API for FHIR service in Azure portal and select the storage account {ENVIRONMENTNAME}stg.

   Time to export data and do some research!

## Task #3: Validate data load
* Go to Resource Group {ENVIRONMENTNAME} created.
* Click on the Logic App and click Run Trigger. You can click on the Running status in Runs History below in the same screen. The time taken to complete depends on the volume of data you have in Azure API for FHIR.
* When completed successfully, view the below
   * Compare the containers with suffix output in {ENVIRONMENTNAME}stg and {ENVIRONMENTNAME}dlg2 Storage Accounts. {ENVIRONMENTNAME}stg will have pre-anonymized ndjson files for every resource. {ENVIRONMENTNAME}dlg2 will have anonymized ndjson files for every resource.

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