#!/usr/bin/perl

use warnings;
use strict;
use List::Util qw(shuffle);
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);
use File::Basename;
use Cwd;

my $start = time();

#my $inPut = $ARGV[0];
my $inPut = "/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/Alignments.DNASE1/DNASE1.Filtered.bed";

open(READ,$inPut) || die "Could not open $inPut:$!";

my %Storage;

while (<READ>) {
	chomp;
	my @temp = split("\t",$_);
	my $READ = $temp[0];

	$Storage{$READ} = $temp[1];

}

my @keys = shuffle keys %Storage;

while (my $key1 = each %Storage) {
	my $key2 = shift(@keys);
	@Storage{$key1,$key2} = @Storage{$key2,$key1};
}

open(TEST,">TESTSHUFFLEOUT");

while (my $keys = each %Storage) {

	print TEST "$keys\t$Storage{$keys}\n";

}

my $stop = time();

my $runtime = $stop - $start;

print "Runtime was:".int($runtime/60)."\n";
