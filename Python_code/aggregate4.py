#-------------------------------------------------------------------------------
# Name:        aggregate.py
# Purpose:     Calculates statistics for coarser pixels based on pixel values at finer resolutions
#
# Author:      Mao-Ning Tuanmu
#
# Created:     12/09/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
# Versions:    ver. 0.1 (9/12/12) - only calculates proportions based on categorical data
#-------------------------------------------------------------------------------
#!/usr/bin/env python

import numpy as np
from osgeo import gdal
import time


t = time.time()
# import NLCD products
#g = gdal.Open('D:\\Work\\Consensus\\consensus_data\\MODIS_Oregon_reclass.tif')
g = gdal.Open('/home/maoningt/LC/Data/glc2k_reclass.tif')
NLCD = g.ReadAsArray()
NLCD_geo = g.GetGeoTransform()

# import consensus data
#g = gdal.Open('D:\\Work\\Consensus\\consensus_data\\Oregon_500m_unst_class_%s_v2.tif' % lc)
g = gdal.Open("/home/maoningt/LC/Output/consensus_1km_class_1.tif")
shape = (g.RasterYSize,g.RasterXSize)
con_geo = g.GetGeoTransform()
con_proj = g.GetProjection()

g = None
b = None
print 'importing data has done in %f mins' % ((time.time() - t)/60.0)


# calculate LC proportions
LX_C = con_geo[0]  # left X coordinate for consensus data
UY_C = con_geo[3]  # upper Y coordinate for consensus data
CS_C = con_geo[1]  # cell size for consensus data
LX_N = NLCD_geo[0]  # left X for NLCD
UY_N = NLCD_geo[3]  # upper Y for NLCD
CS_N = NLCD_geo[1]  # cell size for NLCD


NLCD1km = {}
for lc in range(1,13):
    NLCD1km[str(lc)] = np.empty(shape, dtype='uint8')
    NLCD1km[str(lc)].fill(255)

t = time.time()

for r in range(shape[0]):
    print 'processing the Row %d/%d...' % (r+1, shape[0])
    for c in range(shape[1]):
        LX_W = LX_C + CS_C * c  # left X for the window (a pixel of the new array)
        RX_W = LX_W + CS_C      # right X for the window
        UY_W = UY_C - CS_C * r  # upper Y for the window
        LY_W = UY_W - CS_C      # lower Y for the window
        minCol = int((LX_W - LX_N) / CS_N)  # the following four values indicate the GlobCover pixels intercepting with the window
        maxCol = int((RX_W - LX_N) / CS_N)
        minRow = int((UY_N - UY_W) / CS_N)
        maxRow = int((UY_N - LY_W) / CS_N)

        if NLCD.shape[1] > maxCol > 0 and NLCD.shape[0] > maxRow > 0:
            if minCol < 0:
                minCol = 0
            if minRow < 0:
                minRow = 0

            area = {str(lc):0.0 for lc in range(13)}

            for gr in range(minRow,maxRow+1):  # loop for each NLCD pixel
                for gc in range(minCol,maxCol+1):
                    if int(NLCD[gr,gc]) > 0:
                        LX_g = LX_N + CS_N * gc  # left X for the NLCD pixel
                        RX_g = LX_g + CS_N       # right X for the NLCD pixel
                        UY_g = UY_N - CS_N * gr  # upper Y for the NLCD pixel
                        LY_g = UY_g - CS_N       # lower Y for the NLCD pixel
                        length = min(CS_N, CS_C)
                        width = min(CS_N, CS_C)
                        if LX_g < LX_W:
                            width = min(RX_g - LX_W, CS_C)
                        if RX_g > RX_W:
                            width = min(RX_W - LX_g, CS_C)
                        if UY_g > UY_W:
                            length = min(UY_W - LY_g, CS_C)
                        if LY_g < LY_W:
                            length = min(UY_g - LY_W, CS_C)

                        area[str(int(NLCD[gr,gc]))] += length * width

            for lc in NLCD1km.keys():
                NLCD1km[lc][r,c] = round(area[lc]/(CS_C*CS_C)*100)

print 'calculation has done in %f mins' % ((time.time() - t)/60.0)

# export
t = time.time()

driver = gdal.GetDriverByName('GTiff')
for lc in NLCD1km.keys():
#    output = driver.Create('D:\\Work\\Consensus\\consensus_data\\Oregon_500m_unst_class_%s_v2.tif' % lc, con500m[lc].shape[1], con500m[lc].shape[0], 1, gdal.GDT_Byte)
    output = driver.Create("/home/maoningt/LC/Output/glc2k_1km_class_%s.tif" % lc, shape[1], shape[0], 1, gdal.GDT_Byte, ['COMPRESS=LZW'])
    output.SetGeoTransform(con_geo)
    output.SetProjection(con_proj)
    output.GetRasterBand(1).WriteArray(NLCD1km[lc])
    output.GetRasterBand(1).SetNoDataValue(255)
    output = None

print 'exporting data has done in %f mins' % ((time.time() - t)/60.0)



