package WMGR;

use strict;
use warnings;
use File::Slurp;

my %opt;

sub import {
  my ($package, %import) = @_;
  %opt = %import;
}

sub get_config {
    my ($entry) = @_;

    my $conf_file = "$opt{home}/xterms.conf.pl";
    if (! -f $conf_file) {
        return undef;
    }

    my %config = eval read_file($conf_file) or die "Corrupt $conf_file? $@";
    return $config{$entry};
}

1;
