library(dplyr)


create_chunks <- function(df, mu){
  
  df_chunks_DARs_synth <- df |>
    dplyr::group_by(seg=base::cut(T, breaks=base::seq(0, max(T), by=mu), include.lowest=FALSE)) |>
    dplyr::summarise(
    speed_mean = base::mean(speed, na.rm = TRUE),
    speed_std = base::sd(speed, na.rm = TRUE),
    turning_angle_mean = base::mean(turning_angle, na.rm = TRUE),
    turning_angle_std = base::sd(turning_angle, na.rm = TRUE),
    disp_ends = sqrt((X[n()] - X[1])^2 + (Y[n()] - Y[1])^2),
    disp_consec = sum(sqrt(diff(X)^2 + diff(Y)^2)),
    n_pts = n(),
    ) |>
    filter(n_pts==mu) |>
    summarise(
    seg,
    speed_mean, speed_std, turning_angle_mean, turning_angle_std,
    net_displacement = disp_ends/disp_consec
    )
  
  df_chunks_DARs_synth[is.na(df_chunks_DARs_synth)] <- 0.0001
  
  row.names(df_chunks_DARs_synth) <- 1:nrow(df_chunks_DARs_synth)
  
  return(df_chunks_DARs_synth)
}


mu=05
df_chunks_DARs_synth = create_chunks(df_DARs_synth, mu)


saveRDS(df_chunks_DARs_synth, file=".../segments-for-vector-clust_ANIMOV.Rds")
