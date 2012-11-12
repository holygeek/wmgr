tmp_dir = /dev/shm
all: alphabet_icons

.PHONY: alphabet_icons xterms_icons update_icons
alphabet_icons:
	for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z; do \
		filename=`echo $$i|tr 'A-Z' 'a-z'`.png; \
		./createicon.sh $$i $$filename; \
	done

update_icons:
	for i in $(tmp_dir)/term.*.winid; \
	do \
		x=`echo $$i|sed -e 's/[^.]\+.//' -e 's/\(.\).*/\1/'`; \
		xwit -id `cat $$i` -bitmap $$x.xbm || echo xwit error for $$i; \
	done
