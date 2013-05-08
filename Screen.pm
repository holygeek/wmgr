package Screen;

use strict;
use warnings;

sub new {
  my ($package) = @_;
  my $self = {};
  return bless $self, $package;
}

sub list {
  my ($self) = @_;
  my @screens = `screen -ls|sort -k 2 -t.`;
  my @list;
  foreach my $line (@screens) {
    next if $line !~ /^\t/;
    my ($pid, $name, $date, $status) = ($line =~ m{
        \s*([0-9]+)
        \.
        ([A-z0-9]+)
        \s+
        \(([0-9/AMPM: ]+)\)
        \s+
        \((Attached|Detached)\)
        }gxms);
      push @list, {
        pid => $pid,
        name => $name,
        date => $date,
        status => $status,
      };
  }
  return @list;
}

sub status {
  my ($self) = @_;
  my %status;
  foreach my $s ($self->list()) {
    $status{$s->{name}} = {
      pid => $s->{pid},
      date => $s->{date},
      status => $s->{status},
    };
  }
  return \%status;
}

sub isDetached {
  my ($self, $status, $session) = @_;
  return 1 if ! defined $status->{$session};
  return 1 if $status->{$session} eq 'Detached';
  return 0;
}

sub clean {
  my ($self) = @_;
  qx/screen -wipe/;
}

sub runner {
  my ($self, $session) = @_;
  return "screen -DR $session";
}

1;
