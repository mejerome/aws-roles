#!/bin/bash

# Here is a sample bash script that uses AWS profiles to compare the permissions between two roles 
# with multiple policies in different AWS accounts:

# Define the AWS profiles for each account
profile1="PROFILE_1"
profile2="PROFILE_2"

# Define the role names in each account
role_name1="ROLE_NAME_1"
role_name2="ROLE_NAME_2"

# Get the policy names for each role in each account
role_policies1=$(aws --profile $profile1 iam list-role-policies --role-name $role_name1 --output text)
role_policies2=$(aws --profile $profile2 iam list-role-policies --role-name $role_name2 --output text)

# Split the policy names into arrays
IFS=$'\n' read -r -a policies1 <<< "$role_policies1"
IFS=$'\n' read -r -a policies2 <<< "$role_policies2"

# Store the policy documents for each role in each account
declare -A role_policy_docs1
declare -A role_policy_docs2

# Get the policy document for each policy in each role in each account
for policy_name in "${policies1[@]}"; do
    role_policy_docs1[$policy_name]=$(aws --profile $profile1 iam get-role-policy --role-name $role_name1 --policy-name $policy_name --output text)
done

for policy_name in "${policies2[@]}"; do
    role_policy_docs2[$policy_name]=$(aws --profile $profile2 iam get-role-policy --role-name $role_name2 --policy-name $policy_name --output text)
done

# Compare the policy documents
policy_match=true

for policy_name in "${policies1[@]}"; do
    if [[ ! "${role_policy_docs2[$policy_name]+isset}" ]]; then
        echo "Policy $policy_name is not present in $role_name2"
        policy_match=false
    elif [[ "${role_policy_docs1[$policy_name]}" != "${role_policy_docs2[$policy_name]}" ]]; then
        echo "The policy for $policy_name in $role_name1 and $role_name2 are different."
        policy_match=false
    fi
done

for policy_name in "${policies2[@]}"; do
    if [[ ! "${role_policy_docs1[$policy_name]+isset}" ]]; then
        echo "Policy $policy_name is not present in $role_name1"
        policy_match=false
    fi
done

if $policy_match; then
    echo "The policies for $role_name1 and $role_name2 match."
fi
