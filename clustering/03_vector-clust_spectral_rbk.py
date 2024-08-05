import numpy as np
import pandas as pd
import pyreadr
import numexpr as ne
from sklearn.cluster import SpectralClustering


df_chunks_DARs <- pyreadr.read_r(".../segments-for-vector-clust_ANIMOV.Rds")  # for working w/ ANIMOVER1 segment data; line 8 to be uncommented and lines 9, 10 to be commented
# df_chunks_DARs <- pyreadr.read_r(".../base-segments-for-vector-clust_barn-owl.Rds")  # for working w/ barn owl base segment data; line 9 to be uncommented and lines 8, 10 to be commented
# df_chunks_DARs <- pyreadr.read_r(".../word-segments-for-vector-clust_barn-owl.Rds")  # for working w/ barn owl word segment data; line 10 to be uncommented and lines 8, 9 to be commented

df_chunks_DARs = df_chunks_DARs_indiv[None]
df_chunks_DARs = df_chunks_DARs_indiv.drop('seg', axis=1)


arr_chunks_DARs = df_chunks_DARs.to_numpy()

norm_arr_chunks_DARs_indiv = np.sum(arr_chunks_DARs_indiv**2, axis=-1)

gaussian_kernel =
  ne.evaluate('exp(-g * (A + B - 2 * C))',
              {'A' : norm_arr_chunks_DARs_indiv[:,None],
               'B' : norm_arr_chunks_DARs_indiv[None,:],
               'C' : np.dot(arr_chunks_DARs_indiv, arr_chunks_DARs_indiv.T),
               'g' : 0.5
              }
             )  # radial base kernel with \sigma=1 to be passed as argument in spectral clustering

nk=4  # number of clusters
np.random.seed(17)
result_clustering = SpectralClustering(
    affinity='precomputed',
    n_clusters=nk, eigen_solver='amg',
    random_state=17,
    n_init=10
).fit_predict(gaussian_kernel)

result_clustering


cluster_statistics_occupancy=[]

for ic in range(0,nk):
    speed_mean=[]
    speed_std=[]
    turning_angle_mean=[]
    turning_angle_std=[]
    net_displacement=[]
  
    for idx in np.where(result_clustering==ic):
        speed_mean.extend(df_chunks_DARs_indiv.loc[idx,'speed_mean'])
        speed_std.extend(df_chunks_DARs_indiv.loc[idx,'speed_std'])
        turning_angle_mean.extend(df_chunks_DARs_indiv.loc[idx,'turning_angle_mean'])
        turning_angle_std.extend(df_chunks_DARs_indiv.loc[idx,'turning_angle_std'])
        net_displacement.extend(df_chunks_DARs_indiv.loc[idx,'net_displacement'])

    print(f"Cluster {ic} speed_mean centroid: {sum(speed_mean)/len(speed_mean)}")
    print(f"Cluster {ic} speed_std centroid: {sum(speed_std)/len(speed_std)}")
    print(f"Cluster {ic} turning_angle_mean centroid: {sum(turning_angle_mean)/len(turning_angle_mean)}")
    print(f"Cluster {ic} turning_angle_std centroid: {sum(turning_angle_std)/len(turning_angle_std)}")
    print(f"Cluster {ic} net_displacement centroid: {sum(net_displacement)/len(net_displacement)}")
    print(f"Occupancy of cluster {ic}: {len(speed_mean)}")
    cluster_statistics_occupancy.append([sum(mean_spd)/len(mean_spd), sum(std_spd)/len(std_spd), sum(mean_turAn)/len(mean_turAn), sum(std_turAn)/len(std_turAn), sum(relDisp)/len(relDisp), len(mean_spd)])


occupancy = [column[5] for column in cluster_statistics_occupancy]

cluster_statistics_occupancy.sort(key = lambda x: x[0])
cluster_statistics_occupancy.reverse()
occupancy_sorted_wrt_speed = [sublist[5] for sublist in cluster_statistics_occupancy]
np.savetxt(
  '.../cluster-occupancy_decreasing-speed',
  np.array(occupancy_sorted_wrt_speed, dtype='int')[np.newaxis],
  fmt='%i',
  delimiter=' '
)

# To find new cluster order, given original cluster order [0,1,2,3]
new_order=dict()
for index, num in enumerate(occupancy_sorted_wrt_speed):
  orig_index = occupancy.index(num)
  if orig_index < 0:
    raise Exception('number not found in unsorted occupancy array')
  new_order[index] = orig_index

result_clustering_new_order=[]
for element in result_clustering:
  result_clustering_new_order.append(new_order[element])  
result_clustering_new_order = [1+int(element) for element in result_clustering_new_order]

result_clustering_new_order =
  np.array(
    result_clustering_new_order,
    dtype='int'
  )  # clusterin sequence with new cluster order
np.savetxt(
  '.../cluster-sequence_decreasing-speed',
  result_clustering_new_order[np.newaxis],
  fmt='%i',
  delimiter=' '
)
