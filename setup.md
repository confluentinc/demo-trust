# Setup

## Create Okta Free Trial

Create a free trial with Okta called something like `trust-demo`
- https://www.okta.com/free-trial/

Also keep track of your company name (admin panel -> Settings -> Account)

Chuck's demo org:
- confluenttrust-demo.okta.com
- company name: confluent-org-2355759

Use a secure password because we don't want people being able to mess with the demo, and who knows, these accounts might stick around for future iterations of the demo.

## Create Okta Users and Groups

You can create all these users in one go and give them the same secure password that you used to create the Okta organization (just set the password as admin so you don't have to verify email for each user).

Users
- You (whatever confluent cloud account you are using for this demo)
  - e.g. chuck+training@confluent.io
  - You are playing the role of Confluent Cloud Organization Admin. You are the bootstrap superuser.
- Environment admin (call her Priya)
  - use email alias `admin1`
  - e.g. chuck+admin1@confluent.io
- devteamA team lead (call him Jeff)
  - use email alias `devlead`
  - e.g. chuck+devlead@confluent.io
- Michael (member of devteamA)
  - use email alias `dev1`
  - e.g. chuck+dev1@confluent.io
- Maygol (also member of devteamA)
  - use email alias `dev2`
  - e.g. chuck+dev2@confluent.io

Groups
- Confluent Cloud devteamA
- Confluent Cloud devteamB

> NOTE: Confluent Cloud RBAC does not support group rolebindings yet (as of Feb 2022). This is for future development of this demo.

## Prepare Your Terminal

### Run terminal in the browser
You can run the `confluent CLI` locally or you can run in a preconfigured remote environment by clicking this link:
- https://gitpod.io/#https://github.com/chuck-confluent/template-confluent-cli

### Run terminal locally
If you want to install the CLI locally, follow the documentation and I suggest also to enable shell tab autocompletion:
- https://docs.confluent.io/confluent-cli/current/install.html

### Run in preconfigured docker workspace image
If you want to run locally, but want it all packaged in a docker container workspace, you can build and run a docker container locally:
```bash
git clone https://github.com/confluentinc/demo-trust.git
cd demo-trust
docker build -t workspace . -f .gitpod.Dockerfile
docker run -v ${PWD}:/home/gitpod/demo-trust \
    -w /home/gitpod/demo-trust \
    --rm -it workspace 
```

### Source environment variables

[The demo](./demo.md) currently uses hardcoded values for the first person who ran the demo. If you are the second person running this demo, please refactor it to use environment variables instead of hardcoded values.

1. Fill in `scripts/.env` with values obtained from [Create Confluent Cloud Resources](#create-confluent-cloud-resources)

2. Export the variables in each terminal shell you will run commands from by sourcing a script.
```bash
source scripts/export-vars.sh
```

## Create a Confluent Cloud Organization

If you haven't already, sign up at https://confluent.cloud or with the `confluent cloud-singup` command to create an account.

## Configure Okta + Confluent Cloud SSO Integration


1. In Okta admin panel, go to Applications -> Create App Integration
2. Choose SAML 2.0 
    > NOTE: In the future, we may support OIDC integration and there may be reasons to do that instead.
3. Follow https://docs.confluent.io/cloud/current/access-management/authenticate/sso/sso.html#configuring-sso, using your Okta company name (admin panel -> Settings -> Account)
    - e.g. confluent-org-2355759
4. In Okta, use Name ID Format `EmailAddress`
5. In Confluent, use the default `email: http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier` for the SAML fields mapping. This will work because you used `EmailAddress` as the Name ID Format in the previous step.
6. Copy/paste all the necessary things from Confluent to Okta
7. Copy/paste the SSO URL from Okta to Confluent and upload Okta's public signing cert and submit.
8. Assign the Okta app to all your users in Okta.
9. Log into Confluent Cloud as an org admin and add all the users under Accounts & access.
    > Right now, users have to be created manually in Confluent in addition to the identity provider. In the future, it may be possible to programmatically add SSO users to confluent. Even further in the future, Confluent will support full OIDC integration; at which time, Confluent will be able to use information in the OIDC token to create a user automatically.
10. You should now be able to open an incognito browser window, go to `https://confluent.cloud/login/sso/<your okta org>` and sign in with any of the okta users.
11. Bookmark the Okta URL and the Confluent SSO URL for easy access throughout the demo.

## Create Confluent Cloud Resources

Resources:

- Create an environment for the demo.
- Create a dedicated cluster called `trust-demo` with data plane RBAC enabled (may need to talk to security product managers)
- Create a topic called `gcp.commerce.fact.purchases`
    > Fun fact: This topic follows a popular topic naming convention of \<data center>.\<domain>.\<event type>.\<data description>. The data center allows for some disaster recovery strategies (especially with cluster linking). The event type is usually fact, command (e.g. updateThing, thingUpdated), or cdc (change data capture with a compacted topic). See [this blog post](https://devshawn.com/blog/apache-kafka-topic-naming-conventions/) for more info.
- Create a datagen connector with the `purchases` template to produce to the `gcp.commerce.fact.purchases` topic.
- Create a Schema Registry API key and secret for the environment. Keep it safe in LastPass. You will need to it deserialize the avro values in the CLI consumer in the demo.
- In Accounts & access, give dev1 rolebindings for topics prefixed by `gcp.commerce` and consumer groups prefixed by `trust-app`.
- In Accounts & access, give devlead the `CloudClusterAdmin` role for the `trust-demo` cluster
- If one doesn't exist already, create an API key to access audit logs
    ```bash
    # Get special service account, env id, and cluster id
    confluent audit-log describe
    confluent api-key create \
        --service-account $AUDIT_SA \
        --resource $AUDIT_CLUSTER
    ```
    > WARNING: Your organization can only have 2 audit log API keys, so you may need to just use a key that already exists. To do that, use the information from `confluent audit-log describe` as flags in a `confluent api-key list` command to see the existing keys.

### dev2 Permissions

This part is a little tricky, so I am putting it into a sub section. We need to:
- give dev2 permissions
- log in as dev2 to create an api key to be used later
- take away dev2's permissions again (this is part of the demo to show audit log events in real time).

Run while logged in as an admin:
```bash
confluent iam rbac role-binding create \
    --role DeveloperRead \
    --principal User:$EMAIL_PREFIX+dev2@confluent.io \
    --environment $ENV_ID \
    --cloud-cluster $CLUSTER \
    --kafka-cluster-id $CLUSTER \
    --resource Topic:gcp.commerce \
    --prefix

confluent iam rbac role-binding create \
    --role DeveloperRead \
    --principal User:$EMAIL_PREFIX+dev2@confluent.io \
    --environment $ENV_ID \
    --cloud-cluster $CLUSTER \
    --kafka-cluster-id $CLUSTER \
    --resource Group:trust-app \
    --prefix
```

Run while logged in as dev2:
```bash
confluent api-key create --resource $CLUSTER
```

Run as admin:
```bash
confluent iam rbac role-binding delete \
    --role DeveloperRead \
    --principal User:$EMAIL_PREFIX+dev2@confluent.io \
    --environment env-y60pp \
    --cloud-cluster $CLUSTER \
    --kafka-cluster-id $CLUSTER \
    --resource Topic:gcp.commerce \
    --prefix

confluent iam rbac role-binding delete \
    --role DeveloperRead \
    --principal User:$EMAIL_PREFIX+dev2@confluent.io \
    --environment env-y60pp \
    --cloud-cluster $CLUSTER \
    --kafka-cluster-id $CLUSTER \
    --resource Group:trust-app \
    --prefix
```