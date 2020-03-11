#load ayob pi_ijnt
#average across all sectors for each ij relationship
#result will be 3d matrix which we can melt
library(reshape2)
pi_ijt = apply(all_year_obs_array[["pi_ijnt"]], c(1,2,4), mean) # now it is 30 by 30 by 19

#melt this
pi_ijt = melt(pi_ijt)
colnames(pi_ijt) = c("Country1", "Country2", "Period", "pi_value")
pi_ijt$year = pi_ijt$Period + 1999

#export to csv
setwd("/Users/erineidschun/Desktop/StructEst_W20/Projects/Data")
write.csv(pi_ijt, "pi_ijt.csv")
