df_DARs_synth <- data.frame(readRDS(".../normalised_merged-DARs_ANIMOVER1.Rds"))


matrix_DARs_synth <- as.matrix(df_DARs_synth[ ,c('step_length', 'turning_angle')])  # a segment needs to be represented as a matrix


create_list_chunks <- function(mat, mu)
{
  list_matrices_chunks_DARs <-
    base::lapply(
      base::seq_len(nrow(mat)/mu)-1,
      function(i) mat[((mu*i)+1):((mu*i)+mu), ]
    )

  return(list_matrices_chunks_DARs)
}  # method to return a list of segments (as matrices)

mu=45  # for 45-step segments
list_matrices_chunks_DARs <- create_list_chunks(matrix_DARs_synth, mu)


saveRDS(df_chunks_DARs_synth, file=".../segments-for-shape-clust_ANIMOV.Rds")
