#!/bin/bash

# Simple script to check the health of a created droplet
fail_count=1

while true
do
  sleep 5
  echo "$(date -u) Checking instance statuses on Autoscaling Group: $2 ..."
  response="$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $2 --output json)"
  #echo"${response}"
  echo "${response}" > "test.json"
  sleep 2
  currInst="$(grep -Po '"LifecycleState": "InService",' test.json | wc -l)"
  #echo "${currInst}"
  if [ "${currInst}" -ge "$1" ] ; then
    echo "$(date -u) All $2 instances ready...Done!"
    sleep 2
    exit 0
  else
    if [ "${fail_count}" -gt 120 ]; then
      echo "$(date -u) ASG creation failed..."
      sleep 3
      exit 2
    else
    echo "$(date -u) Attempt ${fail_count}/100: ASG not yet available"
    fail_count="$["$fail_count" +1]"
    echo "$(date -u) Only ${currInst} instances ready...need $1"
    fi
  fi


done