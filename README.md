# Trust Launch Demo

"Trust" is a key marketing pillar for Confluent. Businesses need to feel confident that we will keep their data safe and be reliable partners for their most critical needs. This demo helps to support the launch of the Trust pillar by highlighting several Confluent Cloud capabilities:
- Bring Your Own Key
- Role Based Access Control
- Audit logs
- Stream Governance (specifically stream lineage)


## Draft outline

Here is a draft outline for the flow of the demo:
- Create a free trail org on Okta and do an okta+ccloud integration with some fake admins, team leads, and developers. If this doesn't work, I can just manually add a couple admin, team lead, and dev users in the ccloud console and probably just use my own email address with aliases for each one.
- Log in as admin to set org/env rolebindings
- Log in as team lead to set team rolebindings on prefixed kafka topics using a script (show off that this is all CLI/API enabled, and thus automatable)
- Create a cli consumer for audit log events (pretending now to be an admin)
- Use cli producer as a dev to trigger audit log events, which is a good point to talk about the value of audit logs being just a normal kafka topic and sinking to Splunk
- I, as audit log admin, see this poor developer needs access. I look them up in Okta to see who their team lead is. I, the admin, will not get bogged down in granting individuals access. I'm going to bug the team lead to get their shit together.

> Where is stream governance?

## Future Work
As the RBAC and audit log products mature, this demo will be able to evolve into something really impressive. Here are the key capabilities this demo needs to shine:
- RBAC group access control
- RBAC for schema registry, ksqlDB, and Kafka Connect
- Out of the box support for sending audit logs to Splunk, Elastic, etc.

## References

We may be able to reuse or be inspired by material from CP RBAC course:
- https://github.com/confluentinc/training-adm-sec-rbac
