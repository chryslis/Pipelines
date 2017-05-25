#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use List::Util qw(sum);

my $inPut = $ARGV[0];
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

my $mean = int ( mean(@readsPerInstance) ) ;
my $covCut = 0.60;

close(READ);
open(READ2,$inPut) || die "Could not open $inPut: $!";

while (<READ2>) {
	chomp;
	my @line = split("\t",$_);

	if (exists $sortHash{$line[4]}) {

		#Assuming that after filtering this data is technically not required anymore.
		#my $Coverage = join("\t",@{$sortHash{$line[4]}});
		#my $Annotation = join("\t",@line);
		my $Annotation = $line[3]."\t".$line[4]."\t".$line[5];

		my @temp = @{$sortHash{$line[4]}};

		#The Coverage data is probably not necessary to include anymore
		#unless ($temp[0] < $mean && $temp[3] < $covCut ) {
		#	print "$Annotation\t$Coverage\n";
		#}

		#Likewise, probably not necessary to include start/stop etc...
		unless ($temp[0] < $mean && $temp[3] < $covCut ) {
			print "$Annotation\n";
		}
	}
}





