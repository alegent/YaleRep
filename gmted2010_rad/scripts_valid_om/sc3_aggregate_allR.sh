
wrdc.diffuse = tmp2
rm(tmp2)
wrdc.diffuse$year = as.numeric(wrdc.diffuse$year )

save.image("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/RData/wrdc.RData")

wrdc.diffuse.agr = aggregate ( wrdc.diffuse, by=list(wrdc.diffuse$station)  , FUN=mean  , na.rm=TRUE  )
wrdc.diffuse.agr$station <- NULL
colnames(wrdc.diffuse.agr)[1] <- "station"

save.image("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/RData/wrdc.RData1")

