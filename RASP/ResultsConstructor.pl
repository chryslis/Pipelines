#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use List::MoreUtils qw(uniq);

#Input requires the location of 
#my $AlignmentLocations = $ARGV[0];
my $AlignmentLocations = "/media/chrys/HDDUbutuMain/Concat.2272017/";

opendir(RESULTS,$AlignmentLocations) || die "Could not read folder $!";

#Storage for Alignments folder
my @Alignments;

while (readdir RESULTS) {
	
	if ($_ =~ m/Alignments\..+/g) {

		push(@Alignments,$_);
		
	}
}
#Checking for Marks
my @AllMarks;

foreach my $folders (@Alignments){

	my $tempPath = $AlignmentLocations.$folders;

	opendir (ANALYSIS, $tempPath) || die "Could not read folder $!";

	while (readdir ANALYSIS) {
		if ($_ =~ m/\.Analysis\.Adjusted/g) {

			$tempPath = $AlignmentLocations.$folders."/".$_;

			push(@AllMarks,$tempPath);

		
		}	
	}
}

#StashHash for Marks -> Families -> Binary
my %ResultsHash;

###############################
#    THRESHOLDS ARE here      #
###############################


my $signif = 0.05;
my $signifFold = 2.0;


my @Features;
my @Marks;

foreach my $AnalysisFiles(@AllMarks){

	my @temp = split(/\//,$AnalysisFiles);
	my @temp2  = split(/\./,$temp[@temp-1]);
	my $mark = $temp2[0];
	push(@Marks,$mark);



	open(READ,$AnalysisFiles) || die "Could not open $AnalysisFiles : $!";

	while (<READ>) {
		chomp;
		if ($_ =~ /^FeatureName.+/g) {
				next;
		}

		my @temp = split("\t",$_);
		my $feature = $temp[0];
		push(@Features,$feature);
		my $pVal = $temp[3];
		my $FoldChange = $temp[4];
		my $bin;

		if ($pVal < $signif && $FoldChange > $signifFold) {

			$bin = 1;

		}else{
			
			$bin = 0;
		}

		$ResultsHash{$mark}{$feature} = $bin;

	}	
}

my @uniqFeatures = uniq sort @Features;
my @uniqMarks = uniq sort @Marks;
@Features = undef;
@Marks = undef;

my @temp =split("/\//",$AlignmentLocations);
my $dump = $temp[$#temp];
$dump =~ m/([0-9]+)/;
my $ID = $1;



open(OUTPUT,">$AlignmentLocations/EnrichmentMatrix.Control.$ID");

my $header = join("\t",@uniqFeatures);
print OUTPUT "\t$header";
print  OUTPUT "\n";

open(OUTFEATURE,">$AlignmentLocations/FeatureList.$ID") || die "Could not open, $!";
print OUTFEATURE "$header";



sub tabdel {


foreach my $marks(@uniqMarks){

	print OUTPUT "$marks";

	foreach my $feature(@uniqFeatures){

		if (exists $ResultsHash{$marks}{$feature}) {

			print OUTPUT "\t$ResultsHash{$marks}{$feature}"; 
			#print "Value: $ResultsHash{$marks}{$feature}\t"
		}
	}
	print OUTPUT "\n";
}

}

tabdel();




#print Dumper \%ResultsHash;


