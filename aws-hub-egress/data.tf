# Share the TGW with cluster's AWS account via Resource Access Manager.
# Skipped when cluster's account is the same as the owning account (RAM rejects self-sharing).
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
