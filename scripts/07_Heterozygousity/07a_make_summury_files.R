#Libraries
library(tidyverse)
library(stringr)
library(dplyr)
library(purrr)

####Summrizing the SNPs counts
# Get all hap files with full paths
hap_files <- list.files(
  path = "data_out/07_Hom_het_snp_stats/",
  pattern = "_hap.tsv$",
  full.names = TRUE
)

hap_list <- list()

for (file in hap_files) {
  
  # Get chromosome name from file basename
  chr <- str_extract(basename(file), "^Chr[A-Z]")
  
  # Read file content
  lines <- readLines(file)
  
  # Find sample lines
  sample_lines <- grep("^Sample Name:", lines)
  
  sample_ids <- c()
  hap_snp_counts <- c()
  
  for (i in sample_lines) {
    sample_id <- str_trim(sub("Sample Name:\\s*", "", lines[i]))
    snp_line <- lines[(i+1):(i+15)]
    snp_index <- grep("Haploid SNPs", snp_line)
    
    if (length(snp_index) == 1) {
      hap_snp <- as.numeric(str_trim(sub("Haploid SNPs\\s*:\\s*", "", snp_line[snp_index])))
    } else {
      hap_snp <- NA
    }
    
    sample_ids <- c(sample_ids, sample_id)
    hap_snp_counts <- c(hap_snp_counts, hap_snp)
  }
  
  hap_df <- data.frame(Sample = sample_ids)
  hap_df[[chr]] <- hap_snp_counts
  hap_list[[chr]] <- hap_df
}




# Merge all chromosome data frames on "Sample"
final_df <- reduce(hap_list, full_join, by = "Sample")

# Order by Sample name
final_df <- final_df[order(final_df$Sample), ]

# Save to CSV
write.csv(final_df, "data_out/07_Hom_het_snp_stats/haploid_snps_by_chromosome.csv", row.names = FALSE)

# Preview
head(final_df)




######Extract heterozygous count from diploid

# Get all *_dip.tsv files with full paths
dip_files <- list.files(
  path = "data_out/07_Hom_het_snp_stats/",
  pattern = "_dip.tsv$",
  full.names = TRUE
)

# Initialize list to store per-chromosome data
het_list <- list()

for (file in dip_files) {
  
  # Extract chromosome name from the filename
  chr <- str_extract(basename(file), "^Chr[A-Z]")
  
  # Read file lines
  lines <- readLines(file)
  
  # Find lines starting with "Sample Name:"
  sample_lines <- grep("^Sample Name:", lines)
  
  sample_ids <- c()
  het_counts <- c()
  
  for (i in sample_lines) {
    sample_id <- str_trim(sub("Sample Name:\\s*", "", lines[i]))
    
    # Look in next 15 lines for "SNP Het/Hom ratio"
    het_line <- lines[(i+1):(i+15)]
    het_line_match <- grep("^SNP Het/Hom ratio", het_line)
    
    if (length(het_line_match) == 1) {
      het_info <- het_line[het_line_match]
      
      # Safely extract number inside parentheses
      het_number <- str_match(het_info, "\\((\\d+)/\\d+\\)")[,2]
      het_number <- as.numeric(het_number)  # NA if not found
      
    } else {
      het_number <- NA
    }
    
    sample_ids <- c(sample_ids, sample_id)
    het_counts <- c(het_counts, het_number)
  }
  
  # Only create df if samples exist
  if (length(sample_ids) > 0) {
    het_df <- data.frame(Sample = sample_ids, stringsAsFactors = FALSE)
    het_df[[chr]] <- het_counts
    het_list[[chr]] <- het_df
  }
}

# Merge all chromosome het data frames
het_snp_df <- reduce(het_list, full_join, by = "Sample")

# Sort by Sample
het_snp_df <- het_snp_df[order(het_snp_df$Sample), ]

# Save to file
write.csv(het_snp_df, "data_out/07_Hom_het_snp_stats/het_snps_by_chromosome.csv", row.names = FALSE)

# Preview
head(het_snp_df)

