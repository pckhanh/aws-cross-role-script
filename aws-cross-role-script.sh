#!/bin/sh
#################################################
# Author: Khanh Pham                            #
# Date: 27 May 2020                             #
#################################################

### Installation required packages #####
# - aws-cli
# - jq

### Functions
check_cmd() {
    ## Check aws-cli command
    which aws >/dev/null;
    if [ $? -eq 1 ]; then
        echo "!!! Need to install aws-cli command"
        echo "https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html"
        exit 1
    fi
    which jq >/dev/null;
    ## Check JSON Processor command
    if [ $? -eq 1 ]; then
        echo "!!! Need to install jq command"
        echo "https://stedolan.github.io/jq/download/"
        exit 1
    fi
}
######################### Main Script ####################
### Check Parameter ###
if [ $# -lt 4 ]; then
    echo "Usage: $0 SOURCE_PROFILE_NAME TARGET_ACCOUNT_ID CROSS_ACCOUNT_ROLE TARGET_PROFILE_NAME\n"
    exit 1
fi
### Check required commands
check_cmd

### Variables
SourceProfileName=$1
RoleARN="arn:aws:iam::$2:role/$3"
TargetProfileName=$4
RoleSessionName="$TargetProfileName-CLI"
check_source_identity=`aws sts get-caller-identity --profile $SourceProfileName`

### Check Source Profile Name
if [ "$check_source_identity" == "" ]; then
    echo "\n!!! You must login to main AWS account before crossing role !!!\n"
    exit 1
fi

### Print Source Identity
echo "==================================== Your Source Account Identity =================================="
echo "\n AccountID = "$(echo $check_source_identity | jq -r .Account)
echo "\n User = "$(echo $check_source_identity | jq -r .UserId | awk -F: '{print $2}')
echo "\n Role = "$(echo $check_source_identity | jq -r .Arn | awk -F: '{print $6}' | awk -F/ '{print $2}')
echo "\n ProfileName = $SourceProfileName"
echo "====================================================================================================\n\n"

### Cross-Role
sts_assume=`aws sts assume-role --role-arn "$RoleARN" --role-session-name "$RoleSessionName" --profile "$SourceProfileName"`
### Check Cross-Role
if [ "$sts_assume" == "" ]; then
    echo "\n!!! Can't assume role into to target account !!!\n"
    exit 1
fi

### Configure AWS profile for Target Account
KEY_ID=$(echo $sts_assume | jq -r .Credentials.AccessKeyId)
ACCESS_KEY=$(echo $sts_assume | jq -r .Credentials.SecretAccessKey)
TOKEN=$(echo $sts_assume | jq -r .Credentials.SessionToken)
aws configure set aws_access_key_id $KEY_ID --profile $TargetProfileName
aws configure set aws_secret_access_key $ACCESS_KEY --profile $TargetProfileName
aws configure set aws_session_token $TOKEN --profile $TargetProfileName

check_target_identity=`aws sts get-caller-identity --profile $TargetProfileName`
### Print Target Identity
echo "================================= Your Target Cross-Account Identity ==============================="
echo "\n Cross-AccountID = "$(echo $check_target_identity | jq -r .Account)
echo "\n Cross-SessionName = "$(echo $check_target_identity | jq -r .UserId | awk -F: '{print $2}')
echo "\n Cross-Role = "$(echo $check_target_identity | jq -r .Arn | awk -F: '{print $6}' | awk -F/ '{print $2}')
echo "\n Cross-ProfileName = $TargetProfileName"
echo "====================================================================================================\n"

### Eg for testing TargetProfileName
echo "Eg: aws s3 ls --profile $TargetProfileName\n"
