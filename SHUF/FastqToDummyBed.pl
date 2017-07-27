#!/usr/bin/perl

use warnings;
use strict;
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);

#FastqFile
my $InPut = "/media/chrys/HDDUbuntu/H9CellLine/Aligned/GSM896161.H3K14ac/SRR445375.clean.fastq";
#Output Location
my $outPut = "/media/chrys/HDDUbuntu/H9CellLine/Aligned/GSM896161.H3K14ac/H2BK120ac.Dummy.bed";

open(READ,$InPut) || die "Could not open $InPut! $!";
open(OUT,">",$outPut) || die "Could not open $outPut! $!";

my $start = 0;
my $stop = 0;
my $len = 0;
my $chr = "chrShuff";

while (<READ>) {
	chomp;
	my $line = $_;
	if ($line =~ /length=[0-9]+/) {
		
		my @temp = split(/\=/,$line);
		$len = $temp[1];

	}


	if ($line =~ /\@SRR/g) {

		print "Working...\r";
		my @temp = split(/\s/,$line);
		my $varTemp = $temp[0];
		$varTemp =~ s/@//;

		$stop += $len;

		print OUT "$chr\t$start\t$stop\t$varTemp\n";

		$start = $stop+1;

	}
}

