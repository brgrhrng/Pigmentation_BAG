#!/bin/bash
#SBATCH --partition=sixhour          # Partition Name (Required)
#SBATCH --ntasks=1                   # Run a single task
#SBATCH --cpus-per-task=8            # Number of CPU cores per task
#SBATCH --mem-per-cpu=60gb           # Job memory request
#SBATCH --time=06:00:00              # Time limit hrs:min:sec
#SBATCH --output=/panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project/output/fastp/QC_%A_%a.out  # Error and Out stream; A indicates the parent run number, a indicates the index of the subarrayed file
#SBATCH --job-name=Pigmentation_Project_QC_%A_%a.out
#SBATCH --array=1-384							   # 1 - N number of samples

#USAGE:  sbatch --array [1-n] scripts/Fastp_ARRAY.sh input_directory filtered_directory report_directory
# For each sample file in the input directory (up to "n"), use fastp to trim/filter
# the reads and generate a quality report.

#Trimmed files are saved to the provided "filtered_directory", while html reports and
#.json summary files are saved to the given "report_directory."

####################
# SCRIPT VARIABLES #      (change as appropriate)
####################
#Get project path variables
#source /panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project/scripts/project_config.sh

#Activate environment with fastp installed
module load anaconda
conda activate RNAseq_Project_fastp

# Number of processors to use. Capped at --cpus-per-task, defined in header above.
N_THREADS=8

#Input folder, with raw data files (.gz'd)
INP_DIR=${1}

#Output folders
FILTERED_OUTPUT_DIR=${2}
REPORT_OUTPUT_DIR=${3}


#################
# Running FASTP #
#################
echo Array task \#${SLURM_ARRAY_TASK_ID}

#Get nth fastq filename from input directory
# ${SLURM_ARRAY_TASK_ID} is just n
SAMPLE_PATH=$(ls -d ${INP_DIR}/*.fastq.gz | head -n ${SLURM_ARRAY_TASK_ID} | tail -n 1)
SAMPLE_NAME=$(basename ${SAMPLE_PATH} .fastq.gz)

echo ${SAMPLE_PATH}
echo ${SAMPLE_NAME}

#Running fastp on the data. These are single-end.
#https://github.com/OpenGene/fastp#input-and-output
fastp -i ${SAMPLE_PATH} \
      -o ${FILTERED_OUTPUT_DIR}/${SAMPLE_NAME}.filtered.fastq.gz \
      --html ${REPORT_OUTPUT_DIR}/${SAMPLE_NAME}.fastp-report.html \
      --json ${REPORT_OUTPUT_DIR}/json/${SAMPLE_NAME}.fastp.json \
      --thread ${N_THREADS} \
      --detect_adapter_for_pe \
      --cut_tail \
      --cut_window_size 5 \
      --cut_mean_quality 30 \
      --overrepresentation_analysis || { echo "fastp failed" ; exit 1; } #exit statement on fail

conda deactivate

echo "---------------------"
echo "DONE."
