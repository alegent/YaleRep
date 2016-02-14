#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name:        recode.py
# Purpose:     changing pixel values based on a condition
#
# Author:      Mao-Ning Tuanmu
#
# Created:     02/20/2014
#
# Copyright:   (c) tuanmu 2014
# Licence:     <your licence>
#
# -------------------------------------------------------------------------------
# Usage:       recode.py -con condition -tv true_value
#                        [-fv false_value] -o output_image
#                        [-of output_format] [-no noDataValue]
#                        input_image1
#
# Arguments:   -con condition to be tested
#                       example conditions: "==1", "<10", ">=3.5"
#              -tv  the value assigned to a pixel if the condition is true
#              -fv  the value assigned to a pixel if the condition is false
#                       default: pixel value in the input image
#              -o   output image
#              -f   image format
#                       default: GTiff
#              -no  NoData value
#
#
# -------------------------------------------------------------------------------



# import required modules
import scipy as sp
import scipy.stats as stats
from osgeo import gdal
import math
import sys



# =============================================================================
def Usage():
    print('Usage: recode.py -con condition -tv true_value')
    print('                 [-fv false_value] -o output_image')
    print('                 [-of output_format] [-no noDataValue]')
    print('                 input_image1')
    print('')

# =============================================================================


# set default values
condition = None
tValue = None
fValue = None
outImage = None
fm = 'GTiff'
noData = None
inImage1 = None


# obtain arguments
arg = sys.argv
i = 1
while i < len(arg):
    if arg[i] == '-con':
        i = i + 1
        con = arg[i]
    elif arg[i] == '-tv':
        i = i + 1
        tValue = arg[i]
    elif arg[i] == '-fv':
        i = i + 1
        fValue = arg[i]
    elif arg[i] == '-o':
        i = i + 1
        outImage = arg[i]
    elif arg[i] == '-of':
        i = i + 1
        fm = arg[i]
    elif arg[i] == '-no':
        i = i + 1
        noData = float(arg[i])
    elif arg[i][:1] == '-':
        print('Unrecognised command option: %s' % arg)
        Usage()
        sys.exit( 1 )
    else:
        inImage1 = arg[i]
    i = i + 1

# set initial values
if inImage1 == None:
    print('Please provide at least one image.')
    Usage()
    sys.exit( 1 )
else:
    g = gdal.Open(inImage1)
    proj = g.GetProjection()
    geo = g.GetGeoTransform()

    if noData == None:
        noData = g.GetRasterBand(1).GetNoDataValue()
    arr = sp.ma.masked_values(g.ReadAsArray(), noData)
    nX = g.RasterXSize
    nY = g.RasterYSize


# Test the condition and assign values
trueArray = int(tValue)

if fValue == None:
    falseArray = arr.copy()
else:
    falseArray = int(fValue)

newArray = sp.where(eval('arr'+con), trueArray, falseArray)


# export output (Note: need better handling of data type)

driver = gdal.GetDriverByName(fm)

outFile = driver.Create(outImage, len(newArray[0]), len(newArray), 1, gdal.GDT_Byte, ['COMPRESS=LZW'])
outFile.SetGeoTransform( geo ) # set the datum
outFile.SetProjection( proj )  # set the projection
outFile.GetRasterBand(1).WriteArray(newArray)  # write numpy array band1 as the first band of the multiTiff - this is the blue band
stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
outFile.GetRasterBand(1).SetNoDataValue(noData)
outFile = None




