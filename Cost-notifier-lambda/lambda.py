import json
import boto3
from datetime import datetime, timedelta

def get_billing_data():
    client = boto3.client('ce')  # Cost Explorer client
    today = datetime.today()
    start_date = today.replace(day=1).strftime('%Y-%m-%d')
    end_date = (today + timedelta(days=1)).strftime('%Y-%m-%d')

    response = client.get_cost_and_usage(
        TimePeriod={
            'Start': start_date,
            'End': end_date
        },
        Granularity='DAILY',
        Metrics=['UnblendedCost'],
        GroupBy=[
            {
                'Type': 'DIMENSION',
                'Key': 'LINKED_ACCOUNT'
            },
            {
                'Type': 'DIMENSION',
                'Key': 'SERVICE'
            }
        ]
    )

    account_costs = {}
    for result in response['ResultsByTime']:
        for group in result['Groups']:
            account_id = group['Keys'][0]
            service = group['Keys'][1]
            amount = float(group['Metrics']['UnblendedCost']['Amount'])
            if account_id not in account_costs:
                account_costs[account_id] = {}
            if service in account_costs[account_id]:
                account_costs[account_id][service] += amount
            else:
                account_costs[account_id][service] = amount

    return account_costs, today

def send_email(account_costs, today):
    ses_client = boto3.client('ses')
    email_from = 'do-not-reply@aws.example.com'
    email_to = 'devops@example.com'
    date_str = today.strftime('%Y-%m-%d')
    subject = f'Daily AWS Cost Report - {date_str}'

    body = f"""
    <html>
    <head>
        <style>
            body {{
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
                background-color: #f4f4f4;
            }}
            .container {{
                width: 100%;
                margin: 0 auto;
                padding: 20px;
                background-color: #fff;
            }}
            .header {{
                background-color: #333;
                color: #fff;
                padding: 10px;
                text-align: center;
            }}
            .cost {{
                font-size: 2em;
                color: #333;
                text-align: center;
                margin: 20px 0;
            }}
            table {{
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
            }}
            th, td {{
                padding: 10px;
                border: 1px solid #ddd;
                text-align: left;
            }}
            th {{
                background-color: #333;
                color: #fff;
            }}
            tr:nth-child(even) {{
                background-color: #f4f4f4;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Daily AWS Cost Report - {date_str}</h1>
            </div>
            <div class="cost">
                The total AWS cost for the current month up to today ({date_str}) is:
            </div>
    """

    total_cost = 0
    for account, services in account_costs.items():
        sorted_services = sorted(services.items(), key=lambda x: x[1], reverse=True)
        body += f"""
            <h2>Account {account}</h2>
            <table>
                <tr>
                    <th>Service</th>
                    <th>Cost</th>
                </tr>
        """
        account_total_cost = 0
        for service, cost in sorted_services:
            body += f"""
                <tr>
                    <td>{service}</td>
                    <td>${cost:.2f}</td>
                </tr>
            """
            account_total_cost += cost
        body += f"""
            </table>
            <div class="cost">
                <strong>Total cost for account {account}: ${account_total_cost:.2f}</strong>
            </div>
        """
        total_cost += account_total_cost

    body += f"""
            <div class="cost">
                <h2>Summary</h2>
    """
    for account, services in account_costs.items():
        account_total_cost = sum(services.values())
        body += f"""
                <p>Account {account}: ${account_total_cost:.2f}</p>
        """
    body += f"""
                <p><strong>Total cost: ${total_cost:.2f}</strong></p>
            </div>
        </div>
    </body>
    </html>
    """

    response = ses_client.send_email(
        Source=email_from,
        Destination={
            'ToAddresses': [email_to]
        },
        Message={
            'Subject': {
                'Data': subject
            },
            'Body': {
                'Html': {
                    'Data': body
                }
            }
        }
    )

def lambda_handler(event, context):
    account_costs, today = get_billing_data()
    send_email(account_costs, today)
    return {
        'statusCode': 200,
        'body': json.dumps('Email sent successfully!')
    }
