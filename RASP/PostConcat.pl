#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use List::Util qw(sum);

#The general purpose of this script is a filtering step.
#Two filters are getting applied here:
#First filter is the total amount of reads covering a feature.
#The mean sub can be used to remove all features lower then the mean.

# Input 1 is the bedintersected file
my $inPut = $ARGV[0];
# Input 2 is the coverage calculation by bedtools.
my $inPut2 = $ARGV[1];
my $mark = $ARGV[2];
my %sortHash;

my @readsPerInstance;

open(READ,$inPut2) || die "Could not open $inPut2: $!";

while (<READ>) {
	chomp;
	my @line = split("\t",$_);

	$sortHash{$line[3]} = [ $line[4],$line[5],$line[6],$line[7] ];
	push(@readsPerInstance,$line[4]);
}

sub mean{
	return sum(@_)/@_;
}

#Mean number of reads covering a feature. Change this as needed
#my $threshold = int ( mean(@readsPerInstance) ) ;

#Having at least one read covering half of a feature is the currently used filter.
my $threshold = 1;

#Fraction of bases with non-zero coverage. Meaning that very clipped features will
#be thrown out. At this point, it is required that at least 60% of the bases have non-zero cov and
#that they have a certain amount of reads overlapping them ( defined by the threshold variable).
my $covCut = 0.60;

close(READ);
open(READ2,$inPut) || die "Could not open $inPut: $!";

while (<READ2>) {
	chomp;
	my @line = split(/\s/,$_);


	if (exists $sortHash{$line[4]}) {

		my $Annotation = $line[3]."\t".$line[4];

		my @temp = @{$sortHash{$line[4]}};

		#Filtering happens here, adjust if needed

		unless ($temp[0] < $threshold && $temp[3] < $covCut ) {
			print "$Annotation\n";
		}
	}
}

close(READ2);




