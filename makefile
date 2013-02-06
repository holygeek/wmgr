scripts=$(shell find . -maxdepth 1 -type f -perm /100|sed -e 's,\./,,')

install:
	@for s in $(scripts); do \
	  symlink=~/bin/$$s; \
	  target=$(PWD)/$$s; \
	  if [ -e $$symlink -a ! -L $$symlink ]; then \
	    echo "x   not a symlink: $$symlink"; \
	    continue; \
	  fi; \
	  if [ -L $$symlink ]; then \
	    if [ "`readlink -e $$symlink`" = "$$target" ]; then \
	      echo "✓   $$symlink"; \
	    else \
	      echo "x   `file $$symlink`"; \
	    fi; \
	  else \
	    echo "✓   ln -s $$target $$symlink"; \
	    ln -s $$target $$symlink; \
	  fi; \
	done

uninstall:
	@for s in $(scripts); do \
	  symlink=~/bin/$$s; \
	  target=$(PWD)/$$s; \
	  if [ -L $$symlink ]; then \
	    if [ "`readlink -e $$symlink`" = "$$target" ]; then \
	      echo "✓   removing: $$symlink"; \
	      rm -f $$symlink; \
	    else \
	      echo "x   left alone: $$symlink"; \
	    fi; \
	  fi; \
	done
