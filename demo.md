# Trust Demo


> In this demo, we're going to take a short tour of the features that set Confluent apart as the most trusted partner for data in motion.

> I'm going to play a few different characters who work for a company onboarding with Confluent Cloud.

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

4. Go to "Add cluster" to show BYOK option. Cancel and select `trust-demo` dedicated cluster.

5. Show cluster elasticity.
   -  In Cluster Overview -> Dashboard, show cluster load metric.
   - In Cluster Overview -> Cluster settings -> Capacity, show the "Adjust capacity" slider.

6. Go to top-right hamburger menu -> Administration -> Accounts & access and search for "Chuck" to bring up all the users for this demo.

    > Here we see org admin, env admin, developer lead, and two developers. This is a scalable way to manage access. Give managers ownership over their own isolated part of the system.

7. Show devlead's rolebinding on the trust-demo cluster.

8. Log in as devlead.

9. Show stream lineage for topic.
   - Drill into schema and show schema tag.
   - Go to Schema Registry -> Tag Management -> Recommended to show some of the recommended tags.

10. Open the terminal and use confluent CLI to log in as `chuck+devlead@confluent.io`.
    ```bash
    confluent login
    ```

11. Set up audit log API key

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

    > Audit logs are cool. It's just a kafka topic, which means you can use connectors to integrate Confluent Cloud access data into 3rd party security tools like Splunk as a part of your company-wide access pattern monitoring strategy.

11. Create rolebindings for dev1 and dev2

    > look, it's not just GUI! There's a REST API and a CLI as well. Very scriptable! Automatable! Onboarding 100 devs becomes a simple script.

1. show support portal (click on liferaft icon in top right)

## Summary

- SSO integration
- BYOK
- Elastic scaling with cluster load metric
- Stream Governance
- Scalable access management with rolebindings


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

## Useful Commands

Put useful commands here.

