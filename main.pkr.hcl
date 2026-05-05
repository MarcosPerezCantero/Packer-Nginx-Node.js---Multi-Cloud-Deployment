packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = ">= 2.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "azure_subscription_id" {
  default = ""
}

variable "azure_client_id" {
  default = ""
}

variable "azure_client_secret" {
  default   = ""
  sensitive = true
}

variable "azure_tenant_id" {
  default = ""
}

# Builder AWS
source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-nginx-node-{{timestamp}}"
  instance_type = "t3.micro"
  region        = var.region
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  associate_public_ip_address = true
}

# Builder Azure
source "azure-arm" "ubuntu" {
  subscription_id                   = var.azure_subscription_id
  client_id                         = var.azure_client_id
  client_secret                     = var.azure_client_secret
  tenant_id                         = var.azure_tenant_id
  managed_image_resource_group_name = "packer-rg"
  managed_image_name                = "packer-nginx-node-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts"

  location = "westeurope"
  vm_size  = "Standard_B1s"

  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.azure-arm.ubuntu"
  ]

  provisioner "shell" {
    script = "install.sh"
  }

  provisioner "shell" {
    only   = ["azure-arm.ubuntu"]
    inline = [
      "sudo waagent -deprovision+user -force"
    ]
  }
}
