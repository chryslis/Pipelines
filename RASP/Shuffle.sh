#!/bin/bash

echo "Specify path to Conncatenated Genome."
#read ConcGenome
ConcGenome=/media/chrys/HDDUbutuMain/Concat.2272017/ConcatenatedGenome.2272017
#echo "Preparing Shuffle..."
outDir=$(dirname "${ConcGenome}")
jobID=$(basename ${ConcGenome} | tr -dc 0-9)
echo "What Mark is getting aligned?"
#read Mark
Mark=H2BK15ac
echo "What sorting was used?[F/S]"
#read sortType
sortType=S
sorting=$(echo "${sortType^^}") 

if [[ "$sorting" == "S" ]]
then 
	echo "Selected species"
	LIST=$outDir/Species.Summary.*
	SELECTION=Species

elif [[ "$sorting" == "F" ]] 
then
	echo "Selected SuperFamily"
	LIST=$outDir/Super.Summary.*
	SELECTION=SuperFamily
else
	echo "Nothing selected,defaulting to species"
	sorting="S"
	LIST=$outDir/Species.Summary.*
fi


ENRICHMENT=${PWD}/ReadEnrichment.pl
REVERT=${PWD}/IDReverte.pl
OriginalIndex=$outDir/RepeatMaskerTrack.Sorted.Cleaned.July17.Indexed.2272017
VECTOR=$outDir/Alignments.$Mark/$Mark.ReadWeightVector


mkdir $outDir/Alignments.$Mark/Shuffle.$Mark

for (( i = 4; i < 5; i++ )); do

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
	paste $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}" $outDir/Alignments.$Mark/$Mark.IDList > $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark"-${i}".Shuffle

	#Removing intermediate files
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark.ShuffledReads."${i}"

	#Removing temporary folder
	rm -r $outDir/Alignments.$Mark/Shuffle.$Mark/Temp/

	echo "	Reverting IDs to features for shuffle..."

	#Final steps for processing.
	$REVERT $OriginalIndex $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark"-${i}".Shuffle | $ENRICHMENT $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark"-${i}".Shuffle $sorting $VECTOR $LIST
	rm $outDir/Alignments.$Mark/Shuffle.$Mark/$Mark"-${i}".Shuffle


done

### This only if loop is used for all shufs###
# SIGNIF=${PWD}/SignifSub.pl;
# $SIGNIF $outDir/Alignments.$Mark/$Mark.Enrichment$SELECTION.Result

# FDR=${PWD}/FDR.R 

# Rscript --vanilla $FDR $outDir/Alignments.$Mark/$Mark.Enrichment"${SELECTION}".Analysis $outDir/Alignments.$Mark/$Mark.Enrichment"${SELECTION}".Analysis.Adjusted