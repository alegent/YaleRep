# asciiraster.py
# Some functions for working with ArcInfo
# ascii raster Grid files.
#
# A. Shortridge, 1/2007, 2/2007
# Modified by Mao-Ning Tuanmu, 7/8/2009
#

def openAsciiRaster(filename):
    '''Opens an Arc Ascii file.

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




def writeAsciiRaster(raster, filename):
    '''Writes an ESRI ascii raster file from a Raster instance'''

    outfile = open(filename, 'w')
    outfile.writelines('ncols ' + str(raster.ncols) + '\n')
    outfile.writelines('nrows ' + str(raster.nrows) + '\n')
    outfile.writelines('xllcorner ' + str(raster.Xll) + '\n')
    outfile.writelines('yllcorner ' + str(raster.Yll) + '\n')
    outfile.writelines('cellsize ' + str(raster.cellsize) + '\n')
    outfile.writelines('NODATA_value ' + str(raster.nodata) + '\n')

    for row in raster.elements.data:
        strList = []
        for value in row:
            strList.append(str(value))
        space = ' '
        line = space.join(strList)
        outfile.writelines(line + '\n')

    outfile.close()
