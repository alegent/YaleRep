# Name:        rasterArray.py
# Purpose:     A script for reading raster images as Raster instances and writing
#               Raster instances to raster images
#
# Author:      Mao-Ning Tuanmu
#
# Created:     24/04/2012
# Copyright:   (c) Mao-Ning Tuanmu 2012
# Licence:     <your licence>
#
# Version:
#              v.1.0 (5/2012) - integrates with the Raster class defined in raster.py
#                                  incorporates the functions in asciiraster.py
#              v.1.1 (6/2012) - adds functions for reading/writing HDF4 images
#                                   and HDF-EOS images
#                               modifies the functions to read mulitple bands at once
#-------------------------------------------------------------------------------

from osgeo import gdal
from spatial import raster
from numpy import ma
import sys



def readImage(inFile, bands=[1], Xoff=0, Yoff=0, nx=None, ny=None):
    '''Reads bands of a raster image using GDAL and returns a Raster

        inFile: string; the full path of the input file
        Xoff and Yoff: integer; the offsets of column and row
        nx and ny: integer; the number of column and row to be read'''

    g = gdal.Open(inFile)

    if g is None:
        print gdal.GetLastErrorMsg()
        sys.exit(1)

    else:
        rastList = []
        for band in bands:
            b = g.GetRasterBand(band)
            Array = b.ReadAsArray(xoff=Xoff, yoff=Yoff, win_xsize=nx, win_ysize=ny)
            scale = b.GetScale()
            offset = b.GetOffset()
            NoData = b.GetNoDataValue()

            if scale != 1.0 or offset != 0.0:
                Array = ma.masked_values(Array, NoData)
                Array = Array.astype('float32')
                Array = scale * (Array - offset)

            geo = g.GetGeoTransform()
            if geo[1] != -geo[5]:
                print 'warning: pixels are not squared (%s, %s)\nCell size is assigned as %s' % (geo[1], -geo[5], geo[1])
            cellSize = geo[1]

            Xll = geo[0] + Xoff*geo[1] + Yoff*geo[2]
            Yll = geo[3] + Xoff*geo[4] + (Yoff+Array.shape[0])*geo[5]


            proj = g.GetProjection()

            rastList.append(raster.Raster(Array,cellSize, Xll, Yll, NoData, proj))

        g = None

        return rastList


def writeImage(Rast, outFile, dr='GTiff', dataType='float32'):
    '''Writes a raster image from Raster'''

    driver = gdal.GetDriverByName(dr)
    output = driver.Create(outFile, Rast.ncols, Rast.nrows,\
                           1, gdal.GetDataTypeByName(dataType))

    geo = [Rast.Xll, Rast.cellsize, 0, Rast.Yll+Rast.cellsize*Rast.nrows, 0, Rast.cellsize*(-1)]

    output.SetGeoTransform(geo)
    output.SetProjection(Rast.proj)

    output.GetRasterBand(1).WriteArray(Rast.elements.data)
    output.GetRasterBand(1).SetNoDataValue(Rast.nodata)
#    output.GetRasterBand(1).SetStatistics(Rast.stat['min'], Rast.stat['max'], Rast.stat['mean'], Rast.stat['std'])

    output = None

def array2image(Array, outFile, Rast=None, ncols=None, nrows=None, Xll=None, Yll=None, cellsize=None, nodata=None, proj=None, dr='GTiff', dataType='float32'):
    '''Writes an array to an image with or without a raster as a reference'''

    driver = gdal.GetDriverByName(dr)
    if Rast != None:
        if ncols == None:
            ncols = Rast.ncols
        if nrows == None:
            nrows = Rast.nrows
        if Xll == None:
            Xll = Rast.Xll
        if Yll == None:
            Yll = Rast.Yll
        if cellsize == None:
            cellsize = Rast.cellsize
        if nodata == None:
            nodata = Rast.nodata
        if proj == None:
            proj = Rast.proj

    output = driver.Create(outFile, ncols, nrows, 1, gdal.GetDataTypeByName(dataType))

    geo = [Xll, cellsize, 0, Yll+cellsize*nrows, 0, cellsize*(-1)]

    output.SetGeoTransform(geo)
    output.SetProjection(proj)

    output.GetRasterBand(1).WriteArray(Array)
    output.GetRasterBand(1).SetNoDataValue(nodata)

#    output.GetRasterBand(1).SetStatistics(Rast.stat['min'], Rast.stat['max'], Rast.stat['mean'], Rast.stat['std'])

    output = None


