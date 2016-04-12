
# qsub /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc40_profileSRTM-GMTED_mfcol_multiProfile.R.sh

# qsub -X  -I -q fas_devel -l walltime=4:00:00  
# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc40_profileSRTM-GMTED_mfcol.R.sh") 

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:4:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

# andes orizontal 

# alps vertical 
# borneo vertical 
# alps2 vertical 

echo  andes alps borneo alps2    | xargs -n 1 -P 3 bash -c $'

export AREA=$1

R --vanilla --no-readline   -q  <<\'EOF\' 

AREA = Sys.getenv(c(\'AREA\'))

# AREA = "borneo"

require(raster)
require(rgdal)

GMTED="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/"
SRTM="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/"

line <- readOGR(dsn=paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/shp/",AREA,".shp"), layer=AREA)

# inport data 
# full resolution  GMTED_250

# if ( AREA  == "alps2" )   { AREA=alps }

for ( file in c("altitude_GMTED.tif","aspect_cos_GMTED.tif","aspect_Ew_GMTED.tif","aspect_GMTED.tif","aspect_Nw_GMTED.tif","aspect_sin_GMTED.tif","roughness_GMTED.tif","slope_GMTED.tif","tpi_GMTED.tif","tri_GMTED.tif","vrm_GMTED.tif")){
raster  <- raster(paste(GMTED,"/",AREA,"/GMTED_250/", file  ,sep="")) 
extract <-  extract(raster , line)
assign(paste(file,sep="") , raster  )
assign(paste(file,".extract",sep="") , extract  )
}

# full resolution  SRTM_90

for ( file in c("altitude_SRTM.tif","aspect_cos_SRTM.tif","aspect_Ew_SRTM.tif","aspect_SRTM.tif","aspect_Nw_SRTM.tif","aspect_sin_SRTM.tif","roughness_SRTM.tif","slope_SRTM.tif","tpi_SRTM.tif","tri_SRTM.tif","vrm_SRTM.tif")){
raster  <- raster(paste(SRTM,"/",AREA,"/SRTM_90/", file  ,sep="")) 
extract <-  extract(raster , line)
assign(paste(file,sep="") , raster  )
assign(paste(file,".extract",sep="") , extract  )
}


line_length = line@bbox[2,2]   - line@bbox[2,1]

by_gmted = ( line_length / (length(altitude_GMTED.tif.extract[[1]]) -1 ) ) 
by_srtm  = ( line_length / (length(altitude_SRTM.tif.extract[[1]]) -1  ) )


# from 1 5 10 50 100 km resoultion   GMTED 

for ( km in c(1,5,10,50,100)) {
    for ( file in c("tpi" , "tri" , "vrm" ,  "roughness" ,"slope","aspect-cosine","aspect-sine","eastness","northness" ,"elevation")) {
	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_md_GMTED2010_md_km", km , ".tif")) 
	extract <-  extract(raster , line)
	assign(paste0(file,"_GMTED_km", km ) , raster  )
	assign(paste0(file,"_GMTED_km", km ,".extract"),extract  )
    }
}


# from 1 5 10 50 100 km resoultion SRTM

for ( km in c(1,5,10,50,100)) {
    for ( file in c("tpi" , "tri" , "vrm" ,  "roughness" ,"slope" , "aspect_cos","aspect_sin","aspect_Ew","aspect_Nw","elevation_md")) {

        if ( file == "aspect_cos" )   { raster  <- raster(paste0(SRTM,"/",AREA,"/",file,"_median_SRTM_km", km , ".tif"))   ; file = "aspect-cosine" }
        if ( file == "aspect_sin" )   { raster  <- raster(paste0(SRTM,"/",AREA,"/",file,"_median_SRTM_km", km , ".tif"))   ; file = "aspect-sine"   }
        if ( file == "aspect_Ew" )    { raster  <- raster(paste0(SRTM,"/",AREA,"/",file,"_median_SRTM_km", km , ".tif"))   ; file = "eastness"      }
        if ( file == "aspect_Nw" )    { raster  <- raster(paste0(SRTM,"/",AREA,"/",file,"_median_SRTM_km", km , ".tif"))   ; file = "northness"     }
        if ( file == "elevation_md" ) { raster  <- raster(paste0(SRTM,"/",AREA,"/",file,"_SRTM_km"       , km , ".tif"))   ; file = "elevation"     }

	if ( file == "tpi" ||  file == "tri" ||  file == "vrm" ||  file == "roughness" ||  file == "slope" ) { raster  <- raster(paste0(SRTM,"/",AREA,"/",file,"_median_SRTM_km", km , ".tif"))  }

	extract <-  extract(raster , line)
	assign(paste0(file,"_SRTM_km", km ) , raster  )
	assign(paste0(file,"_SRTM_km", km ,".extract"),extract  )
    }
}


postscript(paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/",AREA,"_profile_SRTMGMTED_90_250m_mfcol.ps") ,  paper="special" ,  horizo=F , width=8, height=10  )	

par (oma=c(4,1,6,1) , mar=c(1,4,0,0) , cex.lab=0.8 , cex=0.8 , cex.axis=0.8  , mfcol=c(10,2) , xpd=TRUE )

for (file in c("altitude_GMTED.tif","tpi_GMTED.tif","tri_GMTED.tif","vrm_GMTED.tif","roughness_GMTED.tif","slope_GMTED.tif","aspect_cos_GMTED.tif","aspect_sin_GMTED.tif","aspect_Ew_GMTED.tif","aspect_Nw_GMTED.tif")){

file 

filename=sub("GMTED.tif","",file)
my.max <- function(x) ifelse( !all(is.na(x)), max(x, na.rm=T), NA) 
my.min <- function(x) ifelse( !all(is.na(x)), min(x, na.rm=T), NA)

ymax=max(my.max(get(paste(filename,"GMTED.tif.extract", sep=""))[[1]]) , my.max(get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ))
ymin=min(my.min(get(paste(filename,"GMTED.tif.extract", sep=""))[[1]]) , my.min(get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ))

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

plot  (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_gmted ) , get(paste(filename,"GMTED.tif.extract", sep=""))[[1]] ,  ylim=c(ymin,ymax) ,  type="l" , ylab=ylab , xaxt="n" , xlab=""  , col="blue" ,  lwd=.5  ,  mar=c(2,4,4,1)  )  

trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

axis(side = 1,  at = c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ) , prec = 8 ) )   , labels=FALSE  ,    tck = -0.1)

lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_srtm  ) , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ,  lwd=.5 ,  col="red", xlab="") 
lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_gmted ) , get(paste(filename,"GMTED.tif.extract", sep=""))[[1]],  lwd=.5 ,  lty=2    , col="blue", xlab="") 
lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_srtm  ) , get(paste(filename,"SRTM.tif.extract", sep=""))[[1]] ,  lwd=.5 ,  lty=2    , col="red"  , xlab="") 

}

