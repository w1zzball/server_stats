#!/bin/env bash

CURRENT=()
cpu_stats=$(cat /proc/stat | grep cpu)

read_proc(){
  local cpu user nice system idle iowait irq softirq \
    steal guest guest_nice
  while read -r cpu user nice system idle iowait irq \
    softirq steal guest guest_nice; do
    echo "$cpu"
    busy=$((user + nice + system + irq + softirq + steal + guest + guest_nice))
    idle=$((idle + iowait))

    value="$busy $idle"
    echo $value
    num=${cpu#cpu}

    CURRENT[num]=$value
  done <<< $cpu_stats

}

read_proc
