#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name:        Aggregation.py
# Purpose:     Calculating texture measures within fixed windows
#
# Author:      Mao-Ning Tuanmu
#
# Created:     07/05/2012
# Modified:    05/08/2013 - Make it reusable
#              02/05/2015 - Add flag "scale"
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#
# -------------------------------------------------------------------------------
# Usage:       Aggregation.py [-m "metric_name [metric_name...]"] [-o output_folder]
#                             [-rxy ref_x ref_y] [-pn n_pixel_x n_pixel_y]
#                             [-ps pixelsize_x pixelsize_y] [-ref ref_image]
#                             [-f output_format] [-no noDataValue] [-cut Min Max]
#                             [-scale Min Max] [-qa] input_image
#
# Arguments:   -m   metrics to calculate
#                       available metrics: mean, std, max, min, cv, range, skew, sum,
#                                       qt0.XX, unique, shannon, simpson, pielou,
#                                       all (default)
#              -o   output folder (full directory)
#                       one image for each metric will be created in the output folder
#                       default: the same folder where the input image locates
#              -rxy reference point
#                       x and y coordinates used as a reference point
#                       default: x and y in the upper left corner of the input image
#              -pn  times larger than the pixel size of the input image
#                       default: 3 3
#              -ps  pixel size in the unit of the input image
#                       override the argument -pn
#              -ref reference image (full directory)
#                       reference point and pixel size will be obtained from
#                       the reference image and override the arguments -rxy -pn -ps
#              -f   image format
#                       default: GTiff
#              -no  NoData value
#                       default: -9999
#              -qa  output quality layer (# of non-Null pixels)
#              -cut cut pixel values
#                       values smaller than the given Min will be converted to Min
#                       values larger than the given Max will be converted to Max
#              -scale rescale pixel values by multiplying the given value
#                       rescaling will be done after the cutting (see above)
#
# -------------------------------------------------------------------------------



# import required modules
import scipy as sp
import scipy.stats as stats
from osgeo import gdal
import math
import sys

# define some functions
def Stat(Array, stat, NoData=-9999):
    '''Calculates a statistic from an array and returns the statistic.

        stat='mean': mean
        stat='sum': sum
        stat='max': maximum
        stat='min': minimum
        stat='std': standard deviation
        stat='cv': coefficient of variation
        stat='range': range (maximum-minimum)
        stat='skew': skewness
        stat='kurtosis': kurtosis
        stat='qt0.XX': 0.XX quantile (e.g., 0.95)
        stat='unique': number of unique values
        stat='shannon': Shannon Diversity Index
        stat='simpson': Simpson Diversity Index
        stat='pielou': Pielou Evenness Index
        '''

    if type(Array) is not sp.ma.core.MaskedArray:
        Array = sp.ma.masked_values(Array, NoData)

    if stat == 'mean' or stat == 'sum' or stat == 'max' or stat == 'min' or stat == 'std':
        value = eval('Array.' + stat + '()')
    elif stat == 'cv':
        if Array.mean() != 0:
            value = Array.std() / Array.mean()
        else:
            value = NoData
    elif stat == 'range':
        value = Array.max() - Array.min()
    elif stat == 'skew':
        value = float(stats.mstats.skew(Array, axis=None).data)
    elif stat == 'kurtosis':
        value = float(stats.mstats.kurtosis(Array, axis=None))
    elif stat.startswith('qt'):
        value = float(stats.mstats.mquantiles(Array, [float(stat[2:])]))
    elif stat == 'unique':
        s = set(Array.flatten())
        value = len(s)
        if None in s:
            value = value-1
    elif stat == 'shannon':
        allElem = Array.flatten().tolist()
        uniElem = set(allElem)
        if None in uniElem:
            uniElem.remove(None)
        if len(uniElem) == 0:
            value = NoData
        elif len(uniElem) == 1:
            value = 0
        else:
            fElem = [allElem.count(v) for v in uniElem]
            nElem = sum(fElem)
            pElem = [f/float(nElem) for f in fElem]
            hElem = [p*sp.log(p) for p in pElem]
            value = sum(hElem) * (-1)

    elif stat == 'simpson':
        allElem = Array.flatten().tolist()
        uniElem = set(allElem)
        if None in uniElem:
            uniElem.remove(None)
        if len(uniElem) == 0:
            value = NoData
        elif len(uniElem) == 1:
            value = 0
        else:
            fElem = [allElem.count(v) for v in uniElem]
            nElem = sum(fElem)
            pElem = [f/float(nElem) for f in fElem]
            lElem = [p*p for p in pElem]
            value = 1 - sum(lElem)

    elif stat == 'pielou':
        allElem = Array.flatten().tolist()
        uniElem = set(allElem)
        if None in uniElem:
            uniElem.remove(None)
        if len(uniElem) == 0:
            value = NoData
        elif len(uniElem) == 1:
            value = 0
        else:
            fElem = [allElem.count(v) for v in uniElem]
            nElem = sum(fElem)
            pElem = [f/float(nElem) for f in fElem]
            hElem = [p*sp.log(p) for p in pElem]
            H = sum(hElem) * (-1)
            value = H/sp.log(len(uniElem))

    return value


