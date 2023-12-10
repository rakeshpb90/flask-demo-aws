#!/bin/bash

# Set environment variables
CLUSTER=$1
ENV_NAME=$2
APP=$3
COMMAND=$4
NAMESPACE=$5

# Auth to Cluster
CLUSTER_AUTH=$(aws eks update-kubeconfig --name ${CLUSTER} --kubeconfig ${CLUSTER}.cfg)
ls -lh ${CLUSTER}.cfg
if [ $? -eq 0 ]; then
  echo "INFO: Generated KubeConfig"
else
  echo "ERROR: Failed to Authenticate to Cluster"
fi

# Current Health
DEPLOYMENT_HEALTH=$(helmfile -e ${ENV_NAME} --kube-context ${CLUSTER} --selector name=${APP} status | sed -n -e 's/^.*STATUS: //p' | tr -d '[:space:]')
echo "${DEPLOYMENT_HEALTH}"
if [ "${DEPLOYMENT_HEALTH}" == 'deployed' ]; then
  echo "INFO: Helm Deployment is OK"
else
  if [ "${ENABLE_CHECKS}" == "true" ]; then
    echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Current Helm State is Bad"
  else
    echo "INFO: ENABLE CHECKS is false - so we are proceeding despite deployment state"
  fi
fi

# Template Deployment
TEMPLATE_DEPLOYMENT=$(helmfile -e ${ENV_NAME} --kube-context ${CLUSTER} --selector name=${APP} template > template.json)
if [ $? -eq 0 ]; then
  echo "INFO: Template Created"
else
  echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Failed to Generate Template"
fi

# Validate Template
VALIDATED=$(kubeval --ignore-missing-schemas template.json)
if [ $? -eq 0 ]; then
  echo "INFO: Template Validated"
else
  echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Kubeval Validation Failed"
  error 'ERROR: Kubeval Validation Failed'
fi
rm template.json

# # Diff Template
# APP_DIFF=$(helmfile -e ${ENV_NAME} --kube-context ${CLUSTER} --selector name=${APP} diff)
# echo "${APP_DIFF}"

# # Upgrade Deployment
# HELM_UPGRADE=$(helmfile -e ${ENV_NAME} --kube-context arn:aws:eks:us-east-1:291053455966:cluster/eks-epx-prod-blue --selector name=${APP} ${COMMAND})
# echo "${HELM_UPGRADE}"
# if [ "${HELM_UPGRADE}" -eq 0 ]; then
#   echo "INFO: Helm ${COMMAND} Completed"
# else
#   echo "ERROR: Failed to Deploy Pastry: ${IMAGE_NAME} to ENV: ${ENV_NAME} - Helm ${COMMAND} Failed"
# fi

# # Verify Upgrade
# timeout 8s bash -c 'while [[ "$(kubectl rollout status -n ${NAMESPACE}-${APP} deployment/${APP} | grep 'successfully rolled out')" == "" ]]; do sleep 1; done'

