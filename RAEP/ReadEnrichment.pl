#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use File::Basename;
use Cwd;

my $start = time();
my $current = 0;

my $input = $ARGV[0];
my $lineCount = $ARGV[1];
my $sortType = $ARGV[2];
my $selection;
my $weightVecor = $ARGV[3];
my $famCounts = $ARGV[4];

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

open(GETWEIGHTS,$weightVecor) || die "Could not reade weight vector: $!";

print "\tProcessing weight vector...\n";
my %weightsHash;

while (<GETWEIGHTS>) {
	chomp;
	my @temp = split("\t",$_);
	$weightsHash{$temp[0]} = $temp[1];
}

my $fileName = basename($input);
my @temp1 = split(/$fileName/,$input);
my $path = $temp1[0];
my $outPut = $path;
my @temp2 = split(/\./,$fileName);
my $len = $#temp2;
$temp2[$len-1] = "Enrichment".$selection;
my $outName = join(".",@temp2);
my $outPutPath = $path.$outName;

open(READ,$input) || die "Could not read $input: $!";

my %CountingHash;
my $counter = 0;


print "\tProcessing Features and Reads...\n";

while (<READ>) {

	my $progress = int(($counter/$lineCount)*100);
	print "\tProgress: $progress % \r";
	chomp;
	my @temp = split("\t",$_);
	my $sortingElement = $temp[$sortType];
	my $read = $temp[0];
	$CountingHash{$read}{$sortingElement} += 1;
	$counter++;

}

open(OUTPUT,">$outPutPath" ) || die "Could not create $outPutPath:$!";
#open(OUTPUT,">","TestOut" ) || die "Could not create $outPutPath:$!";

print"\tDoing weight calculations...\n";
my %resultHash;
$counter = 0;
my $size = scalar(keys % weightsHash);

foreach my $Reads(keys %weightsHash){
	my $progress = int(($counter/$size)*100);
	print "\tProgress: $progress % \r";

	if ( exists $CountingHash{$Reads} ) {

		foreach my $fam (keys %{$CountingHash{$Reads}} ){

			my $FamilyPerReadCount = $CountingHash{$Reads}{$fam};
			my $weight = $weightsHash{$Reads};

			$resultHash{$fam} += $FamilyPerReadCount*$weight;
		}
	}
	$counter ++;
}

open(GETFAMCOUNTS,$famCounts) || die "Could not open $famCounts: $!";

my %famCounts;

while (<GETFAMCOUNTS>){
	chomp;
	my @temp = split("\t",$_);
	my $fam = $temp[0];
	my $count = $temp[1];

	$fam =~ s/^\s+|\s+$//g;
	$famCounts{$fam} = $count;
}

print "\tPrinting Outputs!\n";

foreach my $keys(sort keys %resultHash){
	my $norm = $resultHash{$keys}/$famCounts{$keys};
	print OUTPUT "$keys\t$resultHash{$keys}\t$famCounts{$keys}\t$norm\n";

}

close(READ);
close(OUTPUT);

my $stop = time();
my $runTime = int((($stop - $start)/60));

print "\n";
print "\tDone!\t Finished in $runTime Minutes.\n";