if ( AREA == "andes" ) {
axis(side = 1,  at = c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ), prec = 8 ) ) , lab=c(trunc( seq ( line@bbox[1,1] , line@bbox[1,2] , abs((line@bbox[1,1] - line@bbox[1,2]  )/4) ) , prec = 2 )) ,  tck = -0.1)
} else {
axis(side = 1,  at = c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ), prec = 8 ) ) , lab=c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ) , prec = 2 )) ,  tck = -0.1)
}

by_1km   =  ( line_length  / (length(vrm_GMTED_km1.extract[[1]]) -1   ) ) 
by_5km   =  ( line_length  / (length(vrm_GMTED_km5.extract[[1]]) -1   ) ) 
by_10km  =  ( line_length  / (length(vrm_GMTED_km10.extract[[1]]) -1  ) )
by_50km  =  ( line_length  / (length(vrm_GMTED_km50.extract[[1]]) -1  ) )  
by_100km =  ( line_length  / (length(vrm_GMTED_km100.extract[[1]]) -1 ) ) 

for ( file in c("elevation","tpi" , "tri" , "vrm" ,  "roughness" ,"slope","aspect-cosine","aspect-sine","eastness","northness")) {

file

ymax=max(my.max(get(paste(file,"_GMTED_km1.extract", sep=""))[[1]]) , my.max(get(paste(file,"_SRTM_km1.extract", sep=""))[[1]]) , my.max( get(paste(file,"_GMTED_km100.extract", sep=""))[[1]])  , my.max(get(paste(file,"_SRTM_km100.extract", sep=""))[[1]] ))
ymin=min(my.min(get(paste(file,"_GMTED_km1.extract", sep=""))[[1]]) , my.min(get(paste(file,"_SRTM_km1.extract", sep=""))[[1]]) , my.min( get(paste(file,"_GMTED_km100.extract", sep=""))[[1]])  , my.min(get(paste(file,"_SRTM_km100.extract", sep=""))[[1]] ))

plot  (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_1km ) , get(paste(file,"_GMTED_km1.extract", sep=""))[[1]] ,  ylim=c(ymin,ymax) ,  type="l" , ylab=""  , xaxt="n" , xlab="" ,   col="blue" ,  lwd=.5 ,  )

