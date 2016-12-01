# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc43_Topo_correlation_plot_hetero_curvat.R.sh")

# module load Apps/R/3.1.1-generic

library(raster)
library(ecodist)
library(corrplot)
library(ggplot2 , lib="/lustre/home/client/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.1")
library(ggdendro , lib="/lustre/home/client/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.1")
library(grid)

##### plotting correlation figures from data tables #####

## import data

GMTED_CURV_1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt/GMTED_curvature_km1.txt", sep=" ", header=T)
GMTED_HETE_1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt/GMTED_hetero_km1.txt", sep=" ", header=T)

## remove NA data

GMTED_CURV_1km[GMTED_CURV_1km == -9999 ] <- NA  
GMTED_HETE_1km[GMTED_HETE_1km == -9999 ] <- NA  

GMTED_CURV_1km <- na.omit (GMTED_CURV_1km  )
GMTED_HETE_1km <- na.omit (GMTED_HETE_1km  )

## obtain samples full dataset 216001 
sampleRow  = sample.int(nrow(GMTED_CURV_1km), 200000)

GMTED_CURV_1km  = GMTED_CURV_1km[sampleRow,]
GMTED_HETE_1km = GMTED_HETE_1km[sampleRow,]

## change colnames

colnames(GMTED_CURV_1km)[1] =  "slope md"
colnames(GMTED_CURV_1km)[2] =  "aspectcosine md"
colnames(GMTED_CURV_1km)[3] =  "aspectsine md"  
colnames(GMTED_CURV_1km)[4] =  "eastness md"     
colnames(GMTED_CURV_1km)[5] =  "northness md"    
colnames(GMTED_CURV_1km)[6] =  "pcurv md"        
colnames(GMTED_CURV_1km)[7] =  "tcurv md"        
colnames(GMTED_CURV_1km)[8] =  "dx md"           
colnames(GMTED_CURV_1km)[9] =  "dxx md"          
colnames(GMTED_CURV_1km)[10] = "dy md"           
colnames(GMTED_CURV_1km)[11] = "dyy md"          


## change colnames

colnames(GMTED_HETE_1km)[1] =  "elevation sd"   
colnames(GMTED_HETE_1km)[2] =  "elevation psd"  
colnames(GMTED_HETE_1km)[3] =  "tri md"         
colnames(GMTED_HETE_1km)[4] =  "tpi md"         
colnames(GMTED_HETE_1km)[5] =  "roughness md"   
colnames(GMTED_HETE_1km)[6] =  "vrm md"         
colnames(GMTED_HETE_1km)[7] =  "slope sd"       
colnames(GMTED_HETE_1km)[8] =  "aspectcosine sd"
colnames(GMTED_HETE_1km)[9] =  "aspectsine sd"  
colnames(GMTED_HETE_1km)[10] =  "eastness sd"     
colnames(GMTED_HETE_1km)[11] =  "northness sd"    
colnames(GMTED_HETE_1km)[12] =  "pcurv sd"        
colnames(GMTED_HETE_1km)[13] =  "tcurv sd"        
colnames(GMTED_HETE_1km)[14] =  "dx sd"           
colnames(GMTED_HETE_1km)[15] =  "dxx sd"         
colnames(GMTED_HETE_1km)[16] =  "dy sd"          
colnames(GMTED_HETE_1km)[17] =  "dyy sd"         
colnames(GMTED_HETE_1km)[18] =  "geom count"     
colnames(GMTED_HETE_1km)[19] =  "geom maj"       
colnames(GMTED_HETE_1km)[20] =  "geom sha"      
colnames(GMTED_HETE_1km)[21] =  "geom uni"      
colnames(GMTED_HETE_1km)[22] =  "geom ent"      
colnames(GMTED_HETE_1km)[23] =  "geomflat perc"
colnames(GMTED_HETE_1km)[24] =  "geompeak perc"
colnames(GMTED_HETE_1km)[25] =  "geomridge perc" 
colnames(GMTED_HETE_1km)[26] =  "geomshoulder perc"
colnames(GMTED_HETE_1km)[27] =  "geomspur perc"    
colnames(GMTED_HETE_1km)[28] =  "geomslope perc"   
colnames(GMTED_HETE_1km)[29] =  "geomhollow perc"  
colnames(GMTED_HETE_1km)[30] =  "geomfootslope perc"
colnames(GMTED_HETE_1km)[31] =  "geomvalley perc"   
colnames(GMTED_HETE_1km)[32] =  "geompit perc"      


## cluster                                                            ### tree brances 
pcGMTED_HETE_1km = prcomp(t(scale(GMTED_HETE_1km)))

fitGMTED_HETE_1km = hclust(distance(pcGMTED_HETE_1km$x), method="ward")

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig6_cluster_GMTED_HETE_1km.ps", width=3, height=8 , paper="special" ,  horizo=F)
                                         #  rotate = T  , labels=F
print (ggdendrogram( fitGMTED_HETE_1km, rotate = T  , labels=F  )   +  theme(axis.ticks = element_blank(), axis.text.x = element_blank() , axis.text.y = element_blank()) ,   vp=viewport(angle=-180)  )

# plot(fitGMTED_HETE_1km, hang=-1, axes=F, main=NULL, ylab=NULL, ann=F)
dev.off()

pcGMTED_CURV_1km  = prcomp(t(scale(GMTED_CURV_1km)))
fitGMTED_CURV_1km = hclust(distance(pcGMTED_CURV_1km$x), method="ward")
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig7_cluster_GMTED_CURV_1km.ps", width=3, height=8 , paper="special" ,  horizo=F)
                                
print (ggdendrogram( fitGMTED_CURV_1km, rotate = T  , labels=F  )   +  theme(axis.ticks = element_blank(), axis.text.x = element_blank() , axis.text.y = element_blank()) ,   vp=viewport(angle=-180)  )

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

GMTED_CURV_1km_cor = cor (GMTED_CURV_1km_ordered)
GMTED_HETE_1km_cor = cor (GMTED_HETE_1km_ordered)

cols = c("red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue")

col2 <- colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7",      "#FFFFFF", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061"))

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig7_corplot_GMTED_CURV_1km.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
corrplot( GMTED_CURV_1km_cor, order="original" , tl.col=cols, addrect=6 , col=rev(col2(200)) )
dev.off()

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig6_corplot_GMTED_HETE_1km.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
corrplot(GMTED_HETE_1km_cor , order="original", tl.col=cols, addrect=6 , col=rev(col2(200)) )
dev.off()

system("convert -flatten -density 300  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig6_cluster_GMTED_HETE_1km.ps   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig6_cluster_GMTED_HETE_1km.png" )
system("convert -flatten -density 300  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig7_cluster_GMTED_CURV_1km.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig7_cluster_GMTED_CURV_1km.png" )

system("ps2epsi   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig6_corplot_GMTED_HETE_1km.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig6_corplot_GMTED_HETE_1km.eps" )
system("ps2epsi   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig7_corplot_GMTED_CURV_1km.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/Fig7_corplot_GMTED_CURV_1km.eps" )

# transfer to laptop and merge with inkscape. 
