
scripts=$(shell find . -maxdepth 1 -type f -perm /100|sed -e 's,\./,,')
pwd = $(shell readlink -e `pwd`)

install:
	@for s in $(scripts); do \
	  target=~/bin/$$s; \
	  if [ -e $$target -a ! -L $$target ]; then \
	    echo "x   $$target already exists, and it's not a symlink?"; \
	    continue; \
	  fi; \
	  if [ -L $$target ]; then \
	    if [ "`readlink -e $$target`" != "$(pwd)/$$s" ]; then \
	      echo "x   `file $$target`"; \
	    fi; \
	  else \
	    echo "✓   ln -s $(pwd)/$$s $$target"; \
	    ln -s $(pwd)/$$s $$target; \
	  fi; \
	done
