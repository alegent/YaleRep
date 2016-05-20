# source ("/lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc50_plot_geomorphon_levelplot.R.sh" ) 

rm(list = ls())

AREA = "alps"

require(raster)
require(rgdal)
require(rasterVis)
require(gridExtra)

raster = raster ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/GMTED_250/geomorphic250_GMTED2010_md.tif",  col=c("#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#fdbf6f","#ff7f00","#cab2d6","#554c4c") )


options(scipen=10)
trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

postscript( "/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/geom_250GMTED.ps" ,  paper="special" ,  horizo=F , width=2.85, height=2 )
par (oma=c(0.3,0.5,0.5,0.5) , mar=c(0.5,0.5,0.5,0.3) , cex.lab=0.5 , cex=0.6 , cex.axis=0.4  ,  xpd=NA    )

plot(raster   , col=c("#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#fdbf6f","#ff7f00","#cab2d6","#554c4c") , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab=""  , legend=FALSE   , cex.main=0.65 , font.main=2 , maxpixels=ncell(raster), box=FALSE)
plot(raster, axis.args=list( at=seq (1 , 10 , 1) ,  labels=c("flat","summit","ridge","shoulder","spur","slope","hollow","footslope","valley","depression") ,   tck=0 , line=-0.9 , cex.axis=0.5), smallplot=c(0.70,0.75,0.1,0.9),  line=2 ,    zlim=c( 1, 10 ) , legend.only=TRUE,  legend.width=1, legend.shrink=0.75 , col=c("#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#fdbf6f","#ff7f00","#cab2d6","#554c4c") )

dev.off()

system("evince /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/geom_250GMTED.ps")

system("convert -flatten -density 300 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/geom_250GMTED.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/geom_250GMTED.png")
system("ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/geom_250GMTED.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/geom_250GMTED.eps")





