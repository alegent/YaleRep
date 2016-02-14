#-------------------------------------------------------------------------------
# Name:        ConsensusLC.py
# Purpose:     Generate consensus land cover data from existing land cover products
#
# Author:      Mao-Ning Tuanmu
#
# Created:     23/08/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

import numpy as np
from osgeo import gdal
import time

t = time.time()
# import LC products
con500m = {}

for lc in range(1,13):
#    g = gdal.Open('D:\\Work\\Consensus\\consensus_data\\Oregon_500m_unst_class_%s_v2.tif' % lc)
    g = gdal.Open("/home/maoningt/LC/Output/consensus_500m_unst_class_%s.tif" % lc)
    con500m[str(lc)] = g.ReadAsArray()
con_geo = g.GetGeoTransform()
con_proj = g.GetProjection()

g = None

print 'importing data has done in %f mins' % ((time.time() - t)/60.0)


# standardize data

t = time.time()

for r in range(con500m['1'].shape[0]):
    print 'processing the Row %d/%d...' % (r+1, con500m['1'].shape[0])
    for c in range(con500m['1'].shape[1]):
        totalPP = 0.0
        for lc in con500m.keys():
            totalPP += con500m[lc][r,c]
        for lc in con500m.keys():
            if totalPP != 0:
                con500m[lc][r,c] = round(con500m[lc][r,c] / totalPP *100)
            else:
                con500m[lc][r,c] = 0

print 'standardization has done in %f mins' % ((time.time() - t)/60.0)


driver = gdal.GetDriverByName('GTiff')
for lc in con500m.keys():
#    output = driver.Create('D:\\Work\\Consensus\\consensus_data\\Oregon_1km_class_%s_v2.tif' % lc, con1km[lc].shape[1], con1km[lc].shape[0], 1, gdal.GDT_Byte)
    output = driver.Create('/home/maoningt/LC/Output/con_500m_class_%s.tif' % lc, con500m[lc].shape[1], con500m[lc].shape[0], 1, gdal.GDT_Byte, ['COMPRESS=LZW'])
    output.SetGeoTransform(con_geo)
    output.SetProjection(con_proj)
    output.GetRasterBand(1).WriteArray(con500m[lc])
    output.GetRasterBand(1).SetNoDataValue(255)
    output = None




