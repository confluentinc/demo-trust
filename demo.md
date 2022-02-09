# Trust Demo


> In this demo, we're going to take a short tour of the features that set Confluent apart as the most trusted partner for data in motion.

> I'm going to play a few different characters who work for a company onboarding with Confluent Cloud.

## SSO Integration

1. Open an incognito browser window.

2. Paste in the SSO URL link
    ```
    https://confluent.cloud/login/sso/confluent-org-2355759
    ```
    Keep the okta URL open in another tab so you can easily sign out of accounts.
    ```
    https://confluenttrust-demo.okta.com/
    ```

    > Single Sign-On integration with your favorite enterprise security vendors like Okta!

3. Log into Confluent Cloud via Okta SSO with the user
    ```
    chuck+admin1@confluent.io
    ```
    (use the trust demo password you set up in Okta)

## Bring Your Own Key

4. Go to "Add cluster" to show BYOK option. Cancel and select `trust-demo` dedicated cluster.

## Elastic Scalability

5. Show cluster elasticity.
   -  In Cluster Overview -> Dashboard, show cluster load metric.
   - In Cluster Overview -> Cluster settings -> Capacity, show the "Adjust capacity" slider.

    > Mention production experience with over 10,000 clusters

## Stream Governance

9. Show stream lineage for topic.
   - Drill into schema and show schema tag.
   - Go to Schema Registry -> Tag Management -> Recommended to show some of the recommended tags.

    > Quality (schemas), observability (lineage), discovery (stream catalog and tagging)

## Scale Access with RBAC -- Now with Kafka Resources

6. Go to top-right hamburger menu -> Administration -> Accounts & access and search for "Chuck" to bring up all the users for this demo.

    > Here we see org admin, env admin, developer lead, and two developers. This is a scalable way to manage access. Give managers ownership over their own isolated part of the system.

7. Show devlead's rolebinding on the trust-demo cluster.

## Audit Logs

11. Set up audit log API key

    > Audit logs are cool. It's just a kafka topic, which means you can use connectors to integrate Confluent Cloud access data into 3rd party security tools like Splunk as a part of your company-wide access pattern monitoring strategy.

## Manage Access Programmatically

8. Log in as devlead.

10. Open the terminal and use confluent CLI to log in as `chuck+devlead@confluent.io`.
    ```bash
    confluent login
    ```

11. Split screen terminal with devlead reading audit log on one side and dev2 on other side trying to log in.
    ```bash
    # log in as devlead on left
    confluent blah blah

    confluent consume audit logs blah
    ```

    ```bash
    # log in as dev2 on right
    confluent consume gcp.commerce.facts.purchases topic
    ```

11. Create rolebindings for dev1 and dev2

    > look, it's not just GUI! There's a REST API and a CLI as well. Very scriptable! Automatable! Onboarding 100 devs becomes a simple script.

## Need Help? We've Got Your Back

1. show support portal (click on liferaft icon in top right)

## Summary

- SSO integration to make it easy to onboard your employees to Confluent
- BYOK to give you control over your at-rest data encryption
- Elastic scaling with cluster load metric (take advantage of production experience with over 10,000 clusters)
- Stream Governance to allow you to maintain data quality, set governance policies, and see end-to-end data flow
- Scalable access management with rolebindings
- Audit logs that can be exported to your security analysis tools as a part of your company-wide threat monitoring
- Support that taps into over 3 million hours of expertise


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

env ID
```
env-y60pp
```

Cluster ID
```
lkc-856k7
```

## Useful Commands

Put useful commands here.

create rolebinding
```bash
export XX_CCLOUD_RBAC_DATAPLANE=1

confluent iam rbac role-binding create \
    --role DeveloperRead \
    --principal User:chuck+dev1@confluent.io \
    --environment env-y60pp \
    --cloud-cluster lkc-856k7 \
    --kafka-cluster-id lkc-856k7 \
    --resource Group:trust-app \
    --prefix
```

create api key
```bash
confluent api-key create --resource lkc-856k7
```

use api key (replace with whatever key you created)
```bash
confluent api-key use F4WEN42RY5T36TZB
```

consume from topic (requires DeveloperRead on topic and consumer group, as well as a SR api key)
```bash
confluent kafka topic consume \
    gcp.commerce.fact.purchases \
    --value-format avro
    --group trust-app \
    --cluster lkc-856k7 \
    --sr-endpoint https://psrc-4r3n1.us-central1.gcp.confluent.cloud  \
```

Set up cli to consume audit logs
```bash
# View audit log cluster info
confluent audit-log describe

# use audit log env and cluster
confluent env use env-w8q9m
confluent kafka cluster use lkc-d6071

# Create new audit log api key (max 2 keys)
# confluent api-key create --service-account sa-yom2mj --resource lkc-d6071

# Use audit log api key (or create your own first)
confluent api-key use LKBI3R4U3TTCQPF6 --resource lkc-d6071
```

grab user info for dev2
```bash
confluent iam user list -o json \
    | jq '.[] | select( .email |contains("dev2"))'
```

Scan audit logs for user dev2 getting denied (id u-38mwr0)
```bash
confluent kafka topic consume -b \
    confluent-audit-log-events \
    | grep u-38mwr0 \
    | jq '. | select(.data.authorizationInfo.granted != true)'
```