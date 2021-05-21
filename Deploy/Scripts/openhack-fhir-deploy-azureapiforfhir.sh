#!/bin/bash
echo "Start openhack-fhir-azureapiforfhir deployment script."

echo "Start openhack-fhir-prereqs deployment script."
./openhack-fhir-prereqs.sh
echo "End openhack-fhir-prereqs deployment script."

echo "Start openhack-fhir-auth-config deployment script."
./openhack-fhir-auth-config.sh
echo "End openhack-fhir-auth-config deployment script."

echo "Start openhack-fhir-environment deployment script."
./openhack-fhir-environment.sh
echo "End openhack-fhir-environment deployment script."

sleep 10

