#-------------------------------------------------------------------------------
# Name:        ConsensusLC_step1.py
# Purpose:     Reclassify GlobCover
#
# Author:      Mao-Ning Tuanmu
#
# Created:     05/09/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

GC2GL = {'1':[70,90], '2':[40,160,170], '3':[50,60], '4':[100,110,120],\
        '5':[130], '6':[140], '7':[11,14,20,30], '8':[180], '9':[190],\
        '10':[220], '11':[150,200], '12':[210], '0':[230]}
MODIS2GL = {'1':[1,3], '2':[2], '3':[4], '4':[5,8,9], '5':[6,7],\
        '6':[10], '7':[12,14], '8':[11], '9':[13], '10':[15],\
        '11':[16], '12':[0], '0':[254,255]}
GLCC2GL = {'1':[1,3], '2':[2], '3':[4], '4':[5,8,9], '5':[6,7],\
        '6':[10], '7':[12,14], '8':[11], '9':[13], '10':[15],\
        '11':[16], '12':[17], '0':[100]}
GLC2k2GL = {'1':[4,5], '2':[1,7,8], '3':[2,3], '4':[6,9,10], '5':[11,12],\
        '6':[13], '7':[16,17,18], '8':[15], '9':[22], '10':[21],\
        '11':[14,19], '12':[20], '0':[23]}

import numpy as np
#from spatial import raster
#from spatial import rasterArray as ra
from osgeo import gdal
import time

t = time.time()
g = gdal.Open('/home/maoningt/LC/Data/glcc_CEA.tif')
b = g.GetRasterBand(1)
a = b.ReadAsArray()
geo = g.GetGeoTransform()
proj = g.GetProjection()
nodata = b.GetNoDataValue()
print 'importing data has done in %f mins' % ((time.time() - t)/60.0)

t = time.time()
for r in range(a.shape[0]):
    print 'processing the Row %d/%d...' % (r, a.shape[0])
    for c in range(a.shape[1]):
        for i in GLCC2GL.iteritems():
            if a[r,c] in i[1]:
                a[r,c] = int(i[0])
                break

print 'reclassifying data has done in %f mins' % ((time.time() - t)/60.0)

driver = gdal.GetDriverByName('GTiff')
output = driver.Create("/home/maoningt/LC/Output/glcc_reclass_CEA.tif", a.shape[1], a.shape[0], 1, gdal.GDT_Byte, 'COMPRESS=LZW')
output.SetGeoTransform(geo)
output.SetProjection(proj)
output.GetRasterBand(1).WriteArray(a)
output.GetRasterBand(1).SetNoDataValue(nodata)
output = None