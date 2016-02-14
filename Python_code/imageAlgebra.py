#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name:        imageAlgebra.py
# Purpose:     Doing calculation between two images
#
# Author:      Mao-Ning Tuanmu
#
# Created:     07/16/2012
#
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#
# -------------------------------------------------------------------------------
# Usage:       imageAlgebra.py -op operator [-o output_image]
#                             [-of output_format] [-no noDataValue]
#                             input_image1 [input_image2]
#
# Arguments:   -op   operator
#                       available operators: "add", "sub" (substract), "mul" (multiply),
#                                           "div" (divide)

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
    print('Usage: imageAlgebra.py -op operator -o output_image')
    print('                      [-of output_format] [-no noDataValue]')
    print('                      input_image1 [input_image2]')
    print('')

# =============================================================================


# set default values
operator = None
outImage = None
fm = 'GTiff'
noData = None
inImage1 = None
inImage2 = None

# obtain arguments
arg = sys.argv
i = 1
while i < len(arg):
    if arg[i] == '-op':
        i = i + 1
        operator = arg[i]
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
        if i < len(arg):
            inImage2 = arg[i+1]
        i = i + 1
    i = i + 1

# set initial values
if inImage1 == None:
    print('Please provide at least one image.')
    Usage()
    sys.exit( 1 )
else:
    if inImage2 == None: # when only one image is provided, applying the operator to the image itself
        inImage2 = inImage1
    if outImage == None:
        outImage = operator + '_' + inImage1
    g1 = gdal.Open(inImage1)
    proj1 = g1.GetProjection()
    geo1 = g1.GetGeoTransform()

    if noData == None:
        noData = g1.GetRasterBand(1).GetNoDataValue()
    arr1 = sp.ma.masked_values(g1.ReadAsArray(), noData)

    g2 = gdal.Open(inImage2)
    proj2 = g2.GetProjection()
    geo2 = g2.GetGeoTransform()
    arr2 = sp.ma.masked_values(g2.ReadAsArray(), noData)

    # check if two images have the same projection and geotransform values
    if proj1 != proj2 or geo1 != geo2:
        print('Two images should have the same extent, resolution and projection')
        sys.exit(1)

# Applying operator (this part needs revision to better deal with data types)
if operator == "add":
    newArray = arr1 + arr2
elif operator == "sub":
    newArray = arr1.astype('int16') - arr2
elif operator == "mul":
    newArray = arr1 * arr2
elif operator == "div":
    newArray = arr1.astype('float')/arr2


# export output
if newArray.dtype == 'float32':
    eType = gdal.GDT_Float32
elif newArray.dtype == 'int32':
    eType = gdal.GDT_Int32
elif newArray.dtype == 'int16':
    eType = gdal.GDT_Int16
elif newArray.dtype == 'uint8':
    eType = gdal.GDT_Byte



driver = gdal.GetDriverByName(fm)

outFile = driver.Create(outImage, len(newArray[0]), len(newArray), 1, eType, ['COMPRESS=LZW'])
outFile.SetGeoTransform( geo1 ) # set the datum
outFile.SetProjection( proj1 )  # set the projection
outFile.GetRasterBand(1).WriteArray(newArray)  # write numpy array band1 as the first band of the multiTiff - this is the blue band
stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
outFile.GetRasterBand(1).SetNoDataValue(noData)
outFile = None




