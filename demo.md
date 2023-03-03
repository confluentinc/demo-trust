# Trust Demo




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

    > Thanks Kevin! To start, I'm going to log into Confluent Cloud, which redirects to my company's identity provider (Okta, in this case). Confluent Cloud integrates Single Sign-On to make authentication easy.

3. Log into Confluent Cloud via Okta SSO with the user
    ```
    chuck+admin1@confluent.io
    ```
    (use the trust demo password you set up in Okta)

    > Here you see only the environments for which I have access. Typically, there will be separate development, staging, and production environments, but you can create different environments according to your needs.

    > Let's see some of the security options available when we create a new cluster.

## OAuth Authentication

>We support Oauth which is a centralized-identity management in addition to SSO now so administrators can work with a single repository of user IDs

1. Sign up for Okta trial account

2. Go to OAuth Application and create application integration with all defaults and copy client ID + secret

3. Go to oauth.tools, Demo: Client Credentials Flow, type in and run client id + secrets to auto-generate token endpoint 
    
4. Go back to to Oauth security and select API -> 
    Click default and create scope with name as “test-perf” and set as default scope

5. Go back to oauth.tools, Curity Playground and type in metadata URL to auto-fill in all necessary endpoints

6. Go to back to Confluent Cloud: Accounts & Access, select Identity Provider tab and click +Add Provider:
-    Choose Identity Provider (in this case, Okta)
-    Enter domain which will auto-populate Issuer URI and JWKS URI 

7. Create an identity pool and identity claim

> Use identity pools to map groups and other attributes to policies (Role Based Access Controls or ACLs). 
-    Create an identity pool [demo pool] and copy identity pool ID.
> Use identity claims to filter which identities can be authenticated using this pool. 
-    Create identity claim with [claims.sub=='topic-perf'] and access with CloudClusterAdmin for “demo-trust” cluster.

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

> So we've looked at security and elasticity, but what about the data itself? That’s where Stream Governance come’s in -- the industry's only data governance suite for real-time event streaming.

1. Show stream lineage for topic.
   - Drill into schema and show schema tag.

    > In the Stream Lineage view, we can see the end-to-end data flow from source to destination. It's not very interesting right now, but let's click into the purchases topic and look at the schema. Confluent Schema Registry makes it easy to evolve schemas along with your business needs. Here we also see a field tagged as "Sensitive". Tags like this can be used to allow teams across your organization to discover the data they need.
    
    > Make sure to check out our other demos that focus extensively on Stream Governance.

## Scale Access with RBAC -- Now with Kafka Resources

> So I have a secure, elastic cluster with high quality data. Now I just need to onboard hundreds of architects and developers to use it. And I need to do this responsibly so each one of them has only the minimum access they need. That's where Role Based Access Control (aka RBAC) comes in.

1. Go to top-right hamburger menu -> Administration -> Accounts & access and search for "Chuck" to bring up all the users for this demo.

    > Here we see an org admin, environment admin, developer lead, and two developers.

2. Show devlead's rolebinding on the trust-demo cluster.

    > The Developer Lead has the `CloudClusterAdmin` role on the `trust-demo` cluster. Here we start to see the beauty of Role Based Access Control -- I can delegate access management for this cluster to the Developer Lead, who in turn can grant access to the rest of the team.

3. Go to top right hamburger menu -> Accounts & access -> Access to look at Michael's access.

    > Let's look at one of the developers. Introducing for the first time, Role Based Access Control at the Kafka resource level. As the Developer Lead, I can give my team the resource-level access they need to do their work.

    > So we have some users onboarded with granular permissions established. That's not quite enough, though. I also need visibility into how these resources are being used. Let's go to the command line.

## Cloud CLient Quotas

>To produce data into Confluent, we will be using the kafka-producer-perf-test which is often used to optimize for throughput and latency. 
1. Create a topic [topic-perf] where the perf test will produce into
2: Create a java.config that connects to your CC that also includes the OAuth JSON Web Token (JWT) 

