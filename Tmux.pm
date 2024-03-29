package Tmux;

use strict;
use warnings;
use Carp;
use Getopt::Std;
use POSIX qw(strftime);
use base qw/Muxer/;

my $TMUX_HISTSIZE = 19000;
my $tmux_bin = "tmux";

my $tmux_path = `which $tmux_bin`;
chomp $tmux_path;
if (length $tmux_path == 0) {
	# tmux not available
	$tmux_bin = ": tmux";
}

sub list {
  my ($self) = @_;
  # $ tmux list-sessions
  # a: 3 windows (created Thu May  9 09:54:20 2013) [156x33] (attached)
  # foobar: 1 windows (created Thu May  9 09:55:49 2013) [156x33]

  my @sessions = `$tmux_bin list-sessions -F '#{session_name} #{pane_pid} #{session_windows} #{session_created} #{?session_attached,attached,detached}'`;
  my @list;
  foreach my $line (@sessions) {
    chomp $line;
    my ($name, $pid, $nwindows, $epoch, $status) = split / /, $line;
    my $date = strftime '%a %b %d %H:%M:%S %Y', localtime $epoch;
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
  return $status->{$session}->{status} eq 'detached';
}

sub runner {
  return start(@_);
}
sub start {
  my ($self, $session) = @_;
  my $tmux_arg = "-2 new-session -DA -s $session";
  return $tmux_bin . "-starter" . " $tmux_arg";
}
sub attacher {
  return start(@_);
}

my %cmdHandler = (
  a => \&cmd_active,
  attached => \&cmd_active,
  cmd => \&cmd_cmd,
  d => \&cmd_inactive,
  detached => \&cmd_inactive,
  dump => \&cmd_dump,
  goto => \&cmd_goto,
  list => \&cmd_list,
  listall => \&cmd_list_all_windows,
  start => \&cmd_start,
  title => \&cmd_title,
  num => \&Muxer::cmd_num,
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
  my $outfile = $ARGV[0]; # or croak "mux dump: Not outfile given for dump";
  my $dst = "";
  if ($outfile && $outfile ne '-') {
    $dst = "> $outfile";
  }

  if (length($with_scrollback) > 0) {
    $with_scrollback = "-S -$TMUX_HISTSIZE";
  }

  my $cmd = "$tmux_bin capture-pane -J -t $session $with_scrollback \\;"
    . " show-buffer \\; delete-buffer $dst";
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
  print `$tmux_bin list-windows -a`;
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

  system("TMUX= tmux-starter new-session -d -s $session_name ';' attach-session -t $session_name");
}

sub cmd_cmd {
  my ($self) = @_;
  my ($session, @command) = @ARGV;

  if (! defined $session || scalar @command == 0) {
    die "Usage: mux cmd <session> <commands>";
  }

  system(join(" ", $tmux_bin, @command) . " -t $session");
}

sub cmd_goto {
  my ($self) = @_;
  my ($session, $window) = @ARGV;

  if (! defined $session || ! defined $window) {
    die "Usage: mux goto <session> <window>";
  }

  system("$tmux_bin select-window -t $window");
}

sub cmd_title {
  my ($self) = @_;
  my $title = escape_quote(join(" ", @ARGV));

  system("$tmux_bin rename-window \"$title\"");
}

sub escape_quote {
  my ($text) = @_;
  $text =~ s/"/\\"/g;
  return $text;
}

1;
