# # ECR repository for the Lambda image
# resource "aws_ecr_repository" "lambda" {
#   name                 = "myapp-lambda"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = {
#     Name = "myapp-lambda"
#   }
# }

# # Build and push the Docker image
# resource "null_resource" "docker_build" {
#   triggers = {
#     dockerfile = filesha256("${path.module}/Dockerfile")
#     source = sha256(join("", [
#       for f in fileset("${path.module}/src", "**") :
#       filesha256("${path.module}/src/${f}")
#     ]))
#   }

#   provisioner "local-exec" {
#     command = <<-EOT
#       # Log in to ECR
#       aws ecr get-login-password --region ${var.aws_region} | \
#         docker login --username AWS --password-stdin ${aws_ecr_repository.lambda.repository_url}

#       # Build the image
#       docker build -t ${aws_ecr_repository.lambda.repository_url}:latest \
#         -f ${path.module}/Dockerfile ${path.module}

#       # Push to ECR
#       docker push ${aws_ecr_repository.lambda.repository_url}:latest
#     EOT
#   }
# }

# # Lambda function from container image
# resource "aws_lambda_function" "main" {
#   function_name = "myapp-handler"
#   role          = aws_iam_role.lambda_exec.arn
#   timeout       = 300
#   memory_size   = 512

#   package_type = "Image"
#   image_uri    = "${aws_ecr_repository.lambda.repository_url}:latest"

#   depends_on = [null_resource.docker_build]

#   tags = {
#     Name = "myapp-handler"
#   }
# }