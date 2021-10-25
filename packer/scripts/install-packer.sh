#!/bin/bash

set -ex

# install packer
yum install -y awscli git yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install packer

