#-------------------------------------------------------------------------------
# Name:        exportPV.py
# Purpose:     A script for exporting all pixel values of images to a csv file
#
# Author:      Mao-Ning Tuanmu
#
# Created:     09/05/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python


from osgeo import gdal
import numpy

# settings

path = "D:\\Work\\Texture\\LEDAPS\\NDMI\\Mosaic\\"
#path = "/home/maoningt/NDVI/"
pre = "Oregon_"
post = '_clip.tif'
fList = ['NDMI_pValid','NDMI_mean','NDMI_std','NDMI_cv','NDMI_max','NDMI_min','NDMI_range',\
        'NDMI_ASM','NDMI_CON','NDMI_COR','NDMI_DIS','NDMI_ENT','NDMI_GLCMMAX',\
        'NDMI_GLCMMEAN','NDMI_GLCMVAR','NDMI_HOM']


path2 = "D:\\Work\\Texture\\LEDAPS\\NDVI\\Mosaic\\"
#path = "/home/maoningt/NDVI/"
pre2 = "Oregon_"
post2 = '_clip.tif'
fList2 = ['NDVI_mean','NDVI_std','NDVI_cv','NDVI_max','NDVI_min','NDVI_range',\
        'NDVI_ASM','NDVI_CON','NDVI_COR','NDVI_DIS','NDVI_ENT','NDVI_GLCMMAX',\
        'NDVI_GLCMMEAN','NDVI_GLCMVAR','NDVI_HOM']

path3 = "D:\\Data\\RS Data\\MCD12Q1\\"
#path = "/home/maoningt/NDVI/"
pre3 = "Oregon_"
post3 = '_v51.tif'
fList3 = ['IGBP_LC']

path4 = "D:\\Work\\Texture\\NLCD\\Mosaic\\"
#path = "/home/maoningt/NDVI/"
pre4 = "Oregon_"
post4 = '_MODIS_grid_clip.tif'
fList4 = ['DIVISION','ED','ENN_AM','FRAC_CV','FRAC_MN','LPI','LSI','PARA_CV',\
        'PARA_MN','PR','SHDI','SHEI','SIDI','SIEI']

path5 = "D:\\Work\\Texture\\NBCD\\"
#path = "/home/maoningt/NDVI/"
pre5 = "Oregon_"
post5 = '_clip.tif'
fList5 = ['BAW_height_mean','BAW_height_std','BAW_height_cv','BAW_height_max',\
            'BAW_height_min','BAW_height_range','FIA_ALD_biomass_mean',\
            'FIA_ALD_biomass_std','FIA_ALD_biomass_cv','FIA_ALD_biomass_max',\
            'FIA_ALD_biomass_min','FIA_ALD_biomass_range','NCE_ALD_biomass_mean',\
            'NCE_ALD_biomass_std','NCE_ALD_biomass_cv','NCE_ALD_biomass_max',\
            'NCE_ALD_biomass_min','NCE_ALD_biomass_range','NBCD_pValid']

path6 = "D:\\Work\\Texture\\Ecoregion\\"
#path = "/home/maoningt/NDVI/"
pre6 = "EPA_"
post6 = '_L3.tif'
fList6 = ['ecoregion']

outFile = 'D:\\Work\\Texture\\Analyses\\Ecoregion\\texture.csv'



# open Raster data

arrayList = []

for f in fList:
    g = gdal.Open(path + pre + f + post)
    arr = g.ReadAsArray()
    arrayList.append(arr)

for f in fList2:
    g = gdal.Open(path2 + pre2 + f + post2)
    arr = g.ReadAsArray()
    arrayList.append(arr)

for f in fList3:
    g = gdal.Open(path3 + pre3 + f + post3)
    arr = g.ReadAsArray()
    arrayList.append(arr)

for f in fList4:
    g = gdal.Open(path4 + pre4 + f + post4)
    arr = g.ReadAsArray()
    arrayList.append(arr)

for f in fList5:
    g = gdal.Open(path5 + pre5 + f + post5)
    arr = g.ReadAsArray()
    arrayList.append(arr)

for f in fList6:
    g = gdal.Open(path6 + pre6 + f + post6)
    arr = g.ReadAsArray()
    arrayList.append(arr)

# randomly selects pixels
n = 10000  # selected number of cells
nr = arrayList[0].shape[0]  # total number of rows
nc = arrayList[0].shape[1]  # total number of columns

selectedCells = []  # a list of selected cells
selectedValues = []  # a list of selected cell values
allValues = []  # a list of selected values from all images

i = 0  # counts of selected cells
while i < n:
    sr = numpy.random.randint(0,nr)  # randomly selected row
    sc = numpy.random.randint(0,nc)  # randomly selected col
    if (sr,sc) not in selectedCells:
        if arrayList[0][sr,sc] == 1 and arrayList[46][sr,sc] > 0:
            selectedCells.append((sr,sc))
            i = i + 1

# get cell values based on selectedCells
for arr in arrayList:
    for cell in selectedCells:
        selectedValues.append(arr[cell[0],cell[1]])
    allValues.append(selectedValues)
    selectedValues = []



# export pixel values as a csv file
outfile = open(outFile, 'w')
#outfile.writelines('%s,%s\n' %(','.join(fList), ','.join(fList2)))
fListAll = fList + fList2 + fList3 + fList4 + fList5 + fList6
outfile.writelines('X,Y,%s\n' % (','.join(fListAll)))


for r in range(len(allValues[0])):
    newLine =''
    for c in range(len(allValues)):
        newLine = newLine + str(selectedCells[r][0]) + ',' + str(selectedCells[r][1]) + ',' + str(allValues[c][r]) + ','
    outfile.writelines(newLine +'\n')
outfile.close()

