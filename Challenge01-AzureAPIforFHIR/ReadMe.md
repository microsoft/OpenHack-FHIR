# Challenge01 - Azure API for FHIR

## Scenario
Your team has now learned a little about the FHIR standard. Our first challenge focuses on you as a software developer on the data interoperability team. **Any Healthcare’s** strategic direction is to build new solutions on public cloud resources wherever possible.

The first task has landed on you: In order to learn a bit about the capabilities of Azure’s API for FHIR, you will set up a development instance. This development instance is designed to highlight the key features, by building a demo-like environment. Once you are done with the setup you will verify the service is functioning by loading some synthetic data. The data is generated using Synthea which allows you to mimic EMR/EHR data. You will then use the dashboard app and run some basic queries to ensure the core functionality is working. 

## Reference Architecture
<center><img src="../images/challenge01-architecture.png" width="550"></center>

## To complete this challenge successfully, you will perform the following tasks.

* **Provision Azure API for FHIR demo environment**. Given the limited time, we'll provide a set of scripts to accomplish this. For step by step instructions, check the appendix.
* **Load Synthetic data**. You can generate the data using Synthea or use a staged dataset that we'll provide.
* **Validate data load**. You can use the dashboard application to validate the data or the provided APIs by using Postman.

## Before you start

Make sure you have completed the pre-work covered in the previous challenge: [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

* **Azure Subscription**: You will need permissions to perform CRUD operations in your Azure subscription.

* **Install prerequisite PowerShell modules**: While there are other options, we recommend PowerShell scripts to provision your Azure API for FHIR resources. You can use either Azure PowerShell or Windows PowerShell and make sure you are running it as an administrator. (Right-click the PowerShell icon and choose **Run as Administrator**)
   * Get PowerShell module version: Make sure your version is 5.1. If not, install [this](https://www.microsoft.com/en-us/download/details.aspx?id=54616) version.

   ```powershell
   $PSVersionTable.PSVersion
   ```  
   * Get Azure PowerShell module versions: If your results show Az version 4.1.0 and AzureAd version 2.0.2, then proceed to login step. If not, get the right versions.

   ```powershell
   Get-InstalledModule -Name Az -AllVersions
   Get-InstalledModule -Name AzureAd -AllVersions
   ```  

   * If these aren't the versions you have installed, uninstall and re-install PowerShell modules: Uninstall Az and AzureAd modules and install the right version needed.
   ```powershell
   Uninstall-Module -Name Az
   Uninstall-Module -Name AzureAD
   ```  

   ```powershell
   Install-Module -Name Az -RequiredVersion 4.1.0 -Force -AllowClobber -SkipPublisherCheck
   Install-Module AzureAD -RequiredVersion 2.0.2.4
   ```

* **Log into Primary AD tenant**:
   * Open a new PowerShell session. Login using your Azure account where you want to deploy resources and authenticate. This will be referred to as **Primary AD**, for clarity.
   ```powershell
   Login-AzAccount
   ```

   >   If you are seeing errors or you don't see the correct subscription in your **Primary AD**, into which you want to deploy resources, you might be running in the wrong Azure context. Run the following to Clear, Set and then verify your Azure context.
   >   ```powershell
   >   Clear-AzContext
   >   Connect-AzAccount
   >   Set-AzContext -TenantId **{YourPrimaryADTenantID}**
   >   Get-AzContext
   >   ```

* **Create Secondary AD tenant**: Azure API for FHIR needs to be deployed into an Azure Active Directory tenant that allows for Data and Resource control plane authorization. Most companies lock down Active Directory App Registrations for security purposes which will prevent you from publishing an app, registering roles, or granting permissions. To avoid this, you will create a separate "secondary" Active Directory domain. (A basic Azure Active Directory domain is a free service.)
   * Use a browser to navigate to the Azure Portal, navigate to Azure Active Directory. Click "Create a tenant". Enter an Organization name e.g. "{yourname}fhirad". Enter an Initial domain name and click the Create button. This will be referred to as **Secondary AD** for clarity. 

   * Connect to your **Secondary AD** and authenticate. **DO NOT SKIP THIS**
   ```powershell
   Connect-AzureAd -TenantDomain **{{yourname}fhirad}.onmicrosoft.com**
   ``` 
   * Replace **{{yourname}fhirad}** with the name of the Secondary AD you created.

## Getting Started

## Task #1: Provision Azure API for FHIR demo environment.

   * You will get a security exception error if you haven't set the execution policy below. This is because the repo you will clone in the next step is a public repo, and the PowerShell script is not signed. Run the following PowerShell command to set the execution policy and type A, to run unsigned Powershell scripts.
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass
   ```
   
* **Get the repo** fhir-server-samples from Git into C or sub-folder in C drive. If you don't have Git, install it from the link in [Challenge00](../Challenge00-Prerequistes/ReadMe.md).
   ```powershell
   git clone https://github.com/Microsoft/fhir-server-samples
   ``` 
* This Git repo contains the script that will provision all of our Azure API for FHIR resources. Navigate to the scripts directory where the Git repo was downloaded. Run the **one shot deployment.** Don't forget the **.\** before Create. Make sure to leave $true for EnableExport as it will needed in Challenge03.
   ```powershell
   cd fhir-server-samples/deploy/scripts
   
  .\Create-FhirServerSamplesEnvironment.ps1 -EnvironmentName <ENVIRONMENTNAME> -EnvironmentLocation eastus -UsePaaS $true -EnableExport $true
   ```
   * The **ENVIRONMENTNAME Example:fhirhack THIS IS AN EXAMPLE, DO NOT USE THIS** is a value you type that will be used as the prefix for the Azure resources that the script deploys, therefore it should be **globally unique**, all lowercase and can't be longer than 12 characters.
   * EnvironmentLocation could specified, for this Hack leave the default as some services might not be available in the location you specify.
   * We want the PaaS option, so leave that parameter set to $true.
   * When EnableExport is set to $true, bulkexport is turned on, service principle identity is turned on, storage account for export is created, access to storage account added to FHIR API through managed service identity, service principle identity is added to storage account.
   * If all goes well, the script will kickoff and will take about 10-15 minutes to complete. If the script throws an error, please check the **Help I'm Stuck!** section at the bottom of this page.
   
* On **successful completion**, you'll have two resource groups and lots of resources created with the prefix <ENVIRONMENTNAME>. Explore these resources and try to understand the role they play in your FHIR demo environment. NOTE: Application Insights is not available in all locations and will be provisioned in East US.

   The following resources in resource group **{ENVIRONMENTNAME}** Ex:fhirhack will be created:
   <center><img src="../images/challenge01-fhirhack-resources.png" width="550"></center>

   * Azure API for FHIR ({ENVIRONMENTNAME}) is the FHIR server
   * Key Vault ({ENVIRONMENTNAME}-ts) stores all secrets for all clients (public for single page apps/javascripts that can't hold secrets, confidential for clients that hold secrets, service for service to service) needs to talk to FHIR server.
   * App Service/Dashboard App ({ENVIRONMENTNAME}dash) used to analyze data loaded.
   * App Service Plan ({ENVIRONMENTNAME}-asp) to support the App Service/Dashboard App.
   * Function App ({ENVIRONMENTNAME}imp) is the import function that listens on the import storage account where you can drop bundles that get loaded into FHIR server.
   * App Service Plan ({ENVIRONMENTNAME}imp) to support the Function App.
   * Application Insights ({ENVIRONMENTNAME}imp) to monitor the Function App.
   * Storage Account ({ENVIRONMENTNAME}export) to store the data when exported from FHIR server.
   * Storage Account ({ENVIRONMENTNAME}impsa) is the storage account where synthetic data will be uploaded for loading to FHIR server.


   The following resources in resource group **{ENVIRONMENTNAME}-sof** will be created for SMART ON FHIR applications:
   <center><img src="../images/challenge01-fhirhacksof-resources.png" width="550"></center>

   * App Service/Dashboard App ({ENVIRONMENTNAME}growth) supports {ENVIRONMENTNAME}dash App.
   * App Service Plan ({ENVIRONMENTNAME}growth-plan) to support the growth App Service/Dashboard App.
   * App Service/Dashboard App ({ENVIRONMENTNAME}meds) supports {ENVIRONMENTNAME}dash App.
   * App Service Plan ({ENVIRONMENTNAME}meds-plan) to support the meds App Service/Dashboard App.

* Go to the **Secondard AD** in Portal. Go to App Registrations. All the 3 different clients are registered here.

## Task #2: Generate & Load synthetic data.

* ### Option 1: Use Staged data
   * Download the generated [data](../Synthea/fhir.zip)
      * NOTE: there are 109 files in fhir.zip, you can choose to upload a small subset (10 files) to complete the upload faster, and still able to learn all functionality. 
      * Once the data has been generated, you can use the Azure Storage Explorer in Portal or from your desktop App to upload the json files into the **fhirimport** folder in **{ENVIRONMENTNAME}impsa** storage account created in Task #1. 
      * Once the data is loaded into **fhirimport** folder, the Azure function {ENVIRONMENTNAME}imp will be triggered to start the process of importing the data into {ENVIRONMENTNAME} FHIR instance. For 50 users, assuming the default of 1000 RUs for the Azure CosmosDB, it will take about 5-10 minutes. You can check the **fhirimport** folder in storage account **{ENVIRONMENTNAME}impsa** and when import is complete there won't be any files. You can also go to **{ENVIRONMENTNAME}imp**, click Monitoring and check Log Stream. You will see the status of files getting loaded. If there are errors, the funtion retries and loads into Azure API for FHIR.


* ### Option 2: Generate Synthea data
   * **Setup Synthea**: 
      * This section shows how to setup and generate health records with [Synthea](https://github.com/synthetichealth/synthea). 
      * Synthea requires [Java 8 JDK](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html). Make sure to select the JDK and not the JRE install.
      * After successfull install of Java 8
         * Option1: Manual Download: Download the [Synthea Jar File](https://github.com/synthetichealth/synthea/releases/download/master-branch-latest/synthea-with-dependencies.jar) 
         * Option2: Script Download: Open command prompt and run the below command. The .jar file will be downloaded to directory you are running the command from.
            ```cmd
            curl https://synthetichealth.github.io/synthea/build/libs/synthea-with-dependencies.jar --output synthea-with-dependencies.jar
            ```
   * **Generate Data**:
      * Follow instructions below to generate your synthetic data set. Note that, we are using the Covid19 module (-m "covid19") and generating a 50 person (-p 50) sample. 50 patients and related resources will be downloaded as json files to a output sub-folder.
      ```shell
      cd {directory_you_downloaded_synthea_to}
      java -jar synthea-with-dependencies.jar -m "covid19" -p 50
      ```
      * NOTE: the above will generate 100+ files, you can choose to upload a small subset (10 files) to complete the upload faster, and still able to learn all functionality. 
      * Once the data has been generated, you can use the Azure Storage Explorer in Portal or from your desktop App to upload the json files into the **fhirimport** folder in **{ENVIRONMENTNAME}impsa** storage account created in Task #1. 
      * Once the data is loaded into **fhirimport** folder, the Azure function {ENVIRONMENTNAME}imp will be triggered to start the process of importing the data into {ENVIRONMENTNAME} FHIR instance. For 50 users, assuming the default of 1000 RUs for the Azure CosmosDB, it will take about 5-10 minutes. You can check the **fhirimport** folder in storage account **{ENVIRONMENTNAME}impsa** and when import is complete there won't be any files. You can also go to **{ENVIRONMENTNAME}imp**, click Monitoring and check Log Stream. You will see the status of files getting loaded. If there are errors, the funtion retries and loads into Azure API for FHIR.

## Task #3: Validate Data Loaded

* ### Use the Dashboard App
    * Go to **Secondary AD** tenant. Go to Azure AD, click on Users. Part of the deployment will create an admin user {ENVIRONMENTNAME}-admin@{yournamefhirad}.onmicrosoft.com. Click on the admin user and Reset password.
    * Go to **Primary AD** tenant. Click on the App Service "{your resource prefix}dash". Copy the URL. Open Portal "InPrivate" window. Go to the App Service URL and login using the admin user above. 
    * The dashboard will show you all the patients in the system and allows you to see the patients medical details. You can click on little black **fire** symbol against each records and view fhir bundle and details.
    * You can click on resource links lik Condition, Encounters...to view those resource. 
    * Go to Patients, and click on little black **i** icon next to a patient record. You will notice 2 buttons "Growth Chart" and "Medications" SMART ON FHIR Apps.
 
* ### Use Postman to run queries
    * Download [Postman](https://www.postman.com/downloads/) if you haven't already.
    * Open Postman and import [Collection](../Postman/FHIR%20OpenHack.postman_collection.json).
    * Import [Environment](../Postman/FHIR%20OpenHack.postman_environment.json). An environment is a set of variables pre-created that will be used in requests. Click on Manage Environments (a slider on the top right). Click on the environment you imported. Enter these values for Initial Value:
      * adtenantId: This is the **tenant Id of the Secondary AD** tenant
      * clientId: This is the **client Id** that is stored in **Secret** "{your resource prefix}-service-client-id" in "{your resource prefix}-ts" Key Vault.
      * clientSecret: This is the **client Secret** that is stored in **Secret** "{your resource prefix}-service-client-secret" in "{your resource prefix}-ts" Key Vault.
      * bearerToken: The value will be set when "AuthorizeGetToken SetBearer" request below is sent.
      * fhirurl: This is **https://{your resource prefix}.azurehealthcareapis.com** from Azure API for FHIR you created in Task #1 above
      * resource: This is the Audience of the Azure API for FHIR **https://{your fhir name}.azurehealthcareapis.com** you created in Task #1 above.      
   * Import [Collection](../Postman/FHIR%20OpenHack.postman_collection.json). Collection is a set of requests.
   * After you import, you will see both the Collection on the left and Environment on the top right.
      <center><img src="../images/challenge01-postman.png" width="850"></center>
   * Run Requests:
      * Open "AuthorizeGetToken SetBearer", make sure the environment you imported is selected in the drop-down in the top right. click Send. This should pass the values in the Body to AD Tenant, get the bearer token back and assign it to variable bearerToken. Shows in Body results how many seconds the token is valid before expires_in. 
      * Open "Get Metadata" and click Send. This will return the CapabilityStatement with a Status of 200 ....This request doesn't use the bearerToken.
      * Open "Get Patient" and click Send. This will return all Patients stored in your FHIR server. Not all might be returned in Postman.
      * "Get Patient Count" will return Count of Patients stored in your FHIR server.
      * "Get Patient Sort LastUpdated" will returns Patients sorted by LastUpdated date. This is the default sort.
      * "Get Patient Filter ID" will return one Patient with that ID. Change the ID to one you have loaded and analyze the results.
      * "Get Patient Filter Missing" will return data where gender is missing. Change to different column and analyze the results.
      * "Get Patient Filter Exact" will return a specific Patient with a given name. Change to different name and analyze the results.
      * "Get Patient Filter Contains" will return Patients with letters in the given name. Change to different letters and analyze the results.
      * "Get Filter Multiple ResourceTypes" will return multiple resource types in _type. Change to other resource type and analyze the results.
      * NOTE: bearerToken expires in ...so if you get Authentication errors in any requests, re-run "AuthorizeGetToken SetBearer" to set new value to bearerToken variable.

## Task #4: Clean Up Resources
* **Pause/Disable/Stop** Azure resources created above if you are NOT going to use it immediately
* **Delete** Azure resources created above if you DON'T need them anymore

## Congratulations! You have successfully completed Challenge01! 

## Help, I'm Stuck!
Below are some common setup issues that you might run into with possible resolution. If your error/issue is not here and you need assistance, please let your coach know.

* **{ENVIRONMENTNAME} variable error**: EnvironmentName is used a prefix for naming Azure resources, you have to adhere to Azure naming guidelines. The value has to be globally unique and can't be longer than 12 characters. Here's an example of an error you might see due to a long name.
   <center><img src="../images/challenge01-errors-envname-length.png" width="850"></center>

* **PowerShell Execution Policy errors**: are another type of error that you might run into. In order to allow unsigned scripts and scripts from remote repositories, you might see a couple of different errors documented below.
   <center><img src="../images/challenge01-powershell-executionpolicy-1.png" width="850"></center>
   <center><img src="../images/challenge01-powershell-executionpolicy-2.png" width="850"></center>

   To allow PowerShell to run these scripts and resolve the errors, run the following command:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass
   ```
* **Git Missing**: This challenge uses scripts from Git that are downloaded and installed. If you don't have Git installed you might see the following error or something similiar. Get [Git](https://git-scm.com/downloads) and try again.
   <center><img src="../images/challenge01-git-client-install.png" width="850"></center>


***

[Go to Challenge02 - HL7 Ingest and Convert: Ingest HL7v2 messages and convert to FHIR format](../Challenge02-HL7IngestandConvert/ReadMe.md)
