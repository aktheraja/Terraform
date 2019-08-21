#!/usr/bin/env bash


while true
do
  #sleep 5
  line=$(head -n 1 .ASG1Active.txt)
  #done_stat=$(head -n 1 Done_stat.txt)

echo "${line}"
  if  ([ "${line}" == "true" ] && [ "$1" == "ASG2" ]) || ([ "${line}" == "false" ] && [ "$1" == "ASG1" ]) ; then
    exit 0
  fi
done