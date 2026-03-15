library(tidyverse)
library(ggbeeswarm)
library(patchwork)
# Read the CSV you created earlier
hom_df <- read_csv("data_out/07_Hom_het_snp_stats/homozygous_snps_by_chromosome.csv")

#I noticed that two samples had extremly low counts
#I think they are the references isolates names differently by the authors. they cluster with the referance
# ERR1938055  3558  3149  4976  4145  4190  6324  6103  6181  7775  7115  8108  9362  8638
# ERR1938056    31    44    89    38    94    85    83    86    63    82   110    99    82
# ERR1938057  3113  2364  3124  3407  3212  4272  4948  4570  6396  5006  6746  5466  6150
# ERR1938059     7    18    11    11    14    10    10    37     3    19    13     3     4
#I wil exclude them

# Exclude specific samples
hom_df_red <- hom_df %>%
  filter(!Sample %in% c("ERR1938056", "ERR1938059","ERR1938063"))



# Reshape to long format: one row per sample-chromosome
hom_long <- hom_df_red %>%
  pivot_longer(
    cols = -Sample,
    names_to = "Chromosome",
    values_to = "Homozygous_SNPs"
  )


#Make table of aneuploid isolates 
#I took this directly from Tablse S1
# Raw aneuploidy info (as named vector)
aneu_raw <- c(
  "SRR8068052" = "chrA +1, chrC +1, chrE +1",
  "ERR1938055" = "chrA+1",
  "ERR1938062" = "chrA+1; chrD +1",
  "SRR8068022" = "chrC + 1; chrE +1",
  "ERR1938056" = "chrD +1",
  "ERR1938059" = "chrD +1",
  "ERR1938057" = "chrE +1",
  "SRR5239767" = "chrE +1",
  "SRR5239770" = "chrE +1",
  "SRR5239772" = "chrE +1",
  "SRR8068014" = "chrE +1",
  "SRR8068015" = "chrE +1",
  "SRR8068018" = "chrE +1",
  "SRR8068021" = "chrE +1",
  "SRR8068031" = "chrE +1",
  "SRR8068032" = "chrE +1",
  "SRR8068043" = "chrE +1",
  "SRR8068047" = "chrE +1",
  "SRR8068050" = "chrE +1",
  "SRR8068060" = "chrE +1",
  "SRR10725598" = "chrF +1",
  "SRR8697280" = "chrL +1"
)

# Convert to data frame
aneuploidy_df <- enframe(aneu_raw, name = "Sample", value = "Aneuploid_Info") %>%
  separate_rows(Aneuploid_Info, sep = "[,;]") %>%
  mutate(
    Aneuploid_Info = str_trim(Aneuploid_Info),
    Chromosome = str_extract(Aneuploid_Info, "chr[A-Z]"),
    Chromosome = str_replace(Chromosome, "chr", "Chr")  # Match your hom_long format
  ) %>%
  select(Sample, Chromosome) %>%
  mutate(Aneuploid = TRUE)

hom_long <- hom_long %>%
  left_join(aneuploidy_df, by = c("Sample", "Chromosome")) %>%
  mutate(Aneuploid = ifelse(is.na(Aneuploid), FALSE, TRUE))


ggplot(hom_long, aes(x = Chromosome, y = Homozygous_SNPs)) +
  geom_violin(fill = "grey90", color = "black", trim = TRUE) +
  geom_quasirandom(
    aes(color = Aneuploid),
    size = 1.2, alpha = 0.8, groupOnX = TRUE
  ) +
  scale_color_manual(values = c("FALSE" = "black", "TRUE" = "red")) +
  theme_minimal() +
  labs(
    x = "Chromosome",
    y = "Number of Homozygous SNPs",
    color = "Aneuploid"
  ) +
  theme(
    axis.text.x = element_text( hjust = 1, size = 14),  # X axis labels
    axis.text.y = element_text(size = 14),                         # Y axis labels
    axis.title.x = element_text(size = 16),                        # X axis title
    axis.title.y = element_text(size = 16),                        # Y axis title
    plot.title = element_text(size = 18, face = "bold"),           # Main title
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    # Add axis lines
    axis.line.x = element_line(color = "black", linewidth = 0.5),
    axis.line.y = element_line(color = "black", linewidth = 0.5),
    
    # Remove grid lines
    panel.grid = element_blank()
  )




#For heterozygous SNPs
# Load heterozygous SNP data
het_df <- read.csv("data_out/07_Hom_het_snp_stats/het_snps_by_chromosome.csv")
# Exclude specific samples
het_df_red <- het_df %>%
  filter(!Sample %in% c("ERR1938056", "ERR1938059","ERR1938063"))

# Convert to long format
het_long <- het_df_red %>%
  pivot_longer(-Sample, names_to = "Chromosome", values_to = "Heterozygous_SNPs") #%>%
#filter(Heterozygous_SNPs >= 200)  # Optional: exclude low counts

# Match chromosome naming
het_long$Chromosome <- factor(het_long$Chromosome, levels = paste0("Chr", LETTERS[1:13]))

# Merge aneuploidy info
het_long <- het_long %>%
  left_join(aneuploidy_df, by = c("Sample", "Chromosome")) %>%
  mutate(Aneuploid = ifelse(is.na(Aneuploid), FALSE, TRUE))

#SRR5239770
#SRR8068014

# Plot


ggplot(het_long, aes(x = Chromosome, y = Heterozygous_SNPs)) +
  geom_violin(fill = "grey90", color = "black", trim = TRUE) +
  geom_quasirandom(
    aes(color = Aneuploid),
    size = 1.2, alpha = 0.8, groupOnX = TRUE
  ) +
  scale_color_manual(values = c("FALSE" = "black", "TRUE" = "red")) +
  theme_minimal() +
  labs(
    x = "Chromosome",
    y = "Number of Heterozygous SNPs",
    color = "Aneuploid"
  ) +
  theme(
    axis.text.x = element_text( hjust = 1, size = 14),  # X axis labels
    axis.text.y = element_text(size = 14),                         # Y axis labels
    axis.title.x = element_text(size = 16),                        # X axis title
    axis.title.y = element_text(size = 16),                        # Y axis title
    plot.title = element_text(size = 18, face = "bold"),           # Main title
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    # Add axis lines
    axis.line.x = element_line(color = "black", linewidth = 0.5),
    axis.line.y = element_line(color = "black", linewidth = 0.5),
    
    # Remove grid lines
    panel.grid = element_blank())




