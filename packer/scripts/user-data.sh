#!/bin/bash

set -ex

# CloudWatch Agent
amazon-linux-extras install epel -y
yum update -y
yum install amazon-cloudwatch-agent collectd -y
systemctl start collectd
sudo systemctl enable collectd
systemctl start amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent

# StrongDM
echo '# strongDM CA' >> /etc/ssh/sshd_config
echo 'TrustedUserCAKeys /etc/ssh/sdm_ca.pub' >> /etc/ssh/sshd_config
systemctl restart sshd

# gpumon
curl -O https://s3.amazonaws.com/aws-bigdata-blog/artifacts/GPUMonitoring/gpumon.py -o gpumon.py
sed -i "25s/.*/my_NameSpace = 'Gentle'/" gpumon.py
yum install python2-pip -y
pip install nvidia-ml-py boto3

