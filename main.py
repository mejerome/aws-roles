import boto3

# Set up the AWS client for IAM
iam_client1 = boto3.client('iam', aws_access_key_id='ACCESS_KEY_1',
                         aws_secret_access_key='SECRET_KEY_1',
                         region_name='REGION_1')

iam_client2 = boto3.client('iam', aws_access_key_id='ACCESS_KEY_2',
                         aws_secret_access_key='SECRET_KEY_2',
                         region_name='REGION_2')

# Define the role names in each account
role_name1 = "ROLE_NAME_1"
role_name2 = "ROLE_NAME_2"

# Get the policy names for each role
role_policies1 = iam_client1.list_role_policies(RoleName=role_name1)
role_policies2 = iam_client2.list_role_policies(RoleName=role_name2)

# Store the policy documents for each role
role_policy_docs1 = {}
role_policy_docs2 = {}

# Get the policy document for each policy in each role
for policy_name in role_policies1['PolicyNames']:
    role_policy_docs1[policy_name] = iam_client1.get_role_policy(RoleName=role_name1, PolicyName=policy_name)['PolicyDocument']

for policy_name in role_policies2['PolicyNames']:
    role_policy_docs2[policy_name] = iam_client2.get_role_policy(RoleName=role_name2, PolicyName=policy_name)['PolicyDocument']

# Compare the policy documents
policy_match = True

for policy_name in role_policies1['PolicyNames']:
    if policy_name not in role_policy_docs2:
        print(f"Policy {policy_name} is not present in {role_name2}")
        policy_match = False
    elif role_policy_docs1[policy_name] != role_policy_docs2[policy_name]:
        print(f"The policy for {policy_name} in {role_name1} and {role_name2} are different.")
        policy_match = False

for policy_name in role_policies2['PolicyNames']:
    if policy_name not in role_policy_docs1:
        print(f"Policy {policy_name} is not present in {role_name1}")
        policy_match = False

if policy_match:
    print(f"All policies for {role_name1} and {role_name2} match.")
