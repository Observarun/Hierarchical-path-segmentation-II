library(ggplot2)

distinct_labels <- readRDS(".../labels-for-word-types")
cluster_occupancy_words <- scan(".../cluster-occupancy_decreasing-speed")
cluster_sequence_words <- scan(".../cluster-sequence_decreasing-speed")


# Word type counts by CAMs

k=4  # number of CAMs
list_labels <-
  rep(
    list(
      data.frame(
        distinct_labels,
        count=c(rep(0,32768))
      )
    ),
    k
  )

for(c in 1:k)
{
  for(idx in which(cluster_sequence_words %in% c))
  {
    label <- paste0(
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-1)]
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-2)],
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-3)],  # not required for m<3
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-4)],  # not required for m<4
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-5)]  # not required for m<5
    )
    
    list_labels[[c]]$count[which(list_labels[[c]]$distinct_labels %in% label)]
      = list_labels[[c]]$count[which(list_labels[[c]]$distinct_labels %in% label)] + 1
  }
}

saveRDS(list_labels, ".../word-type-distributions-each-CAM.Rds")


# Maximum count of a word type and the corresponding cluster

df_labels_counts_maxcountcluster <-
  data.frame(
    distinct_labels,
    max_count_cluster=c(rep(0,32768)),
    max_count=c(rep(0,32768)),
    total_count=c(rep(0,32768))
    )

for (label in distinct_labels)
{
  count_label <- c()
  for (c in 1:k){
    count_label <- append(count_label, list_labels[[c]]$count[list_labels[[c]]$distinct_labels==label])
  }
  df_labels_counts_maxcountcluster$max_count_cluster[which(df_labels_counts_maxcountcluster$distinct_labels %in% label)]=which.max(count_label)
  df_labels_counts_maxcountcluster$max_count[which(df_labels_counts_maxcountcluster$distinct_labels %in% label)]=max(count_label)
  df_labels_counts_maxcountcluster$total_count[which(df_labels_counts_maxcountcluster$distinct_labels %in% label)]=sum(count_label)
}

saveRDS(df_labels_counts_maxcountcluster, ".../label_count_max-count-cluster.Rds")


# Barplot of word type counts

colour_bar <- c('red4', 'red', 'orange', 'yellow', 'green', 'lightblue', 'blue3', 'violet')

for(c in 1:nk){
  colour_palette <-
    ifelse(
      df_labels_counts_maxcountcluster$max_count_cluster==c,
      colour_bar[c],
      'white'
    )
  bplot <-
    ggplot2::ggplot(
      list_labels[[c]],
      aes(x=distinct_labels, y=count)
    ) +
    geom_bar(
      stat='identity',
      width=c(rep(1,64)),
      colour='black',  # outline of bar
      aes(fill=colour_palette)
    ) +
    scale_fill_identity() +
    coord_cartesian(
      ylim = c(0, 8)
    ) +  # change the higher limit in ylim based on the largest value 
    theme_classic() +
    theme(
      axis.ticks.x=element_blank(),
      axis.text.x=element_blank()
    )
  print(bplot)
}
