# Challenge03 - Export and Anonymize FHIR data

Check out the [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

## Scenario
You’ve got the core functionality of your new FHIR-based “hub” all set up! Congratulations!!

Moving data between systems is great, but you’ve yet to provide real BUSINESS value. That changes now as a business unit has come to you with a need to utilize your aggregated data to analyze several COVID-related data points in the hopes of identifying potential outbreaks early.

At this point, the team has an existing system set up for their data experiments so they just need a snapshot export of your FHIR-based data. As a health care provider we need to take special care to annonomize all data- afterall we don't want to accidentally create a HIPPA violation.    The business unit feels confident they can accomplish quite a bit with anonymized data (and that makes the privacy team happy).

First, you will need to bulk export the data from Azure API for FHIR into Azure Blob Storage. You’ll validate that this is working by checking for the files loaded into the Azure Blob Storage using the Azure Portal. Then you'll download and use the FHIR Data tools to manually anonomize them.  Finally you'll automate this process by setting up an Azure Data Factory pipeline to deidentify and store that data into Azure Data Lake. You’ll validate that this is working through the Azure portal.

## Reference Architecture
<center><img src="../images/challenge03-architecture.png" width="450"></center>


## To complete this challenge successfully, you will perform the following tasks.

* **Export FHIR data** using postman
* **Anonymize FHIR data manually**. You will use the FHIR data tools and manually deidentify data.
* **Anonymize FHIR data automatically**. You will setup an Azure Data Factory to deidentify data to a data lake.
* **Validate data load**. You will validate the data using the Azure Portal.

## Before you start

Make sure you have completed the pre-work covered in the previous challenge: [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

## Getting Started

## Task #1: Bulk Export
We know how to view data, but sometimes we'll need to export it as well.  HL7 defines an easy method for [bulk data export](https://hl7.org/Fhir/uv/bulkdata/export/index.html). Let's try it out.
 
* Open up Postman and get a token
* Check that you get results when you GET /Patient?_count=3
* Create a request to /Patient/$export You need to add two headers:
Accept|application/fhir+json
Prefer|respond-async
* The response will be blank- don't refresh it, look at the headers.  See the response header labeled "X-Request-ID"
* In the Azure Portal go to your FHIR API resource group and look for a stroage account lableeled <your instance>export
* In the storage account click on containers- you'll see a container with the request ID from above
* Click into that container and you'll see a single file- it has your data in it
* Download it and open it
* OH NO - it has First Name, Given Name, address, all kinds of PII!  We can't let this stand

## Task #2: Anonymization
We know we need to de-identify the data.  We could do this manually- but as you'd suspect there is a set of tools to do this for us.
Check out [FHIR Tools for Anonymization](https://github.com/microsoft/FHIR-Tools-for-Anonymization).  This is a Microsoft provided open-source set of tools to automate data deidentification.  Let's try it out.
* Clone the repo `` https://github.com/microsoft/FHIR-Tools-for-Anonymization#anonymize-fhir-data-using-azure-data-factory``
* in the cloned directory make a new bin directory ``mkdir bin``
* buidl the project using ``dotnet build Fhir.Anonymizer.sln  -o bin/``
* Now if you look in bin you'll see several executables

The anonymization engine uses a configuration file specifying different parameters as well as de-identification methods for different data-elements and datatypes.
The repo contains a sample configuration file, which is based on the HIPAA Safe Harbor method. You can modify the configuration file as needed based on the information provided below.
Let's run in
* let's make a few data directories for data INto the tool and data OUT of the tool
* now let's run the tool: ``./Microsoft.Health.Fhir.Anonymizer.R4.CommandLineTool.exe -i ../data/in -o ../data/out -c Configurations/common-config.json -b``
-i is the input folder
-o is the output folder
-c is the config file used for deidentifcation
-b indicates that the input files are bulk (.ndjson files) 
* Now if you look at the output folder you'll see the private data has been redacted!
* Try running the command again with other config files
So this is all great, but there's no way we're going to manually download PHI on to our machines just so we can redact.  Next let's automate thsi process!

## Task #3: Anonymize FHIR data automatically.
Ok so let's setup an Azure Data Factory to automate this process
Create Data Factory pipeline

*  go to the data tool's root folder and then src\Microsoft.Health.Fhir.Anonymizer.<version>.AzureDataFactoryPipeline. Locate AzureDataFactorySettings.json in the project and replace the values as described below.

    [!NOTE] dataFactoryName can contain only lowercase characters or numbers, and must be 3-19 characters in length.
```
{
  "dataFactoryName": "<Custom Data Factory Name>",
  "resourceLocation": "<Region for Data Factory>",
  "sourceStorageAccountName": "<Storage Account Name for source files>",
  "sourceStorageAccountKey": "<Storage Account Key for source files>",
  "destinationStorageAccountName": "<Storage Account Name for destination files>",
  "destinationStorageAccountKey": "<Storage Account Key for destination files>",
  "sourceStorageContainerName": "<Storage Container Name for source files>",
  "sourceContainerFolderPath": "<Optional: Directory for source resource file path>",
  "destinationStorageContainerName": "<Storage Container Name for destination files>",
  "destinationContainerFolderPath": "<Optional: Directory for destination resource file path>",
  "activityContainerName": "<Container name for anonymizer tool binraries>"
}
```
Define the following variables in PowerShell. These are used for creating and configuring the execution batch account.
```
> $SubscriptionId = "SubscriptionId"
> $BatchAccountName = "BatchAccountName. New batch account would be created if account name is null or empty."
> $BatchAccountPoolName = "BatchAccountPoolName"
> $BatchComputeNodeSize = "Node size for batch node. Default value is 'Standard_d1'"
> $ResourceGroupName = "Resource group name for Data Factory. Default value is $dataFactoryName + 'resourcegroup'"
```
    Run powershell scripts to create data factory pipeline
```
> .\DeployAzureDataFactoryPipeline.ps1 -SubscriptionId $SubscriptionId -BatchAccountName $BatchAccountName -BatchAccountPoolName $BatchAccountPoolName -BatchComputeNodeSize $BatchComputeNodeSize -ResourceGroupName $ResourceGroupName
```
## Validate data load
* To check your data simply download the file and verify the data is deidentifiied!

## Congratulations! You have successfully completed Challenge03!

## Help, I'm Stuck!
* Below are some common setup issues that you might run into with possible resolution. If your error/issue is not here and you need assistance, please let your coach know.

***

***

[Go to Challenge04 - IoT Connector for FHIR: Ingest and Persist device data from IoT Central](../Challenge04-IoTFHIRConnector/ReadMe.md)

## References
* [HIPPA Safe Harbor Method](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)
* [HL7 bulk export](https://hl7.org/Fhir/uv/bulkdata/export/index.html)
* [FHIR Tools for Anonymization](https://github.com/microsoft/FHIR-Tools-for-Anonymization)