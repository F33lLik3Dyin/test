# Question Bank Online Hoken Kokushi Staging Terraform root module

Question Bank Online 保健師国家試験の検証環境のルートモジュールです。

## Usage

開発者端末からTerraform CLIを使用して保健国試検証環境へ適用する。

```sh
$ export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
$ export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
$ export AWS_DEFAULT_REGION="YOUR_REGION"
$ terraform init
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adminbff"></a> [adminbff](#module\_adminbff) | ../../../modules/bff | n/a |
| <a name="module_adminfrontend"></a> [adminfrontend](#module\_adminfrontend) | ../../../modules/frontend | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../../modules/bastion | n/a |
| <a name="module_batch"></a> [batch](#module\_batch) | ../../../modules/batch | n/a |
| <a name="module_contents_delivery_server"></a> [contents\_delivery\_server](#module\_contents\_delivery\_server) | ../../../modules/strage | n/a |
| <a name="module_database"></a> [database](#module\_database) | ../../../modules/database | n/a |
| <a name="module_userbff"></a> [userbff](#module\_userbff) | ../../../modules/bff | n/a |
| <a name="module_userfrontend"></a> [userfrontend](#module\_userfrontend) | ../../../modules/frontend | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_basic_authentication_password"></a> [basic\_authentication\_password](#input\_basic\_authentication\_password) | value of basic authentication password | `string` | n/a | yes |
| <a name="input_basic_authentication_user_id"></a> [basic\_authentication\_user\_id](#input\_basic\_authentication\_user\_id) | value of basic authentication user id | `string` | n/a | yes |
| <a name="input_rds_master_password"></a> [rds\_master\_password](#input\_rds\_master\_password) | value of the rds master password. | `string` | n/a | yes |
| <a name="input_rds_master_username"></a> [rds\_master\_username](#input\_rds\_master\_username) | value of the rds master username. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