def calcStats(Array, statList, NoData=-9999, cutoff=None, scale=None):
    '''Calculates multiple statistics from an array and returns
        the statistics as a dictionary

        statList can be a subset of ['mean','sum','max','min','std','cv','range','skew','qt0.05','count'...]'''

    valueDic = {}
    if cutoff != None:
        sp.place(Array, Array < cutoff[0], cutoff[0])
        sp.place(Array, Array > cutoff[1], cutoff[1])
    if scale != None:
        Min = cutoff[0]
        Max = cutoff[1]
        Range = Max - Min
        sMin = scale[0]
        sMax = scale[1]
        sRange = sMax - sMin
        sArray = ((Array - Min)*(sRange/Range)+sMin).round()
    else:
        sArray=Array
    for stat in statList:
        valueDic[stat] = Stat(sArray, stat, NoData)

    return valueDic


# =============================================================================
def Usage():
    print('Usage: aggregation.py [-m "metric_name [metric_name...]"] [-o output_folder]')
    print('                      [-rxy ref_x ref_y] [-pn n_pixel_x n_pixel_y]')
    print('                      [-ps pixelsize_x pixelsize_y] [-ref ref_image]')
    print('                      [-f output_format] [-no noDataValue] [-qa]')
    print('                      [-cut MinMax] [-scale sMinMax] input_image')
    print('                      [--help-general]')
    print('')
    print('Metrics: mean, std (standard deviation), max, min, cv (coefficient of variation)')
    print('         range, skew, kurosis, unique (number of unique values)')
    print('         shannon (Shannon diversity index), simpson (Simpson diversity index)')
    print('         pielou (Pielou evenness index), quantile (e.g. qt0.05: 5th quantile, qt0.9: 90th)')
    print('')

# =============================================================================


# set default values
metric = ['mean','std','max','min','cv','range','skew','qt0.05','qt0.5','qt0.95','unique']
outPath = None
refX = None
refY = None
winX = 3
winY = 3
pSizeX = None
pSizeY = None
refImg = None
fm = 'GTiff'
noData = None
inFile = None
MinMax = None
sMinMax = None
outputQA = False
mode = 1

# obtain arguments
arg = sys.argv
i = 1
while i < len(arg):
    if arg[i] == '-m':
        i = i + 1
        if arg[i] != 'all':
            metric = arg[i].split()
    elif arg[i] == '-o':
        i = i + 1
        outPath = arg[i]

    elif arg[i] == '-rxy':
        refX = float(arg[i+1])
        refY = float(arg[i+2])
        i = i + 2
    elif arg[i] == '-pn':
        winX = int(arg[i+1])
        winY = int(arg[i+2])
        i = i + 2
    elif arg[1] == '-ps':
        pSizeX = float(arg[i+1])
        pSizeY = -1 * abs(float(arg[i+2]))
        i = i + 2
    elif arg[i] == '-ref':
        i = i + 1
        refImg = arg[i]
    elif arg[i] == '-f':
        i = i + 1
        fm = arg[i]
    elif arg[i] == '-no':
        i = i + 1
        noData = float(arg[i])
    elif arg[i] == '-cut':
        MinMax = [float(arg[i+1]), float(arg[i+2])]
        i = i + 2
    elif arg[i] == '-scale':
        sMinMax = [float(arg[i+1]), float(arg[i+2])]
        i = i + 2
    elif arg[i] == '-qa':
        outputQA = True
    elif arg[i][:1] == '-':
        print('Unrecognised command option: %s' % arg)
        Usage()
        sys.exit( 1 )
    else:
        inFile = arg[i]
    i = i + 1

# set initial values
if inFile == None:
    print('No input file provided.')
    Usage()
    sys.exit( 1 )
else:
    g = gdal.Open(inFile)
    proj = g.GetProjection()
    geo = g.GetGeoTransform()
    if noData == None:
        noData = g.GetRasterBand(1).GetNoDataValue()
    arr = sp.ma.masked_values(g.ReadAsArray(), noData)
    nX = g.RasterXSize
    nY = g.RasterYSize
    g = None
    if inFile.rfind('/') < 0:
        filename = inFile[inFile.rfind('\\')+1:]
    else:
        filename = inFile[inFile.rfind('/')+1:]

if outPath == None:
    outPath = inFile[:inFile.rfind('/')+1]
    if outPath == '':
        outPath = inFile[:inFile.rfind('\\')+1]
elif '/' in outPath:
    outPath = outPath + '/'
