#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use File::Basename;
use Cwd;

#Results from analysis of Enrichment Pipeline
my $results = $ARGV[0];

#Decomposition for paths
my @decomp = split(/\//,$results);

#Sorting out where to put output
my $lenNamePath = $#decomp;
my $path = join("/",@decomp[0...$lenNamePath-1]);

#Getting mark information from decomposed path
my $sampleName = $decomp[$lenNamePath];
@decomp = split(/\./,$sampleName);
my $mark = $decomp[0];

#Just location stuff
my $shuffLoc = "/Shuffle.".$mark;
my $shuffleFolder = $path.$shuffLoc;

#Results go here
my %EnrichResultsHash;
#Information like occurence of feature, cummulative length of the feature and mean feature length go here.
my %SupplementaryHash;

open(RESULT,$results) || die "Could not open results $results:$!";

#Read the enrichment calculation results from the output of the RASP Scrit "*.Enrichement.*"
while(<RESULT>){
	chomp;
	my @temp = split("\t");
	my $len = $#temp;

	$EnrichResultsHash{$temp[0]} = $temp[1];
	$SupplementaryHash{$temp[0]} = join("\t",@temp[2..$len]);
}

close(RESULT);

#Opens the shuffle directory, this already exists of course
opendir(SHUFFLE,$shuffleFolder) || die "Could not read folder $shuffleFolder $!";
#read all the shuffle names, please be aware that stuff in the folder that carries the mark name as index will be recognized here and may disturb some later code.
my @Shuffles;

while (readdir SHUFFLE) {
	chomp;
	if ($_ =~ m/$mark\./g) {
		push(@Shuffles,$_);
	}
}

close(SHUFFLE);

#Number of permutations done
my $permNum = scalar( @Shuffles);

#Hash for capturing shuffle results
my %ShuffResHash;

#Iterate over all shuffles
for $_(@Shuffles){

	#Standard stuff
	my @temp = split (/\./,$_);
	my $len = $#temp;
	#Index for which number of shuffle was done.
	my $num = $temp[$len];
	my $currentFile = $shuffleFolder."/".$_;

	open(SHUFRES,$currentFile) || die "Could not open $_ :$!";

	while (<SHUFRES>) {
		chomp;
		my @temp = split("\t");
		my $len = $#temp;

		$ShuffResHash{$num}{$temp[0]} = $temp[1];
	}
}

close(SHUFRES);

my %reportHash;
my %SumHash;

#Calculation of pValue and a general sum for how many reads there were.
foreach my $shuffs(sort keys %ShuffResHash){

	foreach my $shuffedfeatures (keys %{$ShuffResHash{$shuffs}}){

		#If the amount of mapped reads per shuffle was larger then enrichment +1
		if ( ${ShuffResHash{$shuffs}{$shuffedfeatures}} > $EnrichResultsHash{$shuffedfeatures}) {

			$reportHash{$shuffedfeatures} += 1;


		}else{
		#If not, nothing but a 0 gets added because one likes to avoid empty hash keys
			$reportHash{$shuffedfeatures} += 0; 
		}

		#Calculates a sum over all reads per feature to calculate how many reads were shuffled on average
		$SumHash{$shuffedfeatures} += ${ShuffResHash{$shuffs}{$shuffedfeatures}}
	}
}

#Output stuff
for my $keys (keys %reportHash){

	$reportHash{$keys} = $reportHash{$keys}/$permNum;
}

for my $keys(keys %SumHash){

	$SumHash{$keys} = $SumHash{$keys}/$permNum
}

my $outPath = $path."/".$mark.".$decomp[1].Analysis";

open(OUT,">",$outPath) || die "Could not create $outPath: $!";

print OUT "FeatureName\tReadCount\tpValue\tFeatureOccurence\tCummulativeLength\tFeatureMeanLength\tMeanShufReadCount\n";

foreach my $keys(sort keys %reportHash){

	print OUT "$keys\t$EnrichResultsHash{$keys}\t$reportHash{$keys}\t$SupplementaryHash{$keys}\t$SumHash{$keys}\n";

}

print "Number of Shuffles was: $permNum \n";
