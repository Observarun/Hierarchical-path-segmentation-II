list_segs_in_rectified_CAMs <- readRDS(".../segments_corresp_each_word.Rds")
df_labels_counts_maxcountcluster <- data.frame(readRDS(".../label_count_max-count-cluster.Rds"))


k=4
list_segs_in_rectified_CAMs <-
  vector(
    mode='list',
    length=k
  )
                             
for(c in 1:k){
  list_segs_in_rectified_CAMs[[c]] <-
    vector(
      mode='list',
      length=6
    )
  list_segs_in_rectified_CAMs[[c]][[1]] <- c
}

for(l in 1:length(labels_words)){
  if(df_labels_counts_maxcountcluster$total_count[l]==0)
    next
  else if(df_labels_counts_maxcountcluster$total_count[l]!=0)
  {
    for(n_seg_l in 1:length(list_words_corresponding_segments[[l]][[2]])){
      list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[2]] <- append(list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[2]], list_words_corresponding_segments[[l]][[2]][n_seg_l])
      list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[3]] <- append(list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[3]], list_words_corresponding_segments[[l]][[3]][n_seg_l])
      list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[4]] <- append(list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[4]], list_words_corresponding_segments[[l]][[4]][n_seg_l])
      list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[5]] <- append(list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[5]], list_words_corresponding_segments[[l]][[5]][n_seg_l])
      list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[6]] <- append(list_segs_in_rectified_CAMs[[df_label_max_count$max_count_cluster[l]]][[6]], list_words_corresponding_segments[[l]][[6]][n_seg_l])
    }
  }
}


for(c in 1:k){
  print(noquote(paste0("Rectified CAM ",list_segs_in_rectified_CAMs[[c]][[1]])))
  print(noquote(paste0("Occupancy: ", length(list_segs_in_rectified_CAMs[[c]][[2]]))))
  print(noquote(paste0("Mean speed centroid: ", mean(list_segs_in_rectified_CAMs[[c]][[2]]))))
  print(noquote(paste0("Std speed centroid: ", mean(list_segs_in_rectified_CAMs[[c]][[3]]))))
  print(noquote(paste0("Mean turning angle centroid:", mean(list_segs_in_rectified_CAMs[[c]][[4]]))))
  print(noquote(paste0("Std turning angle centroid: ", mean(list_segs_in_rectified_CAMs[[c]][[5]]))))
  print(noquote(paste0("Net displacement centroid: ", mean(list_segs_in_rectified_CAMs[[c]][[6]]))))
}