def readHDFEOS(inFile, bands=[1], Xoff=0, Yoff=0, nx=None, ny=None):
    '''Reads HDF-EOS files as Raster instances'''


    hdf = gdal.Open(inFile)

    if hdf is None:
        print gdal.GetLastErrorMsg()
        sys.exit(1)

    else:
        rastList = []
        for band in bands:
            g = gdal.Open(hdf.GetSubDatasets()[band-1][0])
            b = g.GetRasterBand(1)
            Array = b.ReadAsArray(xoff=Xoff, yoff=Yoff, win_xsize=nx, win_ysize=ny)
            scale = b.GetScale()
            offset = b.GetOffset()
            NoData = b.GetNoDataValue()

            if scale != None or offset != None:
                Array = ma.masked_values(Array, NoData)
                Array = Array.astype('float32')
                Array = scale * (Array - offset)

            geo = g.GetGeoTransform()

            if geo[1] != -geo[5]:
                print 'warning: pixels are not squared (%s, %s)\nCell size is assigned as %s' % (geo[1], -geo[5], geo[1])
            cellSize = geo[1]

            Xll = geo[0] + Xoff*geo[1] + Yoff*geo[2]
            Yll = geo[3] + Xoff*geo[4] + (Yoff+Array.shape[0])*geo[5]

            proj = g.GetProjection()

            rastList.append(raster.Raster(Array,cellSize, Xll, Yll, NoData, proj))

        g = None
        hdf = None

        return rastList



def readHDF4(inFile, bands=[1]):
    '''Reads HDF4 images as Raster instances using pyhdf'''

    from pyhdf.SD import SD, SDC

    g = SD(inFile, mode=SDC.READ)
    cellSize = g.attributes()['PixelSize']


    m = g.attributes()['StructMetadata.0']
    start = m.find('(', m.find('UpperLeft'))+1
    Xll = float(m[start:m.find(',',start)])

    start = m.find(',', m.find('LowerRight'))+1
    Yll = float(m[start:m.find(')',start)])

    rastList=[]
    for band in bands:
        b = g.select(band-1)

        attribs = b.attributes()
        scale = 1.0
        offset = 0.0

        if attribs.has_key('scale_factor'):
            scale = attribs['scale_factor']
        if attribs.has_key('add_offset'):
            offset = attribs['add_offset']

        NoData = b.getfillvalue()
        arr = ma.masked_values(b.get(), NoData)
        arr = arr.astype('float32')
        arr = scale*(arr - offset)

        b.endaccess()

        rastList.append(raster.Raster(arr, cellSize, Xll, Yll, NoData))

    g.end()

    return rastList
#    return arr


def openAscii(filename):
    '''Opens an ESRI ASCII file.

    Loads it in as a nested list; the first
    element in the list is a dictionary with header
    information (6 tuples), while the second
    element contains the nested rows of values. Result
    is a raster with northern values at the top.'''

    header = {}
    i = 1
    f=open(filename, 'r')
    while i < 7:
        line = f.readline().split()
        header[line[0]] = float(line[1])
        i = i + 1
    raster = []
    dataLine = f.readline()
    while dataLine != '':
        row = []
        dataLine = dataLine.split()
        for cell in dataLine:
            row.append(float(cell))
        raster.append(row)
        dataLine = f.readline()

    return [header,raster]


def ascii2Raster(inFile):
    '''Converts an ESRI ASCII file to a Raster class'''

    asc = openAscii(inFile)

    Rast = raster.Raster(asc[1], asc[0]['cellsize'], asc[0]['xllcorner'], \
        asc[0]['yllcorner'], asc[0]['NODATA_value'])

    return Rast


def Raster2ascii(Rast, outFile, header=True):
    '''Writes an ESRI ascii raster file from a Raster instance'''

    outfile = open(outFile, 'w')

    if header:
        outfile.writelines('ncols %d\n' % Rast.ncols)
        outfile.writelines('nrows %d\n' % Rast.nrows)
        outfile.writelines('xllcorner %f\n' % Rast.Xll)
        outfile.writelines('yllcorner %f\n' % Rast.Yll)
        outfile.writelines('cellsize %f\n' % Rast.cellsize)
        outfile.writelines('NODATA_value %f\n' % Rast.nodata)

    for row in Rast.elements.data:
        strList = [str(value) for value in row]
        line = ' '.join(strList)
        outfile.writelines(line + '\n')

    outfile.close()


def array2ascii(Array, outFile):
    ''' Writes a headerless ascii file from an array'''

    outfile = open(outFile, 'w')

    for row in Array:
        strList = [str(value) for value in row]
        line = ' '.join(strList)
        outfile.writelines(line + '\n')

    outfile.close()



# this function can be removed...
def maToDic(Array, geo=None, proj=None, xSize=None, ySize=None, NoData=None, ref=None):
    '''Generates an array dictionary from a masked array and sets all masked
        pixels as the NoData value

        ref is a array dictionary
        if ref is provided, the information from ref will be applied to the output'''

    if ref != None:
        geo = ref['geo']
        proj = ref['proj']
        xSize = ref['xSize']
        ySize = ref['ySize']
        NoData = ref['NoData']
        cellSize = geo[1]

    for r in range(Array.shape[0]):
        for c in range(Array.shape[1]):
            if Array.mask[r,c]:
                Array.data[r,c] = NoData

    newDic = {}
    newDic['data'] = Array.data
    newDic['geo'] = geo
    newDic['proj'] = proj
    newDic['xSize'] = xSize
    newDic['ySize'] = ySize
    newDic['NoData'] = NoData
    newDic['cellSize'] = cellSize

    return newDic


