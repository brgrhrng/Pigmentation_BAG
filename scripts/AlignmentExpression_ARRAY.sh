#!/bin/bash
#SBATCH --partition=sixhour          # Partition Name (Required)
#SBATCH --ntasks=1                   # Run a single task
#SBATCH --cpus-per-task=8            # Number of CPU cores per task
#SBATCH --mem-per-cpu=60gb           # Job memory request
#SBATCH --time=06:00:00              # Time limit hrs:min:sec
#SBATCH --output=/panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project/output/alignment/Alignment_%A_%a.out  # Error and Out stream; A indicates the parent run number, a indicates the index of the subarrayed file
#SBATCH --job-name=Pigmentation_Project_Alignment_%A_%a.out
#SBATCH --array=1-384							   # 1 - N number of samples

#USAGE:  sbatch --array [1-384] scripts/Alignment_ARRAY.sh input_dir results_dir
# Loads filtered sample files from input_dir, aligns them to the indexed reference
# using hisat2, and saves the aligned .sam files to results_dir/hisat_sam.

#input_dir should be the directory containing trimmed data files, produced by
#Fastp_ARRAY, for a given data preparation
#ie. data/filtered_separate, or data/filtered_pooled.

#results_dir should be the subdirectory of results associated with that data setup.
#ie. results/separate, or results/pooled.

####################
# SCRIPT VARIABLES #      (change as appropriate)
####################
#Get project path variables
source /panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project/scripts/project_config.sh

# Number of processors to use. Capped at --cpus-per-task, defined in header above.
N_THREADS=8

#Filtered data files, from fastp (.gz'd)
FILES_TO_ALIGN=${1}
RESULTS_OUTPUT_DIR=${2}

#############
# Alignment #
#############
echo Array task \#${SLURM_ARRAY_TASK_ID}

#Activate environment with hisat2 installed
module load anaconda
conda activate RNAseq_Project_hisat2

#Get nth fastq filename from input directory
# ${SLURM_ARRAY_TASK_ID} is just n
SAMPLE_PATH=$(ls -d ${FILES_TO_ALIGN}/*.filtered.fastq.gz | head -n ${SLURM_ARRAY_TASK_ID} | tail -n 1)
SAMPLE_NAME=$(basename ${SAMPLE_PATH} .filtered.fastq.gz)

echo ${SAMPLE_PATH}
echo "Starting hisat for sample: ${SAMPLE_NAME}"
echo "---------------------"

#Location to save result file.
SAM_OUTPUT_PATH=${RESULTS_OUTPUT_DIR}/hisat-alignment/sam-output/${SAMPLE_NAME}.hisat2.sam

#Run alignment.
#http://daehwankimlab.github.io/hisat2/manual/
hisat2 -p ${N_THREADS} \
      --phred33 \
      --no-unal \
      --omit-sec-seq \
      --dta \
      --rna-strandness R \
      --mp 1,0 \
      -x ${REF_HISAT2_DIR}/dm6_annot_dsprsnp \
      -U ${SAMPLE_PATH} \
      -S ${SAM_OUTPUT_PATH} \
      --summary-file ${RESULTS_OUTPUT_DIR}/hisat-alignment/${SAMPLE_NAME}.hisat2summary.txt || { echo "hisat2 failed" ; exit 1; }

echo "Saved aligned file to " ${SAM_OUTPUT_PATH}

conda deactivate

echo "---------------------"

##########################
# Sorting aligned files  #
##########################
#Activate environment with samtools installed
conda activate RNAseq_Project_samtools

echo "Sorting aligned files by read name, using samtools..."

#Location to save result file.
BAM_OUTPUT_PATH=${RESULTS_OUTPUT_DIR}/hisat-alignment/sorted-bam/${SAMPLE_NAME}.hisat2.bam

#Generate sorted .bam file.
#http://www.htslib.org/doc/samtools-sort.html
samtools sort -@ ${N_THREADS} \
                -n \
                -o ${BAM_OUTPUT_PATH} \
                ${SAM_OUTPUT_PATH} || { echo "samtools failed" ; exit 1; }

echo "Saved sorted .bam file to " ${BAM_OUTPUT_PATH}

conda deactivate
echo "---------------------"


############################
# Quantifying Expression   #
############################
#Activate environment with subread installed
conda activate RNAseq_Project_subread

echo "Quantifying expression, using featureCounts from subread..."

#Location to save result file.
EXPRESSION_OUTPUT_PATH=${RESULTS_OUTPUT_DIR}/gene-expression/${SAMPLE_NAME}.hisat2.featureCounts.txt

#Threshhold quality score for counting a read.
#This could be raised... 20 is relatively low.
MIN_SCORE=20

#Quantify transcripts for each exon
#http://bioinf.wehi.edu.au/subread-package/SubreadUsersGuide.pdf
#http://bioinf.wehi.edu.au/featureCounts/
featureCounts -T ${N_THREADS} \
                -t exon \
                -g gene_symbol \
                -Q ${MIN_SCORE} \
                -a ${REF_HISAT2_DIR}/dmel-all-r6.39.gtf \
                -o ${EXPRESSION_OUTPUT_PATH} \
                ${BAM_OUTPUT_PATH}

echo "Saved transcript counts to " ${EXPRESSION_OUTPUT_PATH}

#Remove unnecessary columns from the output files.
cut -f1,6,7 ${EXPRESSION_OUTPUT_PATH} | sed '1,2d' > ${EXPRESSION_OUTPUT_PATH}.trim

echo "Saved trimmed down version to " ${EXPRESSION_OUTPUT_PATH}.trim

conda deactivate
echo "---------------------"
echo "DONE."
