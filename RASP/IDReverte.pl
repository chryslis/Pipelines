#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $start = time();
my $current = 0;

#Get original Index file from output of the Sorting (a.G.0.2)Script 
#my $originalIndex = $ARGV[0];
my $originalIndex = $ARGV[0];

open(READ,$originalIndex) || die "Could not open $originalIndex!: $!";
#Storing IDs -> Family since the input file will contain multiple IDs seperated by "|""
my %IDhash;
my %outHash;

#Read the Index file created from Merger Script
while (<READ>) {
	chomp;
	my $line = $_;
	#Split bed
	my @temp = split("\t",$line);
	#ID is stored in field 6 - zero based
	#In this file, IDs and Families are still line by line
	my $ID = $temp[6];
	my @primaryTemp = split(/\:/,$ID);
	my $Family = $temp[3]."\t".$temp[5];
	#the ID hash will containt the ID Number and the respective family this number belongs to.
	$IDhash{$primaryTemp[1]} = $Family;
}

my $annotationFile = $ARGV[1];

open(READ2,$annotationFile) || die "Could not open $annotationFile!: $!";
#Reading annotation file
while (<READ2>) {
	chomp;
	my $line = $_;
	#Split line by tab
	my @temp = split("\t",$line);
	#The IDs of the the concatenated genome are stored in field 9 (0 based)
	my $ID = $temp[1];
	#If more then one ID are in the same line -> Split it up
	my @subID;

	#Seperators of multi-ID lines is "|"
	if ($ID =~ m/\|/g) {

		#Split multi-ID line by "|"
		@subID = split(/\|/,$ID);
		my @temp2;

		#First ID always starts with ":"
		if ($subID[0] =~ m/\:/g ){
			#So split this up aswell and replace the first ID in the Sub ID array
			#with the correctly formated "ID"
			@temp2 = split(/\:/,$subID[0]);
			#SubID[0] now contains the correct ID Number
			$subID[0] = $temp2[1];
		}
	#If it is a simple one ID sample, just remove the "ID:"
	}else{

		my @temp3 = split(/\:/,$ID);
		$subID[0] = $temp3[1];

	}

	foreach my $elements(@subID){

		if (exists $IDhash{$elements}) {

			print "$temp[0]\t$IDhash{$elements}\n";
		}
	}
}