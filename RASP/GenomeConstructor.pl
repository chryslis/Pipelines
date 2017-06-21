#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);

my $inPut = $ARGV[0];
my %CountingHash;
my $sequence;
my $header;
my $outPut = $ARGV[1];

my $outFile = $outPut."/"."names.txt";

open(READ,$inPut) || die "Could not open $inPut: $!";
open(OUTPUT,">",$outFile) || die "Could not open!";

while (<READ>) {
	
	chomp;

	if ($_ =~ /^>/g) {

		$sequence = undef;
		$header = $_;
		$header =~ s/>//;
		
	}else{

		$sequence = $sequence.$_;
	}

	$CountingHash{$header} = $sequence;
}

foreach my $key(sort keys %CountingHash){

	my $len = length($CountingHash{$key});
	print OUTPUT "$key\t$len\n";
}

print "\nDone\n";


