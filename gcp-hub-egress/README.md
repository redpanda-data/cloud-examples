# GCP Hub Egress — Centralized NAT via VPC Network Peering

This Terraform module provisions a **hub/egress VPC** in your GCP project and wires it to one or more Redpanda BYOC clusters through GCP VPC Network Peering with custom route export.  All internet-bound traffic from the Redpanda cluster exits through a **NAT gateway VM** (running in a size-1 MIG for automatic restart) in the hub VPC — the Redpanda cluster's VPC never needs its own Cloud NAT, Cloud Router, or NAT VM.

## Architecture

```
┌──────────────────────────────────┐         ┌──────────────────────────────────────┐
│  Hub / Egress Project            │         │  Redpanda BYOC Project (spoke)       │
│                                  │         │                                      │
│  ┌────────────────────────────┐  │         │  ┌──────────────────────────────┐    │
│  │  Hub VPC                   │  │         │  │  Redpanda VPC                │    │
│  │  100.64.0.0/20 (default)   │  │         │  │  (your CIDR, e.g. 10.0.0.0/16)    │
│  │                            │  │ Peering │  │                              │    │
│  │  NAT VM (MIG/1) ◄──────────┼──┼─────────┼──┼── nodes (no public IPs)      │    │
│  │  │  export_custom_routes   │  │         │  │  import_custom_routes=true   │    │
│  │  └──► Internet             │  │         │  │  (no Cloud Router / NAT)     │    │
│  └────────────────────────────┘  │         │  └──────────────────────────────┘    │
└──────────────────────────────────┘         └──────────────────────────────────────┘
```

**What this Terraform creates:**
- A hub VPC with a single regional subnet
- Two custom static routes:
  - `0.0.0.0/0 → default-internet-gateway` tagged for the NAT VM only (so the NAT VM can reach the internet directly, priority 100)
  - `0.0.0.0/0 → NAT VM internal IP` untagged at priority 900 — this is the route exported via peering to the Redpanda spoke VPC (`next_hop_ip` routes are exportable; `next_hop_gateway` routes are not)
- A NAT gateway VM (Debian, IP forwarding + iptables masquerade) running in a size-1 MIG with a reserved static internal IP (so the exported route remains valid across MIG instance replacements) and a reserved static public IP
- VPC Network Peerings from hub → each Redpanda VPC with `export_custom_routes = true`, one per entry in `redpanda_vpcs`

**What the Redpanda platform does (on your behalf):**
- Creates the cluster VPC without a Cloud Router or Cloud NAT, and without a local default route
- Creates the reciprocal VPC Network Peering from Redpanda VPC → hub VPC with `import_custom_routes = true`
- The imported `0.0.0.0/0 → NAT VM internal IP` route directs all internet traffic through the hub

> **Note on GCP routing:** Local static routes always beat imported peering routes regardless of priority. The Redpanda spoke VPC must not have its own local `0.0.0.0/0` route — if one exists, it will silently win and traffic will not flow through the hub.

## Prerequisites

- Terraform ≥ 1.0
- GCP credentials for the **hub project** (the account that will own the hub VPC)
- If the hub and Redpanda cluster are in **different GCP projects**, the hub project's compute service account must have `roles/compute.networkPeer` in the Redpanda project (or broader network admin rights) so that the peering can be created

## Usage

### 1. Create the hub infrastructure

The Redpanda VPC name follows the pattern `redpanda-<network_id>` and is visible in the Redpanda Cloud console before cluster creation. You can populate `redpanda_vpcs` on the first apply alongside the hub infrastructure.

```hcl
# terraform.tfvars
project         = "my-hub-project"
region          = "us-central1"
hub_subnet_cidr = "100.64.0.0/20"   # must not overlap with Redpanda VPC CIDR

redpanda_vpcs = {
  "cluster-a" = { vpc_name = "redpanda-abc123", project = "my-redpanda-project" }
  "cluster-b" = { vpc_name = "redpanda-def456" }   # project defaults to var.project
}
```

```bash
terraform init
terraform apply
```

Note the outputs:

```
hub_vpc_name   = "hub-vpc"
hub_project_id = "my-hub-project"
nat_public_ip  = "34.x.x.x"
```

