# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc41_plotVariableGMTED4rombo_levelplot.R.sh" ) 

rm(list = ls())

AREA = "rombo"

require(raster)
require(rgdal)
require(rasterVis)
require(gridExtra)

GMTED="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/"

e=extent(-106.0000000, -104.4000000, 29 , 31 )

elevation_GMTED250 = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/rombo/GMTED_250/elevation_250M_GMTED.tif")
elevation_GMTED250  = crop (  elevation_GMTED250 , e)

elevation_SRTM90 = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/rombo/SRTM_90/elevation_90M_SRTM.tif")
elevation_SRTM90  = crop (  elevation_SRTM90 , e)

vrm_GMTED250  = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/rombo/GMTED_250/vrm_250M_GMTED.tif")
vrm_GMTED250  = crop (  vrm_GMTED250 , e)

vrm_SRTM90    = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/rombo/SRTM_90/vrm_90M_SRTM.tif")
vrm_SRTM90  = crop (  vrm_SRTM90 , e)

e=extent(-106.0000000, -104.4000000,  29.1416666666  ,   30.858333333333333  )

vrm_GMTED1km  = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/rombo/vrm_1KMmd_GMTEDmd.tif")
vrm_GMTED1km  = crop (vrm_GMTED1km , e)

vrm_SRTM1km  = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/rombo/vrm_1KMmd_SRTM.tif")
vrm_SRTM1km  = crop (vrm_SRTM1km , e)

n=100
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
cols=colR(n)

options(scipen=10)
trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

postscript(paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.ps") ,  paper="special" ,  horizo=F , width=4, height=6   )
par (oma=c(2,2,2,0.5) , mar=c(0.4,0.5,1,0.8) , cex.lab=0.5 , cex=0.6 , cex.axis=0.6  ,   mfrow=c(3,2) ,  xpd=NA    )

for ( file in c("elevation_SRTM90","elevation_GMTED250","vrm_SRTM90","vrm_GMTED250","vrm_SRTM1km","vrm_GMTED1km") )  { 

raster=get(file)

if(file == "elevation_GMTED250" ) {  des="Elevation GMTED 250 m " ; min=780 ; max=2340  ; at=c(750, 1000, 1250, 1500, 1750 , 2000, 2250)  ; labels=at   ; letter="(b)" }
if(file == "elevation_SRTM90" ) {  des="Elevation SRTM 90 m"     ;  min=775 ; max=2340  ; at=c(750, 1000, 1250, 1500, 1750 , 2000, 2250)  ; labels=at   ; letter="(a)" }

if(file == "vrm_GMTED250" ) {  des="Vector Ruggedness Measure GMTED 250 m" ; max=0.001 ; min=0 ;  at=c(0,0.00025,0.00050,0.00075,0.001)  ; labels=at   ; letter="(d)" }
if(file == "vrm_SRTM90" )   {  des="Vector Ruggedness Measure SRTM 90 m"   ; max=0.001 ; min=0 ;  at=c(0,0.00025,0.00050,0.00075,0.001)  ; labels=at   ; letter="(c)" }

if(file == "vrm_GMTED1km" ) {  des="Vector Ruggedness Measure GMTED 1 km"  ; max=0.0001  ; min=0  ; at=c(0,0.000025,0.000050,0.000075,0.0001  )  ; labels=at   ; letter="(f)" }
if(file == "vrm_SRTM1km"   ) {  des="Vector Ruggedness Measure SRTM 1 km"  ; max=0.0001  ; min=0  ; at=c(0,0.000025,0.000050,0.000075,0.0001 )  ; labels=at   ; letter="(e)" }


raster[raster  > max] <-  max
raster[raster  < min] <-  min

if (( file != "vrm_GMTED1km" ) &&  ( file != "vrm_SRTM1km" ))  { 
plot(raster   , col=cols , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.575 , font.main=2)
plot(raster, axis.args=list(at=at, labels=labels, line=-0.74, tck=0), smallplot=c(0.78,0.83, 0.1,0.9), zlim=c( min, max), legend.only=TRUE , legend.width=1, legend.shrink=0.75 ,  col=cols)
text(-104.25, 31.1, letter , xpd=TRUE , cex=0.6 )
}

if ( file == "vrm_GMTED1km" ) { 
plot(raster   , col=cols , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.575 , font.main=2)
plot(raster, axis.args=list(at=at ,  labels=labels, line=-0.74, tck=0  ), smallplot=c(0.78,0.83, 0.1,0.9), zlim=c( min, max ) , legend.only=TRUE,  legend.width=1, legend.shrink=0.75, col=cols)
text(-104.3, 30.95, letter , xpd=TRUE , cex=0.6 )
}


if ( file == "vrm_SRTM1km"  )   { 
plot(raster, col=cols, yaxp=c( 29.2 , 30.8 , 4) , xaxp=c( -106,  -104.4 , 4) ,  main=des , legend=FALSE   , cex.main=0.575 , font.main=2)
plot(raster, axis.args=list(at=at, labels=labels, line=-0.74 , tck=0), smallplot=c(0.78,0.83, 0.1,0.9), zlim=c( min, max ), legend.only=TRUE, legend.width=1, legend.shrink=0.75,  col=cols) #  , nlevel=4 )
text(-104.3, 30.95, letter , xpd=TRUE , cex=0.6 )
}
} 

dev.off()

print("finish plotting")

# system("evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.ps")

system("ps2pdf /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.pdf")
system("convert -flatten -density 300 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.png")
system("ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/rombo_plot.eps")

