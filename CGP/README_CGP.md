The Comprehensive Genome concatination Pipeline

This pipeline consists in general of six scripts. The input is the RepeatMasker Track aquired by USCS or the download via the RepBase Website ( registration required and really hard to find) and should be already be processed by the RepeatMasker Track Processing Pipeline or script.

What you will get as output is a results folder which can be used as input for the RASP Pipeline.

The script will guide you through its application.

It is imporant to note, that it is recommedended that you move the results folder to anywhere else on your harddrive. The outputs of the RASP pipeline require moderate amouts of space (about 10gb per run) which will be removed after finish, make sure this space is free and availible.


Make sure you have:
1. Path to the genome in fasta format.
2. Path to your processed RepeatMasker Track

As an input, a spacer length is required. This will determine how much spacing is placed between each feature. If you plan to use paired-end reads, make sure that the spacer length is LONGER as the linker used in the paired reads to avoid mapping of a mate to a neighbouring feature in your concatenated genome. Default is 350 which should be enough for most datasets.