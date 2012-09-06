#!/bin/bash
# ch - Show list of windows, change to given window #
# Created: Thu May 13 14:42:47 MYT 2010

usage() {
    echo "Usage: ch [-n N] [-i winid] [regex]"
}

while getopts hi:n: opt
do
  case "$opt" in
    i) winid="$OPTARG";;
    n) nth="$OPTARG";;
    h) usage ; exit;;
    \?) echo Unknown option ; exit;;
  esac
done
shift $(($OPTIND -1))

if [ -n "$winid" ]; then
    wmctrl -i -a $winid
    exit
fi


if [ -z "$1" ]; then
    wmctrl -l|cat -n
    exit
fi

if [[ $1 =~ ^[0-9]+$ ]]; then
    winid=`ch|head -$1|tail -1|awk '{print $2}'`
    ch -i $winid
    exit
fi

wmctrl -a "$@"