axis(side = 1,  at = c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ) , prec = 8 ) )  , labels=FALSE ,  tck = -0.1)

  
lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_1km ) , get(paste(file,"_SRTM_km1.extract", sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_1km ))]  ,  col="red", xlab="") 

lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_5km ) , get(paste(file,"_GMTED_km5.extract", sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_5km ))]  , lty=3  ,  lwd=.5 ,  col="blue", xlab="") 
lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_5km ) , get(paste(file,"_SRTM_km5.extract" , sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_5km ))]   , lty=3  ,  lwd=.5 ,  col="red"  , xlab="") 

lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_10km ) , get(paste(file,"_GMTED_km10.extract", sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_10km ))]  ,lty=2  , lwd=.5 ,  col="blue", xlab="") 
lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_10km ) , get(paste(file,"_SRTM_km10.extract" , sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_10km ))]   ,lty=2  , lwd=.5 ,  col="red"  , xlab="") 

if ( AREA != "alps" ) {

lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_50km ) , get(paste(file,"_GMTED_km50.extract", sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_50km ))]  ,lty=4  , lwd=.5 ,  col="blue", xlab="") 
lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_50km ) , get(paste(file,"_SRTM_km50.extract" , sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_50km ))]   ,lty=4  , lwd=.5 ,  col="red"  , xlab="") 

lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_100km ) , get(paste(file,"_GMTED_km100.extract", sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_100km ))] ,lty=5 , lwd=.5 ,  col="blue", xlab="") 
lines (  seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_100km ) , get(paste(file,"_SRTM_km100.extract" , sep=""))[[1]][1:length(seq( line@bbox[2,1] ,  line@bbox[2,2] ,  by = by_100km ))]  ,lty=5 , lwd=.5 ,  col="red"  , xlab="") 
}

}

if ( AREA == "andes" ) {
axis(side = 1,  at = c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ), prec = 8 ) ) , lab=c(trunc( seq ( line@bbox[1,1] , line@bbox[1,2] , abs((line@bbox[1,1] - line@bbox[1,2]  )/4) ) , prec = 2 )) ,  tck = -0.1)
} else {
axis(side = 1,  at = c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ), prec = 8 ) ) , lab=c(trunc( seq ( line@bbox[2,1] , line@bbox[2,2] , abs((line@bbox[2,1] - line@bbox[2,2]  )/4) ) , prec = 2 )) ,  tck = -0.1)
}

mtext ("SRTM90",   side=3 , cex=0.7 , line=1.5 , outer=TRUE , at=c(0.15) , col = "red"  ) 
mtext ("GMTED250", side=3 , cex=0.7 , line=1.5 , outer=TRUE , at=c(0.3) , col = "blue"  ) 

