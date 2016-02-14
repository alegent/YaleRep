#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      tuanmu
#
# Created:     21/09/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

from osgeo import gdal
from spatial import images as im

g = gdal.Open('/home/maoningt/Ecocast_GLS_2005/NDVI/p044r031_ndvi.tif')

test = im.reproject(g,'+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs')
driver = gdal.GetDriverByName('GTiff')
outFile = driver.CreateCopy('/home/maoningt/LEDAPS_1990/test.tif', test, 0)
outFile=None

