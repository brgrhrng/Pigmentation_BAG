#Usage: sh PoolReplicates.sh
#Combines technical (lane) replicates from data/raw_data/ for each sample, and saves
# the concatenated files to data/raw_pooled/.
#These then can be analyzed separately from the loose raw files.

#This code requires that each sample has at least a lane 1 file, to be processed.
#It also depends on the raw data files being named as follows:
# p[stage]_[temp]C_R#_strain_L#.fastq.gz
# ex p1_18C_R1_11051_L3.fastq.gz

# Given the size of the data files, this script can take a while. I would recommend running it in a virtual
# job using srun.


#Get project path variables
source /panfs/pfs.local/scratch/sjmac/bgroharing_sta/Pigmentation_Project/scripts/project_config.sh

#Move into data/raw_data/
cd ${RAW_DIR}

#For each L1 sample
for file in p*_*C_R?_*_L1.fastq.gz
do
echo "----------------------"
echo "Combining:"

#Get a wild card covering the four lane replicates
file_wc="${file/L1.fastq.gz/L?.fastq.gz}"

echo $(ls ${file_wc})

#Concatenate these files, and save the result to data/raw_pooled/
cat $(ls ${file_wc}) > ${RAW_POOLED_DIR}/${file/L1/pooled}

echo "Output saved to ${RAW_POOLED_DIR}/${file/L1/pooled}"
done

echo "----------------------"
echo "DONE."
