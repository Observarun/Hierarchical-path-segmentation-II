df_labels_counts_maxcountcluster <-
  data.frame(readRDS(".../label_count_max-count-cluster.Rds"))


k=4

words_in_CAMs <-
  vector(
    mode="list",
    length=k
  )
for(c in 1:k){
  words_in_CAMs[[c]] <- 
    append(
      words_in_CAMs[[c]],
      rep(df_labels_counts_maxcountcluster$labels_words [which(df_labels_counts_maxcountcluster$max_count_cluster %in% c)],
          df_labels_counts_maxcountcluster$total_count[which(df_labels_counts_maxcountcluster$max_count_cluster %in% c)])
    )
}


print(noquote(paste0("Proportions of staMEs in ",k, " CAMs:")))
sapply(
  words_in_CAMs,
  function(words_in_a_CAM){
    words_in_a_CAM |>
      strsplit('') |>
      unlist() |>
      as.numeric() |>
      table()/
      words_in_a_CAM |>
        strsplit('') |>
        unlist() |>
        as.numeric() |>
        table() |>
        sum()
  }
)
