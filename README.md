## What does this Terraform project do?
1. Creates HANA Cloud instance and adds admin users
2. Subscribes to SAP Build Work Zone, standard edition and adds admin users
3. Creates subacount in Singapore region, subscribe to Automation Pilot and adds admin users

## How to use
1. Clone this repository
2. Add `terraform.tfvars` file to the root directory with following contents:
```terraform
# Your global account subdomain
globalaccount = ""

# The admin users
admins  = [""]

# Comment out the next line if you want to provide the password here instead of typing it in the console (not recommended for security reasons)
hana_system_password = ""

# ID of trial subaccount
subaccount_id = ""
```
3. Run `terraform init`
4. Run `Terraform apply`

## Reference
https://github.com/SAP-samples/btp-terraform-samples/tree/main