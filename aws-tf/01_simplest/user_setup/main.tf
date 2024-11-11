variable "username" {
  description = "The username to create"
  type        = string
}

variable "public_key" {
  description = "The public SSH key to add to the user's authorized_keys"
  type        = string
}

variable "script_file" {
  description = "The path to the file with the user setup script"
  type        = string
  default     = "user-setup-script.sh"
}

resource "local_file" "user_script" {
  content  = <<-EOT
    #!/bin/bash
    useradd ${var.username}
    usermod -aG sudo ${var.username}
    mkdir -p /home/${var.username}/.ssh
    echo "${var.public_key}" >> /home/${var.username}/.ssh/authorized_keys
    chmod 600 /home/${var.username}/.ssh/authorized_keys
    chown -R ${var.username}:${var.username} /home/${var.username}/.ssh
  EOT
  filename = "${path.module}/${var.script_file}"
}

output "script_file_path" {
  description = "The full path to the file with the user setup script"
  value = local_file.user_script.filename
}
