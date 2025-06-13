import boto3
import json
import logging
from datetime import datetime, timedelta

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
# Set format to include function name and line number
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s')
for handler in logger.handlers:
    handler.setFormatter(formatter)

ACCOUNT_ID = '111111111111'
DEFAULT_REGION = 'ap-south-1'
SENDER_EMAIL = "sender@example.com"  # Replace with your SES verified email
RECIPIENT_EMAIL = "recipient@exampe.com"  # Replace with recipient email

# Convert friendly region names to region codes
REGION_MAPPING = {
    'EU (Ireland)': 'eu-west-1',
    'US East (N. Virginia)': 'us-east-1',
    'US West (Oregon)': 'us-west-2',
    'Asia Pacific (Mumbai)': 'ap-south-1'
}

def get_client(client_name : str, account_id, region):
    """
    Get EC2 client for either same account or cross-account operations.
    """
    if account_id != ACCOUNT_ID:
        # For cross-account operations, assume role
        sts = boto3.client('sts')
        assumed_role = sts.assume_role(
            RoleArn=f'arn:aws:iam::{account_id}:role/EC2RebootRole',
            RoleSessionName='CrossAccountEC2Reboot'
        )
        logger.info("Authenticated with account %s", account_id)
        
        # Create session with assumed role
        client = boto3.client(
            client_name,
            aws_access_key_id=assumed_role['Credentials']['AccessKeyId'],
            aws_secret_access_key=assumed_role['Credentials']['SecretAccessKey'],
            aws_session_token=assumed_role['Credentials']['SessionToken'],
            region_name=region
        )
        return client
    return boto3.client(client_name, region_name=region)

def get_instance_name(instance):
    """
    Extract instance name from EC2 instance tags.
    """
    for tag in instance.get('Tags', []):
        if tag['Key'] == 'Name':
            return tag['Value']
    return None

def send_reboot_notification(instance_id, account_id, region, instance_name=None):
    """
    Send an email notification using SES about the instance reboot.
    """
    ses = boto3.client('ses', region_name=DEFAULT_REGION)
    # Convert to UTC+5:30
    current_time = (datetime.utcnow() + timedelta(hours=5, minutes=30)).strftime("%Y-%m-%d %H:%M:%S")
    
    # Create the HTML email content
    html_content = f"""
    <html>
    <head>
        <style>
            body {{ font-family: Arial, sans-serif; }}
            .container {{ padding: 20px; }}
            .success {{ color: #28a745; }}
            .info {{ margin: 20px 0; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h2>EC2 Instance Reboot Notification</h2>
            <p class="success">✅ Instance Successfully Rebooted</p>
            <div class="info">
                <p><strong>Instance ID:</strong> {instance_id}</p>
                <p><strong>Instance Name:</strong> {instance_name or 'N/A'}</p>
                <p><strong>AWS Account:</strong> {account_id}</p>
                <p><strong>Region:</strong> {region}</p>
                <p><strong>Reboot Time (UTC+5:30):</strong> {current_time}</p>
            </div>
            <p>This is an automated notification from your EC2 reboot Lambda function.</p>
        </div>
    </body>
    </html>
    """
    
    try:
        ses.send_email(
            Source=SENDER_EMAIL,
            Destination={
                'ToAddresses': [RECIPIENT_EMAIL]
            },
            Message={
                'Subject': {
                    'Data': f'EC2 Instance {instance_id} Reboot Notification'
                },
                'Body': {
                    'Html': {
                        'Data': html_content
                    }
                }
            }
        )
        logger.info(f"Reboot notification email sent successfully for instance {instance_id}")
        return True
    except Exception as e:
        logger.error(f"Error sending email notification: {str(e)}", exc_info=True)
        return False

# Helper function to create and log response
def create_response(status_code, message):
    response = {'statusCode': status_code, 'body': message}
    logger.info("Response: %s", json.dumps(response))
    return response


def find_unhealthy_instances(target_group, account_id, region):
    """
    Find unhealthy instances in a target group.
    Returns: tuple of (instance_id, instance_name, ec2_client) or (None, None, None) if no unhealthy instances found
    """
    try:
        # Get target health and find unhealthy instances
        elbv2 = get_client('elbv2', account_id, region)
        ec2 = get_client('ec2', account_id, region)
        
        target_health = elbv2.describe_target_health(
            TargetGroupArn=f"arn:aws:elasticloadbalancing:{region}:{account_id}:{target_group}"
        )
        logger.info("Target health response: %s", json.dumps(target_health))
        
        # Find unhealthy instances more efficiently
        unhealthy_instances = []
        ip_targets = []
        
        for target in target_health['TargetHealthDescriptions']:
            if target['TargetHealth']['State'] != 'healthy':
                target_id = target['Target']['Id']
                if target_id.startswith('i-'):
                    unhealthy_instances.append(target_id)
                else:
                    ip_targets.append(target_id)
        
        # Batch lookup IPs if any exist
        if ip_targets:
            try:
                instances = ec2.describe_instances(
                    Filters=[{'Name': 'private-ip-address', 'Values': ip_targets}]
                )
                
                for reservation in instances.get('Reservations', []):
                    for instance in reservation.get('Instances', []):
                        unhealthy_instances.append(instance['InstanceId'])
                        logger.info("Found instance %s for IP %s", instance['InstanceId'], instance['PrivateIpAddress'])
            except Exception as e:
                logger.error("Error looking up instances by IP: %s", str(e), exc_info=True)
        
        if not unhealthy_instances:
            logger.info("No unhealthy instances found in target group : %s", target_group)
            return None, None, None
        
        # Set the first unhealthy instance as our target
        instance_id = unhealthy_instances[0]
        logger.info("Found unhealthy instance: %s", instance_id)

        # verify instance exists
        instance_check = ec2.describe_instances(InstanceIds=[instance_id])
        if not instance_check.get('Reservations'):
            logger.error("Instance %s not found in account %s, region %s", instance_id, account_id, region)
            return None, None, None

        # Get instance name from tags
        instance = instance_check['Reservations'][0]['Instances'][0]
        instance_name = get_instance_name(instance)

        return instance_id, instance_name, ec2
    except Exception as e:
        logger.error("Error in find_unhealthy_instances: %s", str(e), exc_info=True)
        return None, None, None


