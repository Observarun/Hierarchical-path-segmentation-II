cluster_occupancy_symbols <- scan(".../cluster-occupancy_decreasing-speed")  # for base ($\mu-$step) segments
cluster_occupancy_words <- scan(".../cluster-occupancy_decreasing-speed")  # for base ($m\mu-$step) segments
list_labels <- readRDS(".../word-type-distributions-each-CAM.Rds")


# Probability distribution and entropy of words before clustering

cluster_occupancy_symbols <- cluster_occupancy_symbols/sum(cluster_occupancy_symbols)

P_Word_before <-
  sapply(  # lapply returns a list even when a vector is passed; sapply returns a vector
    labels_words,
    function(word){
      prod(P_symbol[strsplit(word,'')[[1]] |>
            as.numeric()])
    }
  )

H_before_word_clustering <-
  0 - sum(P_Word_before * log2(ifelse(P_Word_before==0, 1, P_Word_before)))


# Probability distribution and entropy of words after clustering

k=4  # number of CAMs

P_Word_after <- 
  sapply(
    list_labels,
    function(df){
      df[,2]/sum(df[,2])}
  )

H_after_word_clustering <- 0
for (c in 1:k) {
  H_after_word_clustering =
    H_after_word_clustering -
      (cluster_occupancy_words[c]/sum(cluster_occupancy_words)) * sum(P_Word_after[,c] * log2(ifelse(P_Word_after[,c]==0, 1, P_Word_after[,c])))


# Normalised Jensen Shannon divergence

D_JS_norm <- (H_before_word_clustering - H_after_word_clustering)/log2(k**m)
print(noquote('Normalised JS divergence:'))
D_JS_norm
