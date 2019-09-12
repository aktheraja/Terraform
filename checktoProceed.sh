#!/bin/bash

timeout_count=0
while true
do
  line=$(head -n 1 .ASG1Active.txt)
  if  ([ "${line}" == "true" ] && [ "$1" == "ASG2" ]) || ([ "${line}" == "false" ] && [ "$1" == "ASG1" ]) ; then
    exit 0
  fi

  if [ $timeout_count -ge 60 ]; then
      exit 1
  fi

  if   [ "$1" == "ASG2" ] && [ "${line}" == "false" ] ; then
      echo "Waiting for ASG1 to become active..."
  else
      echo "Waiting for ASG2 to become active..."
  fi

  timeout_count=$((timeout_count+1))

  sleep 10
done