def lambda_handler(event, context):
    """
    Lambda function to reboot an EC2 instance, with cross-account support.
    Can be triggered directly by CloudWatch alarm.
    """
    logger.info("Received event: %s", json.dumps(event))
    
    # Process SNS event
    if 'Records' in event and len(event['Records']) > 0 and event['Records'][0].get('EventSource') == 'aws:sns':
        try:
            sns_message = json.loads(event['Records'][0]['Sns']['Message'])
            alarm_name = sns_message['AlarmName']
            alarm_state = sns_message['NewStateValue']
            logger.info("Processing SNS alarm notification: %s, state: %s", alarm_name, alarm_state)
            
            # Only proceed if the alarm is in ALARM state
            if alarm_state != 'ALARM':
                return create_response(200, f'Alarm {alarm_name} is in {alarm_state} state, no action needed')
            
            # Extract target group info from dimensions
            dimensions = sns_message['Trigger']['Dimensions']
            target_group = None
            for dimension in dimensions:
                if dimension['name'].lower() == 'targetgroup':
                    target_group = dimension['value']
                    break
                    
            if not target_group:
                return create_response(400, 'No target group found in alarm data')
            
            logger.info("Found target group: %s", target_group)
            
            # Get account ID and region from SNS message
            account_id = sns_message['AWSAccountId']
            region = sns_message['Region']

            region = REGION_MAPPING.get(region, region)  # Use mapping if exists, otherwise use as is

            if not account_id:
                return create_response(400, 'Invalid account ID in SNS message')

            instance_id, instance_name, ec2_client = find_unhealthy_instances(target_group, account_id, region)
            if instance_id is None:
                return create_response(400, f'No unhealthy EC2 instances found in target group : {target_group}')

        except Exception as e:
            return create_response(400, f'Error processing SNS event data: {str(e)}')
            
    # Process direct CloudWatch alarm event
    elif 'alarmData' in event:
        alarm_name = event['alarmData']['alarmName']
        alarm_state = event['alarmData']['state']['value']
        logger.info("Processing CloudWatch alarm: %s, state: %s", alarm_name, alarm_state)
        
        # Only proceed if the alarm is in ALARM state
        if alarm_state != 'ALARM':
            return create_response(200, f'Alarm {alarm_name} is in {alarm_state} state, no action needed')
        
        try:
            # Extract target group info
            dimensions = event['alarmData']['configuration']['metrics'][0]['metricStat']['metric']['dimensions']
            target_group = dimensions.get('TargetGroup')
            if not target_group:
                return create_response(400, 'No target group found in alarm data')
            
            logger.info("Found target group: %s", target_group)
            
            # Get account ID and region
            account_id = event.get('accountId')
            region = event.get('region', DEFAULT_REGION)

            instance_id, instance_name, ec2_client = find_unhealthy_instances(target_group, account_id, region)
            if instance_id is None:
                return create_response(400, f'No unhealthy EC2 instances found in target group : {target_group}')
            
        except Exception as e:
            return create_response(400, f'Error processing alarm data: {str(e)}')

    # TODO: Implement standalone instance reboot functionality
    # else:
    #     # Direct invocation with parameters
    #     instance_id = event.get('instance_id')
    #     account_id = event.get('account_id')
    #     region = event.get('region', DEFAULT_REGION)
    
    # if not instance_id:
    #     return create_response(400, 'Missing instance_id parameter')
    
    try:

        # Log reboot action
        account_context = f" in account {account_id}, region {region}" if account_id != ACCOUNT_ID else f" in same account (region: {region})"
        logger.info(f"Rebooting instance {instance_id} (Name: {instance_name or 'N/A'}){account_context}")
        
        # Reboot the instance
        ec2_client.reboot_instances(InstanceIds=[instance_id])
        
        # Send email notification
        email_sent = send_reboot_notification(instance_id, account_id or ACCOUNT_ID, region, instance_name)
        success_msg = f'Successfully initiated reboot for instance {instance_id} (Name: {instance_name or "N/A"})'
        if email_sent:
            success_msg += ' and sent notification email'
        else:
            success_msg += ' but failed to send notification email'
        
        return create_response(200, success_msg)
        
    except Exception as e:
        return create_response(500, f'Error rebooting instance: {str(e)}')