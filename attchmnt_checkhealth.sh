#!/usr/bin/env bash
echo "$(date -u) Waiting for ASG to attach to Load balancer"
sleep 15
aws autoscaling detach-load-balancer-target-groups --auto-scaling-group-name $1 --target-group-arns $2
echo "$(date -u) Deregistering old ASG"
sleep 40
exit 0