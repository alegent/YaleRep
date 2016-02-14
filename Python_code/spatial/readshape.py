# readshape.py
# This module contains a class to work with Shapefiles and the
# geometry class objects we've been working on in GEO 825.
# It uses OGR functions to accomplish this.
#
# Currently supports polygon, point and linestring objects
# Requires osgeo and the GEO 825 geometry module.
#
# Written by A. Shortridge, 2/21/2007, 3/2009, 4/2009

class Shape:
    '''A basic class to hold shapefile data and information.

    Includes classes to write itself to Geometry classes. If
    those are used then the geometry module is required.'''

    def __init__(self, shapeFileName):
        '''Read the contents of a shapefile named file.'''

        from osgeo import ogr # OGR shapefile objects are like an onion. We unpeel to get the coords.

#        shp_driver = ogr.GetDriverByName('ESRI Shapefile')
#        shp = shp_driver.Open(shapeFileName)
        shp = ogr.Open(shapeFileName)

#        lyr = shp.GetLayer()  # gets the 1st & only layer.
        lyr = shp.GetLayerByIndex(0)  # gets the 1st & only layer

        self.mbr = lyr.GetExtent()   #  the min. bounding rectangle
        self.count = lyr.GetFeatureCount()

        print self.count

        feature = lyr.GetNextFeature()  # Grab the first feature
        geom = feature.GetGeometryRef()  # Get the geometry of the first feature

        self.geometryType =geom.GetGeometryName()

#        if geom.GetGeometryType() == 1:  # if the feature geom. is a point...
#            if self.count > 1 :          # and there's more than 1 of them...
#                self.geometryType = 'MultiPoint'
#            else: self.geometryType = 'Point'
#        elif geom.GetGeometryType() == 2:  # if the feature geom. is a line...
#            if self.count > 1 :          # and there's more than 1 of them...
#                self.geometryType = 'MultiLineString'
#            else: self.geometryType = 'LineString'
#        elif geom.GetGeometryType() == 3:  # if the feature geom. is a poly
#            if self.count > 1 :          # and there's more than 1 of them...
#                self.geometryType = 'MultiPolygon'
#            else: self.geometryType = 'Polygon'

#        else: self.geometryType = 'Unsupported by my readshape'

        geoDict = {}
        for i in range(self.count):  # Loop through all features
            id = feature.GetFID()  # Get the ID
            coordthing = feature.GetGeometryRef()    # All feature coords
            if coordthing.GetGeometryName().endswith('POINT'):    # if it is a point
                x = coordthing.GetX()
                y = coordthing.GetY()
                geoDict[id] = tuple(x,y)
            elif coordthing.GetGeometryName().endswith('LINESTRING'):  # if it is a line
               coordList = []
               for pt in range(coordthing.GetPointCount()):
                   x = coordthing.GetX(pt)
                   y = coordthing.GetY(pt)
                   coordList.append((x,y))  # append this tuple
               geoDict[id] = coordList
            elif coordthing.GetGeometryName().endswith('POLYGON'):  # if it is a poly
               numrings = coordthing.GetGeometryCount()
               ringList=[]
               for i in range(numrings):
                   ring = []
                   ringGeom = coordthing.GetGeometryRef(i)
                   for pt in range(ringGeom.GetPointCount()):
                       x = ringGeom.GetX(pt)
                       y = ringGeom.GetY(pt)
                       ring.append((x,y))  # append this tuple
                   ringList.append(ring)
               geoDict[id] = ringList
            feature = lyr.GetNextFeature()   # Read in the next feature
        self.features = geoDict



    def convertGeom(self):
        '''This function converts a Shape class object to the appropriate Geometry.'''

        import geometry  # A module with a bunch of spatial classes
        if self.geometryType == 'POINT' or self.geometryType == 'MULTIPOINT':
            pointList = []
            for k in self.features.keys():
                pt = self.features[k]
                pointList.append(geometry.Point(pt[0], pt[1]))
            if len(pointList) > 1:
                return pointList
            else: return pointList[0]   # Just the single Point
        elif self.geometryType == 'LINESTRING' or self.geometryType == 'MULTILINESTRING':
            lineList = self.features.values()   # A list of lists of coords
            ptlnList = []
            for line in lineList:
                ptlist = []
                for pt in line:
                    ptlist.append(geometry.Point(pt[0], pt[1]))
                ptlnList.append(geometry.LineString(ptlist))
            if len(ptlnList) > 1:
                geoInstance = geometry.MultiLineString(ptlnList)
                return geoInstance
            else:
                geoInstance = geometry.LineString(ptlnList[0])
                return GeoInstance     # Just the single LineString
        elif self.geometryType == 'POLYGON' or self.geometryType == 'MULTIPOLYGON':
            geomList = self.features.values()   # A list of lists of coords
            polyList = []
            for poly in geomList:
                ptlnList = []
                for ring in poly:
                    ptlist = []
                    for pt in ring:
                        ptlist.append(geometry.Point(pt[0], pt[1]))
                ptlnList.append(geometry.LineString(ptlist))
                if len(ptlnList) > 1: # If there are holes
                    polyList.append(geometry.Polygon(ptlnList[0], ptlnList[1:]))
                else:
                    polyList.append(geometry.Polygon(ptlnList[0]))
            if len(polyList) > 1:   # it's a multiPolygon
                geoInstance = geometry.MultiPolygon(polyList)
                return geoInstance
            else:
                return polyList[0]  # Just the polygon




