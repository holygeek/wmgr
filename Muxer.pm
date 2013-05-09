package Muxer;

use strict;
use warnings;

sub new {
  my ($package) = @_;
  my $self = {};
  return bless $self, $package;
}

sub clean {
  return;
}

sub isRunning {
  my ($self, $status, $session) = @_;
  return defined $status->{$session};
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

sub cmd_help {
  my ($self) = @_;
  print "NAME
  mux

SYNOPSIS
  mux [help|-h]
  mux <command> [options]

COMMANDS
  attached
    List attached sessions

  goto <sesion name> <window>
    Switch to window <window> in session <session name>

  cmd <session name> <commands>
    Send <commands> to session <session name>

  detached
    List detached sessions

  dump [-h] -s <session name>
    Dumps <session name>, with full scrollback buffer if -h is given.

  list
  list [pid name status date]
  list '%pid.%name'

  start <session name>
    Start or reattach <session name>

  title <title>
    Set tile for current window in current session
";

};

1;
