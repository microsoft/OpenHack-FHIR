#!/bin/bash
echo "Start openhack-fhir-azureapiforfhir deployment script."

echo "Start openhack-fhir-prereqs deployment script."
bash openhack-fhir-prereqs.sh
echo "End openhack-fhir-prereqs deployment script."

echo "Start openhack-fhir-auth-config deployment script."
bash openhack-fhir-auth-config.sh
echo "End openhack-fhir-auth-config deployment script."

echo "Start openhack-fhir-environment deployment script."
bash openhack-fhir-environment.sh
echo "End openhack-fhir-environment deployment script."

sleep 10

