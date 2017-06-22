#!/bin/bash

#echo "Specify path to Conncatenated Genome."
#read ConcGenome
ConcGenome=/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/ConcatenatedGenome.22517
#echo "Preparing Shuffle..."
outDir=$(dirname "${ConcGenome}")
#echo "What Mark is getting aligned?"
#read Mark
Mark=H3K4me3
#echo "What sorting was used?[F/S]"
sorting=F

ENRICHMENT=${PWD}/ReadEnrichment.pl
REVERT=${PWD}/IDReverte.pl
OriginalIndex=$outDir/RepeatMaskerTrack.Sorted.Cleaned.Indexed.*
VECTOR=$outDir/Alignments.$Mark/$Mark.ReadWeightVector

if [[ "$sorting" == "S" ]]; then
	LIST=$outDir/Alignments.$Mark/$Mark.SummaryFam;
else
	LIST=$outDir/Alignments.$Mark/$Mark.SummarySuper;
fi


mkdir $outDir/Alignments.$Mark/Shuffle.$Mark

#if [[ ! -f $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID  ]]; then

#	cut -f2 $outDir/Alignments.$Mark/$Mark.Filtered.bed > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID
#fi

#if [[ ! -f $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.READLIST ]]; then
#	cut -f1 $outDir/Alignments.$Mark/$Mark.Filtered.bed > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.READLIST 
#fi

start=$(date +"%T")

for (( i = 2; i < 3; i++ )); do

	mkdir $outDir/Alignments.$Mark/Shuffle.$Mark/Temp

	split $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.READLIST  -l 1000000 $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/s

	for files in $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/*;
	do
		name=$(basename ${files});
		shuf ${files} > $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/"${name}".shuf;
	done

	cat $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/*.shuf > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}"

	paste $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}" $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffleID > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}"

	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}"

	rm -r $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/

	echo "	Reverting IDs to features for shuffle..."

	$REVERT $OriginalIndex $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}" | $ENRICHMENT $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Features."${i}" $sorting $VECTOR $LIST
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}"

done