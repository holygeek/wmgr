#!/bin/sh
# st - set screen title for current window
# Created: Wed Sep 19 12:58:07 MYT 2012

screen -d -r ${TERM_NAME} -X title "$@"
