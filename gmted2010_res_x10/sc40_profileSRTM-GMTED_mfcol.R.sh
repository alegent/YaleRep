
# qsub -X  -I -q fas_devel -l walltime=4:00:00  
# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc40_profileSRTM-GMTED_mfcol.R.sh") 

require(raster)
require(rgdal)

GMTED="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/"
SRTM="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/"

lines  <- readOGR(dsn="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/line_transect.shp" , layer="line_transect")
lines2 <- readOGR(dsn="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/line_transect2.shp", layer="line_transect2")
lines3 <- readOGR(dsn="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/line_transect3.shp", layer="line_transect3")


# inport data 
# full resolution  GMTED_250

for ( file in c("altitude_GMTED.tif","aspect_cos_GMTED.tif","aspect_Ew_GMTED.tif","aspect_GMTED.tif","aspect_Nw_GMTED.tif","aspect_sin_GMTED.tif","roughness_GMTED.tif","slope_GMTED.tif","tpi_GMTED.tif","tri_GMTED.tif","vrm_GMTED.tif")){
raster  <- raster(paste(GMTED,"GMTED_250/", file  ,sep="")) 
extract <-  extract(raster , lines3)
assign(paste(file,sep="") , raster  )
assign(paste(file,".extract",sep="") , extract  )
}

# full resolution  SRTM_90

for ( file in c("altitude_SRTM.tif","aspect_cos_SRTM.tif","aspect_Ew_SRTM.tif","aspect_SRTM.tif","aspect_Nw_SRTM.tif","aspect_sin_SRTM.tif","roughness_SRTM.tif","slope_SRTM.tif","tpi_SRTM.tif","tri_SRTM.tif","vrm_SRTM.tif")){
raster  <- raster(paste(SRTM,"SRTM_90/", file  ,sep="")) 
extract <-  extract(raster , lines3)
assign(paste(file,sep="") , raster  )
assign(paste(file,".extract",sep="") , extract  )
}


line_length = lines3@bbox[2,2]   - lines3@bbox[2,1]

by_gmted = ( line_length / (length(altitude_GMTED.tif.extract[[1]]) -1 ) ) 
by_srtm  = ( line_length / (length(altitude_SRTM.tif.extract[[1]]) -1  ) )


# from 1 5 10 50 100 km resoultion   GMTED 

for ( km in c(1,5,10,50,100)) {
    for ( file in c("tpi" , "tri" , "vrm" ,  "roughness" ,"slope","aspect-cosine","aspect-sine","eastness","northness" ,"elevation")) {
	raster  <- raster(paste0(GMTED,file,"_md_GMTED2010_md_km", km , ".tif")) 
	extract <-  extract(raster , lines3)
	assign(paste0(file,"_GMTED_km", km ) , raster  )
	assign(paste0(file,"_GMTED_km", km ,".extract"),extract  )
    }
}


# from 1 5 10 50 100 km resoultion SRTM

for ( km in c(1,5,10,50,100)) {
    for ( file in c("tpi" , "tri" , "vrm" ,  "roughness" ,"slope" , "aspect_cos","aspect_sin","aspect_Ew","aspect_Nw","elevation_md")) {

        if ( file == "aspect_cos" )   { raster  <- raster(paste0(SRTM,file,"_median_SRTM_km", km , ".tif"))   ; file = "aspect-cosine" }
        if ( file == "aspect_sin" )   { raster  <- raster(paste0(SRTM,file,"_median_SRTM_km", km , ".tif"))   ; file = "aspect-sine"   }
        if ( file == "aspect_Ew" )    { raster  <- raster(paste0(SRTM,file,"_median_SRTM_km", km , ".tif"))   ; file = "eastness"      }
        if ( file == "aspect_Nw" )    { raster  <- raster(paste0(SRTM,file,"_median_SRTM_km", km , ".tif"))   ; file = "northness"     }
        if ( file == "elevation_md" ) { raster  <- raster(paste0(SRTM,file,"_SRTM_km", km , ".tif"))   ; file = "elevation"     }

	if ( file == "tpi" ||  file == "tri" ||  file == "vrm" ||  file == "roughness" ||  file == "slope" ) { raster  <- raster(paste0(SRTM,file,"_median_SRTM_km", km , ".tif"))  }

	extract <-  extract(raster , lines3)
	assign(paste0(file,"_SRTM_km", km ) , raster  )
	assign(paste0(file,"_SRTM_km", km ,".extract"),extract  )
    }
}


postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.ps" ,  paper="special" ,  horizo=F , width=8, height=10  )	

par (oma=c(1,1,1,1) , mar=c(1,4,1,1) , cex.lab=0.8 , cex=0.8 , cex.axis=0.8  , mfcol=c(10,2) )

for (file in c("altitude_GMTED.tif","tpi_GMTED.tif","tri_GMTED.tif","vrm_GMTED.tif","roughness_GMTED.tif","slope_GMTED.tif","aspect_cos_GMTED.tif","aspect_sin_GMTED.tif","aspect_Ew_GMTED.tif","aspect_Nw_GMTED.tif")){

filename=sub("GMTED.tif","",file)

ymax=max(rbind(get(paste(filename,"GMTED.tif.extract", sep=""))[[1]] , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ,  get(paste(filename,"GMTED.tif.extract", sep=""))[[1]]  , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ))
ymin=min(rbind(get(paste(filename,"GMTED.tif.extract", sep=""))[[1]] , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ,  get(paste(filename,"GMTED.tif.extract", sep=""))[[1]]  , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ))

 if ( file == "altitude_GMTED.tif" )   { ylab = "Elevation" } 
 if ( file == "tpi_GMTED.tif" )        { ylab = "TPI" } 
 if ( file == "tri_GMTED.tif" )        { ylab = "TRI" } 
 if ( file == "vrm_GMTED.tif" )        { ylab = "VRM" } 
 if ( file == "roughness_GMTED.tif" )  { ylab = "Roughness" } 
 if ( file == "slope_GMTED.tif" )      { ylab = "Slope" } 
 if ( file == "aspect_cos_GMTED.tif" ) { ylab = "Aspect-cosine" } 
 if ( file == "aspect_sin_GMTED.tif" ) { ylab = "Aspect-sine"   } 
 if ( file == "aspect_Ew_GMTED.tif" )  { ylab = "Eastness"      } 
 if ( file == "aspect_Nw_GMTED.tif" )  { ylab = "Northness"     }

plot  (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_gmted ) , get(paste(filename,"GMTED.tif.extract", sep=""))[[1]] ,  ylim=c(ymin,ymax) ,  type='l' , ylab=ylab , xaxt="n" , xlab=""  ,   )  

axis(side = 1,  at = c(47.20,47.25,47.30,47.35,47.40)  , labels=FALSE  ,    tck = -0.1)

lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_srtm  ) , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]]   ,col='red', xlab="") 
lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_gmted ) , get(paste(filename,"GMTED.tif.extract", sep=""))[[1]]  ,lty=2    , col='black', xlab="") 
lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_srtm  ) , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]]   ,lty=2    , col='red'  , xlab="") 

}

axis(side = 1,  at = c(47.20,47.25,47.30,47.35,47.40)  ,  lab=c(47.20,47.25,47.30,47.35,47.40) ,  tck = -0.1)

by_1km =     ( line_length  / (length(vrm_GMTED_km1.extract[[1]]) -1   ) ) 
by_5km =     ( line_length  / (length(vrm_GMTED_km5.extract[[1]]) -1   ) ) 
by_10km =    ( line_length  / (length(vrm_GMTED_km10.extract[[1]]) -1  ) )
# by_50km =  ( line_length  / (length(vrm_GMTED_km50.extract[[1]]) -1  ) )  
# by_100km = ( line_length  / (length(vrm_GMTED_km100.extract[[1]]) -1 ) ) 

