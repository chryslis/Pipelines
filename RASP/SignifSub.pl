#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use File::Basename;
use Cwd;

#Results from analysis of Enrichment Pipeline
my $results = $ARGV[0];


my @decomp = split(/\//,$results);
my $lenNamePath = $#decomp;
my $path = join("/",@decomp[0...$lenNamePath-1]);
my $sampleName = $decomp[$lenNamePath];
@decomp = split(/\./,$sampleName);
my $mark = $decomp[0];

my $shuffLoc = "/Shuffle.".$mark;
my $shuffleFolder = $path.$shuffLoc;
my %EnrichResultsHash;
my %Backup;

open(RESULT,$results) || die "Could not open results $results:$!";

while(<RESULT>){
	chomp;
	my @temp = split("\t");
	my $len = $#temp;

	$EnrichResultsHash{$temp[0]} = $temp[$len];
	$Backup{$temp[0]} = join("\t",@temp[1...$len]);
}

close(RESULT);

opendir(SHUFFLE,$shuffleFolder) || die "Could not read folder $shuffleFolder $!";

my @Shuffles;

while (readdir SHUFFLE) {
	chomp;
	if ($_ =~ m/\.Shuffle\./g) {
		push(@Shuffles,$_);
	}
}

close(SHUFFLE);

my $permNum = scalar( @Shuffles);
my %ShuffResHash;
for $_(@Shuffles){

	my @temp = split (/\./,$_);
	my $len = $#temp;
	my $num = $temp[$len];
	my $currentFile = $shuffleFolder."/".$_;

	open(SHUFRES,$currentFile) || die "Could not open $_ :$!";

	while (<SHUFRES>) {
		chomp;
		my @temp = split("\t");
		my $len = $#temp;

		$ShuffResHash{$num}{$temp[0]} = $temp[$len];
	}
}

close(SHUFRES);

my %reportHash;

foreach my $shuffs(sort keys %ShuffResHash){

	foreach my $shuffedfeatures (keys %{$ShuffResHash{$shuffs}}){

		if ( ${ShuffResHash{$shuffs}{$shuffedfeatures}} > $EnrichResultsHash{$shuffedfeatures}) {

			$reportHash{$shuffedfeatures} += 1; 

		}else{

			$reportHash{$shuffedfeatures} += 0; 
		}
	}
}


for my $keys (keys %reportHash){

	$reportHash{$keys} = $reportHash{$keys}/$permNum;
}

my $outPath = $path."/".$mark.".$decomp[1].Analysis";

open(OUT,">",$outPath) || die "Could not create $outPath: $!";

print OUT "FeatureName\tReadCount\tOccurence\tEnrichmentValue\tpValue\n";

foreach my $keys(sort keys %reportHash){

	print OUT "$keys\t$Backup{$keys}\t$reportHash{$keys}\n";

}

print "Number of Shuffles was: $permNum \n";
