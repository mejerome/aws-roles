#!/bin/bash

# Set the profile names for each AWS account
profile1="account1"
profile2="account2"

# Set the role names for comparison
role_name1="role1"
role_name2="role2"

# Get the managed policy ARNs for each role
policies1=($(aws --profile $profile1 iam list-attached-role-policies --role-name $role_name1 --output text | awk '{print $2}'))
policies2=($(aws --profile $profile2 iam list-attached-role-policies --role-name $role_name2 --output text | awk '{print $2}'))

# Get the managed policy documents for each role
declare -A role_policy_docs1
declare -A role_policy_docs2
for policy_arn in "${policies1[@]}"; do
    role_policy_docs1[$policy_arn]=$(aws --profile $profile1 iam get-policy --policy-arn $policy_arn --output text)
done
for policy_arn in "${policies2[@]}"; do
    role_policy_docs2[$policy_arn]=$(aws --profile $profile2 iam get-policy --policy-arn $policy_arn --output text)
done

# Compare the managed policy documents for each role
for policy_arn in "${!role_policy_docs1[@]}"; do
    if [ -z "${role_policy_docs2[$policy_arn]}" ]; then
        echo "Managed policy $policy_arn is missing in role $role_name2"
    else
        if [ "${role_policy_docs1[$policy_arn]}" != "${role_policy_docs2[$policy_arn]}" ]; then
            echo "Managed policy $policy_arn differs between roles $role_name1 and $role_name2"
        fi
    fi
done

# Compare the managed policy permissions for each role
for policy_arn in "${!role_policy_docs1[@]}"; do
    if [ -z "${role_policy_docs2[$policy_arn]}" ]; then
        echo "Managed policy $policy_arn is missing in role $role_name2"
    else
        policy_doc1=$(echo "${role_policy_docs1[$policy_arn]}" | jq '.Policy.Statement')
        policy_doc2=$(echo "${role_policy_docs2[$policy_arn]}" | jq '.Policy.Statement')

        if [ "$policy_doc1" != "$policy_doc2" ]; then
            echo "Permissions in managed policy $policy_arn differ between roles $role_name1 and $role_name2"
        fi
    fi
done
