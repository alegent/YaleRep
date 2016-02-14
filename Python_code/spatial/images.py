#-------------------------------------------------------------------------------
# Name:        images.py
# Purpose:     A module containing functions for precessing images
#
# Author:      Mao-Ning Tuanmu
#
# Created:     14/09/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
# Versions:    ver.0.1 (9/14/2012) - reproject
#-------------------------------------------------------------------------------
#!/usr/bin/env python

def reproject (image, proj4, cellSize=None, method="NN"):
    """
    A function to reproject and (optionally) resample a GDAL dataset.

    image: the original GDAL dataset
    proj4: the Proj4 format of the projection of the dataset
    cellSize: the cell size of the reprojected dataset
        if cellSize=None, the cell size will be calculated based on the dimention (# of rows and columns) of the original dataset
    method: a string indicating the resampling algorithm
        'NN': nearest neighbor (default)
        'BL': bilinear
        'CU': cubic
        'CS': cubic spline
    """
    from osgeo import osr, gdal

    proj_from = osr.SpatialReference()
    proj_from.ImportFromWkt(image.GetProjection())
    proj_to = osr.SpatialReference()
    proj_to.ImportFromProj4(proj4)
    tx = osr.CoordinateTransformation(proj_from, proj_to)

    geo = image.GetGeoTransform()
    x_size = image.RasterXSize
    y_size = image.RasterYSize

    (ulx, uly, ulz) = tx.TransformPoint(geo[0], geo[3])
    (lrx, lry, lrz) = tx.TransformPoint(geo[0] + geo[1]*x_size, geo[3] + geo[5]*y_size)

    if cellSize == None:
        cellSize = (lrx - ulx)/x_size

    mem_drv = gdal.GetDriverByName('MEM')
    dest = mem_drv.Create('', int((lrx - ulx)/cellSize), int((uly - lry)/cellSize), 1, gdal.GDT_Float32)
    new_geo = (ulx, cellSize, geo[2], uly, geo[4], -cellSize)
    dest.SetGeoTransform(new_geo)
    dest.SetProjection(proj_to.ExportToWkt())

    if method == 'NN':
        gra = gdal.GRA_NearestNeighbour
    elif method == 'BL':
        gra = gdal.GRA_Bilinear
    elif method == 'CU':
        gra = gdal.GRA_Cubic
    elif method == 'CS':
        gra = gdal.GRA_CubicSpline

    res = gdal.ReprojectImage(image, dest, proj_from.ExportToWkt(), proj_to.ExportToWkt(), gra)

    return dest

