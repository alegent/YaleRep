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
from spatial import raster
from spatial import rasterArray as ra
import time

t = time.time()
# settings
GC2GL = {'1':[70,90], '2':[40,160,170], '3':[50,60], '4':[100,110,120],\
        '5':[130], '6':[140], '7':[11,14,20,30], '8':[180], '9':[190],\
        '10':[220], '11':[150,200], '12':[210], '0':[0]}
MODIS2GL = {'1':[1,3], '2':[2], '3':[4], '4':[5,8,9], '5':[6,7],\
        '6':[10], '7':[12,14], '8':[11], '9':[13], '10':[15],\
        '11':[16], '12':[0], '0':[254,255]}
GLCC2GL = {'1':[1,3], '2':[2], '3':[4], '4':[5,8,9], '5':[6,7],\
        '6':[10], '7':[12,14], '8':[11], '9':[13], '10':[15],\
        '11':[16], '12':[17], '0':[100]}
GLC2k2GL = {'1':[4,5], '2':[1,7,8], '3':[2,3], '4':[6,9,10], '5':[11,12],\
        '6':[13], '7':[16,17,18], '8':[15], '9':[22], '10':[21],\
        '11':[14,19], '12':[20], '0':[23]}

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
#GlobCover = ra.readImage('D:\\Work\\Consensus\\LC_data\\GlobCover_Oregon_sin.tif')[0]
#MODIS = ra.readImage('D:\\Work\\Consensus\\LC_data\\MODIS_Oregon.tif')[0]
#GLC2k = ra.readImage('D:\\Work\\Consensus\\LC_data\\GLC2k_Oregon_sin.tif')[0]
#GLCC = ra.readImage('D:\\Work\\Consensus\\LC_data\\GLCC_Oregon_sin.tif')[0]
GlobCover = ra.readImage('/home/maoningt/LC/Data/globcover_2006.tif')[0]
MODIS = ra.readImage('/home/maoningt/LC/Data/modis_2005_v51.tif')[0]
GLC2k = ra.readImage('/home/maoningt/LC/Data/glc2000_v11.tif')[0]
GLCC = ra.readImage('/home/maoningt/LC/Data/glcc_v2.tif')[0]

print 'importing data has done in %f mins' % ((time.time() - t)/60.0)

# reclassify
t = time.time()

newGlobCover = np.zeros(GlobCover.elements.shape)
for key in GC2GL.keys():
    con = np.in1d(GlobCover.elements.ravel(), GC2GL[key]).reshape(GlobCover.elements.shape)
    newGlobCover = np.where(con, int(key)+1000, newGlobCover)
newGlobCover = np.where(newGlobCover >= 1000, newGlobCover-1000, newGlobCover)

newMODIS = np.zeros(MODIS.elements.shape)
for key in MODIS2GL.keys():
    con = np.in1d(MODIS.elements.ravel(), MODIS2GL[key]).reshape(MODIS.elements.shape)
    newMODIS = np.where(con, int(key)+1000, newMODIS)
newMODIS = np.where(newMODIS >= 1000, newMODIS-1000, newMODIS)

newGLCC = np.zeros(GLCC.elements.shape)
for key in GLCC2GL.keys():
    con = np.in1d(GLCC.elements.ravel(), GLCC2GL[key]).reshape(GLCC.elements.shape)
    newGLCC = np.where(con, int(key)+1000, newGLCC)
newGLCC = np.where(newGLCC >= 1000, newGLCC-1000, newGLCC)

newGLC2k = np.zeros(GLC2k.elements.shape)
for key in GLC2k2GL.keys():
    con = np.in1d(GLC2k.elements.ravel(), GLC2k2GL[key]).reshape(GLC2k.elements.shape)
    newGLC2k = np.where(con, int(key)+1000, newGLC2k)
newGLC2k = np.where(newGLC2k >= 1000, newGLC2k-1000, newGLC2k)

print 'reclassifying data has done in %f mins' % ((time.time() - t)/60.0)

# calculate LC proportions for GlobCover
LX_M = MODIS.envelope[0][0]  # left X coordinate for MODIS
UY_M = MODIS.envelope[1][1]  # upper Y coordinate for MODIS
CS_M = MODIS.cellsize  # cell size for MODIS
LX_G = GlobCover.envelope[0][0]  # left X for GlobCover
UY_G = GlobCover.envelope[1][1]  # upper Y for GlobCover
CS_G = GlobCover.cellsize  # cell size for GlobCover

