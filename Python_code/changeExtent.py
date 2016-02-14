#-------------------------------------------------------------------------------
# Name:        changeExtent.py
# Purpose:     A script for changing the extent of images using gdalwarp
#
# Author:      Mao-Ning Tuanmu
#
# Created:     11/07/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

import os


inPath = '/home/maoningt/Ecocast_GLS_2005/NDVI/TextMetric_agg/'
outPath = '/home/maoningt/Ecocast_GLS_2005/NDVI/TextMetric_agg/Full_extent/'


fileList = os.listdir(inPath)
#fileList = [fileList[0]]
for filename in fileList:
    line = 'gdalwarp -te -10299441.6884133 4666948.99358451 -8944715.30528692 5148794.21877311 -dstnodata -9999.0 %s %s' % (inPath+filename, outPath+filename)
    os.system(line)
