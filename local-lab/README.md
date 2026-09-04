**LocalStack**

Lets me run real `aws` CLI commands against something that behaves like AWS, without an AWS account or any cost. LocalStack (Apache 2.0 core, Community edition here) emulates the actual APIs.

**Running it**
```bash
cd local-lab
docker compose up -d
```

**Using it**
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url=http://localhost:4566 s3 mb s3://my-test-bucket
aws --endpoint-url=http://localhost:4566 iam create-user --user-name test-analyst
aws --endpoint-url=http://localhost:4566 s3 ls
```
`test`/`test` aren't real credentials — they're LocalStack's documented placeholders and only mean anything against localhost:4566.

**The limitation that actually matters here**
CloudTrail isn't in the free Community edition — it's a Pro feature. Found that out after I'd already planned this repo around CloudTrail-based detections. What you do get for free: S3, IAM, STS, EC2, CloudWatch Logs — enough to actually run IAM-focused attack patterns (see `../detections/simulate-privesc.sh`), just not enough to generate the CloudTrail log shape a real detection query would run against.

Everything here is synthetic and local. No real AWS account touched, ever.
