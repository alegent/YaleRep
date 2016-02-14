# testdraw.py
#
# tests the drawing.
#
# Ashton

import raster
import GISgraphics
import asciiraster

rast = raster.Raster(raster.biggerRast, cellsize=3)


mapwin = GISgraphics.MapWindow('Raster', winXY=(300,300), mapextent=rast.envelope)

rast.draw(mapwin)

mapwin.display()
mapwin.clear()
rast.draw(mapwin)
mapwin.display()

# Now some real data.

ascfile = '../geocode/data/medora_subu.asc'
medoraIn = asciiraster.openAsciiRaster(ascfile)

medoraIn[0]
medora = raster.Raster(medoraIn[1], \
    cellsize=medoraIn[0]['cellsize'], \
    Xll=medoraIn[0]['xllcorner'], \
    Yll=medoraIn[0]['yllcorner'], \
    nodata=medoraIn[0]['NODATA_value'])

mapwin = GISgraphics.MapWindow('Raster', winXY=(300,400), mapextent=medora.envelope)

medora.setBreaks(15)
medora.setColor('grayShade')
medora.draw(mapwin)
mapwin.display()

medora.setBreaks(7)
medora.setColor('BrewerYG')
medora.draw(mapwin)
mapwin.display()


# How about polygons?
mapwin = GISgraphics.MapWindow('Raster', winXY=(300,300), mapextent=rast.envelope)

rast.draw(mapwin)

mapwin.display()
mapwin.clear()
rast.draw(mapwin)
mapwin.display()


# Points
import geometry

pt1 = geometry.Point(1,1)
pt2 = geometry.Point(1,3)
pt3 = geometry.Point(2,5)
pt4 = geometry.Point(3,2)
pt5 = geometry.Point(3,4)
pt6 = geometry.Point(5,4)
pt7 = geometry.Point(7,1)
pt8 = geometry.Point(2,2)
pt9 = geometry.Point(3,3)
pt10 = geometry.Point(4,2)



# Lines
line1 = geometry.LineString([pt1,pt2,pt5, pt7, pt1])
line2 = geometry.LineString([pt8,pt9,pt10, pt8])
line1.draw('red', mapwin, 1)
mapwin.display()


# Polygons
poly1 = geometry.Polygon(line1)
poly1.envelope
poly1.Area()

poly1.draw('blue', mapwin)
mapwin.display()

poly2 = geometry.Polygon(line1, [line2])
poly2.draw('red', mapwin)
mapwin.display()
