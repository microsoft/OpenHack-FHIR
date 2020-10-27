# Challenge00 - Pre-requisites

#### The below lists the Installation Prerequisites technical and Knowledge References needed to complete all challenges.

## Installation Prerequisites
* **NOTE**: This version of the OpenHack assumes hackers are on a **Windows client machine**, but hints are included for `*nix` users.
* **Download this Github to your local drive.**

### Needs to be installed before starting Challenge01:
* **1**. Check if you have one of the below **Azure Subscription**
   * Your Work Internal Subscription
   * Visual Studio Subscription
   * [Free](https://azure.microsoft.com/en-us/free/)

* **2**. **Microsoft Powershell**: You will need powershell in order to run the operations in this document. The correct installation steps for your platform can be found [here](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7).

* **3**. **Install prerequisite PowerShell modules**: While there are other options, we recommend PowerShell scripts in Windows for challenges in this Github. **Run PowerShell as Administrator**.
   * Get PowerShell module version: Make sure your version is 5.1. If not, install [this](https://www.microsoft.com/en-us/download/details.aspx?id=54616) version.
      ```powershell
      $PSVersionTable.PSVersion
      ```  
   * Get Azure PowerShell module versions: If your results show Az version 4.1.0 and AzureAd version 2.0.2.4, then proceed to login step. If not, get the right versions.
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
      NOTE: If you get an error that AzureRM Module is conflicting with Az Module, run the below
      ```powershell
      Uninstall-Module -Name AzureRM
      ```  

   * **NOTE**: If you are using a **`*nix` platform (Mac or Linux)**, you will need to install the `AzureAD.Standard.Preview` module instead of `AzureAD`:
      ```powershell
      # Step 1: If you already installed the AzureAD module, uninstall it
      Uninstall-Module AzureAD

      # Step 2: Add a package source for AzureAD.Standard.Preview module
      Register-PackageSource -Trusted -ProviderName 'PowerShellGet' -Name 'Posh Test Gallery' -Location https://www.poshtestgallery.com/api/v2/

      # Step 3: Install and import AzureAD.Standard.Preview module
      Install-Module AzureAD.Standard.Preview
      Import-Module AzureAD.Standard.Preview
      ```

* **4**. Current Release of **[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&tabs=azure-cli)**

* **5**. **[Postman](https://www.postman.com/downloads/)**
* **6**. **[.NET Core 3.1 (SDK)](https://dotnet.microsoft.com/download/dotnet-core/3.1)**
* **7**. **Optional** [Java 1.8 (JDK, not JRE install)](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html). Java [JRE vs SE vs JDK](https://www.java.com/en/download/help/techinfo.html).

### Needs to be installed before starting Challenge02:
* **8**. **[If you are running Windows 10, enable Windows Linux Subsystem](https://code.visualstudio.com/docs/remote/wsl-tutorial#_enable-wsl).** You can use Windows Dialog or PowerShell. Restart Windows.
* **9**. **[Ubuntu](https://code.visualstudio.com/docs/remote/wsl-tutorial#_install-a-linux-distro).** You can install from the Microsoft Store by using the store app or by searching for Ubuntu in the Windows search bar.
* **10**. **Azure CLI 2.0** on [Ubuntu One Command Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest#install-with-one-command). Run the below in Ubuntu.
      ```
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      ```
   * [Ubuntu Manual Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest#manual-install-instructions)

## Knowledge References
The below services are used across all challenges. Familiarity of these services will not only help you complete but enhance your learning. It's recommended you right-click on the links below and open in new tab.

* **FHIR**
   * [Azure API for FHIR](https://azure.microsoft.com/en-us/services/azure-api-for-fhir/) enables to easily create and deploy a Fast Healthcare Interoperability Resources (FHIR®) service for health data solutions.
   * [Azure API for FHIR Documentation](https://docs.microsoft.com/en-us/azure/healthcare-apis/) is a managed, standards-based, compliant API for clinical health data that enables solutions for actionable analytics and machine learning.
   * [HL7 FHIR](https://hl7.org/fhir/) FHIR is a standard for health care data exchange, published by HL7®.
   * [MLLP Relay](https://hapifhir.github.io/hapi-hl7v2/hapi-hl7overhttp/specification.html) is a standardized transport mechanism to send HL7 v2 messages over a network using the HTTP protocol.

* **Synthea**
   * [Synthea](https://github.com/synthetichealth/synthea) is an open-source synthetic patient and associated health records generator that simulates the medical history of synthetic patients. Synthea generates HL7 FHIR records using the HAPI FHIR library to generate a FHIR Bundle

* **Azure Services**
   * [Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/)
   * [Azure AD PowerShell](https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0)
   * [Azure Powershell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-4.5.0)

   * [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) is Microsoft's object storage solution, optimized for storing massive amounts of unstructured data. 
   * [Azure Data Lake Store Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction) is a set of capabilities dedicated to big data analytics, is the result of converging the capabilities of our two existing storage services, Azure Blob storage and Azure Data Lake Storage Gen1.
   * [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/) is Azure storage management used to upload, download, and manage Azure blobs, files, queues, and tables, as well as Azure Cosmos DB and Azure Data Lake Storage entities.
   * [Azure Function](https://docs.microsoft.com/en-us/azure/azure-functions/) is a serverless compute service that lets you run event-triggered code without having to explicitly provision or manage infrastructure.
   * [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview) is a fully managed enterprise integration message broker. Service Bus can decouple applications and services. 
   * [Azure Logic Apps](https://docs.microsoft.com/en-us/azure/logic-apps/) is used to build automated scalable workflows, business processes, and enterprise orchestrations to integrate your apps and data across cloud services and on-premises systems.
   * [Azure Web App](https://docs.microsoft.com/en-us/azure/app-service/) enables you to build and host web apps, mobile back ends, and RESTful APIs in the programming language of your choice without managing infrastructure.
   * [Azure Batch](https://docs.microsoft.com/en-us/azure/batch/) runs large-scale applications efficiently in the cloud. Schedule compute-intensive tasks and dynamically adjust resources for your solution without managing infrastructure.
   * [Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/)  is Azure's cloud ETL service for scale-out serverless data integration and data transformation.
   * [Azure Databricks](https://docs.microsoft.com/en-us/azure/databricks/scenarios/what-is-azure-databricks) is an Apache Spark-based analytics platform optimized for the Microsoft Azure cloud services platform. 
   * [Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/) is a managed, secure, and intelligent product that use the SQL Server database engine in the Azure cloud.

* **Power Platform**
   * [Power Query](https://docs.microsoft.com/en-us/power-query/power-query-what-is-power-query) is a data transformation and data preparation engine. 
   * [PowerBI](https://docs.microsoft.com/en-us/power-bi/fundamentals/power-bi-overview) is a collection of software services, apps, and connectors that work together to turn your unrelated sources of data into coherent, visually immersive, and interactive insights.

* **IoT**
   * [IoT Central](https://docs.microsoft.com/en-us/azure/iot-central/healthcare/concept-continuous-patient-monitoring-architecture) helps create, customize, and manage healthcare IoT solutions using IoT Central application templates. Continuous patient monitoring is one application template in healthcare IoT space.

## References
* [Microsoft Cloud for Healthcare](https://www.microsoft.com/en-us/industry/health/microsoft-cloud-for-healthcare)
* [Microsoft Health Architecture GitHub](https://github.com/microsoft/health-architectures)
* [Microsoft FHIR Server Samples](https://github.com/microsoft/fhir-server-samples)
* [HIPPA Safe Harbor Method](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)
* [HL7 bulk export](https://hl7.org/Fhir/uv/bulkdata/export/index.html)
* [FHIR Tools for Anonymization](https://github.com/microsoft/FHIR-Tools-for-Anonymization)

***

[Go to Challenge01 - Azure API for FHIR: Generate, Ingest and Store synthetic data into Azure API for FHIR](../Challenge01-AzureAPIforFHIR/ReadMe.md)
