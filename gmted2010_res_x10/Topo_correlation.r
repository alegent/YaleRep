# source ("/lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/Topo_correlation.r")

library(raster)
library(ecodist)
library(corrplot)

##### plotting correlation figures from data tables #####

## import data
GMTED1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt/GMTED_km1.txt", sep=" ", header=T)
SRTM1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/txt/SRTM_km1.txt", sep=" ", header=T)

GMTED_ALL_1km = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt/GMTED_ALL_km1.txt", sep=" ", header=T)

## remove NA data
NARow = GMTED1km$aspect.cosine==-9999 | GMTED1km$aspect.sine==-9999 | SRTM1km$aspect.cosine==-9999 | SRTM1km$aspect.sine==-9999
GMTED1km = GMTED1km[!NARow,]
SRTM1km = SRTM1km[!NARow,]

NARow = GMTED_ALL_1km$aspect.cosine==-9999 | GMTED_ALL_1km$aspect.sine==-9999 
GMTED_ALL_1km = GMTED_ALL_1km[!NARow,]

## obtain samples
sampleRow = sample.int(nrow(GMTED1km), 10000)
GMTED1km = GMTED1km[sampleRow,]
SRTM1km = SRTM1km[sampleRow,]

GMTED_ALL_1km = GMTED_ALL_1km[sampleRow,]

## change colnames
colnames(GMTED1km)[7] = colnames(SRTM1km)[7] = "aspect-cosine"
colnames(GMTED1km)[8] = colnames(SRTM1km)[8] = "aspect-sine"
colnames(GMTED1km) = paste0(colnames(GMTED1km),'_GMTED')
colnames(SRTM1km) = paste0(colnames(SRTM1km), "_SRTM")

colnames(GMTED_ALL_1km)[9]  = colnames(SRTM1km)[7] = "aspect-cosine"
colnames(GMTED_ALL_1km)[10] = colnames(SRTM1km)[8] = "aspect-sine"


## combine tables
GMTED_SRTM1km = cbind(GMTED1km, SRTM1km)

## cluster
pcGMTED1km = prcomp(t(scale(GMTED1km)))
fitGMTED1km = hclust(distance(pcGMTED1km$x), method="ward")
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/cluster_GMTED1km.ps", width=8, height=8 , paper="special" ,  horizo=F)
plot(fitGMTED1km, hang=-1, axes=F, main=NULL, ylab=NULL, ann=F)
dev.off()

pcSRTM1km = prcomp(t(scale(SRTM1km)))
fitSRTM1km = hclust(distance(pcSRTM1km$x), method="ward")
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/cluster_SRTM1km.ps", width=8, height=8 , paper="special" ,  horizo=F)
plot(fitSRTM1km, hang=-1, axes=F, main=NULL, ylab=NULL, ann=F)
dev.off()

pcGMTED_SRTM1km = prcomp(t(scale(GMTED_SRTM1km)))
fitGMTED_SRTM1km = hclust(distance(pcGMTED_SRTM1km$x), method="ward")
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/cluster_GMTED_SRTM1km_ver2.ps", width=8, height=5 , paper="special" ,  horizo=F)
plot(fitGMTED_SRTM1km, hang=-1, axes=F, main=NULL, ylab=NULL, ann=F)
dev.off()

pcGMTED_ALL_1km = prcomp(t(scale(GMTED_ALL_1km)))
fitGMTED_ALL_1km = hclust(distance(pcGMTED_ALL_1km$x), method="ward")
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/cluster_GMTED_ALL_1km_ver2.ps", width=8, height=5 , paper="special" ,  horizo=F)
plot(fitGMTED_ALL_1km, hang=-1, axes=F, main=NULL, ylab=NULL, ann=F)
dev.off()

GMTED1km_ordered = GMTED1km[,fitGMTED1km$order]
SRTM1km_ordered  = SRTM1km[,fitSRTM1km$order]

GMTED_SRTM1km_ordered = GMTED_SRTM1km[,fitGMTED_SRTM1km$order]
GMTED_ALL_1km_ordered = GMTED_ALL_1km[,fitGMTED_ALL_1km$order]

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

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTED1km_pearson.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
pairs(GMTED1km_ordered, lower.panel=panel.smooth, upper.panel=panel.cor,
      diag.panel=panel.hist, labels='')
dev.off()

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_SRTM1km_pearson.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
pairs(SRTM1km_ordered, lower.panel=panel.smooth, upper.panel=panel.cor,
      diag.panel=panel.hist, labels='')
dev.off()

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTED_SRTM1km_pearson.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
pairs(GMTED_SRTM1km_ordered, lower.panel=panel.smooth, upper.panel=panel.cor,
      diag.panel=panel.hist, labels='')
dev.off()

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTED_ALL_1km_pearson.ps", width = 8, height = 8 , paper="special" ,  horizo=F)
pairs(GMTED_ALL_1km_ordered, lower.panel=panel.smooth, upper.panel=panel.cor,
      diag.panel=panel.hist, labels='')
dev.off()

##### GMTED vs. SRTM #####

## calculate correlations
corGS  = cor(GMTED1km, SRTM1km)
corAll = cor(GMTED_SRTM1km)
cor_GMTED_ALL = cor(GMTED_ALL_1km)

## corrplot
postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTEDvsSRTM_1km.ps", width = 8, height = 8 , paper="special" ,  horizo=F )
corrplot(corGS, order="hclust", hclust.method="ward", addrect=4)
dev.off()

cols = c("red","red","red","blue","blue","blue","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red")

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTED_SRTM1km.ps", width = 8, height = 8 , paper="special" ,  horizo=F)
corrplot(corAll, order="hclust", hclust.method="ward", tl.col=cols, addrect=6)
dev.off()

cols = c("red","red","red","blue","blue","blue","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red","blue","red")

postscript("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/corplot_GMTED_ALL_1km.ps", width = 8, height = 8 ,paper="special" ,  horizo=F)
corrplot(cor_GMTED_ALL, order="hclust", hclust.method="ward", tl.col=cols, addrect=6)
dev.off()

