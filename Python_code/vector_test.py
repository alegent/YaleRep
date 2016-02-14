#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      tuanmu
#
# Created:     25/10/2012
# Copyright:   (c) tuanmu 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

import math

def dist_from_lat_long(lat1, long1, lat2, long2):

    # Convert latitude and longitude to
    # spherical coordinates in radians.

    # phi = 90 - latitude
    phi1 = math.radians(90.0 - lat1)
    phi2 = math.radians(90.0 - lat2)

    # theta = longitude
    theta1 = math.radians(long1)
    theta2 = math.radians(long2)

    # Compute spherical distance from spherical coordinates.

    # For two locations in spherical coordinates
    # (1, theta, phi) and (1, theta, phi)
    # cosine( arc length ) =
    #    sin phi sin phi' cos(theta-theta') + cos phi cos phi'
    # distance = rho * arc length

    cos = (math.sin(phi1)*math.sin(phi2)*math.cos(theta1 - theta2) +
           math.cos(phi1)*math.cos(phi2))
    arc = math.acos( cos )
    dist = arc * 6371

    # Remember to multiply arc by the radius of the earth
    # in your favorite set of units to get length.
    return dist




from osgeo import ogr, gdal

target = 12
# import a raster image
#g = gdal.Open('H:\\Data\\Consensus_LC\\con_1km_new\\con_1km_class_5_binary.tif')
#g = gdal.Open('/home/maoningt/LC/Output/consensus_1km_class_12.tif')
#g = gdal.Open('/home/maoningt/LC/Data/globcover_reclass.tif')
#g = gdal.Open('/home/maoningt/LC/Data/modis_reclass.tif')
#g = gdal.Open('/home/maoningt/LC/Data/glcc_reclass.tif')
g = gdal.Open('/home/maoningt/LC/Data/glc2k_reclass.tif')

a = g.ReadAsArray()
#a = b.ReadAsArray()
rgeo = g.GetGeoTransform()
LX = rgeo[0]
UY = rgeo[3]
cellSize = rgeo[1]
g = None

# import a multi-polygon shapefile

#f = 'D:\\Work\\Consensus\\shp\\C_uro.shp'
f = '/home/maoningt/LC/shp/R_rol.shp'
driver = ogr.GetDriverByName('ESRI Shapefile')
v = driver.Open(f,0)
layer = v.GetLayer()

XYList = []
distList = []
pg = layer.GetNextFeature()

while pg:
    geo = pg.GetGeometryRef()
    lon,lat = geo.GetX(),geo.GetY()

# ignore repeated observations
    if (lon,lat) not in XYList:
        XYList.append((lon,lat))
        buf = 0
# check if the point locates within a pixel with the target land cover class

#        if a[int((UY-lat)/cellSize), int((lon-LX)/cellSize)] == 0:
        if a[int((UY-lat)/cellSize), int((lon-LX)/cellSize)] != target:
            buf = 0 #km
            contain = False

            unit_dist_N = dist_from_lat_long(lat, lon, lat+0.01, lon)
            unit_dist_S = dist_from_lat_long(lat, lon, lat-0.01, lon)
            unit_dist_EW = dist_from_lat_long(lat, lon, lat, lon-0.01)
# increase searching radius until the window contains the target land cover class
            while not contain:
                buf += 0.5
                N_bound = lat + (buf / unit_dist_N)*0.01
                S_bound = lat - (buf / unit_dist_N)*0.01
                W_bound = lon - (buf / unit_dist_EW)*0.01
                E_bound = lon + (buf / unit_dist_EW)*0.01

                lx = int((W_bound-LX)/cellSize)
                rx = int((E_bound-LX)/cellSize)
                uy = int((UY-N_bound)/cellSize)
                ly = int((UY-S_bound)/cellSize)

#                if a[uy:ly+1, lx:rx+1].sum() > 0:
                if target in a[uy:ly+1, lx:rx+1]:
#                if target[0] in a[uy:ly+1, lx:rx+1] or target[1] in a[uy:ly+1, lx:rx+1] or target[2] in a[uy:ly+1, lx:rx+1] or target[3] in a[uy:ly+1, lx:rx+1]:
                    contain = True

        distList.append(buf)
    pg = layer.GetNextFeature()

a = None
# export distances

#outfile = open("D:\\Work\\Consensus\\Analyses\\Birds\\C_uro_globcover.csv", 'w')
outfile = open("/home/maoningt/LC/Analyses/R_rol_glc2k.csv", 'w')

for d in distList:
    outfile.writelines(str(d) + '\n')

outfile.close()