if ( AREA == "alps" ) {
mtext ("SRTM    1km"  , side=3 , cex=0.7 , line=3  , outer=TRUE , at=c(0.65) , col = "red"  )  ; mtext ("GMTED   1km" , side=3 , cex=0.7 , line=3   , outer=TRUE , at=c(0.80) , col = "blue"  )  
mtext ("SRTM    5km"  , side=3 , cex=0.7 , line=2  , outer=TRUE , at=c(0.65) , col = "red"  )  ; mtext ("GMTED   5km" , side=3 , cex=0.7 , line=2   , outer=TRUE , at=c(0.80) , col = "blue"  )
mtext ("SRTM 10km"  , side=3 , cex=0.7 , line=1  , outer=TRUE , at=c(0.65) , col = "red" )    ; mtext ("GMTED 10km" , side=3 , cex=0.7 , line=1   , outer=TRUE , at=c(0.80) , col = "blue"  )

} else  { 

mtext ("SRTM    1km"   , side=3 , cex=0.7 , line=3.7 , outer=TRUE , at=c(0.65) , col = "red"  ) ; mtext ("GMTED     1km" , side=3 , cex=0.7 , line=3.7 , outer=TRUE , at=c(0.80) , col = "blue"  )  
mtext ("SRTM    5km"   , side=3 , cex=0.7 , line=2.8 , outer=TRUE , at=c(0.65) , col = "red"  ) ; mtext ("GMTED     5km" , side=3 , cex=0.7 , line=2.8 , outer=TRUE , at=c(0.80) , col = "blue"  )
mtext ("SRTM   10km"   , side=3 , cex=0.7 , line=1.9 , outer=TRUE , at=c(0.65) , col = "red"  ) ; mtext ("GMTED   10km" , side=3 , cex=0.7 , line=1.9 , outer=TRUE , at=c(0.80) , col = "blue"  ) 
mtext ("SRTM   50km"   , side=3 , cex=0.7 , line=1.0 , outer=TRUE , at=c(0.65) , col = "red"  ) ; mtext ("GMTED   50km" , side=3 , cex=0.7 , line=1   , outer=TRUE , at=c(0.80) , col = "blue"  ) 
mtext ("SRTM 100km"   , side=3 , cex=0.7 , line=0.1 , outer=TRUE , at=c(0.65) , col = "red" )   ; mtext ("GMTED 100km" , side=3 , cex=0.7 , line=0.1 , outer=TRUE , at=c(0.80) , col = "blue"  ) 
}

if ( AREA == "andes" ) {
mtext ("Longitude",  side=1 , cex=0.6 , line=0 , outer=TRUE , at=c(0.035) , col = "black"  ) 
mtext ("Latitude",   side=1 , cex=0.6 , line=1 , outer=TRUE , at=c(0.03) , col = "black"  ) 
mtext ( trunc(line@bbox[2,1],prec = 2),  side=1.2 , cex=0.5 , line=1 , outer=TRUE , at=c(0.085) , col = "black"  ) 

} else {
mtext ("Latitude",    side=1 , cex=0.6 , line=0 , outer=TRUE , at=c(0.03) , col = "black"  ) 
mtext ( "Longitude " ,   side=1.2 , cex=0.6 , line=1 , outer=TRUE , at=c(0.035) , col = "black"  ) 
mtext ( trunc(line@bbox[1,1],prec = 2) ,   side=1.2 , cex=0.5 , line=1 , outer=TRUE , at=c(0.085) , col = "black"  ) 
}



dev.off()

 

EOF

ps2pdf  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/${AREA}_profile_SRTMGMTED_90_250m_mfcol.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/${AREA}_profile_SRTMGMTED_90_250m_mfcol.pdf
convert -flatten -density 300  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/${AREA}_profile_SRTMGMTED_90_250m_mfcol.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/${AREA}_profile_SRTMGMTED_90_250m_mfcol.png
ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/${AREA}_profile_SRTMGMTED_90_250m_mfcol.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/${AREA}_profile_SRTMGMTED_90_250m_mfcol.eps

# evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/${AREA}_profile_SRTMGMTED_90_250m_mfcol.ps


' _ 