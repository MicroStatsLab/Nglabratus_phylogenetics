#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=75:00:00
#SBATCH --mem=0
#SBATCH --mail-user=adamubua@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=MLST_bel
#SBATCH --output=%x-%j.out

module load StdEnv/2020
module load bwa/0.7.17
module load picard

#Donwload the updated glabrata database
stringMLST.py --getMLST -P datasets/glab --species glabrata

#Creat a loop for handling the file/samples as pairs. You can run it as parallel instead of this loop


for i in $input/*;
do
withpath="${i}" filename=${withpath##*/}
base="${filename}"
sample_name=`echo "${base}" | awk -F ".fastq.gz" '{print $1}'`


stringMLST.py --predict -P datasets/glab -1 $input/"${base}"/"${base}"_1.trimmed_PE.fastq.gz -2 $input/"${base}"/"${base}"_2.trimmed_PE.fastq.gz
done

