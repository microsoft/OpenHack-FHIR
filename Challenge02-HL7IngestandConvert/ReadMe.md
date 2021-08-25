# Challenge02 - HL7 Ingest and Convert

## Scenario
With Azure API for FHIR up and running with basic EHR synthetic data, you will focus on this challenge of ingesting legacy data from a different format into Azure API for FHIR. Most (but of course not all) of your existing healthcare applications use some version of HL7, and you have to ingest those HL7 messages and convert them into FHIR format. By establishing FHIR as a hub of sorts, you’ll be able to aggregate data from these various systems and enable interoperability.

## FHIR Conversion Options

### **PaaS** using $convert-data custom endpoint
* The $convert-data custom endpoint is integrated into FHIR service is meant for data conversion from different data types to FHIR. It uses the Liquid template engine and the templates from the **[FHIR Converter](https://github.com/microsoft/FHIR-Converter)** project as the default templates. These templates can be customized as needed. Currently it supports two types of conversion, C-CDA to FHIR and HL7v2 to FHIR conversion.

* API calls can be made to the FHIR server to convert the data into FHIR by using **https://<<FHIR service base URL>>/$convert-data**

* $convert-data operation uses a **Parameter resource** in the request body to pass these parameters:
    * **inputData** is a valid JSON string which is the data that needs to be converted
    * **inputDataType** is the data type of input, HL7v2 or Ccda 
    * **templateCollectionReference** is reference to default templates or custom templates in Azure Container Registry registered within the FHIR service.
    * **rootTemplate** is the root template to use while transforming the data.

More on the above [here](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir/convert-data)

* **Test using Postman**
    * You should have completed Postman section in [Challenge01 - Azure API for FHIR](../Challenge01-AzureAPIforFHIR/ReadMe.md) where you imported Collection and Environment
    * Open "AuthorizeGetToken SetBearer". Confirm the environment you imported is selected in the drop-down in the top right. Click the Send button. This should pass the values in the Body to AD Tenant, get the bearer token back and assign it to variable **bearerToken**. The Body results also show how many seconds the token is valid before expires_in.
    * Open "Post Convert HL7" and click the **Send** button. This will return the converted FHIR Bundle.
    * Check [here](https://docs.microsoft.com/en-us/azure/healthcare-apis/fhir/convert-data) for details on hosting templates in Azure Container Registry.

### **Open Source** using Bash or Powershell scripts
[Go to Challenge02.1 - HL7 Ingest and Convert: Ingest HL7v2 messages and convert to FHIR format - Using Bash Scripts](../Challenge02.1-HL7IngestandConvertUsingBash/ReadMe.md)

[Go to Challenge02.2 - HL7 Ingest and Convert: Ingest HL7v2 messages and convert to FHIR format - Using PowerShell Scripts](../Challenge02.2-HL7IngestandConvertUsingPS/ReadMe.md)

## Congratulations! You have successfully completed Challenge02!

---

Break (15 minutes)

---

## Help, I'm Stuck!


***

[Go to Challenge03 - Export and Anonymize: Bulk export data from Azure API for FHIR and deidentify the data](../Challenge03-ExportandAnonymizeData/ReadMe.md)
