#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use List::Util qw( min max );

#Original MER11C.IndexedPositions
my $file1 = $ARGV[0];

#Weight Vextor for the given Mark
my $file2 = $ARGV[1];

#Intersected File
my $file3 = $ARGV[2];

my %OriginalIDs;

open(READ1,$file1) || die "Could not open $file1 ! $!";

while (<READ1>) {
	chomp;
	my @temp = split("\t",$_);
	my @temp2 = split(/\:/,$temp[6]);
	my $ID = $temp2[1];

	$OriginalIDs{$ID} = join("\t",@temp[0..5]);
}

close(READ1);

my %EnrichmentHash;
my %weightsHash;

open(GETWEIGHTS,$file2) || die "Could not open $file2: $!";

while (<GETWEIGHTS>) {
	chomp;
	my @temp = split("\t",$_);
	$weightsHash{$temp[0]} = $temp[1];
}

close(GETWEIGHTS);

open(READ2,$file3) || die "Could not open $file3: $!";
my $sum;

while (<READ2>) {
 	chomp;
 	my @temp = split(/\s/,$_);

 	my @IDs = split(":",$temp[1]);
 	
 	my $IDAlignment = $IDs[1];
 	my $read = $temp[0];


 	if (exists $OriginalIDs{$IDAlignment}) {

 		if (exists $weightsHash{$read}) {

 			$EnrichmentHash{$IDAlignment} += $weightsHash{$read};
 		}
 	}
}

close(READ2);



# foreach my $keys (%EnrichmentHash){

# 	print  "Panik at $keys \n";

# 	my @Informations = split("\t",$OriginalIDs{$keys});

# 	my $originalGenomicLocations = join("\t",@Informations[0..2]);

# 	#print "$originalGenomicLocations\t$EnrichmentHash{$keys}\t$keys\n";

# }

foreach my $elements(sort keys %EnrichmentHash){

	my @Informations = split("\t",$OriginalIDs{$elements});
	my $originalGenomicLocations = join("\t",@Informations[0..2]);

	print "$originalGenomicLocations\t$EnrichmentHash{$elements}\tID:$elements\n";
}