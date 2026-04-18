# Warm Standby

## Overview

Active/passive disaster recovery app infrastructure deployed across two AWS regions (primary: us-east-1, secondary: eu-west-2). The apps consist of two EC2 instance Auto Scaling Groups fronted by Application Load Balancers, with an Amazon RDS for MySQL primary instance in the primary region and a Read Replica in the second. Failover is handled by Route53 and EventBridge is used in conjunction with an AWS Lambda function to promote the Read Replica in response to the failover event. AWS SSM Session Manager is used to trigger the simulated failover by stopping the Apache web server running on the instances.

## Architecture

- AWS Route53, AWS Elastic Load Balancer, AWS EC2, AWS CloudWatch, AWS EventBridge, AWS Lambda, AWS SSM, AWS RDS for MySQL, Apache HTTP Server

## Prerequisites

Terraform, user or role-based access to an AWS account (with permission to create the resources outlined above and local AWS CLI access) and an AWS-registered domain.

## Quick Start

Set the `WARM_STANDBY_DOMAIN` environment variable to your AWS registered domain. This domain will be the entry point for your multi-region web application. Deploy the platform infrastructure from the repository root and wait for completion:

```
make arch=warm-standby

make apply arch=warm-standby
```

## Local Testing

Run `make test arch=warm-standby` from the repository root to simulate the failover. Monitor your website domain in real time to view the failover (the web server will print the region in which the instance is running).

## Note

View logs from the user data script from within the EC2 instances by using session manager and running `sudo cat /var/log/cloud-init-output.log`
