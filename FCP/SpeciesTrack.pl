#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use List::Util qw( min max );

#Subsetted File of the Repeat Masker Track 
#my $file1 = $ARGV[0];
my $file1 = "/media/chrys/HDDUbutuMain/Concat.2272017/LTR7Y.OriginalPositions";

#MergeIndex
#./QuickCompare3.pl ../MER11C.OriginalPositions ../MergeIndex.2272017.bed > MER11C.NewMergeTrack
#my $file2 = $ARGV[1];
my $file2= "/media/chrys/HDDUbutuMain/Concat.2272017/MergeIndex.2272017.bed";




my %OriginalIDs;

open(READ1,$file1) || die "Could not open $file1 ! $!";

while (<READ1>) {
	chomp;
	my @temp = split("\t",$_);
	my @temp2 = split(/\:/,$temp[6]);
	my $ID = $temp2[1];

	$OriginalIDs{$ID} = join("\t",@temp[0..5]);
}


open(READ2,$file2) || die "$!";

while (<READ2>) {
	
	chomp;
	my @temp = split("\t",$_);
	my $ID = $temp[3];
	my @temp2 = split(/\:/,$ID);
	$ID = $temp2[1];

	my @temp3;


	if ($ID =~ /\|/) {
		
		@temp3 = split(/\|/,$ID);
		
	}else{

		@temp3[0] = $ID;
	}

	foreach my $elements (@temp3){

		if (exists $OriginalIDs{$elements}) {



			print "$temp[0]\t$temp[1]\t$temp[2]\tID:$elements\n";
		}
	}
}