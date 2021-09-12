#!/bin/bash

set -ex

# fetch gentle
git clone https://github.com/aiera-inc/gentle

# build gentle container image
cd gentle
git checkout packer # FIXME
git submodule init
git submodule update
aws ecr get-login-password --region region | docker login --username AWS --password-stdin 121356702072.dkr.ecr.region.amazonaws.com
docker pull 121356702072.dkr.ecr.us-east-1.amazonaws.com/gentle:latest
docker build -f Dockerfile -t 121356702072.dkr.ecr.us-east-1.amazonaws.com/gentle:latest .

# push gentle container image
cd packer
PACKER_LOG=1 packer init docker-build.pkr.hcl
PACKER_LOG=1 packer build docker-build.pkr.hcl

