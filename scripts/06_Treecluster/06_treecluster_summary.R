# Load libraries
library(dplyr)
library(ggplot2)
library(tidyr)

# Set path and load data
path <- "data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary"
file_list <- list.files(path, pattern = ".csv", full.names = TRUE)

# Read and combine all CSV files
all_data <- purrr::map_dfr(file_list, function(file_path) {
  df <- read.csv(file_path)
  df$File <- tools::file_path_sans_ext(basename(file_path))
  df <- df %>%
    mutate(
      MaxCluster = ifelse(is.infinite(MaxCluster), NA, MaxCluster),
      Singletons = ifelse(is.infinite(Singletons), NA, Singletons),
      Threshold = as.numeric(Threshold)
    )
  return(df)
})

# Reshape to long format for ggplot
plot_data <- all_data %>%
  pivot_longer(cols = c(MaxCluster, Singletons),
               names_to = "Metric", values_to = "Value")

# Determine number of plots and layout
n_files <- length(unique(plot_data$File))
n_cols <- ceiling(sqrt(n_files))  # Approximate square layout
n_rows <- ceiling(n_files / n_cols)

# Create plot
p <- ggplot(plot_data, aes(x = Threshold, y = Value, color = Metric)) +
  geom_line(size = 1) +
  facet_wrap(~ File, ncol = n_cols, scales = "free_x") +  # Free X-axis only
  scale_color_manual(values = c("MaxCluster" = "#1f77b4", "Singletons" = "#d62728")) +
  labs(
    title = "Clustering Summary Across Thresholds",
    x = "Threshold",
    y = "Cluster Count",
    color = NULL
  ) +
  coord_cartesian(ylim = c(0, 50)) +  
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    strip.text = element_text(size = 10, face = "bold"),
    axis.title = element_text(size = 10),
    legend.position = "top"
  )

# Print the plot
print(p)



####Ploting only maxcluster
# Filter for MaxCluster only
plot_data_max <- plot_data %>%
  filter(Metric == "MaxCluster")

# Determine facet layout
n_files <- length(unique(plot_data_max$File))
n_cols <- ceiling(sqrt(n_files))
n_rows <- ceiling(n_files / n_cols)

# Create the plot
p <- ggplot(plot_data_max, aes(x = Threshold, y = Value)) +
  geom_line(color = "Black", size = 1) +  # Blue line for MaxCluster
  facet_wrap(~ File, ncol = 4, scales = "free_x") +
  labs(
    x = "Threshold",
    y = "MaxCluster Count"
  ) +
  coord_cartesian(ylim = c(0, 50)) +  # Force Y-axis range
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    strip.text = element_text(size = 10, face = "bold"),
    axis.title = element_text(size = 10),
    legend.position = "none"  # No legend needed for one line
  )

# Print the plot
print(p)




library(readr)
max_clade <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_max_clade.csv")
med_clade <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_med_clade.csv")
singlelinkage_clade <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_single_linkage.csv")
length_clade <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_length_clade.csv")
avg_clade <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_avg_clade.csv")
leaf_dist_max <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_leaf_dist_max.csv")
root_dist <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_root_dist.csv")
sum_branch <- read_csv("data_out/06_Treecluster_analyses/N_glabrata_treecluster_summary/250807_sum_branch.csv")


pdf("Figures/TreeCluster.pdf", width = 10, height = 5)
par(mfrow = c(2, 4),oma = c(0, 0, 0, 0))
par(mar = c(2, 2, 1, 1),mfrow = c(2, 4),oma = c(0, 0, 0, 0))

##Avg_clade

avg_clade_freq_table <- table(avg_clade$MaxCluster)
# Convert to numeric for plotting
x_vals <- as.numeric(names(avg_clade_freq_table))
y_vals <- as.numeric(avg_clade_freq_table)

# Plot points
plot(x_vals, y_vals, 
     xlab = "", 
     ylab = "Frequency", 
     main = "Avg clade", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200), 
     xaxt = "n",cex.lab = 1.5,cex.axis = 1.3)

# Add axis ticks without labels
axis(1, labels = FALSE)  # x-axis ticks only
axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)


table(avg_clade$MaxCluster)
# 5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  22  24  28  31  32  33  34  35  37  43  45 
# 185  12 114   5 153  33  49  45  38 150   4  54  17  23  52  22   4   1   1   3   2   2   1   1   1   2   1 
# 51  54  56  60  65  70  73  85  91  97 106 116 126 129 139 145 157 164 168 174 175 177 
# 1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   5 


#leaf_dist_max
leaf_dist_max_freq_table <- table(leaf_dist_max$MaxCluster)
# Convert to numeric for plotting
x_vals <- as.numeric(names(leaf_dist_max_freq_table))
y_vals <- as.numeric(leaf_dist_max_freq_table)

