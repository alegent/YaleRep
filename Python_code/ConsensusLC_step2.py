#-------------------------------------------------------------------------------
# Name:        ConsensusLC.py
# Purpose:     Generate consensus land cover data from existing land cover products
#               Step2 is to integrate GlobCover and MODIS and generate an intermediate dataset
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


# import weight matrices
#path = 'D:\\Work\\Consensus\\weight\\'
path = '/home/maoningt/LC/Weight/'
weight = {}
for w in ['GC','MODIS','GLCC','GLC2k']:
    ar = []
    f = file(path+'%s_weight.csv' % w, 'r')
    line = f.readline()
    while line != '':
        line = line[:-1].split(',')
        ar.append(line)
        line = f.readline()
    weight[w] = np.array(ar).astype('float')
    f.close()

t = time.time()
# import LC products
#g = gdal.Open('D:\\Work\\Consensus\\LC_data\\GlobCover_Oregon_reclass.tif')
g = gdal.Open('/home/maoningt/LC/Data/globcover_reclass.tif')
b = g.GetRasterBand(1)
newGlobCover = b.ReadAsArray()
GC_geo = g.GetGeoTransform()


#g = gdal.Open('D:\\Work\\Consensus\\LC_data\\MODIS_Oregon_reclass.tif')
g = gdal.Open('/home/maoningt/LC/Data/modis_reclass.tif')
b = g.GetRasterBand(1)
newMODIS = b.ReadAsArray()
MODIS_geo = g.GetGeoTransform()
MODIS_proj = g.GetProjection()
MODIS_nodata = b.GetNoDataValue()

g = None
b = None
print 'importing data has done in %f mins' % ((time.time() - t)/60.0)


# calculate LC proportions for GlobCover
LX_M = MODIS_geo[0]  # left X coordinate for MODIS
UY_M = MODIS_geo[3]  # upper Y coordinate for MODIS
CS_M = MODIS_geo[1]  # cell size for MODIS
LX_G = GC_geo[0]  # left X for GlobCover
UY_G = GC_geo[3]  # upper Y for GlobCover
CS_G = GC_geo[1]  # cell size for GlobCover


con500m = {}
for lc in range(13):
    con500m[str(lc)] = np.empty(newMODIS.shape, dtype='uint8')
    con500m[str(lc)].fill(255)

#st_con500m = {}
#for lc in range(13):
#    st_con500m[str(lc)] = np.empty(newMODIS.shape, dtype='uint8')
#    st_con500m[str(lc)].fill(255)


t = time.time()

for r in range(newMODIS.shape[0]):
    print 'processing the Row %d/%d...' % (r, newMODIS.shape[0])
    for c in range(newMODIS.shape[1]):
        LX_W = LX_M + CS_M * c  # left X for the window (a pixel of the new array)
        RX_W = LX_W + CS_M      # right X for the window
        UY_W = UY_M - CS_M * r  # upper Y for the window
        LY_W = UY_W - CS_M      # lower Y for the window
        minCol = int((LX_W - LX_G) / CS_G)  # the following four values indicate the GlobCover pixels intercepting with the window
        maxCol = int((RX_W - LX_G) / CS_G)
        minRow = int((UY_G - UY_W) / CS_G)
        maxRow = int((UY_G - LY_W) / CS_G)

        if newGlobCover.shape[1] > maxCol > 0 and newGlobCover.shape[0] > maxRow > 0:
            if minCol < 0:
                minCol = 0
            if minRow < 0:
                minRow = 0

            area = {str(lc):0.0 for lc in range(13)}

            for gr in range(minRow,maxRow+1):  # loop for each GlobCover pixel
                for gc in range(minCol,maxCol+1):
                    LX_g = LX_G + CS_G * gc  # left X for the GlobCover pixel
                    RX_g = LX_g + CS_G       # right X for the GlobCover pixel
                    UY_g = UY_G - CS_G * gr  # upper Y for the GlobCover pixel
                    LY_g = UY_g - CS_G       # lower Y for the GlobCover pixel
                    length = min(CS_G, CS_M)
                    width = min(CS_G, CS_M)
                    if LX_g < LX_W:
                        width = min(RX_g - LX_W, CS_M)
                    if RX_g > RX_W:
                        width = min(RX_W - LX_g, CS_M)
                    if UY_g > UY_W:
                        length = min(UY_W - LY_g, CS_M)
                    if LY_g < LY_W:
                        length = min(UY_g - LY_W, CS_M)

                    area[str(int(newGlobCover[gr,gc]))] += length * width


# First step of merging data

            if area.values().count(max(area.values())) == 1:
#                print 'MODIS is class %d and GlobCover is class %d for pixel (%d, %d)' % (newMODIS[r,c], int(area.keys()[area.values().index(max(area.values()))]), r, c)
                if int(newMODIS[r,c]) != int(area.keys()[area.values().index(max(area.values()))]):
#                    print 'MODIS is class %d and GlobCover is class %d for pixel (%d, %d)' % (newMODIS[r,c], int(area.keys()[area.values().index(max(area.values()))]), r, c)
                    for lc in range(13):
                        if lc == int(newMODIS[r,c]) or area[str(lc)] > 0:
                            wpp = 0.0
                            for i in area.items():
                                wpp += i[1]/(CS_M*CS_M) * weight['GC'][lc,int(i[0])]
                            wpp += 1 * weight['MODIS'][lc,int(newMODIS[r,c])]
                            con500m[str(lc)][r,c] = round(wpp*0.5*100)
                        else:
                            con500m[str(lc)][r,c] = 0
                else:
                    for lc in range(13):
                        con500m[str(lc)][r,c] = round(area[str(lc)]/(CS_M*CS_M)*100)
#                print 'proportion of class %d is changed from %f to %f' % (newMODIS[r,c], area[str(int(newMODIS[r,c]))]/MC_S*MC_S, con500m[str(int(newMODIS[r,c]))][r,c])
            else:
                print 'Warning: There are more than one dominant class for pixel (%d, %d)' % (r,c)

# standardize con500m
#        totalPP = 0.0
#        for lc in con500m.keys():
#            totalPP += con500m[lc][r,c]
#        for lc in st_con500m.keys():
#            st_con500m[lc][r,c] = round(con500m[lc][r,c] / totalPP * 100)


print 'merging MODIS and GlobCover has done in %f mins' % ((time.time() - t)/60.0)

# export
t = time.time()

driver = gdal.GetDriverByName('GTiff')
for lc in con500m.keys():
#    output = driver.Create('D:\\Work\\Consensus\\consensus_data\\Oregon_500m_unst_class_%s.tif' % lc, con500m[lc].shape[1], con500m[lc].shape[0], 1, gdal.GDT_Byte, 'COMPRESS=LZW')
    output = driver.Create("/home/maoningt/LC/Output/consensus_500m_unst_class_%s.tif" % lc, con500m[lc].shape[1], con500m[lc].shape[0], 1, gdal.GDT_Byte, ['COMPRESS=LZW'])
    output.SetGeoTransform(MODIS_geo)
    output.SetProjection(MODIS_proj)
    output.GetRasterBand(1).WriteArray(con500m[lc])
    output.GetRasterBand(1).SetNoDataValue(255)
    output = None

print 'exporting data has done in %f mins' % ((time.time() - t)/60.0)



