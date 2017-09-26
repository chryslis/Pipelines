#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use File::Basename;
use List::Util qw( min max );
use Math::Complex;
use Cwd;

#Results from analysis of Enrichment Pipeline
#my $results = $ARGV[0];
my $results = "/media/chrys/HDDUbutuMain/Concat.2272017/Alignments.DNAse/DNAse.EnrichmentSpecies.Result";
#my $results = "/media/chrys/HDDUbutuMain/Concat.2272017/Alignments.H2BK120ac/H2BK120ac.EnrichmentSpecies.Result";
#my $results = "/media/chrys/HDDUbutuMain/Concat.2272017/Alignments.H4K8ac/H4K8ac.EnrichmentSpecies.Result";

#CONTROL
my $control = "/media/chrys/HDDUbutuMain/Concat.2272017/Control/Control.EnrichmentSpecies.Result";

#liberary list
my $liberarySizes ="/media/chrys/HDDUbutuMain/Concat.2272017/MarksRange";

#file containing all species
my $SummarFile = "/media/chrys/HDDUbutuMain/Concat.2272017/Species.Summary.2272017";
my @features;

open(SUMMARYFILE,$SummarFile) || die;

	while (<SUMMARYFILE>) {
		chomp;

		my @temp = split(/\s+/,$_);

		push(@features,$temp[0]);
	}


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
#LibSize
my $libSize;
my $controlLib;

open(LIB,$liberarySizes) || die  "Could not read liberary $liberarySizes :$!";

while (<LIB>) {
	chomp;
	my @temp = split(/\s+/);

	if ($temp[0] eq $mark) {
		$libSize = $temp[2];
	}

	if ($temp[0] eq "Control") {
		$controlLib = $temp[2];
	}

}

open(RESULT,$results) || die "Could not open results $results:$!";
#Read the enrichment calculation results from the output of the RASP Scrit "*.Enrichement.*"
while(<RESULT>){
	chomp;
	my @temp = split(/\s+/);
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

foreach my $element(@features){
	$EnrichResultsHash{$element} += 1;
	$FoldHash{$element} += 1;
}



my %reportHash;
my %SumHash;
my %ShuffleVals;

#Calculation of pValue and a general sum for how many reads there were.
foreach my $shuffs(sort keys %ShuffResHash){

	
	foreach my $shuffedfeatures (keys %{$ShuffResHash{$shuffs}}){

		#If the amount of mapped reads per shuffle was larger then enrichment +1
		if (exists  $EnrichResultsHash{$shuffedfeatures} ) {
																							 
			#Collecting all shuffle values                                
			                                                                                
			push(@{$ShuffleVals{$shuffedfeatures}},${ShuffResHash{$shuffs}{$shuffedfeatures}});

	
			if ( ${ShuffResHash{$shuffs}{$shuffedfeatures}} >= $EnrichResultsHash{$shuffedfeatures}) {

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

#Type of analysis either Control or Shuffle - more or less depricated, just leave it on "Control"
my $type = "Control";

my %foldResult;
																	
foreach my $keys(@features){

	#warn "Looking at $keys\n";
	my $resultValue;
	$resultValue = $EnrichResultsHash{$keys};

	#Enrichment Result			
	$resultValue = $resultValue/$libSize;

	#Shuffle Result max
	my $shufResult = max @{$ShuffleVals{$keys}};

	#Input control value
	my $controlRes = $FoldHash{$keys};

	if ($shufResult > $controlRes) {
		
		$controlRes = $shufResult;

	}else{

		$controlRes = $FoldHash{$keys};
	}
																																		
	$controlRes = $controlRes/$controlLib;																							
	my $fold = $resultValue/$controlRes;

								
	$foldResult{$keys} = logn($fold,2);								
																																	
}																		


for my $keys (keys %reportHash){

	$reportHash{$keys} = $reportHash{$keys}/$permNum;
}

for my $keys(keys %SumHash){

	$SumHash{$keys} = $SumHash{$keys}/$permNum
}

my $outPath = $path."/".$mark.".$decomp[1].AnalysisTEST.$type";
my $supInformation;
my $FoldChange;

open(OUT,">",$outPath) || die "Could not create $outPath: $!";

print OUT "FeatureName\tReadCount\tpValue\tFoldChange\tFeatureOccurence\tCummulativeLength\tFeatureMeanLength\tMeanShufReadCount\n";



foreach my $keys(sort keys %reportHash){

	if (exists $SupplementaryHash{$keys}){

		$supInformation = $SupplementaryHash{$keys};

	}else{

		warn "NA created - Supplementary Information: $keys\n";
		$supInformation = "NA\tNA\tNA";

		#$EnrichResultsHash{$keys} = 1;
		#$reportHash{$keys} = 1;

	}


	if (exists $foldResult{$keys}) {

		$FoldChange=$foldResult{$keys};
		
	}else{

		warn "NA created - Fold Enrichment: $keys\n";
		$FoldChange = "NA";

	}



	
	print OUT "$keys\t$EnrichResultsHash{$keys}\t$reportHash{$keys}\t$FoldChange\t$supInformation\t$SumHash{$keys}\n";

}

$permNum=$permNum;
print "Number of Shuffles was: $permNum \n";


