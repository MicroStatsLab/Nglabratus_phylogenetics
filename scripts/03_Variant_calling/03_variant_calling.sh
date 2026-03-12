#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=24:00:00
#SBATCH --mem=350G
#SBATCH --mail-user=adamubua@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=YST6_Genotypevcf_phylogeny
#SBATCH --output=%x-%j.out


module load StdEnv/2020  gcc/9.3.0  openmpi/4.0.3
module load picard gatk 
module load raxml-ng/1.0.1
output="/home/abdul/scratch/N_glabaratus/data_out/varaint_calling/variant_calling"
phylo="/home/abdul/scratch/N_glabaratus/data_out/phylogeny"
ref="/home/abdul/scratch/N_glabaratus/reference/"

#Combine all gvcf files



gatk CombineGVCFs -R $ref/Candida_glabrata.fa.gz --variant gvcf.list  -O $output/231124_combined.g.vcf.gz


#Run genotype vcf to generate final vcf

gatk --java-options "-Xmx4g" GenotypeGVCFs --all-sites -R $ref/Candida_glabrata.fa.gz -V $output/231124_combined.g.vcf.gz -O $output/231124_joint_combined.vcf.gz


gatk SelectVariants \
    -V $output/231124_joint_combined.vcf.gz \
    -xl-select-type INDEL \
    -O $output/231124_snps.vcf.gz \
    -R $ref/Candida_glabrata.fa.gz



gatk SelectVariants \
    -V $output/231124_joint_combined.vcf.gz \
    -select-type INDEL \
    -O $output/231124_indel.vcf.gz \
    -R $ref/Candida_glabrata.fa.gz




gatk VariantFiltration \
    -V $output/231124_snps.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "SOR > 3.0" --filter-name "SOR3" \
    -filter "FS > 60.0" --filter-name "FS60" \
    -filter "MQ < 40.0" --filter-name "MQ40" \
    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -O $output/231124_snps_filtered.vcf.gz





gatk VariantFiltration \
    -V $output/231124_indel.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "FS > 200.0" --filter-name "FS200" \
    -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O $output/231124_indel_filtered.vcf.gz



java -jar $EBROOTPICARD/picard.jar MergeVcfs \
          I=$output/231124_snps_filtered.vcf.gz \
          I=$output/231124_indel_filtered.vcf.gz \
          O=$output/231124_calb_merged_filtered_variants.vcf.gz


###exclude mtDNA
gatk SelectVariants -V $output/231124_calb_merged_filtered_variants.vcf.gz  -XL mito_C_glabrata_CBS138 -R $ref/Candida_glabrata.fa.gz -O $output/231124_calb_merged_filtered_variants.nomtd.vcf.gz






