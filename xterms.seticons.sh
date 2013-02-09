#!/bin/sh
# xterms.seticons.sh - Set icons for xterms
# Created: Wed Feb 15 11:23:53 MYT 2012
cwd=`dirname $0`;
tmp_dir=/dev/shm
for i in $tmp_dir/term.*.winid; do
    window_id=`cat $i`
    xterm_short_id=`echo $i|sed -e 's,.*/term.\(.\).*,\1,'`
    icon_png=$cwd/xterms.d/${xterm_short_id}.png
    if [ -f $icon_png ]; then
	xseticon -id $window_id $icon_png || echo "(xseticon error)"
    else
	echo "$icon_png DNE" >&2
    fi
done
