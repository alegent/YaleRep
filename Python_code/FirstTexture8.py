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

# set parameters

metric = ['mean','std','max','min']
#path = "D:\\Work\\Texture\\NBCD\\"
path = "/home/maoningt/Ecocast_GLS_2005/NDVI/"
f = "p045r031_ndvi"
fref = "MOD13A1.A2000193.h09v04.005.ndvi"
#Xoff = 0
#Yoff = 0
#extent = 9000


# open Raster data
g = gdal.Open(path + f +'_modis_sin.tif')
b = g.GetRasterBand(1)
arr = b.ReadAsArray()
#arr = b.ReadAsArray(xoff=Xoff, yoff=Yoff, win_ysize=extent)

gref = gdal.Open(path + fref +'.tif')


# extract information
geo = g.GetGeoTransform()  # get the datum
proj = g.GetProjection()   # get the projection
#shape = arr.shape        # get the image dimensions - format (row, col)
NoData = b.GetNoDataValue()   # get the NoData value
xsize = b.XSize
ysize = b.YSize

arr = numpy.ma.masked_values(arr, NoData)
#arr = numpy.ma.masked_values(arr, 0)

#geo = (geo[0]+Xoff*geo[1], geo[1], geo[2], geo[3]+Yoff*geo[5], geo[4], geo[5])  # adjust for the test subset
#xsize = extent
#ysize = extent

refgeo = gref.GetGeoTransform()
refproj = gref.GetProjection()


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
        countArray[R,C] = float(win.count())/((r_end-r_start)*(c_end-c_start))
        if win.count() != 0:
            valueDic = ta.calcStat(win, metric, NoData)  # call the function
            for m in metric:
                arrayDic[m][R,C] = valueDic[m]


# set new geo
newGeo = (LX, refgeo[1], 0.0, UY, 0.0, refgeo[5])

# export arrays
driver = gdal.GetDriverByName('GTiff')

for m in metric:
    outFile = driver.Create(path + 'TextMetric/' + f + '_' + m + '.tif', NX, NY, 1, gdal.GDT_Float32)

    outFile.SetGeoTransform( newGeo ) # set the datum
    outFile.SetProjection( proj )  # set the projection


    outFile.GetRasterBand(1).WriteArray(arrayDic[m])  # write numpy array band1 as the first band of the multiTiff - this is the blue band
    stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
    outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
    outFile.GetRasterBand(1).SetNoDataValue(NoData)

    outFile = None

#outFile = driver.Create(path + 'TextMetric/' + f + '_pValid.tif', NX, NY, 1, gdal.GDT_Float32)
#outFile.SetGeoTransform( newGeo ) # set the datum
#outFile.SetProjection( refproj )  # set the projection

#outFile.GetRasterBand(1).WriteArray(countArray)  # write numpy array band1 as the first band of the multiTiff - this is the blue band
#stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
#outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
#outFile.GetRasterBand(1).SetNoDataValue(NoData)

#outFile = None
