#!/usr/bin/env bash
echo "$(date -u) Waiting for ASG to attach to Load balancer"
#echo $1
sleep 15
aws autoscaling detach-load-balancer-target-groups --auto-scaling-group-name $1 --target-group-arns $2
echo "$(date -u) Deregistering old ASG"
sleep 30
exit 0