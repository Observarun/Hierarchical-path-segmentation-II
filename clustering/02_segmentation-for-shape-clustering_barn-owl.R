# Code for coordinated segmentation of a barn owl individual data at the two resolutions ($\mu$ steps and $m\mu$ steps) to perform shape-based clustering.


library(dplyr)
library(tseries)


df_DARs_indiv <- data.frame(readRDS(".../normalised_merged-DARs_barn-owl.Rds"))


mu = 4*50  # for 50-step segments
list_df_coarser_chunks_DARs_indiv <-
  df_DARs_indiv |>
  mutate(segment_id = cut(T, breaks="200 sec")) |>
  group_by(segment_id, .add=TRUE) |>
  group_split(segment_id)
list_df_coarser_chunks_DARs_indiv <-
  list_df_coarser_chunks_DARs_indiv[
    sapply(
      list_df_coarser_chunks_DARs_indiv,
      function(seg_as_df) nrow(seg_as_df)==50
      )
    ]  # list of m$\mu$ segments (as dataframes)

list_matrices_coarser_chunks_DARs_indiv <-
  mclapply(
    list_df_coarser_chunks_DARs_indiv,
    function(segment) {
      as.matrix(segment[,c('speed','turning_angle')])
      }
    )  # list of m$\mu$-step segments (as matrices)

list_matrices_coarser_coordinate_chunks_DARs_indiv <-
  mclapply(
    list_df_coarser_chunks_DARs_indiv,
    function(segment) {
      as.matrix(segment[,c('x','y')])
      }
    )


m=5  # number of 'symbols' making up a word
list_matrices_finer_chunks_DARs_indiv <-
  vector(
    mode='list',
    length=m*length(list_df_coarser_chunks_DARs_indiv)
    )
for(j in 1:length(list_df_coarser_chunks_DARs_indiv)){
  temp_list <-
    list_df_coarser_chunks_DARs_indiv[[j]] |>
    group_by(seg_id=cut(row_number(), breaks=m, include.lowest=FALSE)) |>
    group_split(seg_id) |>
    lapply(
      function(segment){
        as.matrix(segment[,c('speed','turning_angle')])
      }
    )
  for(mm in 1:m){
    list_matrices_finer_chunks_DARs_indiv[[(j-1)*m+mm]] <- temp_list[[mm]]
  }  # list of $\mu$-step segments (as matrices)
}

list_matrices_finer_coordinate_chunks_DARs_indiv <-
  vector(
    mode='list',
    length=m*length(list_df_coarser_chunks_DARs_indiv)
    )
for(j in 1:length(list_df_coarser_chunks_DARs_indiv)){
  temp_list <-
    list_df_coarser_chunks_DARs_indiv[[j]] |>
    group_by(seg_id=cut(row_number(), breaks=m, include.lowest=FALSE)) |>
    group_split(seg_id) |>
    lapply(
      function(segment){
        as.matrix(segment[,c('x','y')])
      }
    )
  for(mm in 1:m){
    list_matrices_finer_coordinate_chunks_DARs_indiv[[(j-1)*m+mm]] <- temp_list[[mm]]
  }  # list of finer chunks (as matrices)
}


saveRDS(list_matrices_coarser_chunks_DARs_indiv, file=".../word-speed-turning-angle-segments-for-shape-clust_barn-owl.Rds")
saveRDS(list_matrices_coarser_coordinate_chunks_DARs_indiv, file=".../word-coordinate-segments-for-shape-clust_barn-owl.Rds")
saveRDS(list_matrices_finer_chunks_DARs_indiv, file=".../base-speed-turning-angle-segments-for-shape-clust_barn-owl.Rds")
saveRDS(list_matrices_finer_coordinate_chunks_DARs_indiv, file=".../base-coordinate-segments-for-shape-clust_barn-owl.Rds")
