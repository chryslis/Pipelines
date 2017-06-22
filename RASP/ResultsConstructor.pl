#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use List::MoreUtils qw(uniq);

my $start = time();

#Input requires the location of 
#my $AlignmentLocations = $ARGV[0];
my $AlignmentLocations = "/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/";

opendir(RESULTS,$AlignmentLocations) || die "Could not read folder $!";

#Storage for Alignments folder
my @Alignments;

while (readdir RESULTS) {
	
	if ($_ =~ m/Alignments\..+/g) {

		push(@Alignments,$_);
		
	}
}

my @AnalysiedMarks;

foreach my $folders (@Alignments){

	my $tempPath = $AlignmentLocations.$folders;

	opendir (ANALYSIS, $tempPath) || die "Could not read folder $!";

	while (readdir ANALYSIS) {

		if ($_ =~ m/\.Analysis/g) {

			$tempPath = $AlignmentLocations.$folders."/".$_;

			push(@AnalysiedMarks,$tempPath);
		
		}	
	}
}

#StashHash for Marks -> Families -> Binary
my %ResultsHash;

#Just temp;
my $signif = 0.05;

my @Fams;
my @Marks;

foreach my $AnalysisFiles(@AnalysiedMarks){

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
		my $fam = $temp[0];
		push(@Fams,$fam);
		my $pVal = $temp[4];
		my $bin;

		if ($pVal < $signif) {
			$bin = 1;
		}else{
			$bin = 0;
		}

		$ResultsHash{$mark}{$fam} = $bin;

	}	
}

my @uniqFams = uniq sort @Fams;
my @uniqMarks = uniq sort @Marks;
@Fams = undef;
@Marks = undef;


open(OUTPUT,">TestResult");

my $header = join("\t",@uniqFams);
print OUTPUT "\t$header";
print  OUTPUT "\n";




sub csv {


foreach my $marks(@uniqMarks){

	print OUTPUT "$marks";

	foreach my $fams(@uniqFams){

		if (exists $ResultsHash{$marks}{$fams}) {

			print OUTPUT "\t$ResultsHash{$marks}{$fams}"; 
			
		}else{

			print OUTPUT "\t"

		}
	}

	print OUTPUT "\n";
}

}

csv();




