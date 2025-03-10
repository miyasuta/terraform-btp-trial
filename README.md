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
Alternatively, you can enable SSO by setting BTP_ENABLE_SSO to true.
```
export BTP_ENABLE_SSO=true
```

4. Run `terraform init`
5. If a trust with an IAS tenant has already been established in your trial subaccount, run: `terraform import btp_subaccount_trust_configuration.trial <subaccount_id>,sap.custom`
6. Run `terraform apply`

## After Successful Run
1. (Optional) In **Security > Trust Configuration**, uncheck the **"Available for User Logon"**  checkbox for the Default Identity Provider.

## Troubleshooting
If you encounter the following error, simply executing `terraform apply` will resolve the issue.

![image](https://github.com/user-attachments/assets/f5306adf-fbdf-4baa-95e5-6a5c6df0fa47)

## References
https://github.com/SAP-samples/btp-terraform-samples/tree/main

If you want to schedule the starting of a HANA Cloud instance using Automation Pilot, please refer to the tutorial below:
https://developers.sap.com/tutorials/hana-cloud-automation-pilot.html
