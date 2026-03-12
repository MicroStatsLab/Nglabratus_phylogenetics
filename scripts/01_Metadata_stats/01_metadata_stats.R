library(readxl)
library(tidyr)
`%nin%` <- Negate(`%in%`)


metadata <- read_excel("Tables/TableS1.xlsx")

metadata <- subset(metadata, Species == "N. glabratus")

metadata$SequenceType[metadata$SequenceType=="Novel"] <- 0
metadata$SequenceType <- as.numeric(metadata$SequenceType)

# clade by continent
continent_table <- table(metadata$Continent,metadata$Source)
chisq.test(continent_table)
chisq.test(table(metadata$Source))
#fisher.test(continent_table,simulate.p.value=TRUE)

# HSC_metadata <- metadata %>% 
#   filter(grepl("Manitoba", "Region"))
# table(HSC_metadata$Source, HSC_metadata$`Sequence Type`)
# table(HSC_metadata$`Sequence Type`)
# table(HSC_metadata$Source)

table(metadata$`Sequence Type`,metadata$Continent)

####Analyses of clusters
# Convert Clade column to factor with ordered levels
metadata$Clade <- factor(metadata$Clade)


continent_clade_table <- table(metadata$Continent, metadata$Clade)

#arrange the clade names in increasing order to samve as a table
# Separate numeric and non-numeric clades
clade_names <- colnames(continent_clade_table)
numeric_clades <- suppressWarnings(as.numeric(clade_names))

# Sort numeric clades, preserve non-numeric ones at the end
numeric_part <- clade_names[!is.na(numeric_clades)]
non_numeric_part <- clade_names[is.na(numeric_clades)]

# Sort and combine
sorted_clades <- c(sort(as.numeric(numeric_part)), sort(non_numeric_part))

# Rearrange table
continent_clade_table_sorted <- continent_clade_table[, as.character(sorted_clades)]
fisher.test(continent_clade_table_sorted,simulate.p.value = TRUE, B = 1e6)

chi_result <- chisq.test(continent_clade_table_sorted)
residuals <- chi_result$stdres
continent_clade_table_sorted
# Flag residuals with absolute value > 2
significant_cells <- abs(residuals) > 3

# Print only significant residuals
residuals[significant_cells]

write.csv(continent_clade_table_sorted, file = "Tables/Table1_continent_clade_table_sorted.csv", row.names = TRUE)


# create source clade the table
table(metadata$Source, metadata$Clade)
# Create the contingency table
source_clade_table <- table(metadata$Source, metadata$Clade)

# Rearrange table
source_clade_table_sorted <- source_clade_table[, as.character(sorted_clades)]

# Save as CSV
write.csv(source_clade_table_sorted, file = "Tables/Table2_source_by_clade.csv", row.names = TRUE)


