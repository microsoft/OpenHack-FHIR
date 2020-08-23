# Challenge02 - HL7 Ingest and Convert

#### This chapter shows how to .

Check out the [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

## Scenario
With the basic EHR synthetic data loaded into Azure API for FHIRup and running on synthetic data, you need to switch to ingesting real data from an existing system into Azure API for FHIRand making it available to another existing system. Most (but of course not all) of your existing healthcare applications use some version of HL7, and you have to ingest those HL7 messages and convert into FHIR format. By establishing FHIR as a hub of sorts, you’ll be able to aggregate data from these various systems.

First, you need to ingest HL7 data from existing another system using secure transfer and loaed into simulated by an Azure Blob storage. Then use FHIR Converter to convert into valid FHIR format to load into Azure API for FHIR. You’ll validate this is working by learning some new query capabilities.
Next, you need to configure FHIR to emit HL7v2 messages when data is created, updated, and deleted.

Task: Deploy the FHIR Proxy

Task: Configure Proxy for events

Task: Transmit sample HL7v2 messages

Task: Verify events are queued

Exit criteria: Coach verifies event is queueddata is loaed into Azure API for FHIR

## Reference Architecture
<center><img src="../images/challenge02-architecture.png" width="550"></center>

## HL7 Ingest
This section shows 
*

## HL7 Conversion to FHIR
This section shows 
*

## Test data loaded in Azure API for FHIR using Postman
* 


***

[Go to Challenge03 - Export and Anonymize: Bulk export data from Azure API for FHIR and deidentify the data](../Challenge03-ExportandAnonymizeData/ReadMe.md)
