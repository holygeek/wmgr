install:
	sh install.sh

uninstall:
	@test -f installed.txt || { echo "No installed.txt"; exit 1; }
	@cat installed.txt|while read symlink; do \
	  rm -f $$symlink && \
	  echo "✓   removing: $$symlink" || echo " x  removing: $$symlink"; \
	done && \
	rm -f installed.txt
