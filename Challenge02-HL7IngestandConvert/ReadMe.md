# Challenge02 - HL7 Ingest and Convert

## Scenario
With Azure API for FHIR up and running with basic EHR synthetic data, you will focus on this challenge of ingesting legacy data that's in a different format into Azure API for FHIR. Most (but of course not all) of your existing healthcare applications use some version of HL7, and you have to ingest those HL7 messages and convert them into FHIR format. By establishing FHIR as a hub of sorts, you’ll be able to aggregate data from these various systems and enable interoperability.

First, you need to ingest HL7 legacy data using secure transfer, place into an Azure Blob storage and create comsumable events on service bus for processing. You’ll validate if this is working by checking for the files loaded into the Azure Blob Storage using Storage Explorer.
Then you will use Logic Apps connector and FHIR Converter to convert those messages into valid FHIR format to load into Azure API for FHIR. You’ll validate if this is working by learning some new query capabilities.

## Reference Architecture
<center><img src="../images/challenge02-architecture.png" width="550"></center>

## To complete this challenge successfully, you will perform the following tasks.

* **Ingest HL7v2 sample message** using MLLP secure transfer into Azure Blob Storage.
* **Convert HL7v2 message into FHIR format**. You will create a workflow that performs orderly conversion.
* **Validate data load**. You will validate the data using Postman.

## Before you start

* Make sure you have completed the pre-work covered in the previous challenge: [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

* Make sure you have completed Challenge01: [Challenge01 - Azure API for FHIR: Generate, Ingest and Store synthetic data into Azure API for FHIR](./Challenge01-AzureAPIforFHIR/ReadMe.md).

## Getting Started

The [FHIR Converter](https://github.com/microsoft/FHIR-Converter) is an open source project that enables healthcare organizations to convert legacy data (currently HL7 v2 messages) into FHIR bundles. Converting legacy data to FHIR expands the use cases for health data and enables interoperability.

## Task #1: HL7 Ingest
HL7 ingest platform is to consume HL7 Messages via MLLP and securely Transfer them to Azure via HL7overHTTPS and place in blob storage and produce a consumable event on a high speed ordered service bus for processing.  

In this task, you will:
* Consume MLLP HL7 Messages
* Securely transfer them to Azure via [HL7overHTTPS](https://hapifhir.github.io/hapi-hl7v2/hapi-hl7overhttp/specification.html)
* Place in blob storage for audit/errors
* Produce a consumable event on a high speed ordered service bus for processing

Let's get started:
* Downloaded this [repo](https://github.com/microsoft/health-architectures).
* [If you are running Windows 10 make sure you have enabled Windows Linux Subsystem](https://code.visualstudio.com/remote-tutorials/wsl/enable-wsl) and [Installed a Linux Distribution](https://code.visualstudio.com/remote-tutorials/wsl/install-linux)
* [Install Azure CLI 2.0 on Linux based System or Windows Linux Subsystem](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest) 
* Open a bash shell into the Azure CLI 2.0 environment
* Switch to the HL7Conversion subdirectory of this repo
* Run the deployhl7ingest.bash script and follow the prompts
* Send in an hl7 message via HL7 over HTTPS:
    + Locate the sample message samplemsg.hl7 in the root directory of the repo
    + Use a text editor to see contents
    + From the linux command shell run the following command to test the hl7overhttps ingest
      ```
        curl --trace-ascii - -H "Content-Type:text/plain" --data-binary @samplemsg.hl7 <your ingest host name from above>/api/hl7ingest?code=<your ingest host key from above>
      ``` 
    + You should receive back an HL7 ACK message
    + Congratulations!!! The sample hl7 message was accepted securely stored into blob storage and queued for further ingest processing on the deployed service bus queue
9. Send in HL7 messages using the local HL7 MLLP Relay. To run a local copy of the HL7 MLLP Relay:
    + Make sure [Docker](https://www.docker.com/) is installed and running in your linux or windows environment
    + From a command prompt run the runhl7relay.bash(linux) or runhl7relay.cmd(windows) passing in the hl7ingest Function App URL (Saved from Above) and the function app access key (Saved from above) as parameters.
        ```
        runhl7relay https://<your ingest host name from above/api/hl7ingest "<function app key from above>"
       ``` 
    + You can now point any HL7 MLLP Engine to the HL7 Relay listening port (default is 8079) and it will transfer messages to the hl7ingest function app over https
    + An appropriate HL7 ACK will be sent to the engine from the relay listener


## Task #2: HL7 Conversion to FHIR
A workflow that performs orderly conversion from HL7 to FHIR via the conversion API and persists the message into a FHIR Server and publishes change events referencing FHIR resources to a high speed event hub to interested subscribers.  
In this task, you will:
* Create a logic app based workflow that performs orderly conversion from HL7 to FHIR via the [FHIR Converter](https://github.com/microsoft/FHIR-Converter), persists the message into an [Azure API for FHIR Server Instance](https://azure.microsoft.com/en-us/services/azure-api-for-fhir/) and publishes FHIR change events referencing FHIR resources to a high speed event hub to interested subscribers.
Features of the HL7toFHIR Conversion Platform:

Let's get started:
* [Deploy the HL7 Ingest Platform](#ingest)
* [Deploy an Azure API for FHIR instance](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir-paas-portal-quickstart)
* [Register a Service Client to Access the FHIR Server](https://docs.microsoft.com/en-us/azure/healthcare-apis/register-service-azure-ad-client-app). You will need the following information to configure the HL72FHIR services
   + Client/Application ID for the Service Client
   + The Client Secret for the Service Client
   + The AAD Tenant ID for the FHIR Server/Service Client
   + The Audience/Resource for the FHIR Server/Service Client typically https://azurehealthcareapis.com for Azure API for FHIR
* [Find the Object Id for the Service Client and Register it with the FHIR Server](https://docs.microsoft.com/en-us/azure/healthcare-apis/find-identity-object-ids)
* You will need the following information from the HL7 Ingest platform deployment (provided at the end of your deployment):
   + The resource group name created
   + The storage account name created
   + The service bus namespace created
   + The service bus destination queue name created
* Open a shell or command window into the Azure CLI 2.0 environment
* Switch to the Managed/HL7Conversion subdirectory of this repo
* Run the deployhl72fhir.bash script and follow the prompts
* After successful deployment your converter pipeline is now tied to your ingest platform from above.  To test simply follow the test direction for HL7 Ingest above with the sample HL7 message and you should see resources from the bundle created in the destination FHIR Server
   + You can also see execution from the HL7toFHIR Logic App Run History in the HL7toFHIR resource group.  This will also provide you with detailed steps to see the transform process:

![Sample Converter Run](samplerun.png)

## Task #3: Validate data load using Postman

* 


## Congratulations! You have successfully completed Challenge02!

## Help, I'm Stuck!
* Below are some common setup issues that you might run into with possible resolution. If your error/issue is not here and you need assistance, please let your coach know.

***

[Go to Challenge03 - Export and Anonymize: Bulk export data from Azure API for FHIR and deidentify the data](../Challenge03-ExportandAnonymizeData/ReadMe.md)
