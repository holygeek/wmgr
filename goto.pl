#!/usr/bin/env perl
use strict;
use warnings;
use Carp;
use Getopt::Std;

#$|++;
# goto - raise window
# Created: Tue Aug 12 15:08:01 MYT 2008

# SYNOPSIS
#   goto
#   goto title
#   goto N

# DESCRIPTION
# 	goto
# 	list all windows
# 	goto N
#   raise N'th window (as listed by goto)
# 	goto title
# 	raise window whose title matches this regex: .*name

my $TMP_DIR = '/dev/shm';
my %opts;
getopts('vef', \%opts);

if ( @ARGV == 0 ) {
	# 	list all windows
	my $cmd_list_window = "wmctrl -l|cat -n|sed -e 's/^    //'";
	run($cmd_list_window, 'quiet', 'foreground');
	exit 0;
}
my $exact_match='';
if ($opts{e}) {
	# Exact match with windows title
	$exact_match = '-F';
}
my $verbose = $opts{v};
sub verbose {
  return if !$verbose;

  my ($text) = @_;
  print $text;
}

sub readline_and_chomp {
  my ($filename) = @_;
  open my $fd, '<', $filename or die "$filename: $!";
  my $line = <$fd>;
  close $fd;

  chomp $line;
  return $line;
}

my $arg = $ARGV[0];

my $currently_focused_windowid=`currwin`;
chomp $currently_focused_windowid;

if ($arg =~ /[0-9]+/) {
	verbose "goto N\n";
	verbose "raise N'th window (as listed by goto)\n";
	my $window_id = get_window_id(`wmctrl -l|head -$arg|tail -1`);
	verbose "window_id = [$window_id]\n";
	if ($window_id =~ m/^0x/) {
		exit raise_window($window_id);
	} else {
		verbose "Invalid argument [$arg]\n";
		exit 1;
	}
} elsif (-f "$TMP_DIR/$arg.winid") {
        verbose "via $TMP_DIR/$arg.winid\n";
        my $window_id = readline_and_chomp("$TMP_DIR/$arg.winid");
        chomp $window_id;
        raise_window($window_id);
        # if ($opts{f}) {
        #       # Focus only, no raise
        #       $cmd = "xdotool windowfocus $window_id";
        # } else {
        #       $cmd = "wmctrl -i -a $window_id";
        # }
        # system($cmd);
        exit 0
        #print 'huha';
} else {
	verbose "via pattern /$arg/\n";
	my $pattern = qr/\Q$arg\E/;
	verbose "raise window whose title matches this regex: $pattern\n";
	open WINDOWS, "wmctrl -l|" or croak "Could not run wmctrl";
	while(<WINDOWS>) {
		if (/$pattern/) {
			my $winid = get_window_id($_);
			my $ret = 0;
			verbose "winid: [$winid]\n";
			verbose "curr:  [$currently_focused_windowid]\n";
			if ($winid ne $currently_focused_windowid) {
				old_window_is($currently_focused_windowid);
				$ret = raise_window($winid);
			} else {
				$ret = raise_previous_window();
			}
			#DEBUG print;
			exit $ret;
		}
	}
	exit 1;
}


sub raise_window {
	my $window_id = shift;
	verbose "raise_window: $window_id\n";
	my $cmd;
        if ($opts{f}) {
                # Focus only, no raise
                $cmd = "xdotool windowfocus $window_id";
        } else {
                # Focus and raise
                $cmd = "wmctrl $exact_match -i -a $window_id; xdotool windowfocus $window_id";
        }
	print "$cmd\n";
	return system($cmd);
}

sub raise_previous_window {
	my $oldwin = readline_and_chomp("$TMP_DIR/oldwin");
	old_window_is($currently_focused_windowid);
	return system("wmctrl -i -a $oldwin; xdotool windowfocus $oldwin");
}

sub old_window_is {
	my $id = shift;
	`/bin/sh -c "set -o noglob; echo $id > $TMP_DIR/oldwin"`;
}

sub get_window_id {
	my $window_info = shift;
	chomp $window_info;
	my $id = (split(/ /, $window_info))[0];
	$id =~ s/0x0*/0x/;
	return $id;
}


sub run {
	my $cmd = shift;
	my $quiet = shift;
	my $foreground = shift;
	if(defined $quiet && not $quiet eq 'quiet') {
		print "$cmd\n";
	}
	if(defined $foreground) {
		$foreground = "";
	} else {
		$foreground = " &";
	}

	if(system($cmd . $foreground) == 0) {
		# all ok
		return 1;
	} else {
		croak "error running $cmd\n";
	}
}
