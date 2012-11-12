#!/bin/sh
convert \
  -size 50x50 canvas:white  \
  -gravity center \
  -font "URW-Bookman-Demi-Bold-Italic" \
  -pointsize 48 \
  -annotate +0+0 $1 \
  $2
