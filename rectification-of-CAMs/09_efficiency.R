library(dplyr)


df_labels_counts_maxcountcluster <-
  data.frame(readRDS(".../label_count_max-count-cluster.Rds"))

df_rectified_counts <-
  df_labels_counts_maxcountcluster |>
  group_by(max_count_cluster) |>
  summarise_at(
    vars(total_count),
    list(sum_max_count=sum)
    )
df_rectified_counts

true_occup <- df_rectified_counts$sum_max_count

eff = - sum((true_occup/sum(true_occup)) * log2((ifelse(true_occup==0,1e-12,true_occup))/sum(true_occup)))
eff = eff/log2(length(true_occup))

print(noquote(paste0("Rectified efficiency: ",eff)))
