# Challenge4 - FHIR Sync Agent

FHIR-SyncAgent sychronizes health data between Azure API for FHIR and Dataverse' Microsoft Cloud for Healthcare securely and seemlessly. Applications built on the Dynamics platform (which includes Dynamics model-driven applications) that uses Dataverse can operate without the need to make REST API calls directly against Azure API for FHIR. 

This challenge is based on **[FHIR Sync Agent](https://github.com/microsoft/fhir-cds-agent)**. Review the main ReadMe as well as the ReadMe in the ./scripts folder for more detail.

## Reference Architecture
<center><img src="../images/fhir-syncagent-new.png" width="400"></center>

## To complete this challenge successfully, you will perform the following tasks.

* **Register a Service Client** in Azure tenant where Dataverse/Dynamics 365 is deployed, for authenticating the Sync Agent with Dataverse.
* **Deploy Sync Agent** Azure Function and related services. 
* **Validate deployment**.

## Prerequsites

1. **If you haven't completed [Challenge0](../Challenge0-Prerequisites/ReadMe.md), [Challenge1](../Challenge1-DeployFHIR/ReadMe.md), and [Challenge2](../Challenge2-AuthSetup/ReadMe.md), complete them now.**
2. The following resource providers must be registered in your subscription. To check, go to Subscriptions, click Resource providers in the left navigation. Then filter by name
   * Function App
   * Application Insights
   * App Service Plan
   * Service Bus Namespace
   * Storage Account
3. Have the target Dataverse/Dynamics 365 URL ready
4. Access to the [Azure FHIR Sync Agent](https://github.com/microsoft/fhir-cds-agent) (currently private to Microsoft Internal), or a downloaded copy of the repo is required
   * **If you are Microsoft Internal**: a personal access token is required to clone the repo. For more information review [PrivateRep.md](./PrivateRepo.md).
      * Ensure your github account is a member of the Microsoft Organization
      * Go to github Settings > Developer Settings > Personal Access Tokens. Generate a new token with **repo** scope. 
      * Once generated, copy and note the token for use in the Deployment steps later. 
      * On the token, click **Configure SSO > Authorize**.
   * **If you are not Microsoft Internal**: request a copy of the downloaded repo from your Microsoft contact.
      * Upload the zip file in the Azure Cloud Shell, and use the `unzip` command 

## Create Service Client for Sync Agent
1. Go to App Registrations in Azure Portal
   > NOTE: You must be in the same Azure Tenant as the target Dataverse/Dynamics 365 environment being integrated with the Azure API for FHIR.
2. Register a new application named **syncdv-svc-client**:
   * Select **Single tenant** for accounts supported
3. In the newly registered application, note the following for use in deployment below:
   * Application (client) ID
   * Directory (tenant) ID
4. Still in the **syncdv-svc-client** application, go to *Certificates & secrets* and add a new secret. 
   * IMPORTANT: Note the secret **Value** for use in deployment steps, as it is only visible during creation
6. For awareness: The details of this App Registration that you are noting now will be entered during deployment below, after which will be stored in the below secrets in the **{prefix}kv** Key Vault deployed in Challenge1. 
   * SA-CDSCLIENTID
   * SA-CDSSECRET
   * SA-CDSTENANTID
   * SA-CDSAUDIENCE

## Deployment
1. [Open Azure Cloud Shell](https://shell.azure.com) you can also access this from [Azure Portal](https://portal.azure.com) 
2. Select Bash Shell for the environment 
3. If you have multiple tenants, set the right tenant<br>
   `az account set --s {subscriptionid or tenantid}`
4. Clone the FHIR Sync Agent repo, entering your Github username, and personal access token generated during prerequisites as the password.<br>
   `git clone https://github.com/fhir-cds-agent.git` <br>
   > NOTE: If you do not have access to this private repo, skip this step, as you should have already uploaded a copy of the repo in prerequisite steps.
5. Change directory into the /scripts folder of the cloned repo.<br>
   `cd ./fhir-cds-agent/scripts`<br>
   > NOTE: the directory path may be different if you uploaded the repo manually.
6. Make the bash script executable.<br>
   `chmod +x deploysyncagent.bash`
7. Execute the deploy script, entering required details when prompted:<br>
   `./deploysyncagent.bash`
   * Subscription ID 
   * Resource Group Name used in Challenge1
   * Resource Group Location used in Challenge1
   * A prefix, such as **{sync}** (keep short additional characters will be appended)
   * Key Vault Name created in Challenge1 **{prefix}kv**
   * Name for Sync App, such as **{sync}** (keep short additional characters will be appended)
   <br>
> NOTE: This deployment will take ~10 minutes
<br>

> NOTE: If Function App is failing in cloud shell, it might be that Function App takes times to deploy and cloud shell is moving too fast; try using [Ubuntu](https://github.com/microsoft/OpenHack-FHIR/tree/main/Challenge00-Prerequistes#needs-to-be-installed-before-starting-challenge02) to deploy

## Configure FHIR Sync Agent to Dataverse Connection
> This step can be done again at any time to change the Dataverse/Dynamics environment the Sync Agent connects to
1. [Open Azure Cloud Shell](https://shell.azure.com) you can also access this from [Azure Portal](https://portal.azure.com) 
2. Select Bash Shell for the environment 
3. If you have multiple tenants, set the right tenant<br>
   `az account set --s {subscriptionid or tenantid}`
4. Change directory into the /scripts folder of the cloned Sync Agent repo cloned (from Deployment step)<br>
   `cd ./fhir-cds-agent/scripts`<br>
   > NOTE: the directory path may be different if you uploaded the repo manually.
5. Make the bash script executable.<br>
   `chmod +x setupSyncAgent.bash`
6. Execute the setup script, entering required details when prompted:<br>
   `./setupSyncAgent.bash`
   * Resource Group Name used in Challenge1
   * Key Vault Name created in Challenge1
   * FHIR Proxy Function App Name from Challenge2 **{prefix}pxyfa**
   * Dataverse/Dynamics 365 URL FHIR data is to be synced with
   * Tenant ID of **syncdv-svc-client** App Registration from earlier step
   * Client ID of **syncdv-svc-client** App Registration from earlier step
   * Client Secret of **syncdv-svc-client** App Registration from earlier step
7. When the script completes, it will provide configuration settings required for Sync Administration within Dataverse. Note these values for use in Challenge 5, including:
   * Service Bus URL
   * Service Queue
   * Service Bus Shared Access Policy
   * Service Bus Shared Access Policy Key

> NOTE: This script will take ~1 minute**

## Validate Deployment & Configuration


1. In Azure Portal, check that the below resources are created in the **{fhirtrainingname}** Resource Group
2. Check the Key Vault **{prefix}kv** for 10 new secrets with prefix SA-. 

| Name | Type | Purpose |
|---|---|---|
| {prefix}**asp** | App Service plan | resource container for Sync Agent Function App |
| {prefix}**sbns** | Service Bus Name Space | Manages bi-directional data queues |
| {prefix}**sstore** | Storage Account | For File Loading and stores function code |
| {syncAppName}[number] | Application Insights | Monitors Sync Agent application |
| {syncAppName}[number] | Function App | Sync Agent Application |

## Post-Deployment 
1. Ensure resolution of configuration references for Proxy App
   * Go to the Proxy **[prefix]pxyfa** Function App
   * Click on Configuration in the left navigation, make sure all Key vault Reference in source column in center section are all green. 
   * Click **Refresh** if your see any reds. Refresh as many times as necessary until all configurations are green
   > NOTE: the FP-RBAC-* secrets may stay red - this is OK.

2. Ensure resolution of configuration references for Sync Agent
   * Go to the Sync Agent **{syncAppName}[number]** Function App
   * Refresh configurations until all are green (same as instructions for Proxy App)
3. KeyVault Issue with Service Bus manual work around
   * Go to the Sync Agent **{syncAppName}[number]** Function App
   * Make the Sync Agent function app editable:
      * click Configuration in the left navigation
      * open the **WEBSITE_RUN_FROM_PACKAGE** configuration and set the value to **0** and click OK
      * click Save at the top to save configuration changes
   * Update integration queue name:
      * click on Functions in the left navigation. If blank, refresh
      * open the FHIRUpdates function, click Integration in the left navigation
      * click on Azure Service Bus (message) in the Trigger box, replace the contects of **Queue name** with **fhirupdates**
      * click save


      
4. Restart both the Proxy **[prefix]pxyfa** Function App and the Sync Agent **{syncAppName}[number]** Function App

## Clean-up
If you are not planning to continue with the other challenges, make sure to delete these to avoid cost in Azure
1. Resource Group **{fhirtrainingname}**
2. App Registration **{prefix}pxyfa** 
---

## Congratulations! You have successfully completed Challenge4! 

***


[Go to Challenge5](../Challenge5-FHIRSyncDV/ReadMe.md)

