#!/bin/bash

#echo "Specify path to Conncatenated Genome."
#read ConcGenome
ConcGenome=/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/ConcatenatedGenome.22517
#echo "Preparing Shuffle..."
outDir=$(dirname "${ConcGenome}")
#echo "What Mark is getting aligned?"
#read Mark
Mark=H3K27acBQ
#echo "What sorting was used?[F/S]"
#read sortType
sortType=S
sorting=$(echo "${sortType^^}") 

if [[ "$sorting" == "S" ]]
then 
	echo "Selected Species"

elif [[ "$sorting" == "F" ]] 
then
	echo "Selected SuperFamily"
else
	echo "Nothing selected,defaulting to SuperFamily"
	sorting="F"
fi


ENRICHMENT=${PWD}/ReadEnrichment.pl
REVERT=${PWD}/IDReverte.pl
OriginalIndex=$outDir/RepeatMaskerTrack.Sorted.Cleaned.Indexed.*
VECTOR=$outDir/Alignments.$Mark/$Mark.ReadWeightVector


mkdir $outDir/Alignments.$Mark/Shuffle.$Mark



for (( i = 7; i < 15; i++ )); do

	echo "Executing shuffle: ${i}"

	#creating directory for shuffle output
	mkdir $outDir/Alignments.$Mark/Shuffle.$Mark/Temp

	#Splitting the files into rather managable chuncks for shuffling
	split $outDir/Alignments.$Mark/$Mark.ReadList  -l 1000000 $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/s

	#Shuffling all the files
	for files in $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/*;
	do
		name=$(basename ${files});
		shuf ${files} > $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/"${name}".shuf;
	done

	#Combing the shuffled files back together
	cat $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/*.shuf > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}"

	#Combing reads and the IDs
	paste $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}" $outDir/Alignments.$Mark/$Mark.IDList > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}"

	#Removing intermediate files
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}"

	#Removing temporary folder
	rm -r $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/

	echo "	Reverting IDs to features for shuffle..."

	#Final steps for processing.
	$REVERT $OriginalIndex $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}" | $ENRICHMENT $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}" $sorting $VECTOR
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.Shuffle."${i}"


done