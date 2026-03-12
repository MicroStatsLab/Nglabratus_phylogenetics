#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=0-58:02:00
#SBATCH --mem=700G
#SBATCH --mail-user=adamubua@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=Trim_alignment_variant
#SBATCH --output=%x-%j.out


#Load modules


module load nixpkgs/16.09
module load StdEnv/2020 bwa picard trimmomatic/0.39 gatk r

#Create the output directory
#The samples.txt file should have the names (excluding the fastq.gz extension) of the isolates to be analyzed on per line.

cat samples.txt | parallel 'mkdir /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}'


cat samples.txt | parallel 'mkdir /home/abdul/scratch/N_glabaratus/data_out/alignment/{}'
#Create directories for each sample
cat samples.txt | parallel 'mkdir /home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}'
cat samples.txt | parallel 'mkdir /home/abdul/scratch/N_glabaratus/data_out/varaint_calling/{}'




#Run Trimmomatic

#cat samples.txt | parallel 'java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads $SLURM_CPUS_PER_TASK -trimlog /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}/{}.log /home/abdul/scratch/N_glabaratus/data_in/fastq_files/{}_R1.fastq.gz /home/abdul/scratch/N_glabaratus/data_in/YST6/{}_R2.fastq.gz /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}/{}_R1.trimmed_PE.fastq.gz /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}/{}_R1.trimmed_SE.fastq.gz /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}/{}_R2.trimmed_PE.fastq.gz /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}/{}_R2.trimmed_SE.fastq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 TOPHRED33'

#Run Alignment

cat samples.txt | parallel 'time bwa mem -t $SLURM_CPUS_PER_TASK /home/abdul/scratch/N_glabaratus/reference/Candida_glabrata_index /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}/{}_R1.trimmed_PE.fastq.gz /home/abdul/scratch/N_glabaratus/data_out/trimmed_reads/{}/{}_R2.trimmed_PE.fastq.gz -o /home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.sam' 


#Sort the Alignment 

cat samples.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar SortSam I=/home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.sam O=/home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.sorted.sam SORT_ORDER=coordinate'



## Collect alignment statistics
cat samples.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar CollectAlignmentSummaryMetrics R=/home/abdul/scratch/N_glabaratus/reference/Candida_glabrata.fa.gz I=/home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.sorted.sam O=/home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.alignment_summary.txt'


##Convert SAM to BAM files

cat samples.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar SamFormatConverter I=/home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.sorted.sam O=/home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.sorted.bam R=/home/abdul/scratch/N_glabaratus/reference/Candida_glabrata.fa.gz'




#Add read groups
cat samples.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar AddOrReplaceReadGroups I=/home/abdul/scratch/N_glabaratus/data_out/alignment/{}/{}.sorted.bam R=/home/abdul/scratch/N_glabaratus/reference/Candida_glabrata.fa.gz O=/home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}/{}.sorted_RG.bam RGID={} RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM={}'


#Mark potential reads duplicates


cat samples.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar MarkDuplicates I=/home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}/{}.sorted_RG.bam O=/home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}/{}.sorted_RG_dedup.bam R=/home/abdul/scratch/N_glabaratus/reference/Candida_glabrata.fa.gz M=/home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}/{}.sorted_RG_dedup.txt CREATE_INDEX=true READ_NAME_REGEX=null'




#echo " Mark duplicates done!"


#Correct possible info differences in the alignmed paired end reads. Readmore on this step




cat samples.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar FixMateInformation I=/home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}/{}.sorted_RG_dedup.bam R=/home/abdul/scratch/N_glabaratus/reference/Candida_glabrata.fa.gz O=/home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}/{}.sorted_RG_dedup_Fixmate.bam ADD_MATE_CIGAR=true CREATE_INDEX=true'




#echo " Fixmate information done!"


#Run Haplotypecaller in g.vcf mode


cat samples.txt | parallel 'gatk --java-options "-Xmx4g" HaplotypeCaller --native-pair-hmm-threads $SLURM_CPUS_PER_TASK  -R /home/abdul/scratch/N_glabaratus/reference/Candida_glabrata.fa.gz -ploidy 1 -I /home/abdul/scratch/N_glabaratus/data_out/clean_alignment/{}/{}.sorted_RG_dedup_Fixmate.bam -O /home/abdul/scratch/N_glabaratus/data_out/varaint_calling/{}/{}.raw.snps.indels.g.vcf.gz -ERC GVCF'


#echo " HaplotypeCaller done!"
