library(gtools)


n=8  # number of StaMEs
m=5  # number of base segments required to form a word

combinations <-
  permutations(
    n=n,
    r=m,
    v=1:n,
    repeats.allowed=TRUE
  )

df_combinations <- as.data.frame(combinations)
df_combinations$sum <- rowSums(df_combinations)
df_combinations <- df_combinations[order(df_combinations$sum), ]

labels_words <- 
  paste(
    df_combinations$V1,
    df_combinations$V2,
    df_combinations$V3,
    df_combinations$V4,
    df_combinations$V5,
    sep=''
  )  # for m=5; for m=4, V1...V4

sink(".../labels-for-word-types")
cat(labels_words)
sink()
