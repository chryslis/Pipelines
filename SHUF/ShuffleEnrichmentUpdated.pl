#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $FeatureList = $ARGV[0];
my %countingHash;
my %BackupData;

while (<STDIN>) {

	chomp;
	my @temp = split(/\s+/,$_);
	my $Read = $temp[0];

	my $SampleName = $temp[1];

	if (exists $countingHash{$SampleName}) {

		$countingHash{$SampleName} += 1;

	}else{

		$countingHash{$SampleName} += 0;
	}
}


open(READ2,$FeatureList) || die "Could not read $FeatureList: $!";

while (<READ2>) {
	chomp;
	my @temp = split("\t",$_);
	my $feature = $temp[0];
	my $supplementaryInfo = join("\t",$temp[1],$temp[2],$temp[3]);

	$BackupData{$feature} = $supplementaryInfo;
}


foreach my $keys (sort keys %BackupData){

	my $key = $keys;
	$key =~ s/\s+//g;

	if (exists $countingHash{$key}) {

		print "$key\t$countingHash{$key}\t$BackupData{$keys}\n";
		
	}else{

		print "$key\t0\t$BackupData{$keys}\n";

	}


}



#print Dumper \%countingHash;

