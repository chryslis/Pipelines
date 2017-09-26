#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);


#First file -> Feature list 
my $file1 = "/media/chrys/HDDUbutuMain/Concat.2272017/FeatureList";

#Second file -> RepeatMasker Database
my $file2 = "/media/chrys/HDDUbutuMain/Concat.2272017/RepeatMaskerTrack.Sorted.Cleaned.July17.Indexed.2272017";

open(READ1,$file1) || die "$!";

my @features;

while (<READ1>) {
 	chomp;
 	push(@features,$_);

}

close(READ1);

my %AnnotationHash;

open(READ2,$file2);

while (<READ2>) {
	chomp;
	my @temp = split("\t",$_);

	my $Species = $temp[3];

	my $Annotation = $temp[4]."\t".$temp[5];

	$AnnotationHash{$Species} = $Annotation;
}

foreach my $species (sort keys %AnnotationHash){
	print "$species\t$AnnotationHash{$species}\n";
}