#!/bin/bash

# Set the profile names for each AWS account
profile1="account1"
profile2="account2"

# Set the role names for comparison
role_name1="role1"
role_name2="role2"

# Get the policy ARNs for each role
policies1=($(aws --profile $profile1 iam list-attached-role-policies --role-name $role_name1 --output text | awk '{print $2}'))
policies2=($(aws --profile $profile2 iam list-attached-role-policies --role-name $role_name2 --output text | awk '{print $2}'))

# Get the policy documents for each role
declare -A role_policy_docs1
declare -A role_policy_docs2
for policy_arn in "${policies1[@]}"; do
    role_policy_docs1[$policy_arn]=$(aws --profile $profile1 iam get-policy --policy-arn $policy_arn --output text)
done
for policy_arn in "${policies2[@]}"; do
    role_policy_docs2[$policy_arn]=$(aws --profile $profile2 iam get-policy --policy-arn $policy_arn --output text)
done

# Get the attached policy ARNs for each role
attached_policies1=($(aws --profile $profile1 iam list-attached-role-policies --role-name $role_name1 --output text | awk '{print $2}'))
attached_policies2=($(aws --profile $profile2 iam list-attached-role-policies --role-name $role_name2 --output text | awk '{print $2}'))

# Get the attached policy documents for each role
declare -A role_attached_policy_docs1
declare -A role_attached_policy_docs2
for policy_arn in "${attached_policies1[@]}"; do
    policy_name=$(echo $policy_arn | awk '{print $2}')
    role_attached_policy_docs1[$policy_name]=$(aws --profile $profile1 iam get-policy --policy-arn $policy_arn --output text)
done
for policy_arn in "${attached_policies2[@]}"; do
    policy_name=$(echo $policy_arn | awk '{print $2}')
    role_attached_policy_docs2[$policy_name]=$(aws --profile $profile2 iam get-policy --policy-arn $policy_arn --output text)
done

# Compare the policy documents for each role
for policy_name in "${policies1[@]}"; do
    if [ -z "${role_policy_docs2[$policy_name]}" ]; then
        echo "Policy $policy_name is missing in role $role_name2"
    else
        if [ "${role_policy_docs1[$policy_name]}" != "${role_policy_docs2[$policy_name]}" ]; then
            echo