# Plot points
plot(x_vals, y_vals, 
     xlab = "", 
     ylab = "", 
     main = "leaf dist max", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200), 
     xaxt = "n", 
     yaxt = "n")

# Add axis ticks without labels
axis(1, labels = FALSE)  # x-axis ticks only
axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)

table(leaf_dist_max$MaxCluster)
# 1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27 
# 8 121  35  29   8   3   2  72  69  24   9  28  25   8   9  23   9  22  29  81  45 118 142  44   8  13   4 
# 28  29  30  31  32  33  34 
# 3   2   3   1   2   1   1 



#leaf_dist_max
length_clade_freq_table <- table(length_clade$MaxCluster)
# Convert to numeric for plotting
x_vals <- as.numeric(names(length_clade_freq_table))
y_vals <- as.numeric(length_clade_freq_table)

# Plot points
plot(x_vals, y_vals, 
     xlab = "", 
     ylab = "", 
     main = "Length clade", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200), 
     xaxt = "n", 
     yaxt = "n")

# Add axis ticks without labels
axis(1, labels = FALSE)  # x-axis ticks only
axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)

table(length_clade$MaxCluster)

# -Inf    1    2    3    5    6    9   11   12   13   14   16   17   18   19   20   21   22   23   24   25 
# 1  207    1   69   57   20   30   35   23    6    1   14    9   26   51   19   33   10   10   54   12 
# 26   27   29   32   34   35   38   53   54   57   61   70   71   72   75   80   82 
# 75  219    1    2    1    3    1    1    1    1    1    2    1    1    1    1    1 


#Max clade
max_clade_freq_table <- table(max_clade$MaxCluster)

# Convert to numeric for plotting
x_vals <- as.numeric(names(max_clade_freq_table))
y_vals <- as.numeric(max_clade_freq_table)

# Plot points
plot(x_vals, y_vals, 
     xlab = "", 
     ylab = "", 
     main = "Max clade", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200), 
     xaxt = "n", 
     yaxt = "n")

# Add axis ticks without labels
axis(1, labels = FALSE)  # x-axis ticks only
axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)
#max_clade
# -Inf    1    4   11   20   22   23   24   25   26   27   28   29   30   32   36   37   40   41 
# 2    2    1    1    1   97   99   31  281   41  353    1   12    7    1    8    2    1    5 
# 42   44   45   46   49   50   53   54   55   58   59   61   64   67   68   69   70   76   77 
# 1    2    4    2    1    3    1    1    1    1    2    2    1    1    1    1    2    1    1 
# 81   84   87   91   94   95   98  100  103  104  105  106  112  114  117  119  125  126  127 
# 2    1    1    1    2    1    1    1    1    1    1    1    1    1    2    1    1    1    1 
# 130  131  132  133 
# 1    1    1    1 




#Med clade
# Plot the frequency of MaxCluster values
# Get frequency table
med_clade_freq_table <- table(med_clade$MaxCluster)

# Convert to numeric for plotting
x_vals <- as.numeric(names(med_clade_freq_table))
y_vals <- as.numeric(med_clade_freq_table)

# Plot points
plot(x_vals, y_vals, 
     xlab = "Number of clusters", 
     ylab = "Frequency", 
     main = "Med clade", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200),cex.lab = 1.5,     # Increase axis label size
     cex.axis = 1.3)

# Add axis ticks without labels
#axis(1, labels = FALSE)  # x-axis ticks only
#axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)

# med_clade
# 
# -Inf    1    4   11   13   14   15   16   17   18   19   20   21   24   25   27   28   31   33 
# 2    2    1    1  127  115  133  186    5  375    6    2    2    1    3    1    1    2    3 
# 34   35   36   37   40   42   45   47   48   49   54   58   61   67   73   76   80   83   87 
# 3    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1 
# 89   90   92   94   97   99  104  105  106  107 
# 2    1    2    1    1    1    1    1    1    1 

#root_dist
# Plot the frequency of MaxCluster values
# Get frequency table
root_dist_freq_table <- table(root_dist$MaxCluster)

# Convert to numeric for plotting
x_vals <- as.numeric(names(root_dist_freq_table))
y_vals <- as.numeric(root_dist_freq_table)

# Plot points
# Plot points
plot(x_vals, y_vals, 
     xlab = "Number of clusters", 
     ylab = "", 
     main = "Root dist clade", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200), 
     yaxt = "n",cex.lab = 1.5,     # Increase axis label size
     cex.axis = 1.3)#, 
     #xaxt = "n")

# Add axis ticks without labels
#axis(1, labels = FALSE)  # x-axis ticks only
axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)

