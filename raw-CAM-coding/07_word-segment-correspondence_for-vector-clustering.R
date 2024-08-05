distinct_labels <- readRDS(".../labels-for-word-types")
cluster_sequence_words <- scan(".../cluster-sequence_decreasing-speed")

df_chunks_DARs_indiv <- data.frame(readRDS(".../word-segments-for-vector-clust_barn-owl.Rds"))


list_words_corresponding_segments <-
  vector(
    mode="list",
    length=length(distinct_labels)
  )  # list of segments corresponding to every word

for(l in 1:length(distinct_labels)){
  list_words_corresponding_segments[[l]] <-
    vector(
      mode="list",
      length=6)
  list_words_corresponding_segments[[l]][[1]] <-
    distinct_labels[l]
}


m=5
k=4
for(c in 1:k)
{ 
  for(idx in which(cluster_sequence_words %in% c))
  {
    label <- paste0(
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-1)],
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-2)],
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-3)],  # not required for m<3
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-4)],  # not required for m<4
      scan(".../cluster-sequence_decreasing-speed")[(m*idx)-(m-5)]  # not required for m<5
    )

    idx_word <-
      which(
        sapply(
          list_words_corresponding_segments,
          function(sublist) label %in% sublist
        )
      )
    list_words_corresponding_segments[[idx_word]][[2]] <-
      append(list_words_corresponding_segments[[idx_word]][[2]], df_chunks_DARs_indiv[idx,2])
    list_words_corresponding_segments[[idx_word]][[3]] <-
      append(list_words_corresponding_segments[[idx_word]][[3]], df_chunks_DARs_indiv[idx,3])
    list_words_corresponding_segments[[idx_word]][[4]] <-
      append(list_words_corresponding_segments[[idx_word]][[4]], df_chunks_DARs_indiv[idx,4])
    list_words_corresponding_segments[[idx_word]][[5]] <-
      append(list_words_corresponding_segments[[idx_word]][[5]], df_chunks_DARs_indiv[idx,5])
    list_words_corresponding_segments[[idx_word]][[6]] <-
      append(list_words_corresponding_segments[[idx_word]][[6]], df_chunks_DARs_indiv[idx,6])
}  # df_chunks_DARs_indiv corresponds to the coarser resolution (word segments)


saveRDS(list_words_corresponding_segments, ".../segments_corresp_each_word.RData")
