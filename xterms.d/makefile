all: xterms_icons update_icons

xterms_icons:
	for i in a g h l r s v f; \
	do echo $$i; \
		xcf2png -C xterms.xcf $$i -o $$i.png; \
		echo convert +repage $$i.png $$i.png; \
		convert $$i.png $$i.xbm; \
	done

update_icons:
	for i in /tmp/term.*.winid; \
	do \
		x=`echo $$i|sed -e 's/[^.]\+.//' -e 's/\(.\).*/\1/'`; \
		xwit -id `cat $$i` -bitmap $$x.xbm; \
	done
