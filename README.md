**aws-identity-detection**

Started this because a couple of the detection engineer postings I was looking at specifically called out AWS alongside Microsoft identity, and everything else in this portfolio was Azure/Entra ID. Did not want a resume that only covers half of what is being asked for.

`detections/simulate-privesc.sh` runs a real IAM privilege-escalation sequence against LocalStack: create a user, immediately attach AdministratorAccess to it, mint an access key. That exact sequence (create → grant yourself admin → get a key) is one of the most common ways an attacker with a low-priv foothold turns it into full account control. `detections/privesc-detection.md` has the write-up, including the part where I could not fully close the loop. More on that below.

No real AWS account IDs, ARNs, or keys anywhere here. Everything is a placeholder or made up.

**The gap I am not hiding**
The attack simulation runs for real against LocalStack, free, no AWS account needed. The detection query is written correctly against CloudTrail's actual schema, but LocalStack's free Community edition does not generate CloudTrail-format logs at all (that is a Pro feature), so I never actually got to run the query against real output. I could have faked a sample log and run my query against my own fake data, but that proves nothing except that I can write a query that matches data I made up to match it. Left it as a documented gap instead. See `detections/privesc-detection.md`.

`local-lab/` has LocalStack itself if you want to run the simulation yourself.

**One-time setup after cloning**
```bash
git config core.hooksPath .githooks
```

For AWS IAM concepts explained alongside their Entra ID equivalents, and why testing against LocalStack instead of a real AWS account is both cheaper and safer here, see [Part 4](https://github.com/danishrafiquekhan/security-lab-notes/blob/main/parts/04-identity-security-deep-dive.md) and [Part 8](https://github.com/danishrafiquekhan/security-lab-notes/blob/main/parts/08-cloud-security-iac.md) of `security-lab-notes`.
