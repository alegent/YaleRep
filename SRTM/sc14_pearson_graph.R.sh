# source ("/lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc14_pearson_graph.R.sh")

for (file  in  c("pearson_altitude_SRTM_GMTED.txt", "pearson_eastness_SRTM_GMTED.txt", "pearson_northness_SRTM_GMTED.txt","pearson_slope_SRTM_GMTED.txt","pearson_roughness_SRTM_GMTED.txt","pearson_tpi_SRTM_GMTED.txt","pearson_tri_SRTM_GMTED.txt","pearson_vrm_SRTM_GMTED.txt") ) {

table = read.table(paste ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/correlation/pearson/",file,sep=""))

png(paste ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/correlation/pearson/",file,".png",sep=""))

km=c(1,5,10,50,100)

plot (table$V1 ~  km , ylab=paste(file) , xlab="km" , ylim=c(min(table),max(table) ) , main="Pearson as function of the aggregation scale" , sub="black=SRTM , red=GMTED"  )

axis (2, c(1,5,10,50,100) , lab=c(1,5,10,50,100)  )

lines   (table$V1 ~  km )
lines   (table$V2 ~  km , col='red' )
points  (table$V2 ~  km , col='red' )

dev.off()

}




