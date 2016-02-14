#-------------------------------------------------------------------------------
# Name:        Mosaic.py
# Purpose:     A script for mosaicking images based on another sets of images
#
# Author:      Mao-Ning Tuanmu
#
# Created:     12/07/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

import numpy
from osgeo import gdal
import glob
from spatial import rasterArray as ra

inPath = '/home/maoningt/Ecocast_GLS_2005/NDVI/TextMetric/Full_extent/'
outPath = '/home/maoningt/Ecocast_GLS_2005/NDVI/TextMetric/Mosaic/'

#inPath = 'D:\\Work\\Texture\\Ecocast_GLS_2005\\NDVI\\TextMetric\\Full_extent\\'
#outPath = 'D:\\Work\\Texture\\Ecocast_GLS_2005\\NDVI\\TextMetric\\Mosaic\\'

mList = ['pValid','ASM','CON','COR','DIS','ENT','GLCMMAX','GLCMMEAN','GLCMVAR','HOM','mean','std','max','min']


fileList = glob.glob(inPath + '*.tif')
fileDic = {}
arrDic = {}
for m in mList:
    fileDic[m] = [item for item in fileList if m in item]
    arrDic[m] = []
    for f in fileDic[m]:
        arrDic[m].append(ra.readImage(f)[0])

# create new arrays
newArrayDic = {}
for m in mList:
    newArray = numpy.empty([arrDic[mList[0]][0].nrows, arrDic[mList[0]][0].ncols])
    newArray.fill(-9999.0)
    newArrayDic[m] = newArray

nImage = numpy.empty([arrDic[mList[0]][0].nrows, arrDic[mList[0]][0].ncols])
nImage.fill(-9999.0)

for r in range(newArrayDic['pValid'].shape[0]):
    print 'processing row %s of %s...' % (r, newArrayDic['pValid'].shape[0]-1)
    for c in range(newArrayDic['pValid'].shape[1]):
        QA = []
        for i in range(24):
            QA.append(arrDic['pValid'][i].elements.data[r,c])
        maxQA = max(QA)
        if maxQA > 0:
            newArrayDic['pValid'][r,c] = maxQA
            for m in mList[1:]:
                V = []
                for j in range(24):
                    if QA[j] == maxQA:
                        V.append(arrDic[m][j].elements.data[r,c])
                newArrayDic[m][r,c] = float(sum(V)) / len(V)
            nImage[r,c] = len(V)

for m in mList:
    ra.array2image(newArrayDic[m], arrDic[m][0], outPath+'Oregon_'+m+'.tif')

ra.array2image(nImage, arrDic['pValid'][0], outPath+'Oregon_nImage.tif')