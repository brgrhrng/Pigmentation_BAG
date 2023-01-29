Pigmentation_Final_Assignment
Brooks Groharing, brooks.groharing@gmail.com
5/14/2021

=============================
 Script Pipeline & Analysis
=============================
Initial Data Acquisition (Run each once):
1) project_config.sh
	Generates an empty directory structure for the project. Some later scripts may fail to produce outputs, if the folder structure isn't initialed beforehand.
	Also saves a path variable to each directory in the project, which downstream scripts sometimes reference.

2) GetReference.sh
	Batch script which downloads necessary drosophila reference files to data/ref_hisat2, and indexes them for hisat2 alignment.
	
3) CombineReplicates.sh
	 Combines sets of technical replicates from data/raw_data/ into single files, saving the combined files to data/raw_pooled/. 

Gene Expression Pipeline (Must be run separately for the separated and pooled datasets)

4) Fastp_ARRAY.sh
	Batch script which runs fastp on each fastq file in a given input folder in parallel, performing automatic read trimming and producing quality reports. Output directories must also be specified, for the filtered fastq file and the quality reports. These should be directed to appropriate subdirectories of data/ and results/, respectively.
	
	Example:
	sbatch --array [1-384] scripts/Fastp_ARRAY.sh data/raw_data/ data/filtered_separate/ results/separate/fastp-reports/

5) AlignmentExpression_ARRAY.sh
	Another batch script, which for each filtered fastq file in the provided folder:
	
	1) Aligns the transcripts to the indexed reference genome saved under ref_hisat2, saving the output to a provided folder
	
	2) Sorts the aligned .sam files by transcript using Samtools, and saves them as binary .bam files
	
	3) Uses subread's featureCounts to count the number of reads for each expressed exon, saving the resulting table to a gene-expression directory.	
	
	This script expects, as an argument, a path to the results subdirectory for the given analysis group (/results/separate, or /results/pooled). 

	Example:
	sbatch --array [1-96] scripts/AlignmentExpression_ARRAY.sh data/filtered_pooled/ results/pooled/

Data Analyis
6) ExpressionAnalysis.rmd
Includes a differential expression analysis on the feature count results from the separate files, using a temperature x pupal stage x strain interaction model to assess
the effect of each variable on gene expression.
Also compares these results with the expression data from the pooled technical replicates, to determine whether combining the files beforehand has any effect on the results.

====================
 References
====================
Drosophila reference transcriptome, via flybase (Release 6, v39)
ftp.flybase.org/genomes/Drosophila_melanogaster/
	
	Additional dm6 reference files: https://hgdownload.soe.ucsc.edu/downloads.html

Drosophilia Synthetic Population Resource
http://wfitch.bio.uci.edu/~dspr/

edgeR (v3.32.1)
https://bioconductor.org/packages/release/bioc/html/edgeR.html

FastP (v0.20.1)
https://github.com/OpenGene/fastp

Limma (v 3.46.0)
https://www.bioconductor.org/packages/release/bioc/vignettes/limma/inst/doc/usersguide.pdf
 
Hisat2 (v2.1.0)
http://daehwankimlab.github.io/hisat2/manual/

Samtools (v1.11)
http://www.htslib.org/doc/samtools.html

Subread (v2.0.1)
http://bioinf.wehi.edu.au/subread-package/SubreadUsersGuide.pdf
