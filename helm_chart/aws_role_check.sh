#!/bin/bash

ROLE_NAME="velero_role1234"
TRUST_POLICY_FILE="trust-policy.json"
IAM_POLICY_FILE="iam-policy.json"

# Check if the IAM role exists
role_exists=$(aws iam get-role --role-name "$ROLE_NAME" 2>&1)


if [ $? -eq 0 ]; then
    echo "IAM role $ROLE_NAME already exists."
    echo "Updating Trusted  policy..."
    aws iam update-assume-role-policy --role-name "$ROLE_NAME" --policy-document file://"$TRUST_POLICY_FILE"
    if [ $? -eq 0 ]; then
        echo "Trust policy updated successfully."
    else
        echo "Failed to update trust policy."
        exit 1
    fi
    echo "Updating IAM  policy..."
    aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "YourPolicyName" --policy-document file://"$IAM_POLICY_FILE"
    if [ $? -eq 0 ]; then
        echo "IAM policy updated successfully."
    else
        echo "Failed to update IAM policy."
        exit 1
    fi
else
    echo "IAM role $ROLE_NAME does not exist. Creating..."
    aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document file://"$TRUST_POLICY_FILE"
    if [ $? -eq 0 ]; then
        echo "IAM role $ROLE_NAME created successfully."
        aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "YourPolicyName" --policy-document file://"$IAM_POLICY_FILE"

        if [ $? -eq 0 ]; then
            echo "IAM policy attached successfully."
        else
            echo "Failed to attach IAM policy."
            exit 1
        fi
    else
        echo "Failed to create IAM role $ROLE_NAME."
        exit 1
    fi
fi
