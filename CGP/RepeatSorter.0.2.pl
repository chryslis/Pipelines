#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Cwd;
use File::Basename;

#requieres input to be sorted by chromosome and length
#use sort -k1,1 -k2,2n for bed files
#Formally known as artificalGenome0.2.pl

my $start = time();
my $file = $ARGV[0];
my $fileName = basename($file);

my $rand = $ARGV[1];
my $outBedFile = $fileName.".Indexed.".$rand;

my $timestamp = localtime();
my $oldcurrent = 0;
my $current = 0;

print "Starting up...\n";

mkdir "results.$rand";
my $newDirName = "results.".$rand;

my $dir = cwd();
my $path = $dir."/".$newDirName."/";

print "Results will be placed in: $path\n";

my $outFile = $path.$outBedFile;

open(READ,$file) || die "Could not open the file:$file because:$!\n";
open(OUTBED,">",$outFile) || die "Could not create $outBedFile:$!\n";


#ID for features
my $idNum = 0;

print "Processing...\n";

while (<READ>) {
	chomp;
	my $line = $_;
	$line =~ s/\s/\t/g;

	#Class Identifier is stored at pos12 / genomeStart = 7, Genome
	my @temp = split("\t",$line);
	#Make exclusion list accessible for user later
	#List of Exclusions: Low_Complexity,Simple_Repeat,"Satellite","tRNA",
	if ($temp[12] eq "Low_complexity" || $temp[12] eq "Simple_repeat" || $temp[12] eq "Satellite" || $temp[12] eq "tRNA" || $temp[12] eq "snRNA" || $temp[12] eq "srpRNA" || $temp[12] eq "scRNA" || $temp[12] eq "rRNA") {
		next;
	}elsif($temp[11] eq "Satellite" || $temp[11] eq "RNA" || $temp[11] =~ m/\D+\?/g){
		next;
	}elsif($temp[5] =~ /chr.+_/g ) {
		next;
	}elsif($temp[5] =~ /chrM/g ) {
		next;
	}else{
		#Generating intermediate file for storage of sequences.
		my $localTemp = $temp[5]."\t".$temp[6]."\t".$temp[7]."\t".$temp[10]."\t".$temp[11]."\t".$temp[12]."\t"."ID:$idNum";
		print OUTBED "$localTemp\n";
		$idNum++;
	}

	$oldcurrent = $current;
	$current = time();
	$current = int($current) - int($start);

	unless ($current == $oldcurrent){
		print "Current runtime: $current seconds";
		
	}

	print "\r";
}

print "\n";
my $end = time ();
my $jobTime = $end-$start;
print "Done!\n";
print "Timestamp:$timestamp\tJob took $jobTime seconds\tJobID:$rand\n";

close(OUTBED);
close(READ);