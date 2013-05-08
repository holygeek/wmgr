package Screen;

use strict;
use warnings;
use Carp;
use Getopt::Std;

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
  return 1 if $status->{$session}->{status} eq 'Detached';
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

my %cmdHandler = (
  dump => \&cmd_dump,
  list => \&cmd_list,
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
  my ($self) = @_;

  foreach my $session ($self->list()) {
    my %s = %{$session};
    print join " ", @s{qw(pid name status date)};
    print "\n";
  }
}

1;
