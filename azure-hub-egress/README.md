# Azure Hub Egress — Centralized Internet Exit via Azure Firewall + VNet Peering

This Terraform module provisions a **hub VNet** in your Azure subscription with an Azure Firewall as the centralized internet exit point for one or more Redpanda BYOC clusters.  All internet-bound traffic from Redpanda cluster VNets is routed through the hub via VNet Peering with Gateway Transit — the Redpanda VNet never needs its own NAT Gateway.

## Architecture

```
┌──────────────────────────────────────┐         ┌──────────────────────────────────────┐
│  Hub / Egress Subscription           │         │  Redpanda BYOC Subscription (spoke)  │
│                                      │         │                                      │
│  ┌──────────────────────────────┐    │         │  ┌──────────────────────────────┐    │
│  │  Hub VNet  10.255.0.0/16     │    │         │  │  Redpanda VNet               │    │
│  │                              │    │ VNet    │  │  (your CIDR, e.g.10.0.0.0/20)│    │
│  │  AzureFirewallSubnet         │    │ Peering │  │                              │    │
│  │  │  Azure Firewall ◄─────────┼────┼─────────┼──┼── private subnets            │    │
│  │  │  allow_gateway_transit    │    │         │  │  UDR: 0.0.0.0/0 → fw IP     │    │
│  │  └──► Internet               │    │         │  │  (no NAT Gateway)            │    │
│  └──────────────────────────────┘    │         │  └──────────────────────────────┘    │
└──────────────────────────────────────┘         └──────────────────────────────────────┘
```

**What this Terraform creates:**
- A resource group and hub VNet with a dedicated `AzureFirewallSubnet`
- A static public IP (Standard SKU) assigned to the firewall
- An Azure Firewall (Standard tier) with a permissive allow-all egress policy
- A Firewall Policy with a network rule collection that allows all outbound traffic (restrict before production use)
- VNet peerings from the hub → each Redpanda VNet with `allow_gateway_transit = true`, one per entry in `redpanda_vnets`

**What the Redpanda platform does (on your behalf):**
- Creates the cluster VNet and private subnets **without** a NAT Gateway
- Creates the reciprocal VNet peering from the Redpanda VNet → hub VNet with `allow_forwarded_traffic = true`
- Associates a User Defined Route (UDR) on each private subnet: `0.0.0.0/0 → hub firewall private IP`

> **Cost note:** Azure Firewall Standard costs approximately **$1.25/hr** plus data processing fees. Destroy the hub when it is not in use.

## Prerequisites

- Terraform ≥ 1.0
- Azure credentials for the **hub subscription** (the account that will own the hub VNet and firewall)
- The Redpanda BYOC cluster VNet must exist before adding it to `redpanda_vnets` — provision the cluster network first, then re-apply this module to create the peering

## Usage

### 1. Create the hub infrastructure

```hcl
# terraform.tfvars
subscription_id        = "00000000-0000-0000-0000-000000000000"
location               = "eastus2"
hub_vnet_address_space = ["10.255.0.0/16"]   # must not overlap Redpanda VNet CIDR
hub_firewall_subnet_cidr = "10.255.0.0/26"   # must be within hub_vnet_address_space
```

```bash
terraform init
terraform apply
```

Note the outputs — all five are required when creating the Redpanda BYOC cluster:

```
hub_vnet_name           = "hub-vnet"
hub_vnet_id             = "/subscriptions/.../virtualNetworks/hub-vnet"
hub_resource_group_name = "hub-egress-rg"
firewall_private_ip     = "10.255.0.4"
firewall_public_ip      = "20.x.x.x"
```

### 2. Create the Redpanda BYOC cluster with hub egress

When creating your Redpanda BYOC cluster, pass all five outputs above. Redpanda will:
- Skip NAT Gateway creation
- Create the reciprocal VNet peering (`allow_forwarded_traffic = true`) from the Redpanda VNet → hub VNet
- Associate a UDR on each private subnet routing `0.0.0.0/0` to the hub firewall private IP

### 3. Add the hub → spoke peering

After the Redpanda cluster VNet is provisioned, retrieve the Redpanda VNet resource ID:

```bash
az network vnet list --resource-group <redpanda-network-rg> --query "[].id" -o tsv
```

