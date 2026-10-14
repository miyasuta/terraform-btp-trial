## What does this Terraform project do?
1. Creates a subscription to Cloud Identity Services and establishes trust with subaccounts (trial and automationPilot)
2. Creates HANA Cloud instance
3. Subscribes to SAP Build Work Zone, standard edition
4. Subscribes to Integration Suite (the rotating app name, e.g. `it-cpitrial05-prov`, is auto-detected)
5. Creates a subaccount in th Singapore region and subscribes to Automation Pilot

## How to use
1. Clone this repository
2. Create a `terraform.tfvars` file in the root directory with the following content:
```terraform
# Your global account subdomain: e.g., 9fcf6fb2trial-ga
# You can check it from the global account > gear icon > General > Global Account Subdomain
globalaccount = ""

# HANA Cloud instance name
hc_instance_name = "HC_HDB"

# Comment out the next line if you want to provide the password here instead of typing it in the console (not recommended for security reasons)
hana_system_password = ""

# ID of trial subaccount
subaccount_id = ""

# Optional: service plan name for integration suite, e.g., it-cpitrial05-prov
# It is auto-detected from the subaccount's subscriptions. Set it only if detection fails
# (e.g. the Integration Suite is not subscribed yet). You can check it from the Service Marketplace
# by selecting Create > Integration Suite
# integration_suite_app_name = ""

# The admin users
admins = [""]
```
3. Log in via the btp CLI and let Terraform reuse that session
```
export USE_BTPCLI_SESSION=true
btp login --sso
```

Alternatively, you can set the credentials directly. 
```
export BTP_USERNAME=username
export BTP_PASSWORD=password
```
The former SSO flow via `BTP_ENABLE_SSO` is deprecated by the provider — use the
btp CLI session instead. Note that the btp CLI session flow is not supported in
CI/CD environments; use the x509 or JWT bearer assertion flow there.

4. Run `terraform init`
5. If a trust with an IAS tenant has already been established in your trial subaccount, run: `terraform import btp_subaccount_trust_configuration.trial <subaccount_id>,sap.custom`
6. Run `terraform apply`

## Integration Suite app name (auto-detection)
The Integration Suite app name on BTP trial changes from time to time (e.g. `it-cpitrial06-prov` → `it-cpitrial05-prov`).
You no longer need to look it up and write it into `terraform.tfvars`: Terraform reads the subaccount's subscriptions
(`btp_subaccount_subscriptions`) and picks the entry whose `commercial_app_name` is `integrationsuite-trial` and whose plan is `trial`.

- **Override:** set `integration_suite_app_name` in `terraform.tfvars` to skip the lookup.
- **When detection fails:** the plan stops with an error if no entry (or more than one) matches, e.g. when the Integration Suite
  was unsubscribed and the subaccount no longer lists it. Set `integration_suite_app_name` manually in that case
  (check **Service Marketplace > Integration Suite > Create**, or `btp list accounts/subscription`).
- **When the name changes:** the subscription is replaced (the app name forces a new resource) and the role collection
  assignment is recreated with it. If Terraform cannot read or destroy the old subscription, remove it from the state with
  `terraform state rm module.integration_suite_setup.btp_subaccount_subscription.integration_suite` and apply again.

## After Successful Run
1. (Optional) In **Security > Trust Configuration**, uncheck the **"Available for User Logon"**  checkbox for the Default Identity Provider.
2. Configure instance mapping for HANA Cloud.
![image](https://github.com/user-attachments/assets/24cf4d46-ba32-4412-92ac-c2e174512f97)

## References
https://github.com/SAP-samples/btp-terraform-samples/tree/main

If you want to schedule the starting of a HANA Cloud instance using Automation Pilot, please refer to the tutorial below:
https://developers.sap.com/tutorials/hana-cloud-automation-pilot.html
