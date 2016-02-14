#-------------------------------------------------------------------------------
# Name:        ConsensusLC.py
# Purpose:     Generate consensus land cover data from existing land cover products
#               Step3 is to integrate GLC2000 and DISCover
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
con500m = {}

for lc in range(13):
#    g = gdal.Open('D:\\Work\\Consensus\\consensus_data\\Oregon_500m_unst_class_%s.tif' % lc)
    g = gdal.Open("/home/maoningt/LC/Output/consensus_500m_unst_class_%s.tif" % lc)
    con500m[str(lc)] = g.ReadAsArray()
con_geo = g.GetGeoTransform()
con_proj = g.GetProjection()

#g = gdal.Open('D:\\Work\\Consensus\\LC_data\\GLCC_Oregon_reclass.tif')
g = gdal.Open('/home/maoningt/LC/Data/glcc_reclass.tif')
newGLCC = g.ReadAsArray()
GLCC_geo = g.GetGeoTransform()

#g = gdal.Open('D:\\Work\\Consensus\\LC_data\\GLC2k_Oregon_reclass.tif')
g = gdal.Open('/home/maoningt/LC/Data/glc2k_reclass.tif')
newGLC2k = g.ReadAsArray()
GLC2k_geo = g.GetGeoTransform()

g = None

print 'importing data has done in %f mins' % ((time.time() - t)/60.0)


# second step of merging data

con1km = {}
for lc in range(13):
    con1km[str(lc)] = np.empty((int(con500m[str(lc)].shape[0]/2), int(con500m[str(lc)].shape[1]/2)), dtype='uint8')
    con1km[str(lc)].fill(255)

LX_M = con_geo[0]  # left X for con500m
UY_M = con_geo[3]  # upper Y for con500m
CS_M = con_geo[1]  # cell size for con500m

LX_GLCC = GLCC_geo[0]  # left X for GLCC
UY_GLCC = GLCC_geo[3]  # upper Y for GLCC
CS_GLCC = GLCC_geo[1]  # cell size for GLCC

LX_GLC2k = GLC2k_geo[0]  # left X for GLC2000
UY_GLC2k = GLC2k_geo[3]  # upper Y for GLC2000
CS_GLC2k = GLC2k_geo[1]  # cell size for GLC2000

t = time.time()

for r in range(con1km['1'].shape[0]):
    print 'processing the Row %d/%d...' % (r, con1km['1'].shape[0])
    for c in range(con1km['1'].shape[1]):
        LX_W = LX_M + CS_M * 2 * c  # left X for the window (a pixel of the new array)
        RX_W = LX_W + CS_M * 2     # right X for the window
        UY_W = UY_M - CS_M * 2 * r  # upper Y for the window
        LY_W = UY_W - CS_M * 2      # lower Y for the window

        minCol_GLCC = int((LX_W - LX_GLCC) / CS_GLCC)  # the following four values indicate the GLCC pixels intercepting with the window
        maxCol_GLCC = int((RX_W - LX_GLCC) / CS_GLCC)
        minRow_GLCC = int((UY_GLCC - UY_W) / CS_GLCC)
        maxRow_GLCC = int((UY_GLCC - LY_W) / CS_GLCC)

        minCol_GLC2k = int((LX_W - LX_GLC2k) / CS_GLC2k)  # the following four values indicate the GLC2000 pixels intercepting with the window
        maxCol_GLC2k = int((RX_W - LX_GLC2k) / CS_GLC2k)
        minRow_GLC2k = int((UY_GLC2k - UY_W) / CS_GLC2k)
        maxRow_GLC2k = int((UY_GLC2k - LY_W) / CS_GLC2k)


