# Challenge2 - Test FHIR Components with Postman



This challenge is based on the following published by Microsoft Health Architectures:
> **[Postman setup + sample Postman environments and collections](https://github.com/microsoft/health-architectures/tree/main/Postman)**

## To complete this challenge successfully, you will perform the following tasks.

* **Set up a workspace in Postman** and import environment templates and collection files.
* **Register a Service Client** for use by Postman with access to FHIR Proxy and Azure API for FHIR.
* **Grant Postman RBAC access roles** to the Azure API for FHIR.
* **Configure environment templates** imported into Postman.
* **Validate connectivity** using Postman.

## Prerequsites

1. **If you haven't completed [Challenge2](../Challenge2-DeployFHIR/ReadMe.md), complete it now.**
2. **[Postman](https://www.postman.com/downloads/)** installed

## Workspace Setup in Postman
1. Download the Postman environment templates (click raw and save as):
   * [api-for-fhir.postman_environment.json](api-for-fhir.postman_environment.json)
   * [fhir-proxy.postman_environment.json](fhir-proxy.postman_environment.json)
2. Download the sample Postman collection files from [Microsoft/Health-Architectures](https://github.com/microsoft/health-architectures) on github:
   * [FHIR-CALLS.postman_collection.json](https://github.com/microsoft/health-architectures/blob/main/Postman/api-for-fhir/FHIR-CALLS.postman_collection.json)
   * [FHIR_Search.postman_collection.json](https://github.com/microsoft/health-architectures/blob/main/Postman/api-for-fhir/FHIR_Search.postman_collection.json)
2. Open Postman and click into Workspaces to **Create Workspace**, or select an existing one if desired.
3. Click Import next to the Workspace name and import the environment template and collection files downloaded.
4. Confirm **FHIR CALLS-Sample** and **FHIR Search** are now in the Collections area, and **api-fhir** and **fhir-proxy** are now in the Environments area. We will fill in the Environment values in later steps. 

## Configure Authentication for Postman
1. In Azure Portal, go to App Registrations and register a new application named **Postman**:
   * Select **Single tenant** for accounts supported
   * Add the following Redirect URI of type **Web** 
      > https://www.getpostman.com/oauth2/callback
2. In the newly created Postman application, and go to *API Permissions*.
3. Add a permission, selecting the FHIR Proxy app ending in **pxyfa** from the *My APIs* tab:
   * Select **Delegated permissions**
   * Select and add the **user_impersonation** permission
4. Add a permission, selecting the FHIR Proxy app ending in **pxyfa** from the *My APIs* tab again:
   * Select **Application permissions**
   * Select and add both **Resource Reader** and **Resource Writer** permissions
5. Add a permission, searching for and selecting **Azure Heatlhcare APIs** from the *APIs my organization uses* tab:
   * Select and add the **user_impersonation** permission
4. Back in API permissions, **Grant admin consent for Default Directory** and confirming for these permissions for all accounts in the Default Directory.
6. Still in the Postman application, go to *Certificates and Secrets*.
7. Add a new client secret and immediately copy the secret **Value**, and paste it into the *clientSecret* initial and current values for both the *api-for-fhir* and *fhir-proxy* environments defined in Postman.

## Assign RBAC Roles to Postman
1. In Azure Portal, go to the **{fhirtrainingname}** Resource Group used for deployment.
2. Open the Azure API for FHIR resource and go to *Access control (IAM)*
3. Add a role assignment of **FHIR Data Contributor** selecting the following members:
   * the **Postman** service principal (created by the application registration in previous steps)
   * your Azure user

## Set Postman Environment Values
1. In Postman, update the rest of the values for the two imported environments by looking them up in the Azure at the locations defined in the table below.
2. Note that the tenantId, clientId, and clientSecret are the same for both environments, as they both use the Postman service principal to authenticate.
3. Enter the values as both the INITIAL VALUE and CURRENT VALUE. 
3. Be sure to Save the environments after updating.

| Environment | Variable | Value Location |
| --- | --- | --- |
| api-fhir | tenantId | AAD Default Directory, copy Tenant ID |
| | clientId | App Registrations, **Postman** app, copy Application (client) ID |
| | clientSecret | set in previous steps |
| | bearerToken | leave blank |
| | resource | {fhirtrainingname} Resource Group, Azure API for FHIR, copy FHIR metadata endpoint, **Remove /metadata** |
| | fhirurl | same as resource |
| fhir-proxy | tenantId | AAD Default Directory, copy Tenant ID |
| | clientId | App Registrations, Postman app, copy Application (client) ID |
| | clientSecret | set in previous steps |
| | bearerToken | leave blank |
| | resource | App Registrations, **{prefix}pxyfa** app, copy Application (client) ID |
| | fhirurl | {fhirtrainingname} Resource Group, **{prefix}pxyfa** function app, copy URL, **append /fhir** |

## Validate Connectivity to FHIR Server using Postman
1. Test direct authentication to the Azure API for FHIR:
   * Select the **api-fhir** environment in the top-right drop-down. 
   * Select the **AuthorizationGetToken** call from the **FHIR Calls-Sample** collection and click Send.
   * You should receive a valid token, which will be automatically set in the bearerToken variable for the environment
   * Select the **List Patients** call from the **FHIR Calls-Samples** collection and click Send. 
   * You should receive an empty bundle of patients from the FHIR Server
2. Test authentication through the FHIR Proxy to the Azure API for FHIR:
   * Select the **fhir-proxy** environment in the top-right drop-down.
   * Repeat the above steps to get an authorization token and list patients.
   * You should receive an empty bundle of patients again

> Note: After token expiry for an endpoint, use the **AuthorizationGetToken** call to update the environment variable with a new token. 

---

## Congratulations! You have successfully completed Challenge2! 

***

[Go to Challenge3](../Challenge3-BulkLoad/ReadMe.md)