#ppArrayDic = {}
#for i in range(len(GC2GL)+1):
#    ppArrayDic[str(i)] = np.empty(MODIS.elements.shape)
#    ppArrayDic[str(i)].fill(-9999)

con500m = {}
for lc in GC2GL.keys():
    con500m[lc] = np.empty(MODIS.elements.shape)
    con500m[lc].fill(-9999)

st_con500m = {}
for lc in GC2GL.keys():
    st_con500m[lc] = np.empty(MODIS.elements.shape)
    st_con500m[lc].fill(-9999)

con1km = {}
for lc in GC2GL.keys():
    con1km[lc] = np.empty((int(MODIS.elements.shape[0]/2), int(MODIS.elements.shape[1]/2)))
    con1km[lc].fill(-9999)

t = time.time()

for r in range(MODIS.elements.shape[0]):
    print 'processing the Row %d/%d...' % (r, MODIS.elements.shape[0])
    for c in range(MODIS.elements.shape[1]):
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

            area = {lc:0.0 for lc in GC2GL.keys()}

            for gr in range(minRow,maxRow+1):  # loop for each GlobCover pixel
                for gc in range(minCol,maxCol+1):
                    LX_g = LX_G + CS_G * gc  # left X for the GlobCover pixel
                    RX_g = LX_g + CS_G       # right X for the GlobCover pixel
                    UY_g = UY_G - CS_G * gr  # upper Y for the GlobCover pixel
                    LY_g = UY_g - CS_G       # lower Y for the GlobCover pixel
                    length = CS_G
                    width = CS_G
                    if LX_g < LX_W:
                        width = RX_g - LX_W
                    if RX_g > RX_W:
                        width = RX_W - LX_g
                    if UY_g > UY_W:
                        length = UY_W - LY_g
                    if LY_g < LY_W:
                        length = UY_g - LY_W

                    area[str(int(newGlobCover[gr,gc]))] += length * width
#            totalArea = sum(area.values())
#            pp = []
#            for lc in GC2GL.keys():
#                ppArrayDic[lc][r,c] = area[lc] / (CS_M*CS_M)
#                ppArrayDic[lc][r,c] = int(round((area[lc] / (CS_M*CS_M)) * 10000, 0))

# First step of merging data
#                pp.append(area[lc] / (CS_M*CS_M))  # proportions of all LC classes

            if area.values().count(max(area.values())) == 1:
#                print 'MODIS is class %d and GlobCover is class %d for pixel (%d, %d)' % (newMODIS[r,c], int(area.keys()[area.values().index(max(area.values()))]), r, c)
                if int(newMODIS[r,c]) != int(area.keys()[area.values().index(max(area.values()))]):
#                    print 'MODIS is class %d and GlobCover is class %d for pixel (%d, %d)' % (newMODIS[r,c], int(area.keys()[area.values().index(max(area.values()))]), r, c)
                    for lc in GC2GL.keys():
                        if lc == str(int(newMODIS[r,c])) or area[lc] > 0:
                            wpp = 0.0
                            for i in area.items():
                                wpp += i[1]/(CS_M*CS_M) * weight['GC'][int(lc),int(i[0])]
                            wpp += 1 * weight['MODIS'][int(lc),int(newMODIS[r,c])]
                            con500m[lc][r,c] = wpp
                        else:
                            con500m[lc][r,c] = 0.0
                else:
                    for lc in GC2GL.keys():
                        con500m[lc][r,c] = area[lc]/(CS_M*CS_M)
#                print 'proportion of class %d is changed from %f to %f' % (newMODIS[r,c], area[str(int(newMODIS[r,c]))]/MC_S*MC_S, con500m[str(int(newMODIS[r,c]))][r,c])
            else:
                print 'Warning: There are more than one dominant class for pixel (%d, %d)' % (r,c)


# standardize con500m
        totalPP = 0.0
        for lc in con500m.keys():
            totalPP += con500m[lc][r,c]
        for lc in st_con500m.keys():
            st_con500m[lc][r,c] = con500m[lc][r,c] / totalPP