# calculate proportions of LC classes for GLCC
        if newGLCC.shape[1] > maxCol_GLCC > 0 and newGLCC.shape[0] > maxRow_GLCC > 0:
            if minCol_GLCC < 0:
                minCol_GLCC = 0
            if minRow_GLCC < 0:
                minRow_GLCC = 0

            area_GLCC = {lc:0.0 for lc in con500m.keys()}
            for gr in range(minRow_GLCC,maxRow_GLCC+1):  # loop for each GLCC pixel
                for gc in range(minCol_GLCC,maxCol_GLCC+1):
                    LX_g = LX_GLCC + CS_GLCC * gc  # left X for the GLCC pixel
                    RX_g = LX_g + CS_GLCC       # right X for the GLCC pixel
                    UY_g = UY_GLCC - CS_GLCC * gr  # upper Y for the GLCC pixel
                    LY_g = UY_g - CS_GLCC       # lower Y for the GLCC pixel
                    length = min(CS_GLCC, CS_M*2)
                    width = min(CS_GLCC, CS_M*2)
                    if LX_g < LX_W:
                        width = min(RX_g - LX_W, CS_M*2)
                    if RX_g > RX_W:
                        width = min(RX_W - LX_g, CS_M*2)
                    if UY_g > UY_W:
                        length = min(UY_W - LY_g, CS_M*2)
                    if LY_g < LY_W:
                        length = min(UY_g - LY_W, CS_M*2)

                    area_GLCC[str(int(newGLCC[gr,gc]))] += length * width

        else:
            area_GLCC = None

# calculate proportions of LC classes for GLC2000
        if newGLC2k.shape[1] > maxCol_GLC2k > 0 and newGLC2k.shape[0] > maxRow_GLC2k > 0:
            if minCol_GLC2k < 0:
                minCol_GLC2k = 0
            if minRow_GLC2k < 0:
                minRow_GLC2k = 0

            area_GLC2k = {lc:0.0 for lc in con500m.keys()}
            for gr in range(minRow_GLC2k,maxRow_GLC2k+1):  # loop for each GLC2k pixel
                for gc in range(minCol_GLC2k,maxCol_GLC2k+1):
                    LX_g = LX_GLC2k + CS_GLC2k * gc  # left X for the GLC2k pixel
                    RX_g = LX_g + CS_GLC2k       # right X for the GLC2k pixel
                    UY_g = UY_GLC2k - CS_GLC2k * gr  # upper Y for the GLC2k pixel
                    LY_g = UY_g - CS_GLC2k       # lower Y for the GLC2k pixel
                    length = min(CS_GLC2k, CS_M*2)
                    width = min(CS_GLC2k, CS_M*2)
                    if LX_g < LX_W:
                        width = min(RX_g - LX_W, CS_M*2)
                    if RX_g > RX_W:
                        width = min(RX_W - LX_g, CS_M*2)
                    if UY_g > UY_W:
                        length = min(UY_W - LY_g, CS_M*2)
                    if LY_g < LY_W:
                        length = min(UY_g - LY_W, CS_M*2)

                    area_GLC2k[str(int(newGLC2k[gr,gc]))] += length * width

        else:
            area_GLC2k = None

# aggregate proportions of LC classes to 1 km for con500m
        wpp_con = {lc:0.0 for lc in con500m.keys()}
        for lc in con500m.keys():
            wpp_con[lc] = (int(con500m[lc][r*2,c*2]) + int(con500m[lc][r*2,c*2+1]) + int(con500m[lc][r*2+1,c*2]) + int(con500m[lc][r*2+1,c*2+1])) / 400.0

