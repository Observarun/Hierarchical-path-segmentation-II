library(dtwclust)
library(fastcluster)

df_chunks_DARs <- data.frame(readRDS(".../segments-for-shape-clust_ANIMOV.Rds"))  # for working w/ ANIMOVER1 segment data; line 4 to be uncommented and lines 5, 6 to be commented
#df_chunks_DARs <- readRDS(".../word-speed-turning-angle-segments-for-shape-clust_barn-owl.Rds")  # for working w/ barn owl word segment data; line 5 to be uncommented and lines 4, 6 to be commented
#df_chunks_DARs <- readRDS(".../base-speed-turning-angle-segments-for-shape-clust_barn-owl.Rds")  # for working w/ barn owl base segment data; line 6 to be uncommented and lines 4, 5 to be commented

wrapper_for_clustering_tsclust <-
  function(distmat) {
    fastcluster::hclust(distmat, "ward.D2")
  }

nk=8  # number of clusters
result_clustering <-
  dtwclust::tsclust(
    list_matrices_chunks_DARs_indiv,
    type = "h", k=nk,
    distance="dtw_basic",  # for Soft-DTW, replace 'dtw_basic' w/ 'soft-dtw'; w/ quotes
    centroid = dba,  # for Soft-DTW, replace 'dba' w/ 'sdtw_cent'; no quotes required
    control =
      hierarchical_control(
        method=wrapper_for_clustering_tsclust,
        symmetric=T
      ),
    preproc=NULL,
    args =
      tsclust_args(
        dist =
          list(
            step.pattern=dtw::symmetric2,
            norm="L2",
            normalize=TRUE,
            window.size=4
          )
      )
  )

silhouetteIdx <-
  cvi(
    result_clustering,
    type="Sil",
    fuzzy=FALSE
  )
noquote("Silhouette index:")
silhouetteIdx

# Cluster centroids through average and standard deviation.
centroids <- matrix(, nrow=nk, ncol=2)
for (ic in 1:nk){
  segsInAClust <- list()
  for (idx in which(result_clustering@cluster %in% ic)){
    segsInAClust[[length(segsInAClust)+1]] <- list_matrices_chunks_DARs[[idx]][,1:2]
  }
  print(noquote(paste0("Mean of average segment sequence for cluster", ic)))
  print(colMeans(Reduce("+", segsInAClust)/length(segsInAClust)))
  centroids[ic,] <- colMeans(Reduce('+', segsInAClust)/length(segsInAClust))
}

occupancy <-
  as.numeric(
    table(
      result_clustering@cluster
    )
  )
noquote("Occupancy:")
occupancy
occupancy_speed_matrix <-
  matrix(
    c(centroids[,1], occupancy),
    ncol=2
  )
occupancy_sorted_wrt_speed <- occupancy_speed_matrix[order(occupancy_speed_matrix[,1], decreasing=T), 2]
sink(".../cluster-occupancy_decreasing-speed")
cat(occupancy_sorted_wrt_speed)
sink()

result_clustering@cluster
original_cluster_order = c(1,2,3,4)  # assuming 4 clusters
new_cluster_order =
  sapply(
    occupancy,
    function(o) which(occupancy_sorted_wrt_speed %in% o)
    )
sink(".../cluster-sequence_decreasing-speed")
cat(new_cluster_order[match(result_clustering@cluster, orig_cl_seq)])
sink()
