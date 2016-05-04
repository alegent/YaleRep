# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc43_Topo_correlation_plot_hetero_curvat.R.sh")

library(raster)
library(ecodist)
library(corrplot)

##### plotting correlation figures from data tables #####

## import data
# GMTED1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt/GMTED_km1.txt", sep=" ", header=T)
# SRTM1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/txt/SRTM_km1.txt", sep=" ", header=T)

GMTED_CURV_1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt/GMTED_curvature_km1.txt", sep=" ", header=T)
GMTED_HETE_1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt/GMTED_hetero_km1.txt", sep=" ", header=T)

## remove NA data

GMTED_CURV_1km[GMTED_CURV_1km == -9999 ] <- NA  
GMTED_HETE_1km[GMTED_HETE_1km == -9999 ] <- NA  

GMTED_CURV_1km <- na.omit (GMTED_CURV_1km  )
GMTED_HETE_1km <- na.omit (GMTED_HETE_1km  )



## obtain samples
sampleRow  = sample.int(nrow(GMTED_CURV_1km), 10000)

GMTED_CURV_1km  = GMTED_CURV_1km[sampleRow,]
GMTED_HETE_1km = GMTED_HETE_1km[sampleRow,]

## change colnames

colnames(GMTED_CURV_1km)[1] =  "slope_1km.md"
colnames(GMTED_CURV_1km)[2] =  "aspect-cosine_1km-md"
colnames(GMTED_CURV_1km)[3] =  "aspect-sine_1km-md"  
colnames(GMTED_CURV_1km)[4] =  "eastness_1km-md"     
colnames(GMTED_CURV_1km)[5] =  "northness_1km-md"    
colnames(GMTED_CURV_1km)[6] =  "pcurv_1km.md"        
colnames(GMTED_CURV_1km)[7] =  "tcurv_1km.md"        
colnames(GMTED_CURV_1km)[8] =  "dx_1km-md"           
colnames(GMTED_CURV_1km)[9] =  "dxx_1km-md"          
colnames(GMTED_CURV_1km)[10] = "dy_1km-md"           
colnames(GMTED_CURV_1km)[11] = "dyy_1km-md"          


## change colnames

colnames(GMTED_HETE_1km)[1] =  "elevation_1km-sd"   
colnames(GMTED_HETE_1km)[2] =  "elevation_1km-psd"  
colnames(GMTED_HETE_1km)[3] =  "tri_1km-md"         
colnames(GMTED_HETE_1km)[4] =  "tpi_1km-md"         
colnames(GMTED_HETE_1km)[5] =  "roughness_1km-md"   
colnames(GMTED_HETE_1km)[6] =  "vrm_1km-md"         
colnames(GMTED_HETE_1km)[7] =  "slope_1km-sd"       
colnames(GMTED_HETE_1km)[8] =  "aspect.cosine_1km-sd"
colnames(GMTED_HETE_1km)[9] =  "aspect.sine_1km-sd"  
colnames(GMTED_HETE_1km)[10] =  "eastness_1km-sd"     
colnames(GMTED_HETE_1km)[11] =  "northness_1km-sd"    
colnames(GMTED_HETE_1km)[12] =  "pcurv_1km-sd"        
colnames(GMTED_HETE_1km)[13] =  "tcurv_1km-sd"        
colnames(GMTED_HETE_1km)[14] =  "dx_1km-sd"           
colnames(GMTED_HETE_1km)[15] =  "dxx_1km-sd"         
colnames(GMTED_HETE_1km)[16] =  "dy_1km-sd"          
colnames(GMTED_HETE_1km)[17] =  "dyy_1km-sd"         
colnames(GMTED_HETE_1km)[18] =  "geom_1km-count"     
colnames(GMTED_HETE_1km)[19] =  "geom_1km-maj"       
colnames(GMTED_HETE_1km)[20] =  "geom_1km-sha"      
colnames(GMTED_HETE_1km)[21] =  "geom_1km-uni"      
colnames(GMTED_HETE_1km)[22] =  "geom_1km-ent"      
colnames(GMTED_HETE_1km)[23] =  "geom.flat_1km-perc"
colnames(GMTED_HETE_1km)[24] =  "geom.peak_1km-perc"
colnames(GMTED_HETE_1km)[25] =  "geom.ridge_1km-perc" 
colnames(GMTED_HETE_1km)[26] =  "geom.shoulder_1km-perc"
colnames(GMTED_HETE_1km)[27] =  "geom.spur_1km-perc"    
colnames(GMTED_HETE_1km)[28] =  "geom.slope_1km-perc"   
colnames(GMTED_HETE_1km)[29] =  "geom.hollow_1km-perc"  
colnames(GMTED_HETE_1km)[30] =  "geom.footslope_1km-perc"
colnames(GMTED_HETE_1km)[31] =  "geom.valley_1km-perc"   
colnames(GMTED_HETE_1km)[32] =  "geom.pit_1km-perc"      


