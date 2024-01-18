#!/bin/bash

# Set environment variables
CLUSTER=$1
ENV_NAME=$2
APP=$3
COMMAND=$4
NAMESPACE=$5
ENABLE_CHECKS=${6:-true}  # Default value for ENABLE_CHECKS is true

# Auth to Cluster
echo "Stage 1: Authenticating to Cluster"
CLUSTER_AUTH=$(aws eks update-kubeconfig --name "${CLUSTER}" --kubeconfig "${CLUSTER}.cfg")
ls -lh "${CLUSTER}.cfg"
if [ $? -eq 0 ]; then
  echo "INFO: Generated KubeConfig"
else
  echo "ERROR: Failed to Authenticate to Cluster"
  exit 1
fi

# Current Health
echo "Stage 2: Checking Current Health"
DEPLOYMENT_HEALTH=$(helmfile -e "${ENV_NAME}" --kube-context "${CLUSTER}" --selector "name=${APP}" status | sed -n -e 's/^.*STATUS: //p' | tr -d '[:space:]')
echo "${DEPLOYMENT_HEALTH}"
if [ "${DEPLOYMENT_HEALTH}" == 'deployed' ]; then
  echo "INFO: Helm Deployment is OK"
else
  if [ "${ENABLE_CHECKS}" == "true" ]; then
    echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Current Helm State is Bad"
    exit 1
  else
    echo "INFO: ENABLE CHECKS is false - so we are proceeding despite deployment state"
  fi
fi

# Template Deployment
echo "Stage 3: Generating Template"
TEMPLATE_DEPLOYMENT=$(helmfile -e "${ENV_NAME}" --kube-context "${CLUSTER}" --selector "name=${APP}" template > template.json)
if [ $? -eq 0 ]; then
  echo "INFO: Template Created"
else
  echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Failed to Generate Template"
  exit 1
fi

# Validate Template
echo "Stage 4: Validating Template"
VALIDATED=$(kubeval --ignore-missing-schemas template.json)
if [ $? -eq 0 ]; then
  echo "INFO: Template Validated"
else
  echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Kubeval Validation Failed"
  exit 1
fi
rm template.json

# Uncomment and customize the following sections based on your requirements

# # Diff Template
# echo "Stage 5: Diffing Template"
# APP_DIFF=$(helmfile -e "${ENV_NAME}" --kube-context "${CLUSTER}" --selector "name=${APP}" diff)
# echo "${APP_DIFF}"

# # Upgrade Deployment
# echo "Stage 6: Upgrading Deployment"
# HELM_UPGRADE=$(helmfile -e "${ENV_NAME}" --kube-context "${CLUSTER}" --selector "name=${APP}" "${COMMAND}")
# echo "${HELM_UPGRADE}"
# if [ $? -eq 0 ]; then
#   echo "INFO: Helm ${COMMAND} Completed"
# else
#   echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Helm ${COMMAND} Failed"
#   exit 1
# fi

# # Verify Upgrade
# echo "Stage 7: Verifying Upgrade"
# timeout 8s bash -c
