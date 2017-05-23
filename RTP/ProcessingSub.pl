#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Cwd;
use File::Basename;
my $total = $ARGV[1];

my $file = "List";
open(READ, $file) || die "Could not open $file ! $!";

my @lineList;

while (<READ>) {
	chomp $_;
	my $str = $_;
	$str =~ s/^\s+|\s+$//g;

	push(@lineList,$str);

}

my $RepTrack = $ARGV[0];

open(READ2,$RepTrack) || die "Could not open second file $RepTrack! $!";
my $outPut = "RepeatMaskerTrack.Sorted.Cleaned";
open(OUT,">",$outPut) || die "Could not create file! $!";
my $counter = 0;

while (<READ2>) {

	chomp;

	my $line = int(($counter/$total)*100);
	print "Current: $line % \r";
	$counter ++;

	my @temp = split("\t",$_);

	foreach my $element(@lineList){

		if ($temp[10] eq $element) {

			print OUT join("\t",@temp);
			print OUT "\n";
		}
	}
}