The parameters you will need are: 
```    
Confluent Cloud bootstrap servers
Oauth token endpoint
Oauth client ID and secret
Oauth scope
Confluent Cloud cluster ID
Confluent Cloud identity pool ID
```
3. Run the kafka-producer-perf test to produce data into Confluent with these configurations and without any client quotas. In this case we will be running 20,000 messages. 
```
user@User's-MBP13 ~ % kafka-producer-perf-test \
    --producer.config /Users/java.config \
    --throughput -1 \
    --record-size 8000 \
    --num-records 20000 \
    --topic topic-perf \
    --producer-props \
        batch.size=200000 \
        linger.ms=100 \
        acks=1
```
4. Notice how the average throughput is 0.7 MB/s by default. Now what if we want to limit the throughput to 0.5 MB/s? 
20000 records sent, 89.908249 records/sec (0.69 MB/sec)

5. Go to Cluster Settings in your cluster, select the Client Quotas tab and click +Add quota

6. Assign cluster, desired ingress and egress throughputs and principal (service account or identity pool) 

7. Go back to terminal and run the exact same test w/ same configurations

8. Notice how the average throughput is 0.5 MB/s instead of 0.7 MB/s, which shows cloud client quota has been established and limited the throughput to 20000 records sent, 65.612923 records/sec (0.50 MB/sec)

## Audit Logs

> All of this signing in and out and accessing data has actually been recorded as authorization events in a kafka topic called an audit log. Let's see some audit log events in real time.

1. Bring up a terminal with split screen. In the left terminal, log in as the org admin (`chuck+training@confluent.io`).

2. Describe the audit logs.
    ```bash
    confluent audit-log describe
    ```

    > The audit log topic is kept in its own Kafka cluster with its own service account. Let's configure the CLI to access these audit logs.

3. Use audit log environment, cluster, and API key.
    ```bash
    confluent env use env-w8q9m
    confluent kafka cluster use lkc-d6071
    confluent api-key use LKBI3R4U3TTCQPF6 \
        --resource lkc-d6071
    ```

    > Let's consume the tail of this log and see authorization events in real time.

4. Consume the audit log.
    ```bash
    confluent kafka topic consume \
        confluent-audit-log-events \
        | grep u-38mwr0 \
        | jq '. | select(.data.authorizationInfo.granted != true)'
    ```

5. In the right terminal, log in with `chuck+dev2@confluent.io`. Make sure you log out of okta before pating the link returned by the command.
    ```bash
    confluent login --no-browser
    ```

    A failed authorization attempt will show up in the left terminal.

    > On the right, a developer is trying to read some data from the cluster, and we can see from the audit log on the left that she's been denied access. What's great about this is the audit log is just a kafka topic. That means I can use connectors to integrate these logs with any 3rd party security tool like Splunk or Elastic.

    > Ok so let's help this developer get the right access.


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

    > Now the developer has read access to all topics prefixed with `gcp.commerce`. To consume that data, she also needs to be able to use a consumer group.

2. Now create a DeveloperRead rolebinding for dev2 so she can use consumer groups prefixed with `trust-app`.
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
    > Ok so now she should be able to use consumer groups prefixed with `trust-app` to read the data from the topics she needs and incorporate them into the app the team is developing.

    > The important point here is that this was done programatically. I can just as easily iterate through a list of 100 developers to give them all the access they need.
    
    > Let's see if the developer can access the data now.

3. In the right terminal, log in with `chuck+dev2@confluent.io`. Make sure you log out of okta before pating the link returned by the command.
    ```bash
    confluent login --no-browser
    ```

4. In the right terminal, use Maygol's API key (previously created).
    ```bash
    confluent api-key use TVRXJH53XV6QXLQI \
        --resource lkc-856k7
    ```

5. Consume from topic as Maygol (must input Schema Registry API key). Stop the topic to view the data a bit.
    ```bash
    confluent kafka topic consume \
        gcp.commerce.fact.purchases \
        --value-format avro \
        --group trust-app \
        --cluster lkc-856k7 \
        --sr-endpoint https://psrc-4r3n1.us-central1.gcp.confluent.cloud  
    ```

    > She did it! Data is flowing into her application.

## Need Help? We've Got Your Back

1. Show support portal (click on liferaft icon in top right)
    
    > Like with anything, there may be bumps along the way and my team might need help. I can easily reach a support staff highly specialized in helping teams like mine implement event streaming applications. Here is the support portal with knowledge base articles, and here you can file a ticket. Confluent has over 3 million hours of expertise helping customers along the journey to set their data in motion, so I feel like I'm in good hands.

    > Alright, back to Kevin!

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
