# Code for coordinated segmentation of a barn owl individual data at the two resolutions ($\mu$ steps and $m\mu$ steps) to perform vector clustering.



library(dplyr)
library(tseries)


df_DARs_indiv <- data.frame(readRDS(".../normalised_merged-DARs_barn-owl.Rds"))


list_df_coarser_chunks_DARs_indiv <-
  df_DARs_indiv |>
  group_by(segment_id = cut(T, breaks="60 sec", include.lowest=FALSE)) |>
  group_split(segment_id)
list_df_coarser_chunks_DARs_indiv <-
  list_df_coarser_chunks_DARs_indiv[
    sapply(
      list_df_coarser_chunks_DARs_indiv,
      function(seg_as_df) nrow(seg_as_df)==15)
    ]  # list of dataframes of m$\mu$ segments

df_finer_chunks_DARs_indiv <-
  data.frame(
    seg=factor(),
    speed_mean=double(),
    speed_std=double(),
    turning_angle_mean=double(),
    turning_angle_std=double(),
    net_displacement=double()
    )
m=3
for(j in 1:length(list_df_coarser_chunks_DARs_indiv)){
  df_finer_chunks_DARs_indiv <-
    rbind(
      df_finer_chunks_DARs_indiv,
      list_df_coarser_chunks_DARs_indiv[[j]] |>
        group_by(seg=cut(as.numeric(T), breaks=m, include.lowest=FALSE)) |>
        summarise(
          speed_mean = mean(speed, na.rm = TRUE),
          speed_std = sd(speed, na.rm = TRUE),
          turning_angle_mean = mean(turning_angle, na.rm = TRUE),
          turning_angle_std = sd(turning_angle, na.rm = TRUE),
          net_displacement = sqrt((X[n()] - X[1])^2 + (Y[n()] - Y[1])^2) / sum(sqrt(diff(X)^2 + diff(Y)^2))
          )
      )  # dataframe of finer resolution ($\mu$-step) segments
}


df_coarser_chunks_DARs_indiv <-
  df_DARs_indiv |>
    group_by(seg=cut(T, breaks="60 sec")) |>
    summarise(
      speed_mean = mean(speed, na.rm = TRUE),
      speed_std = sd(speed, na.rm = TRUE),
      turning_angle_mean = mean(turning_angle, na.rm = TRUE),
      turning_angle_std = sd(turning_angle, na.rm = TRUE),
      net_displacement = sqrt((X[n()] - X[1])^2 + (Y[n()] - Y[1])^2) / sum(sqrt(diff(X)^2 + diff(Y)^2)),
      n_pts = n()
      ) |>
    filter(n_pts == 15) |>
      summarise(
        seg,
        speed_mean,
        speed_std,
        turning_angle_mean,
        turning_angle_std,
        net_displacement
      )
      

saveRDS(df_finer_chunks_DARs_synth, file=".../base-segments-for-vector-clust_barn-owl.Rds")
saveRDS(df_coarser_chunks_DARs_synth, file=".../word-segments-for-vector-clust_barn-owl.Rds")
