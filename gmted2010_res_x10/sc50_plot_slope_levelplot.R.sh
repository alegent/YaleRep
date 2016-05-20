# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc50_plot_slope_levelplot.R.sh" ) 

rm(list = ls())

AREA = "alps"

require(raster)
require(rgdal)
require(rasterVis)
require(gridExtra)

slope_250M  = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/GMTED_250/slope_250M_GMTED.tif")
slope_1KM   = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/slope_1KMmd_GMTEDmd.tif")
slope_1KM   = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/slope_1KMmd_GMTEDmd.tif")
slope_5KM   = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/slope_5KMmd_GMTEDmd.tif")
slope_10KM  = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/slope_10KMmd_GMTEDmd.tif")
slope_50KM  = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/slope_50KMmd_GMTEDmd.tif")
slope_100KM = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/slope_100KMmd_GMTEDmd.tif")


n=100
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
cols=colR(n)

options(scipen=10)
trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

for ( file in c("slope_250M","slope_1KM","slope_5KM","slope_10KM","slope_50KM","slope_100KM" ) )  { 

postscript(paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/",file,".ps") ,  paper="special" ,  horizo=F , width=2.85, height=2 )
par (oma=c(0.3,0.5,0.5,0.5) , mar=c(0.5,0.5,0.5,0.3) , cex.lab=0.5 , cex=0.6 , cex.axis=0.4  ,  xpd=NA    )

raster=get(file)
ext=extent(raster)
if(file == "slope_250M" ) {  max=65 ;  min=0  ; labels=c(0,10,20,30,40,50,60) ; at=labels ; print(min) ;print( max) }
if(file == "slope_1KM" ) {   max=55 ;  min=0  ; labels=c(0,10,20,30,40,50) ; at=labels ; print(min) ;print( max) }
if(file == "slope_5KM" ) {   max=33 ;  min=0  ; labels=c(0,10,20,30) ; at=labels ; print(min) ;print( max) }
if(file == "slope_10KM" ) {  max=29 ;  min=0  ; labels=c(0,5,10,15,20,25) ; at=labels ; print(min) ;print( max) }
if(file == "slope_50KM" ) {  max=22 ;  min=0  ; labels=c(0,5,10,15,20) ; at=labels ; print(min) ;print( max) }
if(file == "slope_100KM" ) { max=20 ;  min=0  ; labels=c(0,5,10,15,20) ; at=labels ; print(min) ;print( max) }

raster[raster  > max] <-  max
raster[raster  < min] <-  min

plot(raster   , col=cols , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab=""  , legend=FALSE   , cex.main=0.65 , font.main=2 , maxpixels=ncell(raster), box=FALSE)
plot(raster, axis.args=list(  at=at , labels=labels ,  tck=0 , line=-0.9 , cex.axis=0.8), smallplot=c(0.70,0.75,0.1,0.9),  line=2 ,    zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=cols)

dev.off()
}


system("evince /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/slope_100KM.ps")

