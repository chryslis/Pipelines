#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use File::Basename;
use Cwd;

my $start = time();
my $current = 0;

#File containing the Reads with the IDs (Location Anchor)
my $input = $ARGV[0];

#Sorting by super or by species
my $sortType = $ARGV[1];


#Location of the weight vector
my $weightVecor = $ARGV[2];

#Just declared here for global
my $selection;

if ($sortType eq "F") {
	$sortType = 2;
	$selection="SuperFamily"


}elsif($sortType eq "S"){
	$sortType = 1;
	$selection="Species"

}else{
	$sortType = 2;
	$selection="SuperFamily"
}

#Reading prepared weight Vector
open(GETWEIGHTS,$weightVecor) || die "Could not reade weight vector: $!";

#Just some feedback...
print "\tProcessing weight vector...\n";
#Hash for saving the weights of a specific read
my %weightsHash;

while (<GETWEIGHTS>) {
	chomp;
	my @temp = split("\t",$_);
	#File is ReadNumber weight with tab as delimiter
	$weightsHash{$temp[0]} = $temp[1];
}

close(GETWEIGHTS);

#Processing stuff to put everything in the proper folders

my $fileName = basename($input);
my @temp1 = split(/$fileName/,$input);
my $path = $temp1[0];
my $outPut = $path;
my @temp2 = split(/\./,$fileName);
my $len = $#temp2;
$temp2[$len-1] = "Enrichment".$selection;
my $outName = join(".",@temp2);
my $outPutPath = $path.$outName;



print "\tProcessing Features and Reads...\n";

my %CountingHash;

#Getting counting data from STD I/O
while (<STDIN>) {
	chomp;
	my @temp = split("\t",$_);
	my $sortingElement = $temp[$sortType];
	my $read = $temp[0];
	$CountingHash{$sortingElement} += $weightsHash{$read};

}

open(OUTPUT,">$outPutPath" ) || die "Could not create $outPutPath:$!";;

print"\tPreparing outputs...\n";


foreach my $keys(sort keys %CountingHash){

	#Printing Feature 	Counts
	print OUTPUT "$keys\t";
	printf OUTPUT "%.3f\t",$CountingHash{$keys};
	print OUTPUT "\n";

}

close(OUTPUT);

my $stop = time();
my $runTime = int((($stop - $start)/60));

print "\n";
print "\tDone!\t Finished in $runTime Minutes.\n";

