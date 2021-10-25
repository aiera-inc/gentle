#!/bin/bash

set -ex

# gpumon
cp -v /home/ec2-user/gpumon.service /etc/systemd/system/gpumon.service
chown -v root:root /etc/systemd/system/gpumon.service
chmod -v 644 /etc/systemd/system/gpumon.service

cp -v /home/ec2-user/gpumon.py /root/gpumon.py
chmod +x /root/gpumon.py

systemctl daemon-reload
systemctl enable gpumon.service

cp -v /home/ec2-user/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
cp -v /home/ec2-user/sdm_ca.pub /etc/ssh/sdm_ca.pub

