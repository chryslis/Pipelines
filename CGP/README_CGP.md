The Comprehensive Genome concatination Pipeline

This pipeline consists in general of six scripts. The input is the RepeatMasker Track aquired by USCS or the download via the RepBase Website ( Registration Required ). Other then format and potentially more up to date data the two tracks are not different. Please note to pick the correct genome assembly for the repeat database.

The input needs to be sorted by chromosome and legnth. Use "sort -k1,1 -k2,2n inputFile" to sort the .bed formated file ( tab-delimited ). Additionally, if you download the Repbase Database, you need to remove the header. This is best done by using "sed -i '1d' inputFile". Note, that this is inplace. Meaning the delete will happen in the file. It is recommended to create a backup.

1.Starting the Pipeline

The first script, is the sorting script.


2.Merging the overlapping features

3.Getting the fasta files

4.Creating an Index

5.Producing a concatenated genome file.


6.Aquiring the size of the new genome.
