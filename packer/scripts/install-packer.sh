#!/bin/bash

set -ex

# install packer
yum install -y git yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install packer

