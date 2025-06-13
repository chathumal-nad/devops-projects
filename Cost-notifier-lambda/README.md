## IAM Role permissions for lambda

- AmazonSESFullAccess
- AWSLambdaBasicExecutionRole
- getcostusage ( customer inline)

## Amazon SES configuration

Need to verify the email domain (email sending domain) and the email address ( email receiver)

- Add necessary DNS records
- verify the receiving email

Ex:

| Identity            | Identity type | Identity status |
|---------------------|---------------|-----------------|
| aws.example.com   | Domain        | Verified        |
| devops@example.com | Email address | Verified        |

## Amazon Eventbridge Scheduler

**Set the following cron expression**

| 30   | 8  | ? | *  | MON-FRI | *   |
|------|----|---|----|---------|-----|
| Minutes | Hours | Day of month | Month | Day of week | Year |


Cron expression for scheduling an event on EventBridge to run daily at 8:30 AM, except on Saturdays and Sundays:

```
cron(30 8 ? * MON-FRI *)
```

Explanation:
- `30` - Minute (30th minute)
- `8` - Hour (8 AM)
- `?` - Day of the month (no specific day)
- `*` - Month (every month)
- `MON-FRI` - Day of the week (Monday to Friday)
- `*` - Year (every year)

This expression will trigger the event every weekday at 8:30 AM.


**Execution IAM role will be created automatically with the following permission**

Sample Role Name : `
Amazon_EventBridge_Scheduler_LAMBDA_<lambda_name>`

Inline Policy: `event_bridge_scheduler_policy.json`