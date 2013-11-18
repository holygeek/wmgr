install: openbox
	sh install.sh

OPENBOX_DIR = $(HOME)/.config/openbox
openbox:
	ln -sf `pwd`/openbox-menu.xml $(OPENBOX_DIR)/menu.xml
	ln -sf `pwd`/openbox-rc.xml $(OPENBOX_DIR)/rc.xml

uninstall:
	@test -f installed.txt || { echo "No installed.txt"; exit 1; }
	@cat installed.txt|while read symlink; do \
	  rm -f $$symlink && \
	  echo "✓   removing: $$symlink" || echo " x  removing: $$symlink"; \
	done && \
	rm -f installed.txt
