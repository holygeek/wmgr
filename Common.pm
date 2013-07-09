package Common;
use strict;
use warnings;
use Carp;

sub read_file {
	my ($filename) = @_;

	local $/ = undef;
	open my $fh, "<", $filename or croak $!;
	my $content = <$fh>;
	close $fh;
	return $content;
}


1;
