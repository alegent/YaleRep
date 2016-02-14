#-------------------------------------------------------------------------------
# Name:        reproject.py
# Purpose:     A script for reprojecting an image using gdalwarp
#
# Author:      Mao-Ning Tuanmu
#
# Created:     05/07/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

import os
import subprocess

path = '/home/maoningt/Ecocast_GLS_2005/NDVI/'

fileList = os.listdir(path)
for filename in fileList:
    line = 'gdalwarp %s %s -t_srs "+proj=sinu +R=6371007.181 +nadgrids=@null +wktext" -tr 30 30 -dstnodata -9999.0' % (path+filename, path+filename[:-4]+'_modis_sin.tif')
    os.system(line)
