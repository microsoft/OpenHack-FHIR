# Challenge4 - FHIR Sync Agent

FHIR-SyncAgent sychronizes health data between Azure API for FHIR and Dataverse' Microsoft Cloud for Healthcare securely and seemlessly. Applications built on the Dynamics platform (which includes Dynamics model-driven applications) that uses Dataverse can operate without the need to make REST API calls directly against Azure API for FHIR. 

This challenge is based off **[FHIR Sync Agent](https://github.com/microsoft/fhir-cds-agent)**, click to get more details.

You will be deploying an Azure Function and supporting Azure services including the Service Client for Access.

## Reference Architecture
<center><img src="../images/fhir-syncagent.png" width="650"></center>

## To complete this challenge successfully, you will perform the following tasks.

* **Register a Service Client** in Azure tenant that is same as Dynamics 365 tenant.
* **Deploy Azure Function and related services**. 
* **Validate deployment**.

## Prerequsites

1. **If you haven't completed [Challenge3](../Challenge3-FHIRLoader/ReadMe.md), complete now.**
2. The following resource providers must be registered in your subscription. To check, go to Subscriptions, click Resource providers in the left navigation. Then filter by name
   * Function App
   * Application Insights
   * App Service Plan
   * Service Bus Namespace
   * Storage Account
3. Go to Challenge2, gather these details for below deployment:
   * FHIR Proxy Function App Name

## Setup App Registration in the same Azure tenant as your Dynamics 365 tenant
1. Go to App Registrations in Azure Portal
2. Click + New registration
3. Enter a Name **syncdv-svc-client**, pick Single tenant, click Register. Note the following for use in deployment below:
   * Application (client) ID
   * Directory (tenant) ID
4. Go to Certificates & secrets in the left navigation, click + New client secret, click Add. 
   * IMPORTANT: Note the secret for use in deployment steps, as it is only visible during creation
6. For awareness: The details of this App Registration will be stored in the below Key Vault secrets **{azureapiforfhirname}kv** once the deployment below is complete
   * SA-CDSCLIENTID
   * SA-CDSSECRET
   * SA-CDSTENANTID
   * SA-CDSAUDIENCE

## Deployment
1. [Open Azure Cloud Shell](https://shell.azure.com) you can also access this from [Azure Portal](https://portal.azure.com) **NOTE: If Function App is failing in cloud shell, it might be that Function App takes times to deploy and cloud shell is moving too fast, so try using [Ubuntu](https://github.com/microsoft/OpenHack-FHIR/tree/main/Challenge00-Prerequistes#needs-to-be-installed-before-starting-challenge02) to deploy** 
2. Select Bash Shell for the environment 
3. If you have multiple tenants, set the right tenant ```az account set --s {subscriptionid or tenantid}```
4. As this is a private repository, follow these steps:
   * Go to the Github https://github.com/cyberuna/fhir-cds-agent. 
   * Click on Account (your picture on the top right corner), then click on Settings. 
   * Click Developer Settings in left menu
   * Click Personal access tokens
   * Click Generate new token 
   * Click Enable SSO and click Authorize against microsoft.
6. Clone this repo ```git clone https://github.com/cyberuna/fhir-cds-agent```, Enter your Github username, and token for password.
7. Change directory ```cd ./fhir-cds-agent/scripts```
8. Make the bash script executable ```chmod +x deploysyncagent.bash```
9. Execute ```./deploysyncagent.bash``` by following the prompts
   * Subscription ID 
   * Same Resource Group Name used in Challenge1
   * Same Resource Group Location used in Challenge1
   * A prefix {azureapiforfhirname}s
   * Same Key Vault Name used in Challenge1
   * New unique name for Proxy App {azureapiforfhir}sapp
10. Make the bash script executable ```chmod +x setupSyncAgent.bash```
11. Execute ```./setupSyncAgent.bash``` by following the prompts
   * FHIR Proxy Function App Name from Challenge2
   * Same Resource Group Name used in Challenge1
   * Same Key Vault Name used in Challenge1
   * Dynamics 365 URL where FHIR data will by synced with
   * Tenant ID from App Registration Setup above
   * Client ID from App Registration Setup above
   * Client Secret from App Registration Setup above

**NOTE: This deployment (both scripts) will take ~10-15 minutes**

## Validate Deployment
1. Go to Azure Portal, and check if these resources are created in the Resource Group **{azureapifhirname}**
   * {azureapiforfhir}sapp Function App
   * {azureapiforfhir}sapp Application Insights
   * {azureapiforfhir}sapp App Service Plan
   * {azureapiforfhir}sbns... Service Bus Namespace
   * {azureapiforfhir}sstore... Storage Account
2. Check the Key Vault **{azureapiforfhirname}kv** for 10 new secrets with prefix SA-. 

## Post-Deployment 
1. Ensure resolution of configuration references for Proxy App
   * Go to the Proxy **{azureapiforfhir}papp** Function App
   * Click on Configuration in the left navigation, make sure all Key vault Reference in source column in center section are all green. 
   * Click **Refresh** if your see any reds. Refresh as many times as necessary until all configurations are green
2. Ensure resolution of configuration references for Syn Agent
   * Go to the Sync Agent **{azureapiforfhir}sapp** Function App
   * Refresh configurations until all are green (same as instructions for Proxy App)
3. KeyVault Issue with Service Bus manual work around
   * Go to the Sync Agent **{azureapiforfhir}sapp** Function App
   * Make the Sync Agent function app editable:
      * click Configuration in the left navigation
      * open the **WEBSITE_RUN_FROM_PACKAGE** configuration and set the value to **0** and click OK
      * click Save at the top to save configuration changes
   * Update integration queue name:
      * click on Functions in the left navigation. If blank, refresh
      * open the FHIRUpdates function, click Integration in the left navigation
      * click on Azure Service Bus (message) in the Trigger box, replace the contects of **Queue name** with **fhirupdates**
      * click save
4. Restart both the Proxy **{azureapiforfhir}papp** Function App and the Sync Agent **{azureapiforfhir}sapp** Function App

## Clean-up
If you are not planning to continue with the other challenges, make sure to delete these to avoid cost in Azure
1. Resource Group **{azureapifhirname}**
---

## Congratulations! You have successfully completed Challenge4! 

***


[Go to Challenge5](../Challenge5-FHIRSyncDV/ReadMe.md)

