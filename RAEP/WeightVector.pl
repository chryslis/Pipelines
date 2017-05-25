#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $inPut = $ARGV[0];

open(READ,$inPut) || die "Could not read $inPut:$!";

my %countHash;

while (<READ>) {

	chomp;
	my @temp = split("\t",$_);
	$countHash{$temp[0]}++;

}
close(READ);

open(READ,$inPut) || die "Could not read $inPut:$!";

while (<READ>) {
	chomp;
	my @temp = split("\t",$_);

	if (exists $countHash{$temp[0]}) {

		my $line = join("\t",@temp);
		my $fraction = 1/$countHash{$temp[0]};

		$line = $line."\t".$fraction;

		print "$line\n";
	}
}

close(READ);

