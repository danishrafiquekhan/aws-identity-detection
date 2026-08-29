# AWS Identity Detection

**Status: in progress** — CloudTrail and GuardDuty-based detection work for identity abuse in AWS.

## What this is
Detections built against CloudTrail logs and GuardDuty findings for common identity attack patterns (credential misuse, privilege escalation, anomalous API activity).

## Why I built it
Detection engineering skills should transfer across cloud providers, not just Microsoft identity — this is the AWS side of that.

## How it works
- `detections/` — detection logic (Athena/CloudTrail queries or GuardDuty finding mappings)
- `evidence/` — sanitised sample findings/log excerpts

## What I learned / trade-offs
_(filled in as detections are added)_

## Security note
No real AWS account IDs, ARNs, or access keys are committed. All identifiers are placeholders or synthetic.

## Running a local AWS emulator for free
`local-lab/` runs LocalStack in Docker — practice real `aws` CLI/IAM/S3 workflows against a local emulator, no AWS account needed. CloudTrail emulation specifically needs LocalStack Pro (not free) — see `local-lab/README.md` for what's actually available in the free Community edition.

## One-time setup after cloning
```bash
git config core.hooksPath .githooks   # enables the gitleaks secret-scan on commit
```
