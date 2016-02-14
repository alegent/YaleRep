#-------------------------------------------------------------------------------
# Name:        mapAlgebra.py
# Purpose:     Simple calculations among Raster instances
#
# Author:      Mao-Ning Tuanmu
#
# Created:     05/04/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#
# Notes:       The code was originally part of raster module
#-------------------------------------------------------------------------------
#!/usr/bin/env python

def mapAlgebra(function, rasterList):
    '''Applies the specified function to a list of Rasters and returns the result
       as a Raster

    following functions can be calculated:
       sum, mean, max, min, std
    rasterList should be a list of Raster instances which have the same size and location'''

    import numpy
    from spatial import raster

    newArray = rasterList[0].elements.copy()
    for r in range(rasterList[0].nrows):
        for c in range(rasterList[0].ncols):
            oneDList = []
            for rast in rasterList:
                oneDList.append(rast.elements[r,c])
            oneDArray = numpy.ma.masked_array(oneDList)
            if function == 'sum':
                newArray[r,c] = oneDArray.sum()
            elif function == 'mean':
                newArray[r,c] = oneDArray.mean()
            elif function == 'max':
                newArray[r,c] = oneDArray.max()
            elif function == 'min':
                newArray[r,c] = oneDArray.min()
            elif function == 'std':
                newArray[r,c] = oneDArray.std()
            else:
                print 'This function cannot be operated'
                return
    return raster.Raster(newArray, rasterList[0].cellsize, rasterList[0].Xll, rasterList[0].Yll, rasterList[0].nodata)