### 2. Create the Redpanda BYOC cluster

When creating your Redpanda BYOC cluster, pass the hub VPC details so that Redpanda skips Cloud Router/NAT creation and imports the default route from the hub.

The Redpanda provisioner will:
1. Create the cluster VPC without a Cloud Router or Cloud NAT, and without a local default route
2. Create a VPC Network Peering from the Redpanda VPC to the hub VPC with `import_custom_routes = true`
3. The imported `0.0.0.0/0` route directs all internet-bound traffic through the hub NAT VM

### 3. Add additional clusters

To peer more Redpanda cluster VPCs with the hub, add entries to `redpanda_vpcs` and re-apply. The module uses `for_each` over this map, so no module modifications are needed:

```hcl
redpanda_vpcs = {
  "cluster-a" = { vpc_name = "redpanda-abc123", project = "my-redpanda-project" }
  "cluster-b" = { vpc_name = "redpanda-def456" }
  "cluster-c" = { vpc_name = "redpanda-ghi789" }   # newly added
}
```

## Variables

| Name | Default | Description |
|------|---------|-------------|
| `project` | (required) | GCP project ID for the hub VPC and NAT gateway VM |
| `region` | (required) | GCP region for all resources |
| `zone` | `""` | GCP zone for the NAT gateway MIG. Defaults to the first available zone in `region` |
| `routing_mode` | `REGIONAL` | VPC routing mode |
| `common_prefix` | `hub` | Prefix applied to all resource names |
| `hub_subnet_cidr` | `100.64.0.0/20` | Hub subnet CIDR. Must not overlap any Redpanda VPC CIDR |
| `redpanda_vpcs` | `{}` | Map of Redpanda BYOC cluster VPCs to peer with the hub. See variable description for shape |
| `nat_machine_type` | `e2-micro` | Machine type for the NAT gateway VM. Size up for higher egress throughput |
| `nat_image` | `debian-cloud/debian-13` | Boot image for the NAT gateway VM |
| `nat_disk_size_gb` | `10` | Boot disk size (GB) for the NAT gateway VM |
| `nat_source_ranges` | RFC-1918 + CGNAT | Source CIDRs allowed to reach the NAT VM for forwarding. Narrow to spoke CIDRs for tighter control |
| `labels` | `{}` | Labels applied to all resources that support labeling (VM, reserved IPs) |

## Outputs

| Name | Description |
|------|-------------|
| `hub_vpc_name` | Hub VPC network name — pass to Redpanda at cluster creation time |
| `hub_vpc_self_link` | Full self-link URL of the hub VPC |
| `hub_project_id` | GCP project ID of the hub VPC |
| `hub_subnet_name` | Name of the hub subnet |
| `nat_public_ip` | Public IP all Redpanda egress traffic appears from |

## Important notes

**Custom route export requires `next_hop_ip`.** GCP's VPC Network Peering only exports *custom* routes, and only those with `next_hop_ip` or `next_hop_instance` — routes with `next_hop_gateway = "default-internet-gateway"` are never exported. This module uses a reserved static internal IP for the NAT VM and exports a `0.0.0.0/0 → NAT internal IP` route. A separate tagged route (`nat-direct`) with `next_hop_gateway` is used only by the NAT VM itself so it can reach the internet directly.

**CIDR overlap.** `hub_subnet_cidr` must not overlap the Redpanda cluster VPC CIDR. GCP will reject the peering if CIDRs overlap. The default `100.64.0.0/20` (CGNAT range) avoids common enterprise ranges.

**Multiple clusters.** VPC Network Peering is point-to-point. The module supports multiple Redpanda clusters via `for_each` over `redpanda_vpcs` — add an entry per cluster, no module changes needed.

**Cross-project peering.** When hub and Redpanda VPCs are in different GCP projects, the principal running Terraform for this module needs `roles/compute.networkPeer` (or equivalent) in the Redpanda project so GCP allows creating the peering from the hub side.

**NAT throughput.** The NAT VM funnels all internet egress for peered clusters through a single instance. `e2-micro` is shared-core with a low per-VM egress bandwidth cap. Set `nat_machine_type` to a larger type if the NAT becomes a throughput bottleneck.
