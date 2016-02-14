#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name:        FirstTextue_NDMI.py
# Purpose:     Calculating texture measures within fixed windows
#
# Author:      Mao-Ning Tuanmu
#
# Created:     07/05/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------


from spatial import TextureAna as ta
import numpy
from osgeo import gdal
import math
import os

# set parameters

metric = ['mean','std','max','min','cv','range','skew','qt0.05','qt0.5','qt0.95']
#metric = ['mean']
#path = "D:\\Work\\Texture\\NBCD\\"
path = "/home/maoningt/textureMODIS/MaxEVI_5y_NA/"
#f = "p047r029_ndvi"
fref = "/home/maoningt/LEDAPS_1990/MOD17A3.A2005001.h09v04.055.npp.tif"
#Xoff = 0
#Yoff = 0
#extent = 9000
scale = 10000.0


# open Raster data
gref = gdal.Open(fref)
refgeo = gref.GetGeoTransform()
refproj = gref.GetProjection()
gref = None

n = 0
fileList = os.listdir(path)
for filename in fileList:
#    if filename.endswith('.tif'):
    if filename == 'MaxEVI_5y_NA_sin.tif':
        print 'processing image %d...' % n
        g = gdal.Open(path + filename)
        proj = g.GetProjection()
        arr = g.ReadAsArray()
        geo = g.GetGeoTransform()

        NoData = -9999
        xsize = g.RasterXSize
        ysize = g.RasterYSize
        g = None

        arr = numpy.ma.masked_values(arr, NoData) / scale

# define the extent of the grid
        LX = (math.ceil((geo[0]-refgeo[0])/refgeo[1])) * refgeo[1] + refgeo[0]
        NX = int(((math.floor(((geo[0]+geo[1]*xsize)-refgeo[0])/refgeo[1])) - (math.ceil((geo[0]-refgeo[0])/refgeo[1]))))

        UY = (math.ceil((geo[3]-refgeo[3])/refgeo[5])) * refgeo[5] + refgeo[3]
        NY = int(((math.floor(((geo[3]+geo[5]*ysize)-refgeo[3])/refgeo[5])) - (math.ceil((geo[3]-refgeo[3])/refgeo[5]))))


# create new arrays
        arrayDic = {}
        for m in metric:
            newArray = numpy.empty((NY,NX))
            newArray.fill(NoData)
            arrayDic[m] = newArray
        countArray = numpy.zeros((NY,NX))


# calculate texture metrics
        for R in range(NY):
            uy = UY + R*refgeo[5]
            ly = uy + refgeo[5]
            r_start = int(round((uy-geo[3])/geo[5]))
            r_end = int(round((ly-geo[3])/geo[5]))

            for C in range(NX):
                lx = LX + C*refgeo[1]
                rx = lx + refgeo[1]
                c_start = int(round((lx-geo[0])/geo[1]))
                c_end = int(round((rx-geo[0])/geo[1]))

                win = arr[r_start:r_end,c_start:c_end]
#                countArray[R,C] = float(win.count())/((r_end-r_start)*(c_end-c_start))
                if win.count() != 0:
                    valueDic = ta.calcStat(win, metric, NoData)  # call the function
                    for m in metric:
                        arrayDic[m][R,C] = valueDic[m]


# set new geo
        newGeo = (LX, refgeo[1], 0.0, UY, 0.0, refgeo[5])

# export arrays
        driver = gdal.GetDriverByName('GTiff')

        for m in metric:
            outFile = driver.Create(path + filename + '_' + m + '.tif', NX, NY, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])

            outFile.SetGeoTransform( newGeo ) # set the datum
            outFile.SetProjection( proj )  # set the projection


            outFile.GetRasterBand(1).WriteArray(arrayDic[m])  # write numpy array band1 as the first band of the multiTiff - this is the blue band
            stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
            outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
            outFile.GetRasterBand(1).SetNoDataValue(NoData)

            outFile = None

#        outFile = driver.Create(path + filename + '_pValid.tif', NX, NY, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])
#        outFile.SetGeoTransform( newGeo ) # set the datum
#        outFile.SetProjection( refproj )  # set the projection

#        outFile.GetRasterBand(1).WriteArray(countArray)  # write numpy array band1 as the first band of the multiTiff - this is the blue band
#        stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
#        outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
#        outFile.GetRasterBand(1).SetNoDataValue(NoData)

#        outFile = None

        n += 1
