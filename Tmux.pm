package Tmux;

use strict;
use warnings;
use Carp;
use Getopt::Std;

my $TMUX_HISTSIZE=2000;
sub new {
  my ($package) = @_;
  my $self = {};
  return bless $self, $package;
}

sub list {
  my ($self) = @_;
  # $ tmux list-sessions
  # a: 3 windows (created Thu May  9 09:54:20 2013) [156x33] (attached)
  # foobar: 1 windows (created Thu May  9 09:55:49 2013) [156x33]

  my @sessions = `tmux list-sessions`;
  my @list;
  foreach my $line (@sessions) {
    chomp $line;
    my ($name, $date, $status) = ($line =~ m{
        ([^:]+)
        :\s*\d+\s*windows\s*
        \(created\s*([^\)]+)\)\s*
        \[\d+x\d+\](?:\ \((attached)\))?
      }gmxs);
      push @list, {
        pid => '/nopid/',
        name => $name,
        date => $date,
        status => $status || 'detached',
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
  return 1 if $status->{$session}->{status} eq 'detached';
  return 0;
}

sub clean {
  my ($self) = @_;
  # no op
  return;
}

sub runner {
  my ($self, $session) = @_;
  return "tmux -2 attach-session -s $session";
}

my %cmdHandler = (
  attached => \&cmd_active,
  cmd => \&cmd_cmd,
  detached => \&cmd_inactive,
  dump => \&cmd_dump,
  goto => \&cmd_goto,
  list => \&cmd_list,
  start => \&cmd_start,
);

sub runCmd {
  my ($self, $cmd) = @_;

  my $handler = $cmdHandler{$cmd} or die "mux: $cmd: no such command.";
  return $handler->($self);
}

sub cmd_dump {
  my ($self) = @_;

  my %opt;
  getopts('hs:', \%opt);

  my $with_scrollback = $opt{h} || '';
  my $session = $opt{s} or croak "mux dump: No session given";
  my $outfile = $ARGV[0] or croak "mux dump: Not outfile given for dump";

  if (length($with_scrollback) > 0) {
    $with_scrollback = "-S -$TMUX_HISTSIZE";
  }

  my $cmd = "tmux capture-pane -t $session $with_scrollback \\;"
    . " show-buffer \\; delete-buffer >  $outfile";
  system($cmd);

  if ($? != 0) {
    die "Failed running '$cmd': $!";
  }
  return $?;
}

sub cmd_list {
  my ($self, $wanted_pattern) = @_;

  $wanted_pattern ||= '.*';

  my %opt;
  getopts('h', \%opt);
  if (defined $opt{h}) {
    print "Usage: mux list [pid name status date]\n";
    print "       mux list '%pid.%name: %status %date'\n";
    exit 0;
  }

  my $format;
  my @fields = qw(pid name status date);
  if (scalar @ARGV > 0) {
    if (scalar @ARGV == 1 && $ARGV[0] =~ /%/) {
      $format = $ARGV[0];
    } else {
      @fields = @ARGV;
    }
  }

  foreach my $session ($self->list()) {
    my %s = %{$session};
    next if $s{status} !~ /$wanted_pattern/i;
    if (defined $format) {
      my $output = $format;
      foreach my $f (@fields) {
        $output =~ s/\%\b$f\b/$s{$f}/g;
      }
      print $output;
    } else {
      print join " ", @s{@fields};
    }
    print "\n";
  }
}

sub cmd_active {
  my ($self) = @_;
  return $self->cmd_list('Attached');
}

sub cmd_inactive {
  my ($self) = @_;
  return $self->cmd_list('Detached');
}

sub cmd_start {
  my ($self) = @_;
  my ($session_name) = @ARGV;

  if (! defined $session_name) {
    die "No session name given";
  }
  if (length $session_name == 0) {
    die "Empty session name";
  }

  system("tmux attach-session $session_name");
}

sub cmd_cmd {
  my ($self) = @_;
  my ($session, @command) = @ARGV;

  if (! defined $session || scalar @command == 0) {
    die "Usage: mux cmd <session> <commands>";
  }

  system("tmux " . join(" ", @command) . " -t $session");
}

sub cmd_goto {
  my ($self) = @_;
  my ($session, $window) = @ARGV;

  if (! defined $session || ! defined $window) {
    die "Usage: mux goto <session> <window>";
  }

  system("tmux select-window -t $session:$window");
}

sub cmd_help {
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
";
};

1;
