package Screen;

use strict;
use warnings;
use Carp;
use Getopt::Std;
use base qw/Muxer/;

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

sub isDetached {
  my ($self, $status, $session) = @_;
  die "$session is not running" if ! $self->isRunning($status, $session);
  return $status->{$session}->{status} eq 'Detached';
}

sub clean {
  my ($self) = @_;
  qx/screen -wipe/;
}

sub runner {
  my ($self, $session) = @_;
  return "screen -DR $session";
}

sub attacher {
  my ($self, $session) = @_;
  return "screen -DR $session";
}

my %cmdHandler = (
  attached => \&cmd_active,
  cmd => \&cmd_cmd,
  detached => \&cmd_inactive,
  dump => \&cmd_dump,
  goto => \&cmd_goto,
  list => \&cmd_list,
  listall => \&cmd_list_all_windows,
  start => \&cmd_start,
  title => \&cmd_title,
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

  my $cmd = "screen -d -r $session -X hardcopy $with_scrollback $outfile";
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

sub cmd_list_all_windows {
  my ($self) = @_;
  print `screen -ls`;
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

  system("screen -DR $session_name");
}

sub cmd_cmd {
  my ($self) = @_;
  my ($session, @command) = @ARGV;

  if (! defined $session || scalar @command == 0) {
    die "Usage: mux cmd <session> <commands>";
  }

  system("screen -d -r $session -X " . join(" ", @command));
}

sub cmd_goto {
  my ($self) = @_;
  my ($session, $window) = @ARGV;

  if (! defined $session || ! defined $window) {
    die "Usage: mux goto <session> <window>";
  }

  system("screen -d -r $session -X select $window");
}

sub cmd_title {
  my ($self) = @_;
  my $title = join(" ", @ARGV);

  system("screen -d -r $ENV{TERM_NAME} -X title '$title'");
}

1;
