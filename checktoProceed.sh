#!/bin/bash


while true
do
  #sleep 5
  line=$(head -n 1 .ASG1Active.txt)
  if  ( [ "$1" == "ASG2" ]) && [ "$1" == false ] ; then
      echo "Waiting for ASG1 to become active..."
  else
      echo "Waiting for ASG2 to become active..."
  fi

  if  ([ "${line}" == "true" ] && [ "$1" == "ASG2" ]) || ([ "${line}" == "false" ] && [ "$1" == "ASG1" ]) ; then
    exit 0
  fi
done