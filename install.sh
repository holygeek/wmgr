#!/bin/sh
scripts="$(find . -maxdepth 1 -type f -perm /100 -o -name common.sh|sed -e 's,\./,,'|sort)"
rm -f installed.txt
log_installed() {
  echo $1 >> installed.txt
}

make_symlink() {
  symlink=$1
  target=$PWD/$2

  if [ -e $symlink -a ! -L $symlink ]; then
    echo " x  not a symlink: $symlink"
    return 1
  fi
  if [ -L $symlink ]; then
    if [ "`readlink -e $symlink`" = "$target" ]; then
      log_installed $symlink
      echo "✓   $symlink"
    else
      echo " x  `file $symlink`"
    fi
  else
    log_installed $symlink
    echo "✓   ln -s $target $symlink"
    ln -s $target $symlink
  fi
}

# Symlink scripts to ~/bin
for s in $scripts; do
  make_symlink ~/bin/$s $s
done
for home_symlink in xbindkeysrc xinitrc; do
  make_symlink $HOME/.$home_symlink $home_symlink
done

# Symlink openbox config files
openbox_dir=~/.config/openbox
mkdir -p $openbox_dir
make_symlink $openbox_dir/menu.xml openbox-menu.xml
make_symlink $openbox_dir/rc.xml openbox-rc.xml
make_symlink $openbox_dir/environment openbox.environment

mkdir -p $HOME/.config/dunst
make_symlink $HOME/.config/dunst/dunstrc dunstrc

# Install xterms.conf.pl
if [ ! -f xterms.conf.pl ]; then
  cp -v xterms.conf.pl.sample xterms.conf.pl
fi

# Check for dependencies
for i in wmctrl xbindkeys xcape xdotool dmenu xftmetric xclip inotifywait workrave; do
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

if [ ! -d ~/code/nmcli-dmenu ]; then
  git -C ~/code clone git@github.com:firecat53/nmcli-dmenu.git
  ln -s ~/code/nmcli-dmenu/nmcli_dmenu .
fi
make_symlink ~/bin/nmcli_dmenu nmcli_dmenu
