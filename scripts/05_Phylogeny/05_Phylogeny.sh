#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=15
#SBATCH --time=268:00:00
#SBATCH --partition=genlm
#SBATCH --mem=1200G # all memory on the node
#SBATCH --mail-user=adamubua@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=N.labrata_phylogeny
#SBATCH --output=%x-%j.out

#Phylogeny
Convert vcf to fasta file
python vcf2phylip/vcf2phylip.py --input 220505_joint_called_filtered.nomtd.snps.vcf.gz --output-folder phylogeny --nexus --nexus-binary --fasta


./FastTreeDbl -nt -gtr phylogeny/220505_joint_called_filtered*.fasta > phylogeny/Global_N.glabratus_tree.nwk
