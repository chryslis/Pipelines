#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Cwd;

my $file = $ARGV[0];
my $addLength = $ARGV[1];

my @temp = split(/\./,$file);


my $JobIDFile = $file;

if($JobIDFile =~ /([0-9]+)/g){
	$JobIDFile = $1;
}

my $outFile = "MergeIndex.".$JobIDFile.".bed";

my $dir = cwd();
my $path = $dir."/"."results.".$JobIDFile."/";
my $pathToOutput = $path.$outFile;

open(READ,$file) || die "Could not open $file,$!";
open(OUT,">",$pathToOutput) || die "Coult not create $outFile $!";

my $start = 0;
my $stop;

my $firstLine = <READ>;
chomp $firstLine;
my @temp1 = split("\t",$firstLine);
my $chrPointerOld = $temp1[0];
$chrPointerOld =~ m/(chr.)/g ;
$chrPointerOld = $1;

#my $chrPointerOld ="chr1";


my $feature = $temp1[2]-$temp1[1];

$start = $start +$addLength;
$stop = $start + $feature; 
my $oldLine = $chrPointerOld."\t".$start."\t".$stop."\t".$temp1[3];
print OUT "$oldLine\n";

$start = $stop;
$stop = 0;

while (<READ>) {
	chomp;

	my @line = split("\t",$_);

	my $chrPointer = $line[0];

	if ($chrPointer ne $chrPointerOld) {
		
		$start = 0;
	}
	
	my $featureLength = $line[2]-$line[1];

	$start = $start + $addLength;
	$stop = $start + $featureLength;

	my $newline = $line[0]."\t".$start."\t".$stop."\t".$line[3];

	print OUT "$newline\n";

	$start = $stop;
	$stop = 0;
	$chrPointerOld = $chrPointer;

}

print "Done!\n";