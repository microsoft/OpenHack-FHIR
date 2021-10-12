# Challenge0 - Pre-requisites

#### The below lists the Installation Prerequisites and Knowledge References needed to complete all challenges.

## Installation Prerequisites
* **NOTE**: This version of the OpenHack assumes hackers are on a **Windows client machine** with no firewall blocking access to Azure.

* **1**. Check if you have one of the below **Azure Subscription**
   * Your Work Internal Subscription
   * Visual Studio Subscription
   * [Free](https://azure.microsoft.com/en-us/free/)

* **2**. Check if you have one of these roles that are required to perform CRUD operations in your Azure tenant. To check, go to **Azure Active Directory, click Roles and administrators** on the left navigation, you should see Your Role: in the center.
   * Azure Global Administrator
   * Application Administrator AND Privileged Role Administrator AND User Administrator

* **3**. Check if you have access to **run Bash CLI from Azure Portal**

* **4**. Check if you have access to **clone Github from Bash CLI in Azure Portal**

* **5**. Check if you have access to **create Application Registrations** in Azure

* **6**. Download and install **[Postman](https://www.postman.com/downloads/)**

## Knowledge References
The below services are used across all challenges. Familiarity of these services will not only help you complete but enhance your learning. It's recommended you right-click on the links below and open in new tab.

* **Azure**
   * [FHIR](https://www.hl7.org/fhir/overview.html) is a standard for exchanging healthcare information electronically.
   * [Azure API for FHIR](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir/) enables to easily create and deploy a Fast Healthcare Interoperability Resources (FHIR®) service for health data solutions.
   * [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) is Microsoft's object storage solution, optimized for storing massive amounts of unstructured data.
   * [Azure Data Lake Storage Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction) is a set of capabilities dedicated to big data analytics, is the result of converging the capabilities of our two existing storage services, Azure Blob storage and Azure Data Lake Storage Gen1.
   * [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts) is a cloud service for securely storing and accessing secrets.
   * [Azure App Service plans](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) defines a set of compute resources for a web app to run. 
   * [Azure Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) is a feature of Azure Monitor, is an extensible Application Performance Management (APM) service used to monitor applications.
   * [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/) is a serverless compute service that lets you run event-triggered code without having to explicitly provision or manage infrastructure.
   * [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview) is a fully managed enterprise integration message broker. Service Bus can decouple applications and services.
   * [Azure Cache for Redis](https://azure.microsoft.com/en-us/services/cache/) is a fully managed, in-memory cache that enables high-performance and scalable architectures.
   * [Azure Event Grid](https://docs.microsoft.com/en-us/azure/event-grid/system-topics) represents one or more events published by Azure services such as Azure Storage and Azure Event Hubs.
   * [Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/)
   * [FHIR Dataverse Integration](https://docs.microsoft.com/en-us/dynamics365/industry/healthcare/configure-sync-clinical-data#use-fhir-sync-agent-administration)

* **Synthea**
   * [Synthea](https://github.com/synthetichealth/synthea) is an open-source synthetic patient and associated health records generator that simulates the medical history of synthetic patients. Synthea generates HL7 FHIR records using the HAPI FHIR library to generate a FHIR Bundle

* **Microsoft Cloud for Healthcare**
   * [Microsoft Cloud for Healthcare Overview](https://www.microsoft.com/en-us/industry/health/microsoft-cloud-for-healthcare)
   * [Microsoft Cloud for Healthcare Documentation](https://docs.microsoft.com/en-us/industry/healthcare/overview)

## References
* [FHIR Server](https://github.com/sordahl-ga/api4fhirstarter)
* [FHIR Loader](https://github.com/microsoft/fhir-loader)
* [FHIR Proxy](https://github.com/microsoft/fhir-proxy)
* [FHIR Sync Agent](https://github.com/microsoft/fhir-cds-agent)

***

[Go to Challenge1](../Challenge1-FHIRServer/ReadMe.md)
