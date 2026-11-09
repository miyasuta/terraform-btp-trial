## What does this Terraform project do?
1. Creates a subscription to Cloud Identity Services and establishes trust with subaccounts (trial and automationPilot)
2. Creates HANA Cloud instance
3. Subscribes to SAP Build Work Zone, standard edition
4. Subscribes to Integration Suite
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

## After Successful Run
1. (Optional) In **Security > Trust Configuration**, uncheck the **"Available for User Logon"**  checkbox for the Default Identity Provider.
2. Configure instance mapping for HANA Cloud.
![image](https://github.com/user-attachments/assets/24cf4d46-ba32-4412-92ac-c2e174512f97)

## References
https://github.com/SAP-samples/btp-terraform-samples/tree/main

If you want to schedule the starting of a HANA Cloud instance using Automation Pilot, please refer to the tutorial below:
https://developers.sap.com/tutorials/hana-cloud-automation-pilot.html

## Troubleshooting

### `terraform plan` fails with "Could not find application with name it-cpitrialNN-prov"

```
Error: API Error Reading Resource Subscription (Subaccount)
Could not find application with name it-cpitrial06-prov and plan trial. [Error: 90017/409]
```

**Cause:** The trial Integration Suite subscription expired and was deleted, or SAP renamed the app (e.g. `it-cpitrial06-prov` → `it-cpitrial05-prov`). Terraform still holds the old subscription in its state and cannot read it.

**Fix:** drop the stale entry from the state and let Terraform create the subscription again.

1. Check what actually exists in the subaccount:
   ```
   btp list accounts/subscription --subaccount <subaccount_id> | grep integrationsuite-trial
   ```
   The row should show status `NOT_SUBSCRIBED`. If it shows `SUBSCRIBED`, stop: the subscription is alive, so do not remove it from the state.
2. Remove the stale subscription from the state (this does not touch real infrastructure; Terraform keeps a `terraform.tfstate.*.backup` copy automatically):
   ```
   terraform state rm module.integration_suite_setup.btp_subaccount_subscription.integration_suite
   ```
3. Run `terraform plan`. It should only create the subscription and the `Integration_Provisioner` role collection assignment, with nothing destroyed. The current app name is detected automatically.
4. Run `terraform apply`.
5. Open **Service Marketplace > Integration Suite** and finish the provisioning manually.

If `terraform plan` stops with an error that no (or more than one) Integration Suite app was found, set `integration_suite_app_name` in `terraform.tfvars` to the name shown in step 1.

### HANA Cloud instance is missing in HANA Cloud Central

**Cause:** Trial HANA Cloud instances are removed after a period of inactivity, but the service instance record stays in the cockpit, so Terraform reports no changes.

**Fix:** recreate the instance and its binding.

1. Run:
   ```
   terraform apply \
     -replace=module.hana_cloud_setup.btp_subaccount_service_instance.hana_cloud \
     -replace=module.hana_cloud_setup.btp_subaccount_service_binding.hana_cloud \
     -target=module.hana_cloud_setup.btp_subaccount_service_instance.hana_cloud \
     -target=module.hana_cloud_setup.btp_subaccount_service_binding.hana_cloud
   ```
   The `-target` options keep other resources (e.g. Cloud Identity Services) out of the change. Creation takes up to 45 minutes.
2. Configure the instance mapping again (see below). Data in the old database cannot be recovered.
