# Challenge2 - Configure Service Client Authentication
With the Azure API for FHIR and FHIR Proxy deployed and configured, service clients need to be set up for secure authentication to each. Once complete we will test the connections in Postman. 

## To complete this challenge successfully, you will perform the following tasks.

* **Register a Service Client** for authentication to the Azure API for FHIR.
* **Register a Service Client** for authentication to the the FHIR Proxy.
* Store authentication information in Key Vault.
* **Validate connectivity** using Postman.

## Prerequsites

1. **If you haven't completed [Challenge1](../Challenge1-DeployFHIR/ReadMe.md), complete it now.**
2. **[Postman](https://www.postman.com/downloads/)** installed

## Create Azure API for FHIR Service Client
1. Go to App Registrations in Azure Portal
2. Register a new application named **{prefix}fs-svc-client**:
   * Select **Single tenant** for accounts supported
3. In the newly registered application, go to *Certificates & secrets* and add a new secret. Leave this window open so you can copy the Value into Key Vault, as it is only visible immediately after creation.
4. In another browser tab, go to the Azure Portal, the **{fhirtrainingname}** Resource Group and open the **{prefix}kv** Key Vault.
5. Go to *Access policies* and Add an Access Policy so you are able to view and create secrets:
   * Configure from template: **Secret Management**
   * Select principal: **your Azure account**
7. Go to *Secrets*, and perform the following steps for each item in the table below, using the values you just 
   * Click **Generate/import**
   * Upload options: **Manual**
   * Name: from the table below
   * Value: lookup in Azure Portal, location in table below
   * Enabled **Yes**
   * Create 

| Name | Value | Location |
| --- | --- | --- | 
| FS-SECRET | API for FHIR Service Client Secret | **{prefix}fs-svc-client** App Registration, new secret Value just created |
| FS-CLIENT-ID | API for FHIR Service Client ID | **{prefix}fs-svc-client** App Registration, Overview, copy Application (client) ID |
| FS-TENANT-NAME | API for FHIR Service Client Tenant ID | **{prefix}fs-svc-client** App Registration, Overview, copy Directory (tenant) ID |
| FS-URL | Azure API for FHIR URL <br> `https://[AzureAPIforFHIRName].azurehealthcareapis.com` | **{prefix}fhir** Azure API for FHIR, copy **FHIR metadata endpoint**, remove `/metadata` |
| FS-RESOURCE | FHIR Resource | Same as FS-URL |
| FP-RBAC-CLIENT-ID | FHIR Proxy Identity Provider Client ID | **{prefix}pxyfa** App Registration created in Challenge1, copy Application (client) ID |


## Create Proxy Service Client
These steps will use an existing script available in the [FHIR Proxy](https://github.com/microsoft/fhir-proxy) OSS project to create a service client for the FHIR Proxy and store the details in Key Vault. 

1. [Open Azure Cloud Shell](https://shell.azure.com) you can also access this from [Azure Portal](https://portal.azure.com) 
2. Select Bash Shell for the environment 
3. If you have multiple tenants, set the right tenant<br>
   `az account set --s {subscriptionid or tenantid}`
4. Clone the [FHIR Proxy](https://github.com/microsoft/fhir-proxy) repo:.<br>
   `git clone https://github.com/microsoft/fhir-proxy.git` <br>
5. Change directory into the /scripts folder of the cloned repo.<br>
   `cd ./fhir-proxy/scripts`<br>
   > NOTE: the directory path may be different if you uploaded the repo manually.
6. Make the bash script executable.<br>
   `chmod +x createproxyserviceclient.bash`
7. Execute the deploy script, entering required details when prompted:<br>
   `./createproxyserviceclient.bash`
   * Key Vault name: **{prefix}kv**
   * Service Client name: **{prefix}fp-svc-client**
8. In the Azure Portal, go to App Registrations and find the new **{prefix}fp-svc-client** application, into API permissions, and **Grant admin consent**.
9. In the **{prefix}kv** Key Vault, confirm the new values were loaded by the script:

| Name | Value | Location |
| --- | --- | --- | 
| FP-SC-CLIENT | FHIR Proxy Service Client ID | **{prefix}kv** |
| FP-SC-SECRET | FHIR Proxy Service Client Secret | **{prefix}kv** |
| FP-SC-RESOURCE | FHIR Resource ID  | **{prefix}kv** |
| FP-SC-TENANT-NAME | FHIR Proxy Service Client Tenant ID | **{prefix}kv** |
| FP-SC-URL | FHIR Proxy URL | **{prefix}kv** |

## Validate Connectivity with Postman
1. Download the Postman environment templates (click raw and save as):
   * [api-for-fhir.postman_environment.json](api-for-fhir.postman_environment.json)
   * [fhir-proxy.postman_environment.json](fhir-proxy.postman_environment.json)
2. Download the sample Postman collection files from [Microsoft/Health-Architectures](https://github.com/microsoft/health-architectures) on github:
   * [FHIR-CALLS.postman_collection.json](https://github.com/microsoft/health-architectures/blob/main/Postman/api-for-fhir/FHIR-CALLS.postman_collection.json)
   * [FHIR_Search.postman_collection.json](https://github.com/microsoft/health-architectures/blob/main/Postman/api-for-fhir/FHIR_Search.postman_collection.json)
2. Open Postman and click into Workspaces to **Create Workspace**, or select an existing one if desired.
3. Click Import next to the Workspace name and import the environment template and collection files downloaded.
4. Confirm **FHIR CALLS-Sample** and **FHIR Search** are now in the Collections area, and **api-fhir** and **fhir-proxy** are now in the Environments area. 
5. Update the values for the two environments, referencing values stored in the **{prefix}kv** Key Vault in previous steps.   
    * Be sure to save the environments!
6. Test direct authentication to the Azure API for FHIR:
   * Select the **api-fhir** environment in the top-right drop-down. 
   * Select the **AuthorizationGetToken** call from the **FHIR Calls-Sample** collection and click Send.
   * You should receive a valid token, which will be automatically set in the bearerToken variable for the environment
   * Select the **List Patients** call from the **FHIR Calls-Samples** collection and click Send. 
   * You should receive an empty bundle of patients from the FHIR Server
7. Test authentication through the FHIR Proxy to the Azure API for FHIR:
   * Select the **fhir-proxy** environment in the top-right drop-down.
   * Repeat the above steps to get an authorization token and list patients.
   * You should receive an empty bundle of patients again

> Note: After token expiry for an endpoint, use the **AuthorizationGetToken** call to update the environment variable with a new token. 

---

## Congratulations! You have successfully completed Challenge2! 

***

[Go to Challenge3](../Challenge3-BulkLoad/ReadMe.md)