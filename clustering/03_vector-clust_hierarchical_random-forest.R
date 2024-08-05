library(randomForest)
library(fastcluster)
library(foreach)
library(doSNOW)
library(parallel)
library(future)


df_chunks_DARs <- data.frame(readRDS(".../segments-for-vector-clust_ANIMOV.Rds"))  # for working w/ ANIMOVER1 segment data; line 9 to be uncommented and lines 10, 11 to be commented
# df_chunks_DARs <- data.frame(readRDS(".../base-segments-for-vector-clust_barn-owl.Rds"))  # for working w/ barn owl base segment data; line 10 to be uncommented and lines 9, 11 to be commented
# df_chunks_DARs <- data.frame(readRDS(".../word-segments-for-vector-clust_barn-owl.Rds"))  # for working w/ barn owl word segment data; line 11 to be uncommented and lines 9, 10, to be commented


set.seed(137)

clustr <-
  parallel::makeCluster(
    future::availableCores(),
    type="SOCK"
  )  # using all available cores
doSNOW::registerDoSNOW(clustr)

d_rf <-
  foreach(n_tree=rep(1000/future::availableCores(), future::availableCores()), .combine=randomForest::combine, .packages="randomForest") %dopar%
  {randomForest(
    df_chunks_DARs_synth[c("Sp_mean","Ta_mean","Sp_std","Ta_std","Rel_disp")],
    y=NULL,
    ntree=n_tree,
    proximity=TRUE,
    oob.prox=TRUE
    )
  }

parallel::stopCluster(clustr)

result_clustering <-
fastcluster::hclust(
  as.dist(sqrt(1-d_rf$proximity)),
  method="ward.D2"
)

n=4  # number of clusters (staMEs)
result_clustering <-
  cutree(
    hierarc_rf_res,
    k=n
  )


print(noquote('Cluster sequence: ')
result_clustering  # cluster sequence

print(noquote('Cluster centroids in decreasing order or speed: ')
centroids <- NULL
for(i in 1:n){
centroids <-
  rbind(
    centroids,
    colMeans(df_chunks_DARs[c("speed_mean","turning_angle_mean","speed_std","turning_angle_std","net_displacement")][result_clustering==i, , drop=FALSE])
  )
}
centroids <- centroids[order(centroids[,1], decreasing=T), ]
centroids

occupancy <-
  as.numeric(
    table(result_clustering)
  )
noquote("Cluster occupancy sorted in decreasing order of speed:")
occupancy_speed_matrix <-
  matrix(
    c(centroids[,1], occupancy),
    ncol=2
  )
occupancy_sorted_wrt_speed <- occupancy_speed_matrix[order(occupancy_speed_matrix[,1], decreasing=T), 2]
occupancy_sorted_wrt_speed
