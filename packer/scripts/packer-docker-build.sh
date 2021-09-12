#!/bin/bash

yum install -y git yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install packer

#ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
#git clone git@github.com:aiera-inc/gentle.git
git clone https://github.com/aiera-inc/gentle
cd gentle
packer init packer/docker-build.pkr.hcl
PACKER_LOG=1 packer build packer/docker-build.pkr.hcl

