#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use File::Basename;
use List::Util qw( min max );
use Cwd;

#Results from analysis of Enrichment Pipeline
#my $results = $ARGV[0];
my $results = "/media/chrys/HDDUbutuMain/Concat.2272017/Alignments.H4K20me1/H4K20me1.EnrichmentSpecies.Result";
my $control = "/media/chrys/HDDUbutuMain/Concat.2272017/Control/Control.EnrichmentSpecies.Result";

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
#Fold change hash
my %FoldHash;
#Information like occurence of feature, cummulative length of the feature and mean feature length go here.
my %SupplementaryHash;
my $supplLen;

open(RESULT,$results) || die "Could not open results $results:$!";

#Read the enrichment calculation results from the output of the RASP Scrit "*.Enrichement.*"
while(<RESULT>){
	chomp;
	my @temp = split("\t");
	my $len = $#temp;
	$supplLen = $len;

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

#####################################################
#													#
#				CONTROL READING						#
#													#
#####################################################

open(CONTROL,$control) || die "Could not open $!";

while (<CONTROL>) {
	chomp;
	my @temp = split("\t",$_);
	$FoldHash{$temp[0]} = $temp[1];

}


close(CONTROL);

#Number of permutations done
my $permNum = scalar( @Shuffles );

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

	#print "NUMBER IS HERE: $shuffs\n";
	
	foreach my $shuffedfeatures (keys %{$ShuffResHash{$shuffs}}){

		#If the amount of mapped reads per shuffle was larger then enrichment +1
		if (exists  $EnrichResultsHash{$shuffedfeatures} ) {

			##################################################################################
			#																				 #
			# Part of calculating Fold Change by max(Shuffle)                                #
			#                                                                                #
			#push(@{$FoldHash{$shuffedfeatures}},${ShuffResHash{$shuffs}{$shuffedfeatures}});#
			#                                                                                #
			##################################################################################
	
			if ( ${ShuffResHash{$shuffs}{$shuffedfeatures}} > $EnrichResultsHash{$shuffedfeatures}) {

				$reportHash{$shuffedfeatures} += 1;

			}else{
			#If not, nothing but a 0 gets added because one likes to avoid empty hash keys
				$reportHash{$shuffedfeatures} += 0; 

			}
			
		}else{

			$reportHash{$shuffedfeatures} += 0;
		}


		#Calculates a sum over all reads per feature to calculate how many reads were shuffled on average
		$SumHash{$shuffedfeatures} += ${ShuffResHash{$shuffs}{$shuffedfeatures}}
	}
}


#########################################################################
#																		#
# ACTIVATE THIS IF YOU WANT TO CALCULATE FOLD CHANGE BY argmax(#Shuffle)#
#																		#
#########################################################################
# foreach my $keys( keys %SupplementaryHash){							#
#																		#	
# 	if (exists $FoldHash{$keys}) {										#
#																		#
# 		my $max = max @{$FoldHash{$keys}};								#
# 		my $res = $EnrichResultsHash{$keys};							#
# 		my $fold = $res/$max;											#
#																		#
# 		$FoldHash{$keys} = $fold;										#
#																		#
# 	}																	#
# }																		#
#########################################################################
#																		#
# CALCULATING FOLD CHANGE BY CONTROL                                    #
#																		#
#########################################################################
#																		#
# foreach my $keys(keys %SupplementaryHash){							#
#																		#
# 	if (exists $FoldHash{$keys}) {										#
#																		#
# 		my $res = $EnrichResultsHash{$keys};							#
# 		my $controlRes = $FoldHash{$keys};								#
# 		my $fold = $res/$controlRes;									#
#																		#
# 		$FoldHash{$keys} = $fold;										#
#																		#
# 	}																	#
# }																		#
#########################################################################

#Output stuff
for my $keys (keys %reportHash){

	$reportHash{$keys} = $reportHash{$keys}/$permNum;
}

for my $keys(keys %SumHash){

	$SumHash{$keys} = $SumHash{$keys}/$permNum
}

my $outPath = $path."/".$mark.".$decomp[1].Analysis.Control";
my $supInformation;
my $FoldChange;

open(OUT,">",$outPath) || die "Could not create $outPath: $!";

print OUT "FeatureName\tReadCount\tpValue\tFoldChange\tFeatureOccurence\tCummulativeLength\tFeatureMeanLength\tMeanShufReadCount\n";


foreach my $keys(sort keys %reportHash){

	if (exists $SupplementaryHash{$keys}){

		$supInformation = $SupplementaryHash{$keys};

	}else{

		my $num = $supplLen-1;

		$supInformation = "NA\t" x $num;
		$EnrichResultsHash{$keys} = 0;
		$reportHash{$keys} = 1;

	}


	if (exists $FoldHash{$keys}) {

		$FoldChange=$FoldHash{$keys};
		
	}else{

		$FoldChange = "NA"
	}



	
	print OUT "$keys\t$EnrichResultsHash{$keys}\t$reportHash{$keys}\t$FoldChange\t$supInformation\t$SumHash{$keys}\n";

}

$permNum=$permNum-1;
print "Number of Shuffles was: $permNum \n";


