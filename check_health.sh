#!/bin/bash

# Simple script to check the health of a created droplet
fail_count=1

while true
do
  response=$(curl --write-out %{http_code} --silent --output /dev/null $1)
  curr_grp=$()

  if [ $response -eq 200 ] ; then
    echo "$(date -u) Server available"
    # wait for loadbalancer to register

    echo "$(date -u) Waiting for new ASG to be created"
    sleep 180
    #aws autoscaling update-auto-scaling-group --auto-scaling-group-name $2 --min-size 0 --max-size 0 --min-size 0 --desired-capacity 0
    #echo "$(date -u)finished setting old ASG to zero"
    #sleep 10
    #aws autoscaling detach-load-balancer-target-groups --auto-scaling-group-name $2 --target-group-arns $3
    #sleep 10
    #"$(date -u)finished detaching from old ASG"
    echo $2 > 'Users/Name/Desktop/TheAccount.txt'
    exit 0
  else
    if [ $fail_count -eq 101 ]; then
      echo "$(date -u) Server unavailable"
      exit 2
    else
      echo "$(date -u) Attempt ${fail_count}/100: Server not yet available"
      sleep 3
      fail_count=$[$fail_count +1]
    fi
  fi


done