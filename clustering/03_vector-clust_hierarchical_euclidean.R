library(parallelDist)
library(fastcluster)


df_chunks_DARs <- data.frame(readRDS(".../segments-for-vector-clust_ANIMOV.Rds"))  # for working w/ ANIMOVER1 segment data; line 5 to be uncommented and lines 6, 7 to be commented
#df_chunks_DARs <- data.frame(readRDS(".../base-segments-for-vector-clust_barn-owl.Rds"))  # for working w/ barn owl base segment data; line 6 to be uncommented and lines 5, 7 to be commented
#df_chunks_DARs <- data.frame(readRDS(".../word-segments-for-vector-clust_barn-owl.Rds"))  # for working w/ barn owl word segment data; line 7 to be uncommented and lines 5, 6 to be commented


d <-
  parDist(
    as.matrix(df_chunks_DARs[c("speed_mean","turning_angle_mean","speed_std","turning_angle_std","net_displacement")]),
    method = "euclidean"
  )
result_clustering <-
  fastcluster::hclust(
    d,
    method="ward.D2"
  )
nk=4  # number of clusters
result_clustering <-
  cutree(
    hierarc_res,
    k=nk
  )

centroids <- NULL
for(ic in 1:nk){
centroids <-
  rbind(
    centroids,
    colMeans(df_chunks_DARs[c("speed_mean","turning_angle_mean","speed_std","turning_angle_std","net_displacement")][result_clustering==ic, , drop=FALSE])
  )
}
centroids <- centroids[order(centroids[,1], decreasing=T), ]
centroids

occupancy <-
  as.numeric(
    table(
      result_clustering
    )
  )
noquote("Occupancy:")
occupancy_speed_matrix <- matrix(c(centroids[,1], occupancy), ncol=2)
occupancy_sorted_wrt_speed <- occupancy_speed_matrix[order(occupancy_speed_matrix[,1], decreasing=T), 2]
sink(".../cluster-occupancy_decreasing-speed")
cat(occupancy_sorted_wrt_speed)
sink()

result_clustering
original_cluster_order = c(1,2,3,4)  # assuming 4 clusters
new_cluster_order =
  sapply(
    occupancy,
    function(o) which(occupancy_sorted_wrt_speed %in% o)
    )
sink(".../cluster-sequence_decreasing-speed")
cat(new_cluster_order[match(result_clustering, orig_cl_seq)])
sink()
