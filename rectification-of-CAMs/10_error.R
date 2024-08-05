distinct_labels <- readRDS(".../labels-for-word-types")
list_labels <- readRDS(".../word-type-distributions-each-CAM.Rds")
cluster_occupancy_words <- scan(".../cluster-occupancy_decreasing-speed")

error_rate <- 0

for (label in distinct_labels)
{
  count_label <- 0
  nr_in_braket <- c()
  dr_in_braket <- 0
  for (c in 1:k){
    count_label <-
      count_label + list_labels[[c]]$count[list_labels[[c]]$distinct_labels==label]
    nr_in_braket <-
      append(
        Nr_in_braket,
        list_labels[[c]]$count[list_labels[[c]]$distinct_labels==label]/cluster_occupancy_words[c]
      )
    dr_in_braket <-
      dr_in_braket + list_labels[[c]]$count[list_labels[[c]]$distinct_labels==label]/cluster_occupancy_words[c]
  }
  if (dr_in_braket==0)
    { error_rate <- error_rate + 0 }
  else
    { error_rate <- error_rate + count_label/sum(cluster_occupancy_words) * (1 - max(nr_in_braket)/dr_in_braket) }
}

error_rate <- error_rate * 100
print(noquote(paste0("Error rate: ", error_rate,"%")))
