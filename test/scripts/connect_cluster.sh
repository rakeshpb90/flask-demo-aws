#!/bin/bash

CLUSTER="your-cluster-name"
ENV_NAME="your-environment-name"

CLUSTER_AUTH=$(aws eks update-kubeconfig --name "${CLUSTER}" --kubeconfig "${CLUSTER}.cfg")

ls -lh "${CLUSTER}.cfg"

if [ $? -eq 0 ]; then
  echo "Generated KubeConfig"
else
  echo "Failed to Authenticate to Cluster"
  exit 1
fi