table(root_dist$MaxCluster)
# 2   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29 
# 61 100  23  71  31  17   6  38  12  11  58   6  13  10  30  26  26  78  44 117 140  45  11  12   2   3   4 
# 30  31  33 
# 2   1   3 



#Singlelinkage
# Plot the frequency of MaxCluster values
# Get frequency table
singlelinkage_freq_table <- table(singlelinkage_clade$MaxCluster)

# Convert to numeric for plotting
x_vals <- as.numeric(names(singlelinkage_freq_table))
y_vals <- as.numeric(singlelinkage_freq_table)

# Plot points
plot(x_vals, y_vals, 
     xlab = "Number of clusters", 
     ylab = "", 
     main = "Single linkage clade", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200), 
     yaxt = "n",cex.lab = 1.5,     # Increase axis label size
     cex.axis = 1.3)#, 
#xaxt = "n")

# Add axis ticks without labels
#axis(1, labels = FALSE)  # x-axis ticks only
axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)

table(singlelinkage_clade$MaxCluster)
# single linkage
# -Inf    1    4   11   21   22   23   24   25   26   27   28   29   31   33   34   38   39   40   42   44   47   48   54   58   63 
# 2    2    1    1  133    1  116  127  148   58  379    1    1    2    1    4    1    1    1    1    1    1    1    1    1    1 
# 65   67   77   81   83   84   85   87   88   92   94   96   98 
# 1    1    1    1    1    1    1    1    2    1    1    1    1 


#Sum branch
# Plot the frequency of MaxCluster values
# Get frequency table
sum_branch_freq_table <- table(sum_branch$MaxCluster)

# Convert to numeric for plotting
x_vals <- as.numeric(names(sum_branch_freq_table))
y_vals <- as.numeric(sum_branch_freq_table)

# Plot points
plot(x_vals, y_vals, 
     xlab = "Number of clusters", 
     ylab = "", 
     main = "Sum branch", 
     pch = 16, col = "black", 
     ylim = c(0, 400), 
     xlim = c(0, 200), 
     yaxt = "n",cex.lab = 1.5,     # Increase axis label size
     cex.axis = 1.3)#, 
#xaxt = "n")

# Add axis ticks without labels
#axis(1, labels = FALSE)  # x-axis ticks only
axis(2, labels = FALSE)  # y-axis ticks only

# Add vertical and horizontal dashed lines
#abline(h = 300, col = "red", lwd = 2, lty = 2)
#abline(v = 5, col = "red", lwd = 2, lty = 2)

dev.off()
table(sum_branch$MaxCluster)


#So i will say it is either 27 (max_clade, single linkage) or 18 (med_clade). Those are conserved > 35 % of the thresholds
#I selected 0.0451.t.txt for max clade 0.0418.t.txt for single linkage and  for 0.0434.t.txt med_clade









max(table(max_clade$MaxCluster))
max(table(med_clade$MaxCluster))
max(table(singlelinkage_clade$MaxCluster))
max(table(length_clade$MaxCluster))
max(table(avg_clade$MaxCluster))
max(table(leaf_dist_max$MaxCluster))
max(table(root_dist$MaxCluster))
max(table(sum_branch$MaxCluster))


subset_data <- subset(
  all_data,
  File %in% c("250807_length_clade", "250807_max_clade", "250807_single_linkage") &
    MaxCluster == 27
)
# Ensure Singletons are factors with all levels
subset_data$Singletons <- factor(subset_data$Singletons, levels = c(7, 8, 9))

# Rename the File values for plotting
subset_data <- subset_data %>%
  mutate(File = recode(File,
                       "250807_length_clade" = "Length clade",
                       "250807_max_clade" = "Max clade",
                       "250807_single_linkage" = "Single linkage"))

# Count rows per File and Singleton
count_data <- subset_data %>%
  count(File, Singletons) %>%
  complete(File, Singletons, fill = list(n = 0)) %>%
  mutate(n = ifelse(n == 0, 0.5, n))  # replace zeros with tiny bar

# Plot
ggplot(count_data, aes(x = Singletons, y = n, fill = File)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  labs(
    x = "Singletons",
    y = "Frequency of singletons in the 27 clusters",
    fill = "Methods"  # change legend title
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 24),  # X-axis label
    axis.title.y = element_text(size = 24),  # Y-axis label
    axis.text.x = element_text(size = 20,color = "black"),   # X-axis tick labels
    axis.text.y = element_text(size = 20,color = "black"),   # Y-axis tick labels
    legend.title = element_text(size = 18),  # Legend title
    legend.text = element_text(size = 16),   # Legend text
    #plot.title = element_text(size = 18, face = "bold"),  # Plot title
    panel.grid.major = element_blank(),  # remove major grid lines
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", size = 0.8)   # remove minor grid lines
  )




