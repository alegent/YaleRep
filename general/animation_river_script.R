# tar xvfz blockfile0_sub_stream.tar.gz
# tar xvfz blockfile0_sub_watershed.tar.gz
# gdal_translate -ot Int16 -a_nodata -1   -projwin 3.7750000  44.0416667 4.5500000  43.4666667  /home/selv/grass_hydro/dem/alt_16.tif  /home/selv/grass_hydro/dem/alt_16_clip.tif
# pksetmask    -i  /home/selv/grass_hydro/dem/alt_16_clip.tif -m /home/selv/grass_hydro/animation/sub_watershedID163.tif --operator '='  -msknodata 255  -nodata -100   -o /home/selv/grass_hydro/animation/alt_16_basin.tif
# pksetmask    -i  /home/selv/grass_hydro/dem/alt_16_clip.tif -m /home/selv/grass_hydro/animation/sub_streamID163.tif --operator '='  -msknodata 255  -nodata -100   -o /home/selv/grass_hydro/animation/alt_16_stream.tif

library(rgdal)
library(raster)
library(sp)
library(maptools)
library(rgeos)
library(ggplot2)
library(rgl)
library(plot3D)
library(GA)
library(rasterVis)

dem=raster("/home/selv/grass_hydro/animation/alt_16_basin.tif")
stream=raster("/home/selv/grass_hydro/animation/sub_streamID163.tif")

Volcano <- as.matrix(dem) 

x <- 1 : nrow(Volcano)
y <- 1 : ncol(Volcano)
# A function that is called after the axes were drawn

panelfirst <- function(pmat) {
  XY <- trans3D(x = rep(1, ncol(dem_mx)), y = y,
                z = Volcano[10,], pmat = pmat)
  scatter2D(XY$x, XY$y, colvar = Volcano[10,],
            type = "l", lwd = 3, add = TRUE, colkey = FALSE)
  XY <- trans3D(x = x, y = rep(ncol(Volcano), nrow(Volcano)),
                z = Volcano[,10], pmat = pmat)
  scatter2D(XY$x, XY$y, colvar = Volcano[,10],
            type = "l", lwd = 3, add = TRUE, colkey = FALSE)
}

pmat <- persp3D(z = Volcano/3, x = x, y = y, scale = FALSE, theta = 120, phi=40,
                expand = 0.05, colkey = FALSE)

stream_cell <- Which(!is.na(stream), cells = TRUE)
stream_alt <- extract(dem, stream_cell)

stream_colrow <- rowColFromCell(stream, stream_cell)
XYZ = as.matrix(cbind(stream_colrow,stream_alt/3))

XY <- trans3D( x = XYZ[,1] , y = XYZ[,2] , z = XYZ[,3] , pmat = pmat$persp)

points(XY, lwd = 3, col='red', pch=15)

# Get boundaries

basin=raster("/home/selv/grass_hydro/animation/sub_watershedID80.tif")

b <- boundaries(basin)
b[b==0] <- NA

b_cell <- Which(!is.na(b), cells = TRUE)
b_alt <- extract(dem, b_cell)

b_colrow <- rowColFromCell(b, b_cell)
XYZ = as.matrix(cbind(b_colrow,b_alt/3))

XY <- trans3D( x = XYZ[,1] , y = XYZ[,2] , z = XYZ[,3] , pmat = pmat$persp)

points(XY, lwd = 3, col='red', pch=15)
persp3D(z = Volcano, contour = list(side = c("zmax", "z")), zlim= c(0, 1),
        phi = 30, theta = 20, d = 10, box = FALSE)

