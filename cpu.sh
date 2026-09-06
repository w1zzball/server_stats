#!/bin/env bash

cpu_stats=$(cat /proc/stat | grep cpu)

read_proc(){
  while read -r cpu user nice_time system idle iowait irq softirq steal guest guest_nice; do
    echo "$cpu"
  done <<< $cpu_stats
}

read_proc
