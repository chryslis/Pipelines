#!/bin/bash

echo "Specify path to Conncatenated Genome."
#read ConcGenome
ConcGenome=/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/ConcatenatedGenome.22517

echo "Preparing Shuffle..."
outDir=$(dirname "${ConcGenome}")

echo "What Mark is getting aligned?"
#read Mark
Mark=DNASE154


ENRICHMENT=${PWD}/ReadEnrichment.pl
REVERT=${PWD}/IDReverte.pl
OriginalIndex=$outDir/RepeatMaskerTrack.Sorted.Cleaned.Indexed.*
sorting=F
VECTOR=$outDir/Alignments.$Mark/$Mark.ReadWeightVector

if [[ "$sorting" == "S" ]]; then
	LIST=$outDir/Alignments.$Mark/$Mark.SummaryFam;
else
	LIST=$outDir/Alignments.$Mark/$Mark.SummarySuper;
fi


mkdir $outDir/Alignments.$Mark/Shuffle.$Mark

if [[ ! -f $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID  ]]; then

	cut -f2 $outDir/Alignments.$Mark/$Mark.Filtered.bed > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID
fi

if [[ ! -f $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.READLIST ]]; then

	cut -f1 $outDir/Alignments.$Mark/$Mark.Filtered.bed > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.READLIST 
fi



#TOTAL=$(wc -l $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.READLIST)
TOTAL=398677991

start=$(date +"%T")

for (( i = 9; i < 12; i++ )); do

	start=$(date +"%T")
	echo "start: $start"

	echo "	Executing shuffle ${i}"
	echo "	Shuffling..."
	shuf $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID."${i}"

	echo "	Combining..."
	paste $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.READLIST $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID."${i}" > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}"
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID."${i}"

	echo "	Reverting IDs to features for shuffle..."
	$REVERT $OriginalIndex $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}" > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle.Features."${i}"
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}"

	echo "	Calculating Shuffled Enrichment..."
	$ENRICHMENT $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle.Features."${i}" $TOTAL $sorting $VECTOR $LIST
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle.Features."${i}"

	end=$(date +"%T")
	echo "End: $end"
done