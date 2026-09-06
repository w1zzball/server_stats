#!/bin/bash

#usage ./progress-bar.sh [length] [amount] [total] | [length ]-p [percent completion]

displa_help() {
  local usage
  read 
}

draw_progress_bar() {
  bar="█";
  empty="░";
  # bar="|";
  # empty=" ";
  local s length prog total perc filled
  local s="[";
  length=$1
  prog=$2;
  total=$3;
  perc=$((prog*100/total))
  filled=$(($perc*$length/100))
  for ((i=0;i<$filled;i++))
  do
    s+=$bar;
  done

  for ((i=$filled;i<$length;i++))
  do
    s+=$empty;
  done

  echo -en "$s] $perc% ($prog / $total)\033[0K\r"
}

main(){
  prog=0;
  total=10;
  length=10
  if [  $# -eq 0 ]; then
    length=10;
  else
    length=$1;
  fi

  if [  $# -ge 3 ]; then
    length=$1;
    prog=$2;
    total=$3;
  elif [ $# -eq 1 ]; then
    length=$1;
  fi
  draw_progress_bar $length $prog $total
  while [[ $prog -lt $total ]]; do
    ((prog++));
    draw_progress_bar $length $prog $total
    sleep 0.1;
  done

}
main "$@"
