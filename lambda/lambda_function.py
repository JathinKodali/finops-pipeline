import boto3
import datetime
import os

ec2 = boto3.client('ec2')
cloudwatch = boto3.client('cloudwatch')
sns = boto3.client('sns')

SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

def lambda_handler(event, context):
    instances = ec2.describe_instances()

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']

            metrics = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                StartTime=datetime.datetime.utcnow() - datetime.timedelta(days=1),
                EndTime=datetime.datetime.utcnow(),
                Period=86400,
                Statistics=['Average']
            )

            if metrics['Datapoints']:
                avg_cpu = metrics['Datapoints'][0]['Average']

                if avg_cpu < 5:
                    message = f"Idle EC2 detected: {instance_id} CPU={avg_cpu}"

                    sns.publish(
                        TopicArn=SNS_TOPIC_ARN,
                        Message=message,
                        Subject="FinOps Alert"
                    )

                    print(message)