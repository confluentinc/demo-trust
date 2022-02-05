# Trust Demo


> In this demo, we're going to take a short tour of the features that set Confluent apart as the most trusted partner for data in motion.

> I'm going to play a few different characters who work for a company onboarding with Confluent Cloud.

1. Open an incognito browser window.

## Things to keep handy

sso link
```
https://confluent.cloud/login/sso/confluent-org-2355759
```

Okta login:
```
https://confluenttrust-demo.okta.com
```

Okta company name:
```
confluent-org-2355759
```









## scratch


Do the demo

> say these words

Here is a draft outline for the flow of the demo:
- Log in as admin to set org/env rolebindings
- Log in as environment admin to set cluster rolebindings
- Log in as team lead to set team rolebindings on prefixed kafka topics using a script (show off that this is all CLI/API enabled, and thus automatable)
- Create a cli consumer for audit log events (pretending now to be an admin)
- Use cli producer as a dev to trigger audit log events, which is a good point to talk about the value of audit logs being just a normal kafka topic and sinking to Splunk
- I, as audit log admin, see this poor developer needs access. I look them up in Okta to see who their team lead is. I, the admin, will not get bogged down in granting individuals access. I'm going to bug the team lead to get their shit together.

> Where is stream governance? Maybe create a tag and put it on a schema field and then search in the catalogue? Also look at stream lineage flow?

## Useful Commands

Put useful commands here.

Sign in as dev team lead and:
- iterate through list of emails to create developerread roles to members of the dev team for topic `gcp.commerce.fact.purchases` and consumer group prefixed with `devteamA`