# merge data
        majority_con = int(wpp_con.keys()[wpp_con.values().index(max(wpp_con.values()))])  # dominant LC class in con500m

        if area_GLCC != None and area_GLC2k !=None:  # if both GLCC or GLC2k have data for the pixel
            majority_GLCC = int(area_GLCC.keys()[area_GLCC.values().index(max(area_GLCC.values()))])  # dominant LC class in GLCC
            majority_GLC2k = int(area_GLC2k.keys()[area_GLC2k.values().index(max(area_GLC2k.values()))])  # dominant LC class in GLC2000
            if majority_con != majority_GLCC and majority_con != majority_GLC2k:  # if con500m disagrees with both GLCC and GLC2000
                for lc in con1km.keys():
                    if area_GLCC[lc] > 0 or area_GLC2k[lc] > 0 or wpp_con[lc] > 0:
                        wpp = 0.0
                        for i in area_GLCC.items():
                            wpp += i[1]/(CS_M*CS_M*4) * weight['GLCC'][int(lc),int(i[0])]
                        for i in area_GLC2k.items():
                            wpp += i[1]/(CS_M*CS_M*4) * weight['GLC2k'][int(lc),int(i[0])]
                        wpp += 2 * wpp_con[lc]
                        con1km[lc][r,c] = round(wpp/4.0*100)
                    else:
                        con1km[lc][r,c] = 0
            else:
                for lc in con1km.keys():  # if con500m agrees with either GLCC or GLC2000
                    con1km[lc][r,c] = round(wpp_con[lc]*100)

        elif area_GLCC != None:  # if only GLC2k does not have data for the pixel
            majority_GLCC = int(area_GLCC.keys()[area_GLCC.values().index(max(area_GLCC.values()))])  # dominant LC class in GLCC
            if majority_con != majority_GLCC:  # if con500m disagrees with GLCC
                for lc in con1km.keys():
                    if area_GLCC[lc] > 0 or wpp_con[lc] > 0:
                        wpp = 0.0
                        for i in area_GLCC.items():
                            wpp += i[1]/(CS_M*CS_M*4) * weight['GLCC'][int(lc),int(i[0])]
                        wpp += 2 * wpp_con[lc]
                        con1km[lc][r,c] = round(wpp/3.0*100)
                    else:
                        con1km[lc][r,c] = 0
            else:
                for lc in con1km.keys():  # if con500m agrees with GLCC
                    con1km[lc][r,c] = round(wpp_con[lc]*100)

        elif area_GLC2k != None:  # if only GLCC does not have data for the pixel
            majority_GLC2k = int(area_GLC2k.keys()[area_GLC2k.values().index(max(area_GLC2k.values()))])  # dominant LC class in GLC2000
            if majority_con != majority_GLC2k:  # if con500m disagrees with GLC2000
                for lc in con1km.keys():
                    if area_GLC2k[lc] > 0 or wpp_con[lc] > 0:
                        wpp = 0.0
                        for i in area_GLC2k.items():
                            wpp += i[1]/(CS_M*CS_M*4) * weight['GLC2k'][int(lc),int(i[0])]
                        wpp += 2 * wpp_con[lc]
                        con1km[lc][r,c] = round(wpp/3.0*100)
                    else:
                        con1km[lc][r,c] = 0
            else:
                for lc in con1km.keys():  # if con500m agrees with GLC2k
                    con1km[lc][r,c] = round(wpp_con[lc]*100)

        else:
            for lc in con1km.keys():  # if both GLCC and GLC2k do not have data for the pixel
                con1km[lc][r,c] = round(wpp_con[lc]*100)


# standardize con1km
        totalPP = 0.0
        for lc in con1km.keys():
            totalPP += con1km[lc][r,c]
        for lc in con1km.keys():
            if totalPP != 0:
                con1km[lc][r,c] = round(con1km[lc][r,c] / totalPP *100)
            else:
                con1km[lc][r,c] = 0

print 'merging all data has done in %f mins' % ((time.time() - t)/60.0)


driver = gdal.GetDriverByName('GTiff')
newGeo = [con_geo[0], con_geo[1]*2, con_geo[2], con_geo[3], con_geo[4], con_geo[5]*2]
for lc in con1km.keys():
#    output = driver.Create('D:\\Work\\Consensus\\consensus_data\\Oregon_1km_class_%s.tif' % lc, con1km[lc].shape[1], con1km[lc].shape[0], 1, gdal.GDT_Byte)
    output = driver.Create('/home/maoningt/LC/Output/consensus_1km_class_%s.tif' % lc, con1km[lc].shape[1], con1km[lc].shape[0], 1, gdal.GDT_Byte, ['COMPRESS=LZW'])
    output.SetGeoTransform(newGeo)
    output.SetProjection(con_proj)
    output.GetRasterBand(1).WriteArray(con1km[lc])
    output.GetRasterBand(1).SetNoDataValue(255)
    output = None




