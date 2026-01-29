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
        ssh_authorized_keys = [tls_private_key.key.public_key_openssh]
      }
    ],
    package_upgrade = true,
    write_files = [
      {
        path        = "/usr/local/bin/install-rpk.sh",
        owner       = "root:root",
        permissions = "0755",
        content     = file("${path.module}/files/install-rpk.sh")
      },
    ]
  }
}
