#!/usr/bin/python

import sys
import os
import os.path
from qgis import *
from qgis.core import *
QgsApplication.setPrefixPath("/usr", True)
QgsApplication.initQgis()
from qgis.analysis import * 

def Usage():
    print('Usage: intersect.py src_shapefile1  src_shapefile1 dst_shapefile')
    sys.exit( 1 )

src_shpA = None
src_shpB = None
dst_shp  = None

if len(sys.argv) != 4:
    sys.exit(Usage())

i = 1
while i < len(sys.argv):
    arg = sys.argv[i]
    if src_shpA is None:
        src_shpA = arg
    elif src_shpB is None:
        src_shpB = arg
    elif dst_shp is None:
        dst_shp = arg
    else:
        Usage()
    i = i + 1

if  src_shpA is None:
    Usage()
 
if  src_shpA is None:
    Usage()

if  dst_shp is None:
    Usage()

print(src_shpA)
print(src_shpB)

shpA = QgsVectorLayer(  src_shpA  , "layerA", "ogr")
if not shpA.isValid():
    print "Layer failed to load!"
    sys.exit(0)

shpB = QgsVectorLayer( src_shpB  , "layerB", "ogr")
if not shpB.isValid():
    print "Layer failed to load!"
    sys.exit(0)

print("start the intersection")
QgsOverlayAnalyzer().intersection( shpA , shpB  , dst_shp )
QgsApplication.exitQgis()
print ("end")








