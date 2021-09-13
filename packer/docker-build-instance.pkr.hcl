packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ecs_gpu_optimized" {
  ami_name             = "ECS-and-GPU-Optimized-CUDA-v10-{{isotime `2006-01-02-15h04m`}}"
  instance_type        = "g4dn.2xlarge"
  region               = "us-east-1"
  skip_create_ami      = true
  iam_instance_profile = "PackerBuild"
  source_ami_filter {
    filters = {
      name                = "ECS-and-GPU-Optimized-CUDA-v10*"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["121356702072"]
  }
  ssh_username = "ec2-user"
}

build {
  name = "ECS-and-GPU-Optimized-CUDA-v10-{{isotime `2006-01-02`}}"
  sources = [
    "source.amazon-ebs.ecs_gpu_optimized"
  ]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    scripts         = ["./scripts/install-packer.sh"]
  }
  # run as ec2-user
  provisioner "shell" {
    scripts = ["./scripts/gentle-docker-build.sh"]
  }
}

