# Code for preprocessing a single barn owl individual data.



list_DARs_indiv <- readRDS(".../mid_to_mid1.Rds")
# See https://github.com/LudovicaLV/DAR_project/blob/main/DAR1_measures.R for
# the code to extract DARs from multi-DAR time-series data of an individual.

set.seed(17)
nbrs_DAR_indiv <- sample(1:113, 25, replace=FALSE)
df_DARs_indiv <- data.frame(matrix(nrow=0, ncol=44))
for (i in nbrs_DAR_indiv){
  df_DARs_indiv <-
    rbind(
      df_DARs_indiv,
      list_DARs_indiv[[i]]
    )
}  # To work with 25 random DARs of an individual

# Alternatively, to work with all available DARs of an individual, uncomment the next line (17).
#df_DARs_indiv <- do.call(rbind, list_DARs_indiv)


# Construct and caluclate the variables for speed (or step length) and turning angle, and append to the data frame.

df_DARs_indiv <- df_DARs_indiv[, c('X','Y','dateTime')]
colnames(df_DARs_indiv)[1] <- "x"
colnames(df_DARs_indiv)[y] <- "y"
colnames(df_DARs_indiv)[3] <- "t"

df_DARs_indiv <- transform(df_DARs_indiv, t=as.numeric(t))
speed <- vector("double", nrow(df_DARs_indiv))
for (i in 2:nrow(df_DARs_indiv))
{
  speed[i] <-
    sqrt(sum((df_DARs_indiv[i,] - df_DARs_indiv[i-1,])^2) - (df_DARs_indiv[i,3]- df_DARs_indiv[i-1,3])^2)/(df_DARs_indiv[i,3] - df_DARs_indiv[i-1,3])
}
df_DARs_indiv <-
  transform(
    df_DARs_indiv,
    t=as.POSIXct(t, origin="1970-01-01", tz="GMT")
  )
df_DARs_indiv$speed <- speed

heading <- vector("double", nrow(df_DARs_indiv))
for (i in 2:nrow(df_DARs_indiv))
{
  heading[i-1] <-
    atan2(df_DARs_indiv[i,2] - df_DARs_indiv[i-1,2], df_DARs_indiv[i,1]-df_DARs_indiv[i-1,1])
}
turning_angle <-
  with(
    df_DARs_indiv,
    diff(df_DARs_indiv$heading)
  )
turning_angle <-
  with(
    df_DARs_indiv,
    angle_turning%%(2*pi)
  )
turning_angle <-
  with(
    df_DARs_indiv,
    ifelse(turning_angle>pi, turning_angle-2*pi, turning_angle)
  )
#angle_turning <- abs(angle_turning)  # only for absolute (or reflection invariant) turning angle; to work with actual value of turning angle, line 66 must be commented
df_DARs_indiv <- df_DARs_indiv[-1, ]  # first point discarded for the lack of turning angle value
df_DARs_indiv$heading <- turning_angle
colnames(df_DARs_indiv)[5] <- 'turning_angle'
row.names(df_DARs_indiv) <- 1:nrow(df_DARs_indiv)


df_DARs_indiv <-
  na.omit(df_DARs_indiv)  # to remove NA values
df_DARs_indiv <-
  df_DARs_indiv[df_DARs_indiv$speed >= 0,]  # to remove spurious negative speeds
df_DARs_indiv <-
  df_DARs_indiv[df_DARs_indiv$speed < 70,]  # to remove obviously bogus points (unrealistically high speeds)


df_DARs_indiv$speed <-
  (df_DARs_indiv$speed)/max(df_DARs$speed)
df_DARs_indiv$turning_angle <-
  (df_DARs_indiv$turning_angle)/pi
# Scaling to bring the variables to range on [0,1].


saveRDS(df_DARs_indiv, file=".../normalised_merged-DARs_barn-owl.Rds")
