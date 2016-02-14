#-------------------------------------------------------------------------------
# Name:        openRaster.py
# Purpose:     A function for opening a raster image using the GDAL library
#
# Author:      Mao-Ning Tuanmu
#
# Created:     05/04/2012
# Copyright:   (c) Mao-Ning Tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

def openRaster(filename, band=1, scale=None, NoData=-9999):
    '''Opens a raster image whose format is supported by GDAL.

    Loads it in as a nested list; the first
    element in the list is a dictionary with image information,
    while the second element contains a Raster instance.
    Result is a raster with northern values at the top.

    Please provide a filename with a complete directory'''

    import gdal
#    import numpy
    from spatial import raster

    f = gdal.Open(filename)

    if f is None:
        print gdal.GetLastErrorMsg()

    else:
        b = f.GetRasterBand(band)
        info = b.GetMetadata()
        info['dataType'] = gdal.GetDataTypeName(b.DataType)
        info['projection'] = f.GetProjection()
        info['ncol'] = b.XSize
        info['nrow'] = b.YSize
        ggt = f.GetGeoTransform()
        info['cellsize'] = float(ggt[1])
        info['Xll'] = float(ggt[0])
        info['Yll'] = float(ggt[3] + ggt[5]*f.RasterYSize)
        if b.GetNoDataValue() != None:
            info['nodata'] = b.GetNoDataValue()
        else:
            info['nodata'] = float(NoData)
        if scale is None:
            info['scale'] = b.GetScale()
        else:
            info['scale'] = float(scale)


        d = b.ReadAsArray()
        r = raster.Raster(d, cellsize=info['cellsize'], Xll=info['Xll'], Yll=info['Yll'], nodata=info['nodata'])

        return [info, r]
