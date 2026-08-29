# AWS Identity Detection

**Status: in progress** — CloudTrail and GuardDuty-based detection work for identity abuse in AWS.

## What this is
Detections built against CloudTrail logs and GuardDuty findings for common identity attack patterns (credential misuse, privilege escalation, anomalous API activity).

## Why I built it
Detection engineering skills should transfer across cloud providers, not just Microsoft identity — this is the AWS side of that.

## How it works
- `detections/simulate-privesc.sh` — reproduces a real IAM self-privilege-escalation sequence (create user → attach AdministratorAccess → mint access key) against LocalStack, verified working
- `detections/privesc-detection.md` — the detection query design for that pattern, written against real CloudTrail's schema, plus an honest gap note (see below)
- `evidence/` — sanitised sample findings/log excerpts

## What I learned / trade-offs
See `detections/privesc-detection.md` in full — short version: the *attack simulation* is genuinely free and reproducible via LocalStack, but LocalStack's free Community edition doesn't emit CloudTrail-format events at all, so the *detection query* is written correctly against real CloudTrail's schema without ever being fired against a live log. Documenting that gap honestly rather than testing against a fabricated sample log that would prove nothing.

## Security note
No real AWS account IDs, ARNs, or access keys are committed. All identifiers are placeholders or synthetic.

## Running a local AWS emulator for free
`local-lab/` runs LocalStack in Docker — practice real `aws` CLI/IAM/S3 workflows against a local emulator, no AWS account needed. CloudTrail emulation specifically needs LocalStack Pro (not free) — see `local-lab/README.md` for what's actually available in the free Community edition.

## One-time setup after cloning
```bash
git config core.hooksPath .githooks   # enables the gitleaks secret-scan on commit
```
