# Challenge03 - Export and Anonymize FHIR data

Check out the [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

## Scenario
You’ve got the core functionality of your new FHIR-based “hub” all set up! Congratulations!!

Moving data between systems is great, but you’ve yet to provide real BUSINESS value. That changes now as a business unit has come to you with a need to utilize your aggregated data to analyze several COVID-related data points in the hopes of identifying potential outbreaks early.

At this point, the team has an existing system set up for their data experiments so they just need a snapshot export of your FHIR-based data. There are some external consultants that will be assisting with the experiments so privacy is a concern. The business unit feels confident they can accomplish quite a bit with anonymized data (and that makes the privacy team happy).

First, you will need to bulk export the data from Azure API for FHIR into Azure Blob Storage. You’ll validate if this is working by checking for the files loaded into the Azure Blob Storage using Storage Explorer. Then, you will use Data Factory and Azure Batch to deidentify and store that data into Azure Data Lake. You’ll validate if this is working by learning some new query capabilities.

## Reference Architecture
<center><img src="../images/challenge03-architecture.png" width="450"></center>


## To complete this challenge successfully, you will perform the following tasks.

* **Export FHIR data** using ...
* **Anonymize FHIR data**. You will .
* **Validate data load**. You will validate the data using Postman.

## Before you start

Make sure you have completed the pre-work covered in the previous challenge: [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

## Getting Started

## Task #1: Bulk Export
This section shows 
*

## Task #2: Anonymization
This section shows 
*

## Task #3: Validate data using Postman
* 

## Congratulations! You have successfully completed Challenge03!

## Help, I'm Stuck!
* Below are some common setup issues that you might run into with possible resolution. If your error/issue is not here and you need assistance, please let your coach know.

***

***

[Go to Challenge04 - IoT Connector for FHIR: Ingest and Persist device data from IoT Central](../Challenge04-IoTFHIRConnector/ReadMe.md)
