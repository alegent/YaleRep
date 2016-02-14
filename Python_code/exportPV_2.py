#-------------------------------------------------------------------------------
# Name:        exportPV.py
# Purpose:     A script for exporting all pixel values of images to a csv file
#
# Author:      Mao-Ning Tuanmu
#
# Created:     09/05/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python


from osgeo import gdal
import glob

# settings

path = "/home/maoningt/Ecocast_GLS_2005/NDVI/"
scene = 'p043r030'

fileList_1 = glob.glob(path + 'TextMetric_1km/Full_extent/*' + scene + '*.tif')
fileList_2 = glob.glob(path + 'TextMetric_agg/Full_extent/*' + scene + '*.tif')
fileList = fileList_1 + fileList_2


# open Raster data

arrayList = []

for f in fileList:
    g = gdal.Open(f)
    b = g.GetRasterBand(1)
    arr = b.ReadAsArray()
    arrayList.append(arr)

NoData = b.GetNoDataValue()
NR = b.YSize
NC = b.XSize

# export pixel values as a csv file
outfile = open(path + 'Analysis/Aggregation/' + scene + '.csv', 'w')

header = ''
for f in fileList:
    header = header + f.split('/')[-1][:-4] + ','
outfile.writelines(header + '\n')

line = ''
for r in range(NR):
    for c in range(NC):
        line = ''
        for arr in arrayList:
            if arr[r,c] == NoData:
                break
            line = line + str(arr[r,c]) + ','
        if line != '':
            outfile.writelines(line + '\n')
outfile.close()

