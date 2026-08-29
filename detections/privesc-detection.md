# IAM self-privilege-escalation

## What this is about
An identity creating another IAM principal and immediately handing it `AdministratorAccess` — sometimes attaching a policy to itself — within seconds of creating it. This is one of the best-documented cloud privilege-escalation patterns out there (Rhino Security Labs' `pmapper` and `weirdAAL` catalog a whole family of variants). Maps to T1098, Account Manipulation.

## Running the attack pattern yourself
```bash
cd ~/securitylab/localstack && docker compose up -d
./simulate-privesc.sh
```
Three real AWS API calls — `iam create-user`, `iam attach-user-policy`, `iam create-access-key` — against LocalStack. Same request shape as real AWS, no cost, no real account anywhere near it.

## What I used instead of the "ideal" tools
The catalog spec here calls for CloudTrail + GuardDuty. I don't have a CloudTrail feed to work with — LocalStack Community doesn't emit CloudTrail-format logs (that's a Pro-only feature), and I'm not paying for GuardDuty just to test a detection query. So the attack simulation is real and reproducible against LocalStack; the detection query below is written directly against CloudTrail's actual event schema so it's ready to point at a real trail the moment I have one, but I haven't run it against real output yet.

## The query
```sql
-- Athena over a CloudTrail table (or adapt as a GuardDuty/Security Hub finding
-- filter). Looks for: same actor, IAM user creation followed by an
-- admin-equivalent policy attach, within a 5-minute window.
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
  -- plus a prior CreateUser from the same actor_arn within 5 minutes —
  -- that's a self-join on actor_arn + time window, left out here since I
  -- can't actually test it against real data yet (see below)
```

## Where I stopped, and why
I could have made up a sample CloudTrail-shaped log file and run this query against my own fabricated data, gotten a green checkmark, and called it done. Didn't do that on purpose — testing a query against data I invented to match it doesn't actually validate anything, it just proves I can write matching SQL. The honest state is: the attack is real and runs, the query is written correctly against the real schema, and the actual validation step is waiting on a real AWS free-tier account with CloudTrail turned on. That's the next thing to do here, not a finished item.

`simulate-privesc.sh` only ever points at `--endpoint-url=http://localhost:4566`, so even if it got run with real AWS credentials exported by mistake, it physically can't reach a real account — the endpoint flag pins every call to localhost.
