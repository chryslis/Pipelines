#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use File::Basename;
use Cwd;

my $start = time();
my $timestamp = localtime();
my $file2 = $ARGV[0];
my $outName = basename($file2);
my $JobIDFile = $file2;

print "Input File: $JobIDFile\n";

if($JobIDFile =~ /([0-9]+)/g){
	$JobIDFile = $1;
}

print "JobID: $JobIDFile\n";

my @outNameNew = split(/\./,$outName);
$outName = $outNameNew[0].".".$outNameNew[1].".".$outNameNew[2];
my $outFile =  $outName.".Merged.".$JobIDFile;
my $dir = cwd();
my $path = $dir."/"."results.".$JobIDFile."/";
my $pathToOutput = $path.$outFile;

print "Results will be placed at $pathToOutput\n";

open(FH,$file2) || die "Could not open $file2: $!\n";
open(OUT,">",$pathToOutput) || die "Could not create Output: $!\n";

defined($_ = <FH>) or exit;
chomp;
my @sample = split;
my $sampleID = $sample[6];

while (<FH>) {
	print "Merging...\r";
	chomp;
	my @newsample = split("\t",$_);
	my $newsampleID = $newsample[6];
	
	if ($sample[0] ne $newsample[0]  || $newsample[2] < $sample[1] || $sample[2] < $newsample[1]) {

		print OUT "$sample[0]\t$sample[1]\t$sample[2]\t$sample[6]\n";

		@sample = @newsample;
		$sampleID = $sample[6];
		
	}elsif ( $sample[1] <= $newsample[1] && $newsample[2] <= $sample[2] ){

		my $concat = $newsampleID;
		$concat =~ s/ID\:/\|/g;
		$sample[6] = $sample[6].$concat
		
	}elsif ( $sample[1] <= $newsample[1] ){

		my $concat = $newsampleID;
		$concat =~ s/ID\:/\|/g;
		$sample[2] = $newsample[2];
		$sample[6] = $sample[6].$concat;

	}elsif ($newsample[2] <= $sample[2] ){

		$sample[1] = $newsample[1];
		print "File was not sorted!\n";
		die

	}else{

		@sample = @newsample;
		$sampleID = $sample[6];

	}	
}


print OUT "$sample[0]\t$sample[1]\t$sample[2]\t$sample[6]\n";

my $end = time ();
my $jobTime = $end-$start;


print "\nDone!\n";

print "Timestamp:$timestamp\tJob took $jobTime seconds\tJobID:$JobIDFile\n";

close(FH);
close(OUT);