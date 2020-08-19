# Challenge 1 - Azure API for FHIR

## Scenario
Your team has now learned a little about the FHIR standard. Our first challenge focuses on you as a software developer on the data interoperability team. **Any Healthcare’s** strategic direction is to build new solutions on public cloud resources wherever possible.

The first task has landed on you: In order to learn a bit about the capabilities of Azure’s API for FHIR API, you will set up a development instance. This development instance is designed to highlight the key features, by building a demo-like environment. Once you are done with the setup you will verify the service is functioning by loading some synthetic data. The data is generated using Synthea which allows you to mimic EMR/EHR data. You will then run some basic queries to ensure the core functionality is working. 

## To complete this challenge successfully, you will perform the following tasks.

* Provision Azure API for FHIR API demo environment. Given the limited time, we'll provide a set of scripts to accomplish this. For step by step instructions, check the appendix.
* Load Synthetic data. You can generate the data using Synthea or use a staged dataset that we'll provide.
* Validate data load. You can use the dashboard application to validate the data or the provided APIs by using Postman.

## Before you start:

Make sure you have completed the pre-work covered in the previous challenge: [Challenge 0 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge0-Prerequistes/ReadMe.md).

We will use PowerShell to deploy the Azure API for FHIR API demo environment. Using either the Windows PowerShell console or the Windows PowerShell ISE, run the following commands.

```powershell
  Install-Module Az
  Install-Module AzureAd
```  

To verify, log into your Azure account using the following command and follow instructions to authenticate:
```cmd
  Login-AzAccount
```

If everything worked, your output should be similiar to the one below:
<center><img src="../images/powershell-login-azccount.png" width="850"></center>

You will need access to an Azure tenant that allows your to create and register applications. Most corporate tenants will typically have this disabled. Fortunately it's relatively easy to create new tenants/directories, check the appendix for additional information.

Once you have the right tenant, get the TenantID, your will need it in subsequent steps.

## Task #1: Provision Azure API for FHIR demo environment.

* ### Get the code
```powershell
  git clone https://github.com/Microsoft/fhir-server-samples
``` 
* ### Connect to your tenant's Azure AD
```powershell
  Connect-AzureAd -TenantDomain <Your TenantID>
``` 
* ### Connect to your tenant's Azure AD
```powershell
  cd fhir-server-samples/deploy/scripts
  .\Create-FhirServerSamplesEnvironment.ps1 -EnvironmentName <ENVIRONMENTNAME> -UsePaaS $true
```
The ENVIRONMENTNAME is a value that you select and will be used as the prefix for the Azure resources that the script deploys, therefore it should be globally unique.

If all goes well, the script will kickoff and will take about 10-15 minutes to complete. If the script throws an error, please check the **Help I'm Stuck!** section at the bottom of this page.

## Task #2: Generate & Load synthetic data.

* ## Option 1: Synthea data
* This section shows how to setup and generate health records with Synthea.
Synthea is an open-source synthetic patient and associated health records generator that simulates the medical history of synthetic patients. Synthea generates HL7 FHIR records using the HAPI FHIR library to generate a FHIR Bundle for these FHIR Resources. More on Synthea [here](https://github.com/synthetichealth/synthea).

* By default, Synthea contains publicly available demographic data obtained from the US Census Bureau. The data was post-processed to create population input data for every place (town and city) in the United States. This post-processed data can be used with Synthea to generate representative populations. (County + SubCounty + Education + Income). See https://github.com/synthetichealth/synthea/wiki/Default-Demographic-Data for details.

* ## Option 2: Staged data


## Task #3: Validate data load
* 


## Help, I'm Stuck!
* 
[Go to Challenge 2 - HL7 Ingest and Convert: Ingest HL7v2 messages and convert to FHIR format](../Challenge2-HL7IngestandConvert/ReadMe.md)
