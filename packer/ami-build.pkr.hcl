packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ecs_gpu_optimized" {
  ami_name      = "ECS-and-GPU-Optimized-CUDA-v10-{{isotime `2006-01-02-15h04m`}}"
  instance_type = "g4dn.2xlarge"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-ecs-gpu-hvm-2.0.20190402*"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
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
    scripts         = ["./scripts/user-data.sh"]
  }
  provisioner "file" {
    source      = "./files/amazon-cloudwatch-agent.json"
    destination = "/home/ec2-user/amazon-cloudwatch-agent.json"
  }
  provisioner "file" {
    source      = "./files/sdm_ca.pub"
    destination = "/home/ec2-user/sdm_ca.pub"
  }
  provisioner "file" {
    source      = "./files/gpumon.service"
    destination = "/home/ec2-user/gpumon.service"
  }
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    scripts         = ["./scripts/gpumon.sh"]
  }
}

