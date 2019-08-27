#!/bin/bash


while true
do
  line=$(head -n 1 .ASG1Active.txt)
  if  ([ "${line}" == "true" ] && [ "$1" == "ASG2" ]) || ([ "${line}" == "false" ] && [ "$1" == "ASG1" ]) ; then
    exit 0
  fi

  if   [ "$1" == "ASG2" ] && [ "${line}" == "false" ] ; then
      echo "Waiting for ASG1 to become active..."
  else
      echo "Waiting for ASG2 to become active..."
  fi


  sleep 10
done