Add it to `redpanda_vnets` and re-apply:

```hcl
# terraform.tfvars
redpanda_vnets = {
  "cluster-a" = {
    vnet_id = "/subscriptions/00000000-.../resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/rp-vnet"
  }
}
```

```bash
terraform apply
```

This creates the hub → spoke peering with `allow_gateway_transit = true`. Once both peerings exist (hub → spoke and spoke → hub), the UDR routes in the Redpanda subnets direct all internet traffic through the Azure Firewall.

### 4. Verify egress IP

After the cluster is running, confirm traffic exits from the expected public IP:

```bash
# From a Redpanda node or test pod in the cluster network
curl -s https://api.ipify.org
# Should return the firewall_public_ip output from this module
```

### 5. Add additional clusters

To route more Redpanda cluster VNets through the same hub, add entries to `redpanda_vnets` and re-apply. All clusters share the same Azure Firewall and exit from the same public IP:

```hcl
redpanda_vnets = {
  "cluster-a" = { vnet_id = "/subscriptions/.../virtualNetworks/rp-vnet-a" }
  "cluster-b" = { vnet_id = "/subscriptions/.../virtualNetworks/rp-vnet-b" }   # newly added
}
```

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `subscription_id` | (required) | Azure subscription ID for hub resources |
| `location` | (required) | Azure region for all resources |
| `resource_group_name` | `hub-egress-rg` | Resource group name for hub resources |
| `common_prefix` | `hub` | Prefix applied to all resource names |
| `hub_vnet_address_space` | `["10.255.0.0/16"]` | Hub VNet address space. Must not overlap any Redpanda VNet CIDR |
| `hub_firewall_subnet_cidr` | `10.255.0.0/26` | AzureFirewallSubnet CIDR. Must be /26 or larger |
| `redpanda_vnets` | `{}` | Map of Redpanda VNets to peer with the hub. See variable description for shape |
| `tags` | `{}` | Tags applied to all resources |
| `client_id` | `""` | Service principal client ID (leave empty for CLI/MSI auth) |
| `client_secret` | `""` | Service principal client secret (leave empty for CLI/MSI auth) |
| `tenant_id` | `""` | Azure tenant ID |
| `use_cli` | `true` | Use Azure CLI for authentication |
| `use_msi` | `false` | Use MSI for authentication |
| `use_oidc` | `false` | Use OIDC for authentication |

## Outputs

| Name | Description |
|------|-------------|
| `hub_vnet_name` | Hub VNet name — required by Redpanda at cluster creation |
| `hub_vnet_id` | Hub VNet resource ID — required by Redpanda to create the spoke→hub peering |
| `hub_resource_group_name` | Resource group of the hub — required by Redpanda at cluster creation |
| `firewall_private_ip` | Firewall private IP — Redpanda creates a UDR on spoke subnets routing `0.0.0.0/0` here |
| `firewall_public_ip` | Firewall public IP — all Redpanda egress traffic will appear from this address |

## Important notes

**CIDR overlap.** `hub_vnet_address_space` must not overlap the Redpanda cluster VNet address space. Azure rejects the peering if address spaces overlap.

**Peering is bidirectional.** VNet peering requires creation on both sides. This module creates the hub → spoke peering (`allow_gateway_transit = true`). The Redpanda platform creates the spoke → hub peering (`allow_forwarded_traffic = true`) during cluster provisioning. Both peerings must be `Connected` before traffic flows.

**UDR takes precedence.** The spoke subnets use a User Defined Route (`0.0.0.0/0 → firewall private IP`) created by Redpanda. This UDR routes internet-bound traffic to the hub firewall instead of the removed NAT Gateway.

**Multiple clusters.** VNet peering is point-to-point. Each Redpanda cluster VNet needs a separate peering entry in `redpanda_vnets`. Re-apply this module after each new cluster is provisioned.

**Firewall provisioning time.** Azure Firewall Standard takes 5–10 minutes to provision. `terraform apply` will wait for the firewall to reach a running state before completing.

**Allow-all rule.** The default firewall policy allows all outbound traffic for initial setup. Restrict it to required destinations before using in production (e.g. allow specific FQDN collections for Redpanda services, container registries, and OS package updates).
