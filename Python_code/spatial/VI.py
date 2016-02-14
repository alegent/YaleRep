# Name:        VI.py
# Purpose:     A script for generating vegetation indices
#
# Author:      Mao-Ning Tuanmu
#
# Created:     24/04/2012
# Copyright:   (c) Mao-Ning Tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import numpy
from spatial import raster

def NDVI(NIR, RED, factor=0.0001, NoData=-9999, Xll=None, Yll=None, cellSize=None, proj = '', mk=None):
    '''Calculates NDVI from arrays or Raster instances representing NIR and
        RED bands and returns an array or a Raster instance of NDVI values

        an optional mask can be applied'''


    if isinstance(NIR, numpy.ndarray):
        NIR = numpy.ma.masked_values(NIR, NoData)

    elif isinstance(NIR, raster.Raster):
        cellSize = NIR.cellsize
        Xll = NIR.Xll
        Yll = NIR.Yll
        NoData = NIR.nodata
        proj = NIR.proj
        NIR = NIR.elements

    if isinstance(RED, numpy.ndarray):
        RED = numpy.ma.masked_values(RED, NoData)
    elif isinstance(RED, raster.Raster):
        RED = RED.elements

    if mk != None:
        NIR = numpy.ma.MaskedArray(NIR, mask=mk)
        RED = numpy.ma.MaskedArray(RED, mask=mk)

    if factor != 1:
        NIR = NIR*factor
        RED = RED*factor

    NIR = numpy.where(NIR<=0, 0.0000001, NIR)
    RED = numpy.where(RED<=0, 0.0000001, RED)
    NIR = numpy.where(NIR>1, 1, NIR)
    RED = numpy.where(RED>1, 1, RED)

    ndvi = raster.Raster((NIR - RED)/(NIR + RED), cellSize, Xll, Yll, NoData, proj)


    return ndvi
