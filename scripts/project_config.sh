# Project directory template

# Usage: sh genomics_config.sh
# Generates the project directory structure.
# Also contains variable definitions for all directory paths in the project...
# These can be accessed by downstream scripts in the pipeline using
#     source /path/to/genomics_config.sh

# Assign project identifier variable.
# This is not the actual project path; it's just a string that can be used
# when naming submitted jobs, for example.
PROJECT="Pigmentation_Project"

# project directory to be created. Rename if necessary.
PROJECT_DIR=/panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project

# Subdirectory variables. These are all relative to PROJECT_DIR,
# so modifying them shouldn't be necessary.
DATA_DIR=${PROJECT_DIR}/data
REF_HISAT2_DIR=${DATA_DIR}/ref_hisat2
RAW_DIR=${DATA_DIR}/raw_data
FILTERED_SEPARATE_DIR=${DATA_DIR}/filtered_separate
RAW_POOLED_DIR=${DATA_DIR}/raw_pooled
FILTERED_POOLED_DIR=${DATA_DIR}/filtered_pooled


RESULTS_DIR=${PROJECT_DIR}/results

RESULTS_SEPARATE_DIR=${RESULTS_DIR}/separate
RESULTS_SEPARATE_FASTP=${RESULTS_SEPARATE_DIR}/fastp-reports
RESULTS_SEPARATE_JSON=${RESULTS_SEPARATE_FASTP}/json
RESULTS_SEPARATE_HISAT=${RESULTS_SEPARATE_DIR}/hisat-alignment
RESULTS_SEPARATE_SAM=${RESULTS_SEPARATE_HISAT}/sam-output
RESULTS_SEPARATE_BAM=${RESULTS_SEPARATE_HISAT}/sorted-bam
RESULTS_SEPARATE_EXPRESSION=${RESULTS_SEPARATE_DIR}/gene-expression

RESULTS_POOLED_DIR=${RESULTS_DIR}/pooled
RESULTS_POOLED_FASTP=${RESULTS_POOLED_DIR}/fastp-reports
RESULTS_POOLED_JSON=${RESULTS_POOLED_FASTP}/json
RESULTS_POOLED_HISAT=${RESULTS_POOLED_DIR}/hisat-alignment
RESULTS_POOLED_SAM=${RESULTS_POOLED_HISAT}/sam-output
RESULTS_POOLED_BAM=${RESULTS_POOLED_HISAT}/sorted-bam
RESULTS_POOLED_EXPRESSION=${RESULTS_POOLED_DIR}/gene-expression


OUTPUT_DIR=${PROJECT_DIR}/output

SCRIPTS_DIR=${PROJECT_DIR}/scripts

#Finally, generate the project directory structure.
mkdir -p ${PROJECT_DIR} \
${DATA_DIR} \
${REF_HISAT2_DIR} \
${RAW_DIR} \
${RAW_POOLED_DIR} \
${FILTERED_SEPARATE_DIR} \
${FILTERED_POOLED_DIR} \
${RESULTS_DIR} \
${RESULTS_SEPARATE_DIR} \
${RESULTS_SEPARATE_FASTP} \
${RESULTS_SEPARATE_JSON} \
${RESULTS_SEPARATE_HISAT} \
${RESULTS_SEPARATE_SAM} \
${RESULTS_SEPARATE_BAM} \
${RESULTS_SEPARATE_EXPRESSION} \
${RESULTS_POOLED_DIR} \
${RESULTS_POOLED_FASTP} \
${RESULTS_POOLED_JSON} \
${RESULTS_POOLED_HISAT} \
${RESULTS_POOLED_SAM} \
${RESULTS_POOLED_BAM} \
${RESULTS_POOLED_EXPRESSION} \
${OUTPUT_DIR} \
${SCRIPTS_DIR}
