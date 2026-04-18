use SSM document to shut down instance

https://stackoverflow.com/questions/39897833/how-to-link-an-aws-cloudwatch-alarm-to-an-aws-route53-health-check-using-terrafo

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-actions-Lambda.html

{
"Version":"2012-10-17",
"Id": "default",
"Statement": [{
"Sid": "AlarmAction",
"Effect": "Allow",
"Principal": {
"Service": "lambda.alarms.cloudwatch.amazonaws.com"
},
"Action": "lambda:InvokeFunction",
"Resource": "arn:aws:lambda:us-east-1:444455556666:function:function-name",
"Condition": {
"StringEquals": {
"AWS:SourceAccount": "111122223333"
}
}
}]
}

/var/log/cloud-init-output.log
