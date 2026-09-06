#!/bin/bash

block_rows=()
filesystems=()
declare -A fs_size 
declare -A fs_used
declare -A fs_avail
declare -A fs_used_perc
declare -A fs_mountpoint
length=30

get_partition_data() { 
  # number of mounted partition
  row_number=$( lsblk -ro MOUNTPOINT | grep '/'| wc -l)
  for ((i=0;i<$row_number;i++))
  do
    #get lines of lsblk output
    block_rows[$i]=$(lsblk -ro MOUNTPOINT | grep '/' | tail -n $(($row_number-$i)) | head -n 1)
  done

  #read usage stats into arrays (df -h)
  for i in ${!block_rows[@]}; do
    usage_stats=$(df -h ${block_rows[$i]} | grep '/')
    IFS=" " read -r fs size used avail useperc mountpt <<< $usage_stats
    filesystems[$i]=$fs
    fs_size[$fs]=$size 
    fs_used[$fs]=$used
    fs_avail[$fs]=$avail
    fs_used_perc[$fs]=$useperc
    fs_mountpoint[$fs]=$mountpt
  done
}

write_logs(){
  local timestamp s
  s=""
  timestamp=$(date)
  if ! [[ -d ./logs/ ]] then
    echo "creating log dir"
    mkdir logs
  fi
  if ! [[ -e ./logs/drives.log ]] then
    echo "creating drive log"
    touch ./logs/drives.log
  fi
  #check drive arrays populated
  if [[ ${#filesystems[@]} -le 0 ]] then
    echo "no drive data" >&2
    return 1
  fi
  s+="t:$timestamp"
  for mnt in ${filesystems[@]}; do
    s+=",{device:$mnt,"
    s+="size:${fs_size[$mnt]},"
    s+="used:${fs_used[$mnt]},"
    s+="available:${fs_avail[$mnt]},"
    s+="used_perc:${fs_used_perc[$mnt]},"
    s+="mountpoint:${fs_mountpoint[$mnt]}}"
  done
  echo $s >> ./logs/drives.log
  echo >> ./logs/drives.log 
}

main(){
  get_partition_data
  for mnt in ${filesystems[@]}; do
    ./progress-bar.sh -p ${fs_used_perc[$mnt]:0:-1}
    echo -n " ${fs_mountpoint[$mnt]} " 
    echo -n "║ ${fs_used_perc[$mnt]} used "
    echo -n "║ ${fs_avail[$mnt]} available "
    echo  "║ ${fs_used[$mnt]} used / ${fs_size[$mnt]} total"
  done
  write_logs
}

main "$@"
