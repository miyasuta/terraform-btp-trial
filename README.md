## What does this Terraform project do?
1. Creates HANA Cloud instance and adds admin users
2. Subscribes to SAP Build Work Zone, standard edition and adds admin users
3. Creates subacount in Singapore region, subscribe to Automation Pilot and adds admin users

## How to use
1. Clone this repository
2. Add `terraform.tfvars` file to the root directory with following contents:
```terraform
# Your global account subdomain: e.g., 9fcf6fb2trial-ga
# You can check it from the global account > gear icon > General > Global Account Subdomain
globalaccount = ""

# The admin users
admins  = [""]

# Comment out the next line if you want to provide the password here instead of typing it in the console (not recommended for security reasons)
hana_system_password = ""

# ID of trial subaccount
subaccount_id = ""

# Service plan name for integration suite: e.g., it-cpitrial05-prov
# You can check it from the Service Marketplace by selecting Create > Integration Suite
integration_suite_app_name = ""
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
5. Run `terraform apply`

## Reference
https://github.com/SAP-samples/btp-terraform-samples/tree/main
