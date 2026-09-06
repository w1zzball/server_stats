#!/bin/env bash

LENGTH=30
PARSED_ARGS=0
PERCENT_MODE=0
VERBOSE=0

display_help() {
    local usage
    read -r -d '' usage <<-EOF
	usage 
    ./progress-bar.sh  [amount] [total] 
    or 
    ./progress-bar.sh -p [percent completion] 

	display a progress bar

  -l [length] length of bar (number of characters)
	-p supply a percentage fill instead of an amount
  -q verbose mode, prints info

	EOF

    echo "$usage"
}

get_args(){
  while getopts "l:pv" opt; do
    case ${opt} in
      l)
        LENGTH=$OPTARG
        ;;
      p)
        PERCENT_MODE=1
        ;;
      v)
        VERBOSE=1
        ;;
      \?)
        echo "Invalid option -$OPTARG" >&2
        display_help
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        display_help
        exit 1
    esac
  done
  #shift $@ to account for consumed arguments
  PARSED_ARGS=$((OPTIND - 1))
}

draw_progress_bar() {
  local s bar empty prog total perc filled
  bar="█";
  empty="░";
  s="│";
  if (( "$PERCENT_MODE" == 1 )); then
    perc=$(($1 <= 100 ? $1 : 100))
    prog=$perc;
    total=100;
  else
    prog=$1;
    total=$2;
    perc=$((prog*100/total))
  fi
  filled=$(($perc*$LENGTH/100))
  for ((i=0;i<$filled;i++))
  do
    s+=$bar;
  done

  for ((i=$filled;i<$LENGTH;i++))
  do
    s+=$empty;
  done
  s+="│"
  if (($VERBOSE==1)); then
    s+=" ~ $perc% ($prog / $total)"
  fi
  echo "$s"
}

main(){
  #parse flags
  get_args "$@"
  shift $PARSED_ARGS
  prog=0;
  total=10;
  draw_progress_bar $@
}
main "$@"
