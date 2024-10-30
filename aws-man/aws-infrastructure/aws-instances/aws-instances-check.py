import boto3

def check_running_instances():
    ec2 = boto3.client('ec2')

    # Get information about all started instances
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )

    # Check if there are running instances
    instances = response['Reservations']
    if not instances:
        print("There are not any running instances in the current AWS account.")
        return

    # Output the information about running instances
    print("Running instances:")
    for reservation in instances:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            state = instance['State']['Name']
            tags = instance.get('Tags', [])
            tag_dict = {tag['Key']: tag['Value'] for tag in tags}

            print(f"Instance ID: {instance_id}, Instance state: {state}, Tags: {tag_dict}")

if __name__ == "__main__":
    check_running_instances()
