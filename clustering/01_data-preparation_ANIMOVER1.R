# Code for preprocessing ANIMOV1 simulation data.


df_DARs_synth <- read.csv(file=".../multi-DAR_sim.csv", skip=6)  #  the file can be downloaded from the Dryad repository https://doi.org/10.5061/dryad.jm63xsjkv
df_DARs_synth <- na.omit(df_DARs_synth)

df_DARs_synth <-
  transform(
    df_DARs_synth,
    Delta=Delta+99*(Day-1)
  )  # Time parameter in ANIMOV1 resets at the turn of each day.

colnames(df_DARs_synth)[6] <- "heading"  # Changing name of column 6 to reflect angle of heading.
df_DARs_synth$heading <-
  with(
    df_DARs_synth,
    pmin(df_DARs_synth$heading, 360-df_DARs_synth$heading)
  )
turning_angle_degree <-
  with(
    df_DARs_synth,
    diff(df_DARs_synth$heading)
  )  # turning angle
turning_angle_degree <- abs(turning_angle_degree)  # only for absolute (or reflection invariant) turning angle

df_DARs_synth <- df_DARs_synth[-1, ]  # time parameters in the ANIMOVER\_1 RAMP to produce $99$ points  for each of our "nominal days" other than for the first, which has $100$ points.
df_DARs_synth$heading <- turning_angle_degree
rm(turning_angle_degree)
colnames(df_DARs_synth)[6] <- "turning_angle_degree"

df_DARs_synth <- transform(df_DARs_synth, turning_angle_degree=turning_angle_degree*pi/180)
colnames(df_DARs_synth)[6] <- "turning_angle_radian"


df_DARs_synth <- df_DARs_synth[, c('X', 'Y', 'Delta', 'Distance', 'turning_angle_radian')]
colnames(df_DARs_synth)[1] <- "x"
colnames(df_DARs_synth)[2] <- "y"
colnames(df_DARs_synth)[3] <- "delta"
colnames(df_DARs_synth)[4] <- "speed"
colnames(df_DARs_synth)[5] <- "turning_angle"


df_DARs_indiv$speed <- (df_DARs$speed)/max(df_DARs$speed)
df_DARs_indiv$turning_angle <- (df_DARs$turning_angle)/pi
# Scaling to bring the variables to range on [0,1].


saveRDS(df_DARs_synth, file=".../normalised_merged-DARs_ANIMOV.Rds")
