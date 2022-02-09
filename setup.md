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
8. Assign the Okta app to all your users in Okta
9. You should now be able to open an incognito browser window, go to `https://confluent.cloud/login/sso/<your okta org>` and sign in with any of the okta users.

