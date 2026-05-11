locals {
  hub_aws_account_id = (
    var.hub_aws_account_id != ""
    ? var.hub_aws_account_id
    : data.aws_caller_identity.current.account_id
  )
  create_ram_share = var.spoke_aws_account_id != local.hub_aws_account_id
}
