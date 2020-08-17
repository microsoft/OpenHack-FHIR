# Challenge 1 - Azure API for FHIR

#### This chapter shows how to generate synthetic data using Synthea, Ingest using Azure Function and Store data into Azure API for FHIR.

Check out the [Challenge 0 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](./Challenge0-Prerequistes/ReadMe.md).

## Scenario
Coming Soon...

###Generate Data using Synthea
This section shows how to setup and generate health records with Synthea.
Synthea is an open-source synthetic patient and associated health records generator that simulates the medical history of synthetic patients. Synthea generates HL7 FHIR records using the HAPI FHIR library to generate a FHIR Bundle for these FHIR Resources. More on Synthea [here](https://github.com/synthetichealth/synthea).

By default, Synthea contains publicly available demographic data obtained from the US Census Bureau. The data was post-processed to create population input data for every place (town and city) in the United States. This post-processed data can be used with Synthea to generate representative populations. (County + SubCounty + Education + Income). See https://github.com/synthetichealth/synthea/wiki/Default-Demographic-Data for details.

## Setup Synthea
*

###Setup and Configure Azure API for FHIR
[Azure API for FHIR](https://docs.microsoft.com/en-us/azure/healthcare-apis/) is a managed, standards-based, compliant API for clinical health data that enables solutions for actionable analytics and machine learning.
*

###Ingest Data using Azure Function and Store in Azure API for FHIR
*

###Test data loaded in Azure API for FHIR using Postman
* 


***

[Go to Challenge 2 - HL7 Ingest and Convert: Ingest HL7v2 messages and convert to FHIR format](./Challenge2-HL7IngestandConvert/ReadMe.md)
