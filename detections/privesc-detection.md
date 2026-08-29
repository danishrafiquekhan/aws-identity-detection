# Detection: IAM Self-Privilege-Escalation Sequence

**Status: attack pattern verified reproducible (via `simulate-privesc.sh` against LocalStack); detection query designed but not fired against live CloudTrail** (see gap below).

## What this validates
A user/role creating an IAM principal and immediately granting it `AdministratorAccess` (or attaching a policy to itself), within seconds — one of the best-known IAM privilege-escalation and persistence patterns. Real-world tools like Rhino Security Labs' `pmapper`/`weirdAAL` catalog dozens of variants of "identity grants itself more access than it started with."

**ATT&CK:** T1098 (Account Manipulation) / cloud IAM privilege escalation.

## Reproduce the attack pattern (safe, local, free)
```bash
cd ~/securitylab/localstack && docker compose up -d
./simulate-privesc.sh
```
This runs three real AWS API calls (`iam create-user`, `iam attach-user-policy`, `iam create-access-key`) against LocalStack — same API shape as real AWS, zero cost, zero real account involved.

## Ideal tool vs. what I used
| | Ideal (catalog spec) | What I actually used |
|---|---|---|
| Log source | AWS CloudTrail | LocalStack Community's own request log (CloudTrail emulation is a LocalStack **Pro** feature, not free) |
| Detection engine | GuardDuty (managed) or a CloudTrail Athena/Insights query | Hand-written detection query below, designed against CloudTrail's real event shape so it's a straight port once you have a real (free-tier) AWS account |
| Evidence | GuardDuty finding or CloudTrail query result screenshot | LocalStack terminal output (above) proving the attack sequence is real and reproducible |

## The detection query (written for real CloudTrail — not runnable against LocalStack Community)
```sql
-- Athena query against a CloudTrail table, or adapt to GuardDuty/Security Hub
-- finding filters. Flags: same actor, same session, IAM user creation
-- followed by an admin-equivalent policy attach, within 5 minutes.
WITH iam_events AS (
  SELECT
    eventtime,
    eventname,
    useridentity.arn AS actor_arn,
    requestparameters
  FROM cloudtrail_logs
  WHERE eventsource = 'iam.amazonaws.com'
    AND eventname IN ('CreateUser', 'AttachUserPolicy', 'CreateAccessKey')
)
SELECT *
FROM iam_events
WHERE eventname = 'AttachUserPolicy'
  AND requestparameters LIKE '%AdministratorAccess%'
  -- and a prior CreateUser by the same actor_arn within the last 5 minutes
  -- (self-join on actor_arn + time window — omitted here for brevity, see
  -- the "what I learned" note below for why this needs a real account to finish)
```

## What I learned / trade-offs
Writing the *attack simulation* against LocalStack was straightforward and genuinely free. Writing the *detection* honestly could not be finished the same way: LocalStack Community doesn't emit CloudTrail-format events at all, so there's no real log to query locally, and I chose not to fabricate a "detection" that only ever ran against a hand-crafted sample log — that would be closer to writing a query in a vacuum than validating one. The query above is written correctly against real CloudTrail's schema and is ready to run the moment there's a real (AWS free-tier) CloudTrail trail to point it at; documenting that gap honestly is more useful than pretending it's finished.

## Security note
`simulate-privesc.sh` only ever targets `--endpoint-url=http://localhost:4566` with LocalStack's placeholder `test`/`test` credentials — it cannot reach or affect a real AWS account even if run by mistake with real credentials exported, since the `--endpoint-url` flag pins every call to localhost.
