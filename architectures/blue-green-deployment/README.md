lambda develop --> AWS Runtime Interface Emulator --> test --> ECR --> lambda hosted

## https://gallery.ecr.aws/lambda/nodejs

<!-- https://docs.aws.amazon.com/lambda/latest/dg/typescript-image.html -->

docker buildx build --platform linux/amd64 --provenance=false -t lambda-ts:test .
docker run --platform linux/amd64 -p 9000:8080 lambda-ts:test
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

- codepipeline --> unit test --> integration test (build image and run with docker, invoke via rie endpoint and assert response)

---

- allows you to debug faulty deployment stack without simply overwriting it with a stable version
- test deployed release candidate before shifting DNS
- zero downtime
- weighted target group forwarder rules

- layered resilience
- code deploy alias shifting for safe rollout (10 minute back and alarm)
- post-release event bridge on alarm triggers ALB TG alias shift

---

https://oneuptime.com/blog/post/2026-02-23-how-to-build-a-ci-cd-infrastructure-with-terraform/view

https://dev.to/aws-builders/deploying-terraform-code-via-aws-codebuild-and-aws-codepipeline-2l0

https://www.tecracer.com/blog/2023/05/build-terraform-ci/cd-pipelines-using-aws-codepipeline.html

https://oneuptime.com/blog/post/2026-02-23-package-lambda-code-with-terraform/view#:~:text=There%20are%20multiple%20ways%20to,deployment%20for%20CI%2FCD%20pipelines.

git remote add origin https://git-codecommit.us-east-2.amazonaws.com/v1/repos/MyDemoRepo

git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
AWS_PROFILE="048408301264_AdministratorAccess" git push -u origin main

git remote set-url origin --push --add https://git-codecommit.us-east-1.amazonaws.com/v1/repos/blue-green-deployment-repo

https://repost.aws/questions/QUmBq_nac-Qh2rUF7Tn94JXw/how-to-trigger-aws-code-pipeline-on-any-branch-with-specific-tag

app delivery pipeline (test, build, deploy)

https://oneuptime.com/blog/post/2026-02-12-codedeploy-lambda-deployments/view

https://docs.aws.amazon.com/codedeploy/latest/userguide/tutorial-lambda-sam.html
