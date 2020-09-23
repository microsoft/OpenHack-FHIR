# Challenge05 - Analytics on FHIR Data

## Scenario
Now that you’ve dipped into the data analysis role a bit, let’s go a little deeper down the rabbit hole. We want to take a look at some other possible ways to utilize FHIR data to draw out additional insights. Can we do some basic analysis of the COVID-related observations that lead toward respirators? How many of those with symptoms moved to respirators? How fast did they move from first symptoms to respirator? How long did they stay on respirators?

From a data analytics perspective, it can often be helpful to first structure the data so that is your first task. [Jeff: I’d like to add more story here about the data story we are investigating. I’m open to ideas. One alternative idea was looking for common patient observations in certain geographies.]

Once your data is more “report-ready”, you’ll need to help your users understand the data by visualizing it. 

## Reference Architecture
<center><img src="../images/challenge05-architecture.png" width="450"></center>


## To complete this challenge successfully, you will pick one option and will perform the following tasks.

## **Option 1: Vizualize in PowerBI using PowerQuery Connector for FHIR**. 
## **Option 2:** 
   * **Process exported FHIR data using Databricks**. 
   * **Persist structured data into Azure SQL DB**.
   * **Vizualize in PowerBI using SQL Connector**.

## Before you start

* Make sure you have completed the pre-work covered in the previous challenge: [Challenge00 - Pre-requisites: Technical and knowledge requirements for completing the Challenges](../Challenge00-Prerequistes/ReadMe.md).

* Make sure you have completed [Challenge01 - Azure API for FHIR: Generate, Ingest and Store synthetic data into Azure API for FHIR](../Challenge01-AzureAPIforFHIR/ReadMe.md).

## Getting Started

## Option 1:
* Go to **Secondary AD** tenant. 
   * Go to Azure AD, click on Users. Part of the [Challenge01](../Challenge01-AzureAPIforFHIR/ReadMe.md) deployment created an admin user {ENVIRONMENTNAME}-admin@{yournamefhirad}.onmicrosoft.com. 
   * Note down the admin user and password. If you don't remember the password, click Reset password. You will get temporary password, use can change password next time you login.
   * Click on the user and note down the Object ID of the user.
* Open PowerBI Desktop. [Download](https://powerbi.microsoft.com/en-us/downloads/) if you don't have one.
   * Go to File --> Options and settings --> Data source settings and Click **Clear All Permissions** 
   * Click **Get Data** from the menu.
   * Search **FHIR**, select and click Connect.
   * Type FHIR URL **https://{your resource prefix}.azurehealthcareapis.com**.
   * Click Sign In.
   * Use admin user from **Secondary tenant** and password.
   * Click Connect.
   * Choose the tables you are interested in analyzing and click **Transform data**.
   * You should see all tables you selected loaded into Power Query Editor.
   * You are ready to transform and analyze the data.

## Option 2:
## Task #1: Process and Load into Azure SQL Database using Azure Databricks
* Azure SQL Server
   * Create a SQL Server/SQL Database. Provide Database User name and Password. You will need these information in the Task #2 below.
   * Open Editor and run DDL script
* Databricks
   * Create Cluster
   * Import notebook
   * Update all values
   * Run All
* Validate data loaded
   * Run Select script

## Task #2: Visualize in PowerBI using Azure SQL Server 
* Open PowerBI Desktop. [Download](https://powerbi.microsoft.com/en-us/downloads/) if you don't have one.
   * Go to File --> Options and settings --> Data source settings and Click **Clear All Permissions** 
   * Click **Get Data** from the menu.
   * Search **Azure SQL**, select and click Connect.
   * Type in Server and Database from Task #1 above. Leave Import checked. Click Ok.
   * Click Database on the left menu. Type in User name and Password from Task #1 above.
   * Choose all the tables you are interested in analyzing/visualizing and click Transform data.
   * You are ready to transform and analyze the data.


## Task #4: Clean Up Resources
* **Pause/Disable/Stop** Azure resources created above if you are NOT going to use it immediately
* **Delete** Azure resources created above if you DON'T need them anymore
* **Disable** Data Export in IoT Central


## Congratulations! You have successfully completed Challenge05!

## Help, I'm Stuck!
* Below are some common setup issues that you might run into with possible resolution. If your error/issue is not here and you need assistance, please let your coach know.

***