print 'merging MODIS and GlobCover has done in %f mins' % ((time.time() - t)/60.0)

# export
t = time.time()

#ra.array2image(newArray, GlobCover, "/home/maoningt/LC/GlobCover/GLOBCOVER_Oregon_reclass.tif", dataType='int16')
#for lc in GC2GL.keys():
#    ra.array2image(st_con500m[lc], 'D:\\Work\\Consensus\\consensus_data\\Oregon_500m_class_%s.tif' % lc, MODIS, nodata=-9999, dataType='float32')
#ra.array2image(newGlobCover, "D:\\Work\\Consensus\\consensus_data\\GlobCover_Oregon_reclass.tif", GlobCover, dataType='int16')
#ra.array2image(newMODIS, "D:\\Work\\Consensus\\consensus_data\\MODIS_Oregon_reclass.tif", MODIS, dataType='int16')
#ra.array2image(newGLCC, "D:\\Work\\Consensus\\consensus_data\\GLCC_Oregon_reclass.tif", GLCC, dataType='int16')
#ra.array2image(newGLC2k, "D:\\Work\\Consensus\\consensus_data\\GLC2k_Oregon_reclass.tif", GLC2k, dataType='int16')

for lc in GC2GL.keys():
    ra.array2image(st_con500m[lc], '/home/maoningt/LC/Output/consensus_500m_class_%s.tif' % lc, MODIS, nodata=-9999, dataType='float32')
ra.array2image(newGlobCover, "/home/maoningt/LC/Output/globcover_reclass.tif", GlobCover, dataType='int16')
ra.array2image(newMODIS, "/home/maoningt/LC/Output/modis_reclass.tif", MODIS, dataType='int16')
ra.array2image(newGLCC, "/home/maoningt/LC/Output/glcc_reclass.tif", GLCC, dataType='int16')
ra.array2image(newGLC2k, "/home/maoningt/LC/Output/glc2k_reclass.tif", GLC2k, dataType='int16')

print 'exporting data has done in %f mins' % ((time.time() - t)/60.0)

# second step of merging data

LX_GLCC = GLCC.envelope[0][0]  # left X for GLCC
UY_GLCC = GLCC.envelope[1][1]  # upper Y for GLCC
CS_GLCC = GLCC.cellsize  # cell size for GLCC

LX_GLC2k = GLC2k.envelope[0][0]  # left X for GLC2000
UY_GLC2k = GLC2k.envelope[1][1]  # upper Y for GLC2000
CS_GLC2k = GLC2k.cellsize  # cell size for GLC2000

t = time.time()

for r in range(con1km['1'].shape[0]):
    print 'processing the Row %d/%d...' % (r, MODIS.elements.shape[0])
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
            for gr in range(minRow_GLCC,maxRow_GLCC+1):  # loop for each GlobCover pixel
                for gc in range(minCol_GLCC,maxCol_GLCC+1):
                    LX_g = LX_GLCC + CS_GLCC * gc  # left X for the GlobCover pixel
                    RX_g = LX_g + CS_GLCC       # right X for the GlobCover pixel
                    UY_g = UY_GLCC - CS_GLCC * gr  # upper Y for the GlobCover pixel
                    LY_g = UY_g - CS_GLCC       # lower Y for the GlobCover pixel
                    length = CS_GLCC
                    width = CS_GLCC
                    if LX_g < LX_W:
                        width = RX_g - LX_W
                    if RX_g > RX_W:
                        width = RX_W - LX_g
                    if UY_g > UY_W:
                        length = UY_W - LY_g
                    if LY_g < LY_W:
                        length = UY_g - LY_W

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
            for gr in range(minRow_GLC2k,maxRow_GLC2k+1):  # loop for each GlobCover pixel
                for gc in range(minCol_GLC2k,maxCol_GLC2k+1):
                    LX_g = LX_GLC2k + CS_GLC2k * gc  # left X for the GlobCover pixel
                    RX_g = LX_g + CS_GLC2k       # right X for the GlobCover pixel
                    UY_g = UY_GLC2k - CS_GLC2k * gr  # upper Y for the GlobCover pixel
                    LY_g = UY_g - CS_GLC2k       # lower Y for the GlobCover pixel
                    length = CS_GLC2k
                    width = CS_GLC2k
                    if LX_g < LX_W:
                        width = RX_g - LX_W
                    if RX_g > RX_W:
                        width = RX_W - LX_g
                    if UY_g > UY_W:
                        length = UY_W - LY_g
                    if LY_g < LY_W:
                        length = UY_g - LY_W

                    area_GLC2k[str(int(newGLC2k[gr,gc]))] += length * width

        else:
            area_GLC2k = None

