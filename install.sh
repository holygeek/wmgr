#!/bin/sh
scripts="$(find . -maxdepth 1 -type f -perm /100|sed -e 's,\./,,') common.sh"
rm -f installed.txt
log_installed() {
  echo $1 >> installed.txt
}

make_symlink() {
  symlink=$1
  target=$PWD/$2

  if [ -e $symlink -a ! -L $symlink ]; then
    echo " x  not a symlink: $symlink";
    continue;
  fi;
  if [ -L $symlink ]; then
    if [ "`readlink -e $symlink`" = "$target" ]; then
      log_installed $symlink
      echo "✓   $symlink";
    else
      echo " x  `file $symlink`";
    fi;
  else
    log_installed $symlink
    echo "✓   ln -s $target $symlink";
    ln -s $target $symlink;
  fi;
}

# Symlink scripts to ~/bin
for s in $scripts; do
  make_symlink ~/bin/$s $s
done
make_symlink ~/.xbindkeysrc xbindkeysrc

# Symlink openbox config files
openbox_dir=~/.config/openbox
mkdir -p $openbox_dir
make_symlink $openbox_dir/menu.xml openbox-menu.xml
make_symlink $openbox_dir/rc.xml openbox-rc.xml

# Install xterms.conf.pl
if [ ! -f xterms.conf.pl ]; then
  cp -v xterms.conf.pl.sample xterms.conf.pl
fi

# Check for dependencies
for i in wmctrl xbindkeys xdotool dmenu xftmetric; do
  if ! which $i > /dev/null; then
    echo " x  not installed: $i"
  fi
done

# Check xbindkeys key bindings
keys=`cat xterms.conf.pl|sed -n -e '/=> join/s/^ *\([a-z]\).*/\1/p'`
for c in $keys; do
  if ! grep -q "Alt + $c" xbindkeysrc; then
    echo " x  missing xbindkeys entry for 'Alt + $c'"
  fi
done
