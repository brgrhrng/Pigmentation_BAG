#!/bin/bash
#SBATCH --partition=sixhour          # Partition Name (Required)
#SBATCH --ntasks=1                   # Run a single task
#SBATCH --cpus-per-task=8            # Number of CPU cores per task should match the NTHREADS variable
#SBATCH --mem-per-cpu=60gb           # Job memory request
#SBATCH --time=06:00:00              # Time limit hrs:min:sec
#SBATCH --output=/panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project/output/GetReference-outfile.out  # Error and Out stream
#SBATCH --job-name=Pigmentation_Project_Reference

#USAGE: sbatch GetReference.sh
#Downloads reference transcriptome, generates necessary files for hisat2, and indexes it.

#Get project path variables
source /panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project/scripts/project_config.sh

#Activate environment with hisat2 installed
module load anaconda
conda activate RNAseq_Project_hisat2

#Download References
echo "Downloading Reference files...."
wget -O ${REF_HISAT2_DIR}/dm6.fa.gz ftp://hgdownload.cse.ucsc.edu/goldenPath/dm6/bigZips/dm6.fa.gz
wget -O ${REF_HISAT2_DIR}/dmel-all-chromosome-r6.39.fasta.gz http://ftp.flybase.org/genomes/Drosophila_melanogaster/dmel_r6.39_FB2021_02/fasta/dmel-all-chromosome-r6.39.fasta.gz
wget -O ${REF_HISAT2_DIR}/dmel-all-r6.39.gtf.gz ftp.flybase.org/genomes/Drosophila_melanogaster/dmel_r6.39_FB2021_02/gtf/dmel-all-r6.39.gtf.gz
wget -O ${REF_HISAT2_DIR}/DSPR.r6.SNPs.vcf.gz http://wfitch.bio.uci.edu/~tdlong/SantaCruzTracks/DSPR_R6/dm6/variation/DSPR.r6.SNPs.vcf.gz
gunzip ${REF_HISAT2_DIR}/*.gz

echo "---------------------"
echo "Generating files for hisat...."

#Get list of splice sites
hisat2_extract_splice_sites.py ${REF_HISAT2_DIR}/dmel-all-r6.39.gtf > ${REF_HISAT2_DIR}/dmel-all-r6.39-splice_sites.txt

#Get list of exons
hisat2_extract_exons.py ${REF_HISAT2_DIR}/dmel-all-r6.39.gtf > ${REF_HISAT2_DIR}/dmel-all-r6.39-exons.txt

# Standardize hisat file, so that every base is uppercase
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' ${REF_HISAT2_DIR}/dm6.fa > ${REF_HISAT2_DIR}/dm6_allcaps.fa

#Get list of SNPs
hisat2_extract_snps_haplotypes_VCF.py --non-rs -v ${REF_HISAT2_DIR}/dm6_allcaps.fa ${REF_HISAT2_DIR}/DSPR.r6.SNPs.vcf ${REF_HISAT2_DIR}/DSPR_dm6_var

echo "---------------------"

#Index using above files
echo "Building index...."
hisat2-build -f \
            -p 8 \
            --ss ${REF_HISAT2_DIR}/dmel-all-r6.39-splice_sites.txt \
            --exon ${REF_HISAT2_DIR}/dmel-all-r6.39-exons.txt \
            --snp ${REF_HISAT2_DIR}/DSPR_dm6_var.snp \
            --haplotype ${REF_HISAT2_DIR}/DSPR_dm6_var.haplotype ${REF_HISAT2_DIR}/dm6.fa ${REF_HISAT2_DIR}/dm6_annot_dsprsnp || { echo "ERROR: hisat2 index failed" ; exit 1; }

conda deactivate

echo "---------------------"
echo "DONE."