# aggregate proportions of LC classes to 1 km for con500m
        wpp_con = {lc:0.0 for lc in con500m.keys()}
        for lc in con500m.keys():
            wpp_con[lc] = (con500m[lc][r*2,c*2] + con500m[lc][r*2,c*2+1] + con500m[lc][r*2+1,c*2] + con500m[lc][r*2+1,c*2+1]) / 4.0

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
                        con1km[lc][r,c] = wpp
                    else:
                        con1km[lc][r,c] = 0.0
            else:
                for lc in con1km.keys():  # if con500m agrees with either GLCC or GLC2000
                    con1km[lc][r,c] = wpp_con[lc]

        elif area_GLCC != None:  # if only GLC2k does not have data for the pixel
            majority_GLCC = int(area_GLCC.keys()[area_GLCC.values().index(max(area_GLCC.values()))])  # dominant LC class in GLCC
            if majority_con != majority_GLCC:  # if con500m disagrees with GLCC
                for lc in con1km.keys():
                    if area_GLCC[lc] > 0 or wpp_con[lc] > 0:
                        wpp = 0.0
                        for i in area_GLCC.items():
                            wpp += i[1]/(CS_M*CS_M*4) * weight['GLCC'][int(lc),int(i[0])]
                        wpp += 2 * wpp_con[lc]
                        con1km[lc][r,c] = wpp
                    else:
                        con1km[lc][r,c] = 0.0
            else:
                for lc in con1km.keys():  # if con500m agrees with GLCC
                    con1km[lc][r,c] = wpp_con[lc]

        elif area_GLC2k != None:  # if only GLCC does not have data for the pixel
            majority_GLC2k = int(area_GLC2k.keys()[area_GLC2k.values().index(max(area_GLC2k.values()))])  # dominant LC class in GLC2000
            if majority_con != majority_GLC2k:  # if con500m disagrees with GLC2000
                for lc in con1km.keys():
                    if area_GLC2k[lc] > 0 or wpp_con[lc] > 0:
                        wpp = 0.0
                        for i in area_GLC2k.items():
                            wpp += i[1]/(CS_M*CS_M*4) * weight['GLC2k'][int(lc),int(i[0])]
                        wpp += 2 * wpp_con[lc]
                        con1km[lc][r,c] = wpp
                    else:
                        con1km[lc][r,c] = 0.0
            else:
                for lc in con1km.keys():  # if con500m agrees with GLC2k
                    con1km[lc][r,c] = wpp_con[lc]

        else:
            for lc in con1km.keys():  # if both GLCC and GLC2k do not have data for the pixel
                con1km[lc][r,c] = wpp_con[lc]


# standardize con1km
        totalPP = 0.0
        for lc in con1km.keys():
            totalPP += con1km[lc][r,c]
        for lc in con1km.keys():
            con1km[lc][r,c] = con1km[lc][r,c] / totalPP

print 'merging all data has done in %f mins' % ((time.time() - t)/60.0)

# export data
#for lc in con1km.keys():
#    ra.array2image(con1km[lc], 'D:\\Work\\Consensus\\consensus_data\\Oregon_1km_class_%s.tif' % lc, MODIS, ncols=con1km[lc].shape[1], nrows=con1km[lc].shape[0], Xll=LX_M, Yll=UY_M-con1km[lc].shape[0]*CS_M*2, cellsize=CS_M*2, nodata=-9999, dataType='float32')

for lc in con1km.keys():
    ra.array2image(con1km[lc], '/home/maoningt/LC/Output/consensus_1km_class_%s.tif' % lc, MODIS, ncols=con1km[lc].shape[1], nrows=con1km[lc].shape[0], Xll=LX_M, Yll=UY_M-con1km[lc].shape[0]*CS_M*2, cellsize=CS_M*2, nodata=-9999, dataType='float32')