## cluster                                                            ### tree brances 
pcGMTED_HETE_1km = prcomp(t(scale(GMTED_HETE_1km)))
fitGMTED_HETE_1km = hclust(distance(pcGMTED_HETE_1km$x), method="ward")
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/cluster_GMTED_HETE_1km.ps", width=8, height=8 , paper="special" ,  horizo=F)
plot(fitGMTED_HETE_1km, hang=-1, axes=F, main=NULL, ylab=NULL, ann=F)
dev.off()

pcGMTED_CURV_1km = prcomp(t(scale(GMTED_CURV_1km)))
fitGMTED_CURV_1km = hclust(distance(pcGMTED_CURV_1km$x), method="ward")
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/cluster_GMTED_CURV_1km.ps", width=8, height=8 , paper="special" ,  horizo=F)
plot(fitGMTED_CURV_1km, hang=-1, axes=F, main=NULL, ylab=NULL, ann=F)
dev.off()


GMTED_CURV_1km_ordered = GMTED_CURV_1km[,fitGMTED_CURV_1km$order]
GMTED_HETE_1km_ordered = GMTED_HETE_1km[,fitGMTED_HETE_1km$order]



#code taken from part of a short guide to R
#Version of November 26, 2004
#William Revelle
# see: http://www.personality-project.org/r/r.graphics.html

panel.cor <- function(x, y, digits=2, prefix="", cex.cor)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r = (cor(x, y, method='pearson'))
  txt <- format(c(abs(r), 0.123456789), digits=digits)[1]
  txt <- paste(prefix, txt, sep="")
  if(missing(cex.cor)) cex <- 0.8/strwidth(txt)
  if(r>=0) tCol <- 'blue'
  else tCol <- 'magenta'
  text(0.5, 0.5, txt, cex = cex * (r*r), col=tCol)
}

## put histograms on the diagonal
panel.hist <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5))
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "cyan", ...)
}

GMTED_CURV_1km_cor = cor (GMTED_CURV_1km)
GMTED_HETE_1km_cor = cor (GMTED_HETE_1km)

cols = c("red","red","red","blue","blue","blue","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red")

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTED_CURV.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
corrplot( GMTED_CURV_1km_cor     , order="hclust", hclust.method="ward", tl.col=cols, addrect=6)
dev.off()

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTED_HETE.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
corrplot(GMTED_HETE_1km_cor , order="hclust", hclust.method="ward", tl.col=cols, addrect=6)
dev.off()





system("convert -flatten -density 300  Fig5_corplot_GMTED_HETE.ps   Fig5_corplot_GMTED_HETE.png" )
system("convert -flatten -density 300  Fig5_corplot_GMTED_CURV.ps   Fig5_corplot_GMTED_CURV.png" )

system("ps2epsi   Fig5_corplot_GMTED_HETE.ps   Fig5_corplot_GMTED_HETE.eps" )
system("ps2epsi   Fig5_corplot_GMTED_CURV.ps   Fig5_corplot_GMTED_CURV.eps" )



