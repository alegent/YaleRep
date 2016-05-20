# source ("/lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc50_plot_shanon_levelplot.R.sh" ) 

rm(list = ls())

AREA = "alps"

require(raster)
require(rgdal)
require(rasterVis)
require(gridExtra)

raster  = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/geom_1KMsha_GMTEDmd_small.tif" )

n=100
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
cols=colR(n)
res=1e6 # res=1e4 for testing and res=1e6 for the final product

postscript( "/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/shannon_1km_GMTEDsmall.ps" ,  paper="special" ,  horizo=F , width=2.85, height=2 )
par (oma=c(0.3,0.5,0.5,0.5) , mar=c(0.5,0.5,0.5,0.3) , cex.lab=0.5 , cex=0.6 , cex.axis=0.4  ,  xpd=NA    )

plot(raster, col=cols , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab=""  , legend=FALSE   , cex.main=0.65 , font.main=2 , maxpixels=ncell(raster), box=FALSE)
plot(raster, axis.args=list( at=c(0,0.5,1,1.5,2),  labels=c(0,0.5,1,1.5,2),   tck=0 , line=-0.9 , cex.axis=0.5), smallplot=c(0.70,0.75,0.1,0.9),  line=2 ,    zlim=c( 0, 2 ) , legend.only=TRUE,  legend.width=1, legend.shrink=0.75 , col=cols  )

dev.off()

system("evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/shannon_1km_GMTEDsmall.ps")

system("convert -flatten -density 300   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/shannon_1km_GMTEDsmall.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/shannon_1km_GMTEDsmall.png")
system("ps2epsi  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/shannon_1km_GMTEDsmall.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/shannon_1km_GMTEDsmall.eps")


  

