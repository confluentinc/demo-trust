# Trust Demo




## SSO Integration

1. Open an incognito browser window.

1. Paste in the SSO URL link
    ```
    https://confluent.cloud/login/sso/confluent-org-2355759
    ```
    Keep the okta URL open in another tab so you can easily sign out of accounts.
    ```
    https://confluenttrust-demo.okta.com/
    ```

    > Thanks Kevin! To start, I'm going to log into Confluent Cloud, which redirects to my company's identity provider (Okta, in this case). Confluent Cloud integrates Single Sign-On to make authentication easy.

1. Log into Confluent Cloud via Okta SSO with the user
    ```
    chuck+admin1@confluent.io
    ```
    (use the trust demo password you set up in Okta)

    > Here you see only the environments for which I have access. Typically, there will be separate development, staging, and production environments, but you can create different environments according to your needs.

    > Let's see some of the security options available when we create a new cluster.

## Private Networking and Bring Your Own Key

1. Go to "Add cluster" and select AWS to show netowrking and BYOK.

    > Because data is encrypted in transit, "Internet" is a great option for most production use cases. But if your organization likes more control over your security posture, you can take advantage of other more isolated networking options like PrivateLink and Transit Gateway.

    > In addition, Confluent Cloud allows you to bring your own encryption key if you want even more control over who can access your data.

    > Security is a great foundation, but I'm also responsible to make sure our clusters are resilient and can scale to meet the needs of the business. Let's switch over to a running cluster.

1. Go back to the `trust-demo` cluster.

## Elastic Scalability

Show cluster elasticity.
   -  In Cluster Overview -> Dashboard, show cluster load metric.
   - In Cluster Overview -> Cluster settings -> Capacity, show the "Adjust capacity" slider.

> If you've ever run Kafka at scale, you know it can be challenging to make scaling decisions. Often, teams that self-manage Kafka clusters find it difficult to expand or shrink clusters in time to meet demand, opting instead to eat the cost of overprovisioning. Luckily I don't have that problem. Production experience with over 10,000 clusters has given Confluent the ability to simplify your decision making process. There's a single "cluster load" metric to help you decide if it's time to expand or shrink your cluster. Choose your capacity and Confluent take care of doing all that scaling work behind the scenes.


## Stream Governance

> So we've looked at security and elasticity, but what about the data itself? Confluent has Stream Governance tools to ensure your data is high quality, observable, and discoverable.

1. Show stream lineage for topic.
   - Drill into schema and show schema tag.

    > In the Stream Lineage view, we can see the end-to-end data flow across the cluster. It's not very interesting right now, but let's click into the purchases topic and look at the schema. Here we see a field tagged as "Sensitive". You can create your own tags or choose from suggested tags. Confluent has best-in-class data governance tools so you can enforce quality and promote discoverability.

## Scale Access with RBAC -- Now with Kafka Resources

> One of the most important aspects of any production system is how easy it is to manage access at scale. Let's see how that works.

1. Go to top-right hamburger menu -> Administration -> Accounts & access and search for "Chuck" to bring up all the users for this demo.

    > Here we see org admin, env admin, developer lead, and two developers. Nobody wants to manage access for hundreds of users and applications. That's why you can use Role Based Access Control to give different people ownership over their own isolated part of the system.

1. Show devlead's rolebinding on the trust-demo cluster.

    > Jeff, the Developer Lead, has the `CloudClusterAdmin` role on the `trust-demo` cluster.

1. Go to top right hamburger menu -> Accounts & access -> Access to look at Michael's access.

    > Introducing for the first time, Role Based Access Control at the Kafka resource level. As Jeff the Developer Lead, I can give my team the resource-level access they need to do their work.

    > This isn't just in the web console. All of this access control is made automation-friendly via API. Let's move to the command line.

## Audit Logs

> All of this signing in and out and accessing data has actually been recorded as authorization events in a kafka topic called an audit log. Let's see some audit log events in real time.

1. Bring up a terminal with split screen. In the left terminal, log in as the org admin (`chuck+training@confluent.io`).

1. Describe the audit logs.
    ```bash
    confluent audit-log describe
    ```

    > The audit log topic is kept in its own Kafka cluster with its own service account. Let's configure the CLI to access these audit logs.

1. Use audit log environment, cluster, and API key.
    ```bash
    confluent env use env-w8q9m
    confluent kafka cluster use lkc-d6071
    confluent api-key use LKBI3R4U3TTCQPF6 \
        --resource lkc-d6071
    ```

    > Let's consume the tail of this log and see authorization events in real time.

1. Consume the audit log.
    ```bash
    confluent kafka topic consume \
        confluent-audit-log-events \
        | grep u-38mwr0 \
        | jq '. | select(.data.authorizationInfo.granted != true)'
    ```

