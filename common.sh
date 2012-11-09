#!/bin/sh
debug() {
  test -z "$debug" && return
  field="$1";
  shift
  printf "%10s DEBUG: %12s: %s\n" "$me" "$field" "$*" >&2
}

bail() {
  echo $*
  if [ -n "$zenity" ]; then
    zenity --error --text "$*"
  fi
  exit 1
}

bail_if_empty() {
  test -z "$1" && bail $2
}

exe() {
  if [ -n "$dry_run" ]; then
    echo "$@"
  else
    if [ -n "$debug" ]; then
      echo " $me EXE: $@" 1>&2
    fi
    sh -c "$*"
  fi
}
