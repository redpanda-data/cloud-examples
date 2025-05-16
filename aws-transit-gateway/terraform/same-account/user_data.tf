# NOTE: THE TF FILES ARE ASLO USED BY THE AWS PRIVATE LINK CERTIFICATION TESTS. MAKE SURE TO RUN THE CERTIFICATION TESTS IF MODIFIED.
locals {
  vm_user_data = {
    users = [
      "default",
      {
        name                = "redpanda",
        gecos               = "redpanda",
        primary_group       = "redpanda",
        sudo                = "ALL=(ALL) NOPASSWD:ALL",
        shell               = "/bin/bash",
        groups              = "users,adm",
        lock_passwd         = false,
        ssh_authorized_keys = [tls_private_key.test.public_key_openssh]
      }
    ],
    package_upgrade = true,
    write_files = [
      {
        path        = "/usr/local/bin/test-transit-gateway.sh",
        owner       = "root:root",
        permissions = "0755",
        content = templatefile(
          "${path.module}/files/test-transit-gateway.sh", {
            kafka_seed_url      = var.rp_kafka_seed_url,
            http_proxy_seed_url = var.rp_http_proxy_seed_url,
            schema_registry_url = var.rp_schema_registry_url,
            console_url         = var.rp_console_url,
        })
      },
      {
        path        = "/usr/local/bin/install-rpk.sh",
        owner       = "root:root",
        permissions = "0755",
        content     = file("${path.module}/files/install-rpk.sh")
      },
    ]
  }
}
