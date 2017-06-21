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

foreach my $Reads(sort keys %countHash){
	print "$Reads\t".1/$countHash{$Reads}."\n";
}


