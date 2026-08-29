# Local lab: LocalStack (open-source AWS emulator)

**Status: running, verified end-to-end on 2026-08-29** with real `aws` CLI commands (`s3 mb`, `iam create-user`) against it.

Lets you practice AWS CLI, IAM, and S3 workflows without an AWS account, real credentials, or any cost — [LocalStack](https://github.com/localstack/localstack) (Apache 2.0 core / Community edition) emulates the AWS APIs locally.

## Run it
```bash
cd local-lab
docker compose up -d
```

## Use it
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url=http://localhost:4566 s3 mb s3://my-test-bucket
aws --endpoint-url=http://localhost:4566 iam create-user --user-name test-analyst
aws --endpoint-url=http://localhost:4566 s3 ls
```
`test`/`test` are LocalStack's standard placeholder credentials — they're not real AWS keys and only work against `localhost:4566`.

## What I learned / trade-offs
**CloudTrail is not available in LocalStack's free Community edition** — it's a Pro-only feature. This means genuine CloudTrail log emulation isn't free. Community edition does give S3, IAM, STS, EC2, and CloudWatch Logs for free, which is enough to practice IAM-focused identity detections (e.g. suspicious `iam:CreateUser`/`iam:AttachUserPolicy` sequences), just not literal CloudTrail-log-shaped detections without a real (free-tier) AWS account or LocalStack Pro.

## Security note
No real AWS account, keys, or ARNs involved — everything here is synthetic, local-only, and free.