1. In the right terminal, log in with `chuck+dev2@confluent.io`. Make sure you log out of okta before pating the link returned by the command.
    ```bash
    confluent login --no-browser
    ```

    A failed authorization attempt will show up in the left terminal.

    > Audit logs are cool. It's just a kafka topic, so you can analyze the events in real time. It also means you can use connectors to integrate with 3rd party security tools like Splunk to pick up access patterns across all services at the company (not just Confluent). We have a bunch of customers actively using this feature.

    > Ok so poor Maygol is blocked on her work. She can't access her Kafka topics. Let's help her out.


## Manage Access Programmatically

1. On the left terminal, create a DeveloperRead rolebinding for dev2 so she can read the topics prefixed with `gcp.commerce`.
    ```bash
    confluent iam rbac role-binding create \
        --role DeveloperRead \
        --principal User:chuck+dev2@confluent.io \
        --environment env-y60pp \
        --cloud-cluster lkc-856k7 \
        --kafka-cluster-id lkc-856k7 \
        --resource Topic:gcp.commerce \
        --prefix
    ```

    > Now Maygol has read access to all topics prefixed with `gcp.commerce`. To consume that data, she also needs to be able to use a consumer group.

1. Now create a DeveloperRead rolebinding for dev2 so she can use consumer groups prefixed with `trust-app`.
    ```bash
    confluent iam rbac role-binding create \
        --role DeveloperRead \
        --principal User:chuck+dev2@confluent.io \
        --environment env-y60pp \
        --cloud-cluster lkc-856k7 \
        --kafka-cluster-id lkc-856k7 \
        --resource Group:trust-app \
        --prefix
    ```
    > Ok so now Maygol should be able to use consumer groups prefixed with `trust-app` to read the data from the topics she needs and incorporate them into the app the team is developing.
    
    > Let's log in as Maygol.

1. In the right terminal, log in with `chuck+dev2@confluent.io`. Make sure you log out of okta before pating the link returned by the command.
    ```bash
    confluent login --no-browser
    ```

1. In the right terminal, use Maygol's API key (previously created).
    ```bash
    confluent api-key use TVRXJH53XV6QXLQI \
        --resource lkc-856k7
    ```

    > I didn't want you to see Maygol's secrets, so this API key was created before the demo. It's important to note that since Maygol created this API key, its access is limited to her access, and if her access changes, that API key's access automatically changes as well.

1. Consume from topic as Maygol (must input Schema Registry API key). Stop the topic to view the data a bit.
    ```bash
    confluent kafka topic consume \
        gcp.commerce.fact.purchases \
        --value-format avro \
        --group trust-app \
        --cluster lkc-856k7 \
        --sr-endpoint https://psrc-4r3n1.us-central1.gcp.confluent.cloud  
    ```
    
    > We also need a separate API key to access schema registry. And here the data is flowing.
    
    > When the team is ready, they can create a service account for the app and apply RBAC to that service account across different environments as well. Confluent Cloud is opinionated about separating the identities of people (users) and apps (service accounts).

## Need Help? We've Got Your Back

1. Show support portal (click on liferaft icon in top right)
    
    > If you need help at any point along the way, you can reach our world-class support staff easily. Here is the support portal with knowledge base articles, and here you can file a ticket. We have over 3 million hours of expertise helping customers along their journey to set their data in motion.

## Summary

In this whirlwind tour, we had a taste of all the features that set Confluent apart as the most trusted data streaming partner, including:

- SSO integration to make it easy to onboard your employees to Confluent
- Private networking and Bring Your Own Key to give you tighter security
- Elastic scaling with cluster load metric, taking advantage of our production experience with over 10,000 clusters
- Stream Governance to allow you to maintain data quality, see end-to-end data flow, and discover data across your organization
- Scalable access management with Role Based Access Control, now with rolebindings for Kafka topics, consumer groups, and transactional IDs
- Audit logs that can be exported to your security analysis tools as a part of your company-wide threat monitoring
- Support that taps into over 3 million hours of expertise

Trust is earned, so go ahead and start with a small use case for free in Confluent Cloud. As we gain your confidence, we'll be happy to help you set your data in motion.

## Re-running the Demo

If you aren't tearing anything down, but you'd like to re-run the demo, the only thing you need to do is delete the rolebindings for dev2 (logged in as devlead, admin1, or your org admin user). This is required so on your next run, the audit logs can show a failed authorization attempt by dev 2:

```bash
confluent iam rbac role-binding delete \
    --role DeveloperRead \
    --principal User:chuck+dev2@confluent.io \
    --environment env-y60pp \
    --cloud-cluster lkc-856k7 \
    --kafka-cluster-id lkc-856k7 \
    --resource Topic:gcp.commerce \
    --prefix

confluent iam rbac role-binding delete \
    --role DeveloperRead \
    --principal User:chuck+dev2@confluent.io \
    --environment env-y60pp \
    --cloud-cluster lkc-856k7 \
    --kafka-cluster-id lkc-856k7 \
    --resource Group:trust-app \
    --prefix
```