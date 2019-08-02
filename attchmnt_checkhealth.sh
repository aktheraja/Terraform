#!/usr/bin/env bash
echo "$(date -u) Waiting for ASG to attach to Load balancer"
sleep 15
aws autoscaling update-auto-scaling-group --auto-scaling-group-name $1 --min-size 0 --max-size 0 --min-size 0 --desired-capacity 0
echo "making zero"
sleep 20
#aws autoscaling detach-load-balancer-target-groups --auto-scaling-group-name $1 --target-group-arns $2
echo "$(date -u) Deregistering old ASG $1 from Target group $2"
sleep 60
exit 0