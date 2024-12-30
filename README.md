## What does this Terraform project do?
1. Creates a subscription to Cloud Identity Services and establishes trust with subaccounts (trial and automationPilot)
1. Creates HANA Cloud instance
2. Subscribes to SAP Build Work Zone, standard edition
3. Subscribes to Integration Suite
4. Creates a subaccount in th Singapore region and subscribes to Automation Pilot

Please note that role assignments are done via mapping with an IAS group.
Therefore, assign your user to the mapped group as described in the **"After Successful Run"** section.

## How to use
1. Clone this repository
2. Add `terraform.tfvars` file to the root directory with following contents:
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

# Service plan name for integration suite: e.g., it-cpitrial05-prov
# You can check it from the Service Marketplace by selecting Create > Integration Suite
integration_suite_app_name = ""

# The admin users
admins = [""]
```
3. Set BTP user's credentials to environment variables
```
export BTP_USERNAME=username
export BTP_PASSWORD=password
```
Alternatively, you can enable SSO by setting BTP_ENABLE_SSO to ture.
```
export BTP_ENABLE_SSO=true
```

4. Run `terraform init`
5. Run `terraform import btp_subaccount_trust_configuration.trial <subaccoint_id>,sap.custom`, if a trust with an IAS tenant has already been established in your trial subaccount.
6. Run `terraform apply`

## After Successful Run
1. (Optional) In **Security > Trust Configuration**, uncheck the **"Available for User Logon"**  checkbox for the Default Identity Provider.

## References
https://github.com/SAP-samples/btp-terraform-samples/tree/main

If you want to schedule the starting of a HANA Cloud instance using Automation Pilot, please refer to the tutorial below:
https://developers.sap.com/tutorials/hana-cloud-automation-pilot.html
