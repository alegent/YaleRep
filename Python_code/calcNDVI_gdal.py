#-------------------------------------------------------------------------------
# Name:        calcNDVI.py
# Purpose:     A script for calculating NDVI
#
# Author:      Mao-Ning Tuanmu
#
# Created:     21/05/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

from spatial import VI
from spatial import MaskImage as mi
from spatial import rasterArray as ra
from spatial import raster
import os
import time


st = time.time()
# settings
#path = "H:\\Data\\Ecocast_GLS_2005\\Venezuela\\"
path = "/home/maoningt/Ecocast_GLS_2005/Venezuela/"
#scene = "p045r029_7dt19991002"
#f3 = ".SR.b03.tif"
#f4 = ".SR.b04.tif"
#qa = scene.replace('t','x') + ".SR.QA.tif"

# import files
n = 0
fileList = os.listdir(path)
#fileList = [fileList[0]]  # testing
for filename in fileList:
    if filename.endswith('.hdf'):
        n += 1
        rastList = ra.readHDFEOS(path+filename, bands=[4,3,8])
        b4 = rastList[0]
        b3 = rastList[1]
        QA = rastList[2]
#        scene = filename.split('.')[1][:-12]
        scene = filename.split('.')[1]

#        print (time.time()-st)/60
        print "generating mask for image %s..." % n
# generate mask
#        mkQA = mi.createMask(QA.elements.astype(int), [1,2,5,8,9,11], ['1','1','0','1','1','0'])
        mkQA = mi.createMask(QA.elements.astype(int), [1,2,5], ['1','1','0'])

#        print (time.time()-st)/60
        print "calculating NDVI..."
# calculate NDVI
        ndvi = VI.NDVI(b4, b3, mk=mkQA)

#        print (time.time()-st)/60
        print "exporting files..."
# export file
        outFile = path + "NDVI/" + scene + "_ndvi.tif"
        ra.writeImage(ndvi, outFile)
        outfile = None

#        print (time.time()-st)/60