elif '\\' in outPath:
    outPath = outPath + '\\'

if refImg != None:
    gref = gdal.Open(refImg)
    refgeo = gref.GetGeoTransform()
    refX = refgeo[0]
    refY = refgeo[3]
    pSizeX = refgeo[1]
    pSizeY = refgeo[5]
    gref = None
elif refX == None or refY == None:
    refX = geo[0]
    refY = geo[3]
    if pSizeX == None or pSizeY == None:
        mode = 2
        pSizeX = geo[1] * winX
        pSizeY = geo[5] * winY
elif pSizeX == None or pSizeY == None:
    pSizeX = geo[1] * winX
    pSizeY = geo[5] * winY


# define the extent of the grid
if mode == 1:
    LX = (math.ceil((geo[0]-refX)/pSizeX)) * pSizeX + refX
    NX = int(((math.floor(((geo[0]+geo[1]*nX)-refX)/pSizeX)) - (math.ceil((geo[0]-refX)/pSizeX))))
    UY = (math.ceil((geo[3]-refY)/pSizeY)) * pSizeY + refY
    NY = int(((math.floor(((geo[3]+geo[5]*nY)-refY)/pSizeY)) - (math.ceil((geo[3]-refY)/pSizeY))))
else:
    LX = geo[0]
    NX = nX / winX
    UY = geo[3]
    NY = nY / winY

# create new arrays
arrayDic = {}
for m in metric:
    newArray = sp.empty((NY,NX))
    newArray.fill(noData)
    arrayDic[m] = newArray
if outputQA:
    countArray = sp.zeros((NY,NX))

# calculate texture metrics
#toolbar_width = 40
#sys.stdout.write("[%s]" % (" " * toolbar_width))
#sys.stdout.flush()
#sys.stdout.write("\b" * (toolbar_width+1))

if mode == 1:
    for R in xrange(NY):
        uy = UY + R*pSizeY
        ly = uy + pSizeY
        r_start = int(round((uy-geo[3])/geo[5]))
        r_end = int(round((ly-geo[3])/geo[5]))

        for C in xrange(NX):
            lx = LX + C*pSizeX
            rx = lx + pSizeX
            c_start = int(round((lx-geo[0])/geo[1]))
            c_end = int(round((rx-geo[0])/geo[1]))

            win = arr[r_start:r_end,c_start:c_end]
            if outputQA:
                countArray[R,C] = float(win.count())/((r_end-r_start)*(c_end-c_start))
            if win.count() != 0:
                valueDic = calcStats(win, metric, noData, MinMax, sMinMax)  # call the function
                for m in metric:
                    arrayDic[m][R,C] = valueDic[m]

#        if (R+1) % (NY/toolbar_width) == 0:
#            sys.stdout.write('-')
#            sys.stdout.flush()

else:
    for R in xrange(NY):
        for C in xrange(NX):
            win = arr[R*winY:(R+1)*winY, C*winX:(C+1)*winX]
            if outputQA:
                countArray[R,C] = float(win.count()) / (winX*winY)
            if win.count() != 0:
                valueDic = calcStats(win, metric, noData, MinMax)  # call the function
                for m in metric:
                    arrayDic[m][R,C] = valueDic[m]

#        if (R+1) % (NY/toolbar_width) == 0:
#            sys.stdout.write('-')
#            sys.stdout.flush()

#sys.stdout.write('\n')



# set new geo
newGeo = (LX, pSizeX, 0.0, UY, 0.0, pSizeY)


# export arrays
driver = gdal.GetDriverByName(fm)

for m in metric:
    outFile = driver.Create(outPath + m + '_' + filename, NX, NY, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])
    outFile.SetGeoTransform( newGeo ) # set the datum
    outFile.SetProjection( proj )  # set the projection
    outFile.GetRasterBand(1).WriteArray(arrayDic[m])  # write numpy array band1 as the first band of the multiTiff - this is the blue band
    stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
    outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
    outFile.GetRasterBand(1).SetNoDataValue(noData)
    outFile = None

if outputQA:
    outFile = driver.Create(outPath + 'pValid_' + filename, NX, NY, 1, gdal.GDT_Float32, ['COMPRESS=LZW'])
    outFile.SetGeoTransform( newGeo ) # set the datum
    outFile.SetProjection( proj )  # set the projection
    outFile.GetRasterBand(1).WriteArray(countArray)  # write numpy array band1 as the first band of the multiTiff - this is the blue band
    stat = outFile.GetRasterBand(1).GetStatistics(1,1)  # get the band statistics (min, max, mean, standard deviation)
    outFile.GetRasterBand(1).SetStatistics(stat[0], stat[1], stat[2], stat[3])  # set the stats we just got to the band
    outFile.GetRasterBand(1).SetNoDataValue(noData)
    outFile = None