for ( file in c("elevation","tpi" , "tri" , "vrm" ,  "roughness" ,"slope","aspect-cosine","aspect-sine","eastness","northness")) {

ymax=max(rbind(get(paste(file,"_GMTED_km1.extract", sep=""))[[1]] , get(paste(file,"_SRTM_km1.extract", sep=""))[[1]] ,  get(paste(file,"_GMTED_km100.extract", sep=""))[[1]]  , get(paste(file,"_SRTM_km100.extract", sep=""))[[1]] ))
ymin=min(rbind(get(paste(file,"_GMTED_km1.extract", sep=""))[[1]] , get(paste(file,"_SRTM_km1.extract", sep=""))[[1]] ,  get(paste(file,"_GMTED_km100.extract", sep=""))[[1]]  , get(paste(file,"_SRTM_km100.extract", sep=""))[[1]] ))

plot  (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_1km ) , get(paste(file,"_GMTED_km1.extract", sep=""))[[1]] ,  ylim=c(ymin,ymax) ,  type='l' , ylab=""  , xaxt="n" , xlab="" )

axis(side = 1,  at = c(47.20,47.25,47.30,47.35,47.40)  , labels=FALSE  ,  tck = -0.1)
  
lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_1km ) , get(paste(file,"_SRTM_km1.extract", sep=""))[[1]]  ,  col='red', xlab="") 

lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_5km ) , get(paste(file,"_GMTED_km5.extract", sep=""))[[1]]  , lty=2  ,    col='black', xlab="") 
lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_5km ) , get(paste(file,"_SRTM_km5.extract", sep=""))[[1]]   , lty=2  ,   col='red'  , xlab="") 

lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_10km ) , get(paste(file,"_GMTED_km10.extract", sep=""))[[1]]  ,lty=3  ,    col='black', xlab="") 
lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_10km ) , get(paste(file,"_SRTM_km10.extract", sep=""))[[1]]   ,lty=3  ,   col='red'  , xlab="") 

# lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_50km ) , get(paste(file,"_GMTED_km50.extract", sep=""))[[1]]  ,lty=2  ,    col='black', xlab="") 
# lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_50km ) , get(paste(file,"_SRTM_km50.extract", sep=""))[[1]]   ,lty=2  ,   col='red'  , xlab="") 

# lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_100km ) , get(paste(file,"_GMTED_km100.extract", sep=""))[[1]]  ,lty=2  ,    col='black', xlab="") 
# lines (  seq( lines3@bbox[2,1] ,  lines3@bbox[2,2] ,  by = by_100km ) , get(paste(file,"_SRTM_km100.extract", sep=""))[[1]]   ,lty=2  ,   col='red'  , xlab="") 

}

axis(side = 1,  at = c(47.20,47.25,47.30,47.35,47.40)  ,  lab=c(47.20,47.25,47.30,47.35,47.40) ,  tck = -0.1)

mtext ("SRTM90",   side=3 , cex=0.8 , line=-0.5 , outer=TRUE , at=c(0.20) , col = "red"  ) 
mtext ("GMTED250", side=3 , cex=0.8 , line=-0.5 , outer=TRUE , at=c(0.35) , col = "black"  ) 

mtext ("SRTM 1-5-10km" , side=3 , cex=0.8 , line=-0.5 , outer=TRUE , at=c(0.67) , col = "red"  ) 
mtext ("GMTED 1-5-10km", side=3 , cex=0.8 , line=-0.5 , outer=TRUE , at=c(0.87) , col = "black"  ) 

# title("Main Title", sub = "sub title",   cex.main = 2,   font.main= 4, col.main= "blue",  cex.sub = 0.75, font.sub = 3, col.sub = "red")



dev.off()

system("ps2pdf  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.pdf")
system("convert -flatten -density 300  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.png")
system("ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.eps")

system ("evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/profile_SRTMGMTED_90_250m_mfcol.ps")

