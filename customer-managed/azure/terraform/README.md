<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =3.98.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.98.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.console](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/key_vault) | resource |
| [azurerm_key_vault.vault](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/key_vault) | resource |
| [azurerm_nat_gateway.redpanda](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_prefix_association.redpanda](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/nat_gateway_public_ip_prefix_association) | resource |
| [azurerm_network_security_group.redpanda_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.redpanda_connectors](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.allow_inbound_to_redpanda_brokers_nodeport](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip_prefix.redpanda](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/public_ip_prefix) | resource |
| [azurerm_resource_group.all](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.agent](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.assign_identity_storage_blob_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.external_dns_rgreader](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.external_dns_zone_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kafka_connect](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.redpanda_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.redpanda_console](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.redpanda_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vault_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.kafka_connect](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_definition) | resource |
| [azurerm_role_definition.redpanda_agent](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_definition) | resource |
| [azurerm_role_definition.redpanda_console](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_definition) | resource |
| [azurerm_role_definition.redpanda_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/role_definition) | resource |
| [azurerm_storage_account.management](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/storage_account) | resource |
| [azurerm_storage_account.tiered_storage](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.redpanda_cloud_storage](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.management](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/storage_container) | resource |
| [azurerm_storage_container.tiered_storage](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/storage_container) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/subnet) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.redpanda](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.external_dns](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.kafka_connect](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.redpanda_agent](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.redpanda_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.redpanda_console](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.redpanda](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/data-sources/client_config) | data source |
| [azurerm_location.redpanda](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/data-sources/location) | data source |
| [azurerm_resource_group.all](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_network.redpanda](https://registry.terraform.io/providers/hashicorp/azurerm/3.98.0/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_identity_name"></a> [aks\_identity\_name](#input\_aks\_identity\_name) | The name of user assigned identity for AKS. | `string` | `"aks-uai"` | no |
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | The client ID of the application used to authenticate with Azure | `string` | `""` | no |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | The client secret of the application used to authenticate with Azure | `string` | `""` | no |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | The subscription ID where the Redpanda cluster will live | `string` | `"60fc0bed-3072-4c53-906a-d130a934d520"` | no |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | The subscription ID where the Redpanda cluster will live | `string` | `"9a95fd9e-005d-487a-9a01-d08c1eab2757"` | no |
| <a name="input_azure_use_cli"></a> [azure\_use\_cli](#input\_azure\_use\_cli) | Whether to use the Azure CLI or Azure API directly | `bool` | `true` | no |
| <a name="input_azure_use_msi"></a> [azure\_use\_msi](#input\_azure\_use\_msi) | Whether to use Azure Managed Identity authentication (formerly MSI) | `bool` | `false` | no |
| <a name="input_azure_use_oidc"></a> [azure\_use\_oidc](#input\_azure\_use\_oidc) | Whether to use Azure OIDC authentication | `bool` | `false` | no |
| <a name="input_create_nat"></a> [create\_nat](#input\_create\_nat) | Whether to create NAT gateway and its assoications | `bool` | `true` | no |
| <a name="input_create_resource_groups"></a> [create\_resource\_groups](#input\_create\_resource\_groups) | If true, the module will create resource groups for Redpanda resources. | `bool` | `true` | no |
| <a name="input_create_role_assignment"></a> [create\_role\_assignment](#input\_create\_role\_assignment) | Whether to create role assigments. | `bool` | `true` | no |
| <a name="input_egress_subnets"></a> [egress\_subnets](#input\_egress\_subnets) | A list of CIDR ranges to use for the *egress* subnets. They needs to be at least /24. | `map(map(string))` | <pre>{<br>  "agent-public": {<br>    "cidr": "10.0.0.0/24",<br>    "name": "snet-agent-public"<br>  }<br>}</pre> | no |
| <a name="input_kafka_connect_identity_name"></a> [kafka\_connect\_identity\_name](#input\_kafka\_connect\_identity\_name) | The name of user assigned identity for Kafka Connect. | `string` | `"kafka-connect-uai"` | no |
| <a name="input_kafka_connect_role_name"></a> [kafka\_connect\_role\_name](#input\_kafka\_connect\_role\_name) | The role name of Kafka Connect. | `string` | `"kafka-connect-role"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of CIDR ranges to use for the *private* subnets. They needs to be at least /24. | `map(map(string))` | <pre>{<br>  "agent-private": {<br>    "cidr": "10.0.3.0/24",<br>    "name": "snet-agent-private"<br>  },<br>  "connect-pod": {<br>    "cidr": "10.0.10.0/24",<br>    "name": "snet-connect-pods"<br>  },<br>  "connect-vnet": {<br>    "cidr": "10.0.11.0/24",<br>    "name": "snet-connect-vnet"<br>  },<br>  "kafka-connect-pod": {<br>    "cidr": "10.0.12.0/24",<br>    "name": "snet-kafka-connect-pods"<br>  },<br>  "kafka-connect-vnet": {<br>    "cidr": "10.0.13.0/24",<br>    "name": "snet-kafka-connect-vnet"<br>  },<br>  "rp-0-pods": {<br>    "cidr": "10.0.4.0/24",<br>    "name": "snet-rp-0-pods"<br>  },<br>  "rp-0-vnet": {<br>    "cidr": "10.0.5.0/24",<br>    "name": "snet-rp-0-vnet"<br>  },<br>  "rp-1-pods": {<br>    "cidr": "10.0.6.0/24",<br>    "name": "snet-rp-1-pods"<br>  },<br>  "rp-1-vnet": {<br>    "cidr": "10.0.7.0/24",<br>    "name": "snet-rp-1-vnet"<br>  },<br>  "rp-2-pods": {<br>    "cidr": "10.0.8.0/24",<br>    "name": "snet-rp-2-pods"<br>  },<br>  "rp-2-vnet": {<br>    "cidr": "10.0.9.0/24",<br>    "name": "snet-rp-2-vnet"<br>  },<br>  "system-pod": {<br>    "cidr": "10.0.1.0/24",<br>    "name": "snet-system-pods"<br>  },<br>  "system-vnet": {<br>    "cidr": "10.0.2.0/24",<br>    "name": "snet-system-vnet"<br>  }<br>}</pre> | no |
| <a name="input_redpanda_agent_identity_name"></a> [redpanda\_agent\_identity\_name](#input\_redpanda\_agent\_identity\_name) | The name of user assigned identity for Redpanda agent. | `string` | `"agent-uai"` | no |
| <a name="input_redpanda_agent_role_name"></a> [redpanda\_agent\_role\_name](#input\_redpanda\_agent\_role\_name) | The role name of Redpanda agent. | `string` | `"agent-role"` | no |
| <a name="input_redpanda_cert_manager_identity_name"></a> [redpanda\_cert\_manager\_identity\_name](#input\_redpanda\_cert\_manager\_identity\_name) | The name of user assigned identity for cert-manager. | `string` | `"cert-manager-uai"` | no |
| <a name="input_redpanda_cluster_identity_name"></a> [redpanda\_cluster\_identity\_name](#input\_redpanda\_cluster\_identity\_name) | The name of user assigned identity for Redpanda cluster. | `string` | `"cluster-uai"` | no |
| <a name="input_redpanda_console_identity_name"></a> [redpanda\_console\_identity\_name](#input\_redpanda\_console\_identity\_name) | The name of user assigned identity for Redpanda Console. | `string` | `"console-uai"` | no |
| <a name="input_redpanda_console_key_vault_name"></a> [redpanda\_console\_key\_vault\_name](#input\_redpanda\_console\_key\_vault\_name) | The name of key vault for Redpanda Console | `string` | `"console-vault"` | no |
| <a name="input_redpanda_console_role_name"></a> [redpanda\_console\_role\_name](#input\_redpanda\_console\_role\_name) | The role name of Redpanda Console. | `string` | `"console-role"` | no |
| <a name="input_redpanda_external_dns_identity_name"></a> [redpanda\_external\_dns\_identity\_name](#input\_redpanda\_external\_dns\_identity\_name) | The name of user assigned identity for external-dns. | `string` | `"external-dns-uai"` | no |
| <a name="input_redpanda_iam_resource_group_name"></a> [redpanda\_iam\_resource\_group\_name](#input\_redpanda\_iam\_resource\_group\_name) | The name of the resource group to place Redpanda IAM resources. | `string` | `"iam-rg"` | no |
| <a name="input_redpanda_management_key_vault_name"></a> [redpanda\_management\_key\_vault\_name](#input\_redpanda\_management\_key\_vault\_name) | The name of key vault for Redpanda management | `string` | `"rp-vault"` | no |
| <a name="input_redpanda_management_storage_account_name"></a> [redpanda\_management\_storage\_account\_name](#input\_redpanda\_management\_storage\_account\_name) | Azure Blob Storage account name for Redpanda management storage. | `string` | `"managementa"` | no |
| <a name="input_redpanda_management_storage_container_name"></a> [redpanda\_management\_storage\_container\_name](#input\_redpanda\_management\_storage\_container\_name) | Name of the storage container for Redpanda management storage | `string` | `"managementc"` | no |
| <a name="input_redpanda_network_resource_group_name"></a> [redpanda\_network\_resource\_group\_name](#input\_redpanda\_network\_resource\_group\_name) | The name of the resource group to place Redpanda network resources. | `string` | `"network-rg"` | no |
| <a name="input_redpanda_private_link_role_name"></a> [redpanda\_private\_link\_role\_name](#input\_redpanda\_private\_link\_role\_name) | The role name of Redpanda private link. | `string` | `"private-link-role"` | no |
| <a name="input_redpanda_resource_group_name"></a> [redpanda\_resource\_group\_name](#input\_redpanda\_resource\_group\_name) | The name of the resource group to place Redpanda resources. | `string` | `"redpanda-rg"` | no |
| <a name="input_redpanda_security_group_name"></a> [redpanda\_security\_group\_name](#input\_redpanda\_security\_group\_name) | The name of Redpanda cluster security group | `string` | `"redpanda-nsg"` | no |
| <a name="input_redpanda_storage_resource_group_name"></a> [redpanda\_storage\_resource\_group\_name](#input\_redpanda\_storage\_resource\_group\_name) | The name of the resource group to place Redpanda storage resources. | `string` | `"storage-rg"` | no |
| <a name="input_redpanda_tiered_storage_account_name"></a> [redpanda\_tiered\_storage\_account\_name](#input\_redpanda\_tiered\_storage\_account\_name) | Azure Blob Storage account name for Redpanda tiered storage. | `string` | `"tieredstoragea"` | no |
| <a name="input_redpanda_tiered_storage_container_name"></a> [redpanda\_tiered\_storage\_container\_name](#input\_redpanda\_tiered\_storage\_container\_name) | Name of the storage container for Redpanda tiered storage | `string` | `"tieredstoragec"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the resources live. | `string` | `"eastus"` | no |
| <a name="input_reserved_subnet_cidrs"></a> [reserved\_subnet\_cidrs](#input\_reserved\_subnet\_cidrs) | Reserved CIDRs for AKS | `map(string)` | <pre>{<br>  "k8s-service": "10.0.15.0/24"<br>}</pre> | no |
| <a name="input_resource_group_name_prefix"></a> [resource\_group\_name\_prefix](#input\_resource\_group\_name\_prefix) | The prefix added to the name of resource group. | `string` | `""` | no |
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | The prefix added to the name of non resource group resource. | `string` | `"pz-"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to use when labeling resources. These will be set inside the provider block<br>as default tags. | `map(string)` | n/a | yes |
| <a name="input_vnet_addresses"></a> [vnet\_addresses](#input\_vnet\_addresses) | The list of IP address prefixes used by vnet. | `list(string)` | <pre>[<br>  "10.0.0.0/20"<br>]</pre> | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the network. If empty, a VNET will be created. | `string` | `""` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Physical availability zone ID. Ex: eastus-az1, eastus-az3, eastus-az2 | `list(string)` | <pre>[<br>  "eastus-az2"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_private_subnet_name"></a> [agent\_private\_subnet\_name](#output\_agent\_private\_subnet\_name) | Agent private subnet name |
| <a name="output_agent_user_assigned_identity_name"></a> [agent\_user\_assigned\_identity\_name](#output\_agent\_user\_assigned\_identity\_name) | Agent user assigned identity name |
| <a name="output_aks_user_assigned_identity_name"></a> [aks\_user\_assigned\_identity\_name](#output\_aks\_user\_assigned\_identity\_name) | AKS user assigned identity name |
| <a name="output_cert_manager_user_assigned_identity_name"></a> [cert\_manager\_user\_assigned\_identity\_name](#output\_cert\_manager\_user\_assigned\_identity\_name) | Cert manager user assigned identity name |
| <a name="output_cluster_user_assigned_identity_name"></a> [cluster\_user\_assigned\_identity\_name](#output\_cluster\_user\_assigned\_identity\_name) | Redpanda cluster user assigned identity name |
| <a name="output_console_key_vault_name"></a> [console\_key\_vault\_name](#output\_console\_key\_vault\_name) | Console key vault name |
| <a name="output_console_user_assigned_identity_name"></a> [console\_user\_assigned\_identity\_name](#output\_console\_user\_assigned\_identity\_name) | Redpanda console user assigned identity name |
| <a name="output_egress_subnet_name"></a> [egress\_subnet\_name](#output\_egress\_subnet\_name) | Egress subnet name |
| <a name="output_external_dns_user_assigned_identity_name"></a> [external\_dns\_user\_assigned\_identity\_name](#output\_external\_dns\_user\_assigned\_identity\_name) | External DNS user assigned identity name |
| <a name="output_iam_resource_group_name"></a> [iam\_resource\_group\_name](#output\_iam\_resource\_group\_name) | IAM resource group name |
| <a name="output_identities"></a> [identities](#output\_identities) | User assigned identities |
| <a name="output_kafka_connect_pods_subnet_name"></a> [kafka\_connect\_pods\_subnet\_name](#output\_kafka\_connect\_pods\_subnet\_name) | Kafka connect pods subnet name |
| <a name="output_kafka_connect_user_assigned_identity_name"></a> [kafka\_connect\_user\_assigned\_identity\_name](#output\_kafka\_connect\_user\_assigned\_identity\_name) | Redpanda Kafka Connect user assigned identity name |
| <a name="output_kafka_connect_vnet_subnet_name"></a> [kafka\_connect\_vnet\_subnet\_name](#output\_kafka\_connect\_vnet\_subnet\_name) | Kafka connect vnet subnet name |
| <a name="output_management_bucket_storage_account_name"></a> [management\_bucket\_storage\_account\_name](#output\_management\_bucket\_storage\_account\_name) | Management bucket storage account name |
| <a name="output_management_bucket_storage_container_name"></a> [management\_bucket\_storage\_container\_name](#output\_management\_bucket\_storage\_container\_name) | Management bucket storage container name |
| <a name="output_management_key_vault_name"></a> [management\_key\_vault\_name](#output\_management\_key\_vault\_name) | Management key vault name |
| <a name="output_network_resource_group_name"></a> [network\_resource\_group\_name](#output\_network\_resource\_group\_name) | Network resource group name |
| <a name="output_networks"></a> [networks](#output\_networks) | Networks |
| <a name="output_redpanda_resource_group_name"></a> [redpanda\_resource\_group\_name](#output\_redpanda\_resource\_group\_name) | Redpanda resource group name |
| <a name="output_redpanda_security_group_name"></a> [redpanda\_security\_group\_name](#output\_redpanda\_security\_group\_name) | Redpanda security group name |
| <a name="output_resource_groups"></a> [resource\_groups](#output\_resource\_groups) | Resource groups |
| <a name="output_roles"></a> [roles](#output\_roles) | IAM roles |
| <a name="output_rp_0_pods_subnet_name"></a> [rp\_0\_pods\_subnet\_name](#output\_rp\_0\_pods\_subnet\_name) | Redpanda 0 pods subnet name |
| <a name="output_rp_0_vnet_subnet_name"></a> [rp\_0\_vnet\_subnet\_name](#output\_rp\_0\_vnet\_subnet\_name) | Redpanda 0 vnet subnet name |
| <a name="output_rp_1_pods_subnet_name"></a> [rp\_1\_pods\_subnet\_name](#output\_rp\_1\_pods\_subnet\_name) | Redpanda 1 pods subnet name |
| <a name="output_rp_1_vnet_subnet_name"></a> [rp\_1\_vnet\_subnet\_name](#output\_rp\_1\_vnet\_subnet\_name) | Redpanda 1 vnet subnet name |
| <a name="output_rp_2_pods_subnet_name"></a> [rp\_2\_pods\_subnet\_name](#output\_rp\_2\_pods\_subnet\_name) | Redpanda 2 pods subnet name |
| <a name="output_rp_2_vnet_subnet_name"></a> [rp\_2\_vnet\_subnet\_name](#output\_rp\_2\_vnet\_subnet\_name) | Redpanda 2 vnet subnet name |
| <a name="output_rp_connect_pods_subnet_name"></a> [rp\_connect\_pods\_subnet\_name](#output\_rp\_connect\_pods\_subnet\_name) | Redpanda connect pods subnet name |
| <a name="output_rp_connect_vnet_subnet_name"></a> [rp\_connect\_vnet\_subnet\_name](#output\_rp\_connect\_vnet\_subnet\_name) | Redpanda connect vnet subnet name |
| <a name="output_security"></a> [security](#output\_security) | Security groups |
| <a name="output_storage"></a> [storage](#output\_storage) | Storage |
| <a name="output_storage_resource_group_name"></a> [storage\_resource\_group\_name](#output\_storage\_resource\_group\_name) | Storage resource group name |
| <a name="output_system_pods_subnet_name"></a> [system\_pods\_subnet\_name](#output\_system\_pods\_subnet\_name) | System pods subnet name |
| <a name="output_system_vnet_subnet_name"></a> [system\_vnet\_subnet\_name](#output\_system\_vnet\_subnet\_name) | System vnet subnet name |
| <a name="output_tiered_storage_account_name"></a> [tiered\_storage\_account\_name](#output\_tiered\_storage\_account\_name) | tiered storage account name |
| <a name="output_tiered_storage_container_name"></a> [tiered\_storage\_container\_name](#output\_tiered\_storage\_container\_name) | tiered storage container name |
| <a name="output_vault"></a> [vault](#output\_vault) | Key vault |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | VNet name |
<!-- END_TF_DOCS -->