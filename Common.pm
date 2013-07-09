package Common;
use strict;
use warnings;
use Carp;

sub read_file {
	my ($filename) = @_;

	local $/ = undef;
	open my $fh, "<", $filename or croak $!;
	my $content = <$fh>;
	close $fh or warn $!;
	return $content;
}

sub write_file {
	my ($filename, $content) = @_;

	open my $fh, ">", $filename or croak $!;
	print $fh $content;
	close $fh or warn $!;
}

1;
