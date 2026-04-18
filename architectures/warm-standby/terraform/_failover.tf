resource "aws_cloudwatch_metric_alarm" "cloudwatch_failover_alarm" {
  provider = aws.eu_west_2

  alarm_name          = "${var.arch}-failover-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0

  dimensions = {
    LoadBalancer = module.app_us_east_1.alb_arn_suffix
    TargetGroup  = module.app_us_east_1.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_event_rule" "eventbridge_failover_event_rule" {
  provider = aws.eu_west_2

  name = "${var.arch}-failover-event-rule"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      alarmName = [aws_cloudwatch_metric_alarm.cloudwatch_failover_alarm.alarm_name]
      state = {
        value = ["ALARM"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  provider = aws.eu_west_2

  rule      = aws_cloudwatch_event_rule.eventbridge_failover_event_rule.name
  target_id = "lambda-failover"
  arn       = aws_lambda_function.failover_lambda.arn
}

data "archive_file" "failover_lambda_zip" {
  type = "zip"

  source {
    content  = <<EOF
const { RDSClient, PromoteReadReplicaCommand } = require("@aws-sdk/client-rds");

exports.handler = async (event) => {
    const region = process.env.AWS_REGION;
    const replicaId = process.env.REPLICA_ID;

    const client = new RDSClient({ region });

    try {
        const command = new PromoteReadReplicaCommand({
            DBInstanceIdentifier: replicaId
        });

        const response = await client.send(command);

        console.log("Promotion triggered:", response);

        return {
            status: "promotion triggered",
            response
        };
    } catch (error) {
        console.error("Error promoting replica:", error);
        throw error;
    }
};
EOF
    filename = "index.js"
  }

  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "failover_lambda" {
  provider = aws.eu_west_2

  function_name    = "${var.arch}-failover-lambda"
  role             = aws_iam_role.failover_lambda_role.arn
  runtime          = "nodejs22.x"
  handler          = "index.handler"
  filename         = data.archive_file.failover_lambda_zip.output_path
  source_code_hash = data.archive_file.failover_lambda_zip.output_base64sha256

  environment {
    variables = {
      REPLICA_ID = aws_db_instance.db_secondary.id
    }
  }
}

resource "aws_lambda_permission" "failover_lambda_eventbridge_permission" {
  provider = aws.eu_west_2

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.eventbridge_failover_event_rule.arn
}

resource "aws_iam_role" "failover_lambda_role" {
  provider = aws.eu_west_2

  name = "${var.arch}-failover-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "failover_lambda_policy" {
  provider = aws.eu_west_2

  name = "${var.arch}-failover-lambda-policy"
  role = aws_iam_role.failover_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:PromoteReadReplica"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}