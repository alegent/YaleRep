# geometry.py
#
# Version 3.0
#
# This code implements a geometry object model in Python.
# The model is based on a portion of the model introduced
# in the OGIS specification for OpenGIS Simple Features
# Specification. See section 6.1.2.2-4 of the OGC Simple
# Features Specification for Geometry methods all
# subclasses must implement, and 6.1.4 for Point, etc.
#
# Set-based algorithms are based on discussion in Worboys
# & Duckham, GIS: A Computing Perspective, Chapter 5.

# Version 3.0 Implements Buffer, Intersects, and
# geometryType information for all classes. Improved
# polygon rendering.
#
# Version 2.1 more fully implements Polygons and Multipolygons.
#
# Version 2.0 puts a little more responsibility on the
# geometry class.
#
# Version 1.x of the code, in conjunction with the
# GISgraphics.py module, enables one to plot vector
# features to a pygame window with appropriate scaling.
#
# written by A. Shortridge, 2/2007, 2/2009, 3/2009
#
# modified by Mao-Ning Tuanmu, 8/12/11
# Adds a function to the Point class calculating Euclidean distance between two points

class Geometry:
    '''An abstract class for 0, 1, and 2-dimensional geometric objects.'''

    def dimension(self):
        return self.dimension

    def geometryType(self):
        return self.gType

    def isSimple(self):
        return self.simple

    def boundary(self):
        return self.boundary



class GeometryCollection:
    '''An abstract class: a collection of 1 or more Geometries.'''


class Point(Geometry):
    '''A 0-dimensional location representing a point.'''

    def __init__(self, x, y):
        self.X = x
        self.Y = y
        self.dimension  = 0
        self.gType = 'Point'
        self.boundary = 0  # by definition, points do not have boundaries
        self.simple = 1    # by definition, points are simple!


    def __str__(self):
        '''Returns a representation in a suitable text format.'''
        return(str(self.X) + ', ' + str(self.Y))


    def draw(self, color, window, size=1):
        '''Draws the point on the Surface.

        Uses the drawPoints functionality of window, which is a
        MapWindow class object. Requires pygame and GISgraphics to
        run. It passes a the coordinate tuple in a list to drawPoints.'''
        ptList = [self.asTuple()]
        window.drawPoints(ptList, color, size)


    def asText(self):
        '''Returns a Well Known Text (WKT) representation.
        See http://en.wikipedia.org/wiki/Well-known_text'''
        return 'POINT (' + str(self.X) + ' ' + str(self.Y) + ')'


    def asTuple(self):
        '''Returns the point coords as a tuple.'''
        return (self.X, self.Y)


    def side(self, beginPoint, endPoint):
        '''Calculate which side of a line segment the self Point falls on.

        beginPoint and endPoint are Points representing a line segment.
        Returns a number: 1 : to the left; -1 : to the right, 0  : collinear.'''

        # create a LineString (probably a triangle) from the points.
        tri = LineString([self, beginPoint, endPoint, self])
        a = tri.RingArea()

        if a > 0: s = 1   # to the left
        if a == 0: s = 0   # collinear
        if a < 0: s = -1  # to the right
        return(s)


    def collinear(self, beginPt, endPt):
        '''Returns True if beginPt, endPt, and self are collinear.'''
        if self.side(beginPt, endPt) == 0:
            return True
        else: return False


    def pointOnSegment(self, beginPt, endPt):
        '''Returns True if self falls on a line between beginPt & endPt.'''
        if self.collinear(beginPt, endPt) == 0:
            if min(beginPt.X, endPt.X) < self.X < max(beginPt.X, endPt.X)\
            and min(beginPt.Y, endPt.Y) < self.Y < max(beginPt.Y, endPt.Y):
                return True
        return False


    def bufferP(self, distance):
        '''Creates a circular polygon around the point with radius=distance.'''

        import math
        distSq = distance**2
        radianCon = 3.1415926 / 180.0

        deg = range(360, -1, -30)  # calc x and y for regularly spaced points

        xcoord = []
        ycoord = []

        for d in deg:
            alpha = radianCon * d
            xcoord.append(self.X + (distance * math.cos(alpha))) # some trig to find x & y
            ycoord.append(self.Y + (distance * math.sin(alpha)))

        # Loop through the coords, turn them into points, and make a poly of them
        pl = []
        for x, y in zip(xcoord, ycoord):
            pl.append(Point(x, y))

        pl.append(Point(xcoord[0], ycoord[0]))

        bufferPoly = Polygon(LineString(pl))

        return bufferPoly


    def inPoly(self, poly):
        '''A function to implement a point in polygon algorithm. Returns True or False.

        Creates a segment connecting the polygon centroid to self. Cycles through each line
        segment in poly, including holes, counting intersections. If the total # of
        intersections is odd, then the point is in the poly. This function assumes that the
        polygon centroid actually falls in the polygon.'''

        if poly.geometryType() is not 'Polygon':
            return 0
        else:
            checkseg = LineString([self, poly.Centroid()])  # line segment from point to centroid
            #print 'checkseg:', checkseg
            intTotal = 0
            for i in range(len(poly.exterior.points)-1):
                pseg = LineString([poly.exterior.points[i], poly.exterior.points[i+1]])
                if checkseg.segInt(pseg) is True:
                    intTotal = intTotal + 1

            # Now check the holes in the polygon
            holes = poly.NumInteriorRing()
            for n in range(holes):
                ring = poly.InteriorRingN(n)
                for i in range(len(ring.points)-1):
                    pseg = LineString([ring.points[i], ring.points[i+1]])
                    if checkseg.segInt(pseg) is True:
                        intTotal = intTotal + 1


            if intTotal == 0:
                return True

            '''CURRENTLY SegInt has problems, so I'm not implementing this
            correctly. As it runs now, this should work as long as the
            polygon is convex with no holes.
            if intTotal%2 == 0:
                return False
            else:
                return True'''

            return False   # Intersections occur

    def EUdist(self, pt):
        '''A function of calculating Euclidean distance to another Point

        pt should be an instance of Point'''

        dist = ((self.X - pt.X)**2 + (self.Y - pt.Y)**2)**0.5
        return dist



class MultiPoint(GeometryCollection):
    '''A Collection of point objects.'''

    def __init__(self, pointList):
        '''Creates a MultiPoint instance with a list of Point instances.'''
        self.points = pointList
        self.calcEnvelope()   # creates self.envelope
        self.gType = 'MultiPoint'


    def __str__(self):
        '''Returns a representation in a suitable text format.'''
        text=''
        for p in self.points:
            text = text + str(p) + '\n'   # str is defined as __str__ in Point
        text = text.rstrip('\n')
        return text


    def draw(self, color, window, size=1):
        '''Draws the points on the Surface.

        Uses the drawPoints functionality of window, which is a
        MapWindow class object. Requires pygame and GISgraphics to
        run. It passes a list of coordinate tuples to drawPoints.'''
        ptList = []
        for p in self.points:
            ptList.append(p.asTuple())
        window.drawPoints(ptList, color, size)


    def calcEnvelope(self):
        '''Calculates the minimum bounding box.'''
        minX = self.points[0].X
        maxX = self.points[0].X
        minY = self.points[0].Y
        maxY = self.points[0].Y

        for p in self.points:
            if p.X < minX: minX = p.X
            if p.X > maxX: maxX = p.X
            if p.Y < minY: minY = p.Y
            if p.Y > maxY: maxY = p.Y
        self.envelope = [(minX, minY), (maxX, maxY)]


    def addPoints(self, newPoints):
        '''Add one or more points to self.

        Input can be a single Point instance, a list of Points or a MultiPoint.'''

        if type(newPoints) == type([1,2,3]):  # tests for type correspondence
            if newPoints[0].geometryType() == 'Point':
                self.points.extend(newPoints)
        elif newPoints.geometryType() == 'Point':
            self.points.append(newPoints)
        elif newPoints.geometryType() == 'MultiPoint':
            self.points.extend(newPoints.points)
        else:
            print 'Type Error: not a Point or MultiPoint Object!'
            return -10
        self.calcEnvelope()
        return 0



class Curve(Geometry):
    '''A 1-dimensional geometric object stored as a sequence of points.
    Only LineStrings are supported.'''



class LineString(Curve):
    '''A curve with linear interpolation between points.

    Each consecutive pair of points defines a line segment.'''

    def __init__(self, pointList):
        '''Creates a LineString instance with a list of Point instances.'''
        self.points = pointList
        self.dimension  = 1
        self.gType = 'LineString'
        self.boundary = 0  # by definition, points do not have boundaries
        self.simple = 1    # by definition, points are simple!

        self.calcEnvelope()    # creates self.envelope


    def __str__(self):
        '''Returns a representation in a suitable text format.'''
        text=''
        for p in self.points:
            text = text + str(p) + '\n'   # str is defined as __str__ in Point
        text = text.rstrip('\n')
        return text

    def draw(self, color, window, width=1):
        '''Draws the LineString on the Surface.

        Uses the drawLines functionality of window, which is a
        MapWindow class object. Requires pygame and GISgraphics to
        run. It passes a list of coordinate tuples to drawLines.'''
        ptList = []
        for p in self.points:
            ptList.append(p.asTuple())
        window.drawLines(ptList, color, width)


    def calcEnvelope(self):
        '''Calculates the minimum bounding box.'''
        minX = self.points[0].X
        maxX = self.points[0].X
        minY = self.points[0].Y
        maxY = self.points[0].Y

        for p in self.points:
            if p.X < minX: minX = p.X
            if p.X > maxX: maxX = p.X
            if p.Y < minY: minY = p.Y
            if p.Y > maxY: maxY = p.Y
        self.envelope = [(minX, minY), (maxX, maxY)]


    def Length(self):
        '''Calculates length of a LineString.'''
        dist = 0
        for i in range(len(self.points)-1):
            xdiff = self.points[i+1].X - self.points[i].X
            ydiff = self.points[i+1].Y - self.points[i].Y
            dist = dist + (xdiff**2 + ydiff**2)**0.5
        return dist


    def StartPoint(self):
        '''Returns the start Point of a LineString.'''
        return self.points[0]


    def EndPoint(self):
        '''Returns the end Point of a LineString.'''
        return self.points[-1]


    def segInt(self, lineseg):
        '''Intersection algorithm: works only on two line segments (two vertices each).

        Returns True or False.
        RIGHT NOW THIS FAILS TO A PATHOLOGICAL CASE WHERE SEG A's RANGE IS
        LONGER THAN SEG B's. BUT THEY DON'T INTERSECT IN REALITY'''

        if lineseg.geometryType() is not 'LineString':
            return 0
        if len(self.points) is not 2 or len(lineseg.points) is not 2:
            return 0    # They weren't really line segments

        a = self.points[0]
        b = self.points[1]
        c = lineseg.points[0]
        d = lineseg.points[1]
        s1 = a.side(b,c)
        s2 = a.side(b,d)
        s3 = c.side(d,a)
        s4 = c.side(d,b)
        if s1 != s2 and s3 != s4: return True  # They intersect

        # We also have to check for collinearity for special cases:
        if a.pointOnSegment(c,d) or b.pointOnSegment(c,d)\
        or c.pointOnSegment(a,b) or d.pointOnSegment(a,b):
            return True

        return False  # We made it all the way through, and no intersections.


    def isClosed(self):
        '''Returns 1 if the LineString is closed (if last point = first point).'''
        if self.StartPoint() == self.EndPoint():
            return 1
        else:
            return 0


    def isSimple(self):
        '''Returns 1 if the LineString does not cross itself. A pathological
        case that currently isn't handled: duplicate points in sequence.
        Based on ideas from Worboys & Duckham, p. 200-201.'''

        if len(self.points) < 4:   # It's too short to cross
            return 1
        for i in range(len(self.points)-3):
            seg1A = self.points[i]
            seg1B = self.points[i+1]
            for j in range(i+2, len(self.points)-2):  # all remaining points
                seg2A = self.points[j]
                seg2B = self.points[j+1]

                # Calculate sidedness for several permutations. (Tricks from Worboys)
                s1 = seg2A.side(seg1A, seg1B)
                s2 = seg2B.side(seg1A, seg1B)
                s3 = seg1A.side(seg2A, seg2B)
                s4 = seg1B.side(seg2A, seg2B)

                if (s1 != s2 and s3 != s4): return 0  # They intersect

        return 1  # We went through all the segments; none crossed.


    def isRing(self):
        '''Returns True if the Linestring is Closed AND Simple (doesn't cross).'''

        if self.isClosed() and self.isSimple():
            return 1  # If True do a segment intersection check.
        else:
            return 0


    def RingArea(self):
        '''Calculate and return interior area of a ring.

        This is not theoretically kosher, since rings don't have area. But
        it makes the code as a whole nicer to write it this way.'''

        areasum = 0
        for i in range(len(self.points)-1):   # loop through the ring coordinates
            pt1 = self.points[i]
            pt2 = self.points[i+1]
            areasum = areasum + ((pt1.X * pt2.Y) - (pt1.Y * pt2.X))
        areasum = areasum * 0.5
        return areasum


    def Intersects(self, linest):
        '''Returns True if the linestring intersects linest.'''
        if linest.geometryType() is not 'LineString':
            return 0   # Both must be linestrings!

        for i in range(len(self.points)-1):
            seg1 = LineString([self.points[i], self.points[i+1]])
            for j in range(len(linest.points)-1):
                seg2 = LineString([linest.points[j], linest.points[j+1]])

                if seg1.segInt(seg2) is True:
                    return True


        return False # Made it all the way through with no intersections.



class MultiCurve(GeometryCollection):
    '''A collection of curves. Only MultiLineStrings are supported.'''




class MultiLineString(MultiCurve):
    '''A Collection of LineString objects.'''

    def __init__(self, lineList):
        '''Creates a MultiLine instance with a list of LineString instances.'''
        self.lines = lineList
        self.calcEnvelope()   # Creates self.envelope
        self.gType = 'MultiLineString'


    def __str__(self):
        '''Returns a representation in a suitable text format.'''
        text=''
        for line in self.lines:
            text = text + str(line) + '\n'   # str is defined as __str__ in LineString
        text = text.rstrip('\n')
        return text


    def draw(self, color, window, width=1):
        '''Draws each LineString in the Collection on the Surface.

        This is just a wrapper function for the LineString draw function.'''

        for line in self.lines:
            line.draw(color, window, width)



    def calcEnvelope(self):
        '''Calculates the minimum bounding box.'''
        minX = self.lines[0].envelope[0][0]
        maxX = self.lines[0].envelope[1][0]
        minY = self.lines[0].envelope[0][1]
        maxY = self.lines[0].envelope[1][1]

        for p in self.lines:
            if p.envelope[0][0] < minX: minX = p.envelope[0][0]
            if p.envelope[1][0] > maxX: maxX = p.envelope[1][0]
            if p.envelope[0][1] < minY: minY = p.envelope[0][1]
            if p.envelope[1][1] > maxY: maxY = p.envelope[1][1]
        self.envelope = [(minX, minY), (maxX, maxY)]


    def isClosed(self):
        '''If all LineStrings in self are closed, return True, otherwise False.'''
        for line in self.lines:
            if line.isClosed() == False:
                return False
        return True

    def Length(self):
        '''Return total length of all Linestrings in the MLS.'''
        dist = 0
        for line in self.lines:
            dist = dist + line.Length()
        return dist


    def Intersects(self, line):
        '''Returns True if self and line intersect.'''
        if line.geometryType() is 'MultiLineString':
            for lineS in self.lines:
                for lineL in line.lines:
                    if lineS.Intersects(lineL): return True


            return False  # None of the LineStrings intersected

        elif line.geometryType() is 'LineString':
            for lineS in self.lines:
                if lineS.Intersects(line): return True

            return False

        else: return 0



class Surface(Geometry):
    '''A non-instatiable class for 2-D surfaces. Only Polygons are supported.'''



class Polygon(Surface):
    '''A planar Surface defined by 1 exterior boundary and 0+ interior boundaries.

    Each interior boundary is a hole in the Polygon.'''

    def __init__(self, exterior, holeList=[]):
        '''Create a Polygon.

        exterior is a closed, simple LineString; holeList is a list of closed,
        simple LineStrings.'''
        self.exterior = exterior
        self.holeList = holeList
        self.envelope = exterior.envelope
        self.gType = 'Polygon'

    def __str__(self):
        '''Returns a polygon representation in a suitable text format.'''
        text=''
        for linestrg in self.exterior:
            text = text + str(linestrg) + '\n'   # __str__ defined elsewhere
        for linestrg in self.holeList:
            text = text + str(linestrg) + '\n'   # __str__ defined elsewhere
        text = text.rstrip('\n')
        return text


    def draw(self, color, window, width=1, fill=False):
        '''Draws the Polygon on the Surface.

        Draws both the poly ring and the holes.'''

        if fill:    # Draw filled-in polygons
            ptList = [p.asTuple() for p in self.exterior.points]
            window.drawPolygon(ptList, color, width=0)
            for line in self.holeList:  # 'Draw' the holes
                ptList = [p.asTuple() for p in line.points]
                window.drawPolygon(ptList, window.bkdColor, width)

        else:      # Draws outlines as lineStrings (no fill)
            self.exterior.draw(color, window, width)
            for line in self.holeList:
                line.draw(color, window, width)


    def Area(self):
        '''Returns the area of the Polygon.

        Area will be positive if rings were encoded in counter-clockwise direction.'''

        # Calculate the area of all of the interior rings
        holeArea = 0
        for ring in self.holeList:
            holeArea = holeArea + ring.RingArea()

        return self.exterior.RingArea() - holeArea


    def Centroid(self):
        '''Returns the centroid (a Point) for the Polygon.'''

        xc = 0
        yc = 0
        count = 0
        for pt in self.exterior.points[:-1]:  # Don't do the last pt, which is same as 1st
            xc = xc + pt.X
            yc = yc + pt.Y
            count = count + 1
        xc = xc / float(count)
        yc = yc / float(count)
        return Point(xc,yc)


    def ExteriorRing(self):
        '''Returns the exterior ring of the Polygon.'''

        return self.exterior



    def NumInteriorRing(self):
        '''Returns the number of interior rings of the Polygon.'''

        return len(self.holeList)


    def InteriorRingN(self, N):
        '''Returns the Nth interior ring of the Polygon.'''

        return self.holeList[N-1]


    def Intersects(self, geom):
        '''Returns True if self and geom intersect.'''
        if geom.geometryType() == 'Polygon':
            return self.exterior.Intersects(geom.exterior)

        elif geom.geometryType() == 'LineString':
            return self.exterior.Intersects(geom)

        elif geom.geometryType() == 'MultiLineString':
            return self.exterior.Intersects(geom)

        else: return False


class MultiSurface(GeometryCollection):
    '''A collection of Surfaces. Only Polygons are supported.'''



class MultiPolygon(MultiSurface):
    '''A collection of Polygon objects.'''

    def __init__(self, polyList):
        '''Create a MultiPolygon with a list of Polygon objects.'''
        self.polygons = polyList
        self.calcEnvelope()   # Creates self.envelope
        self.gType = 'MultiPolygon'


    def __str__(self):
        '''Returns a representation in a suitable text format.'''
        text=''
        for poly in self.polygons:
            text = text + str(poly) + '\n'   # str is defined as __str__ in Polygon
        text = text.rstrip('\n')
        return text


    def draw(self, color, window, width=1, fill=False):
        '''Draws each Polygon in the Collection on the window Surface.

        This is just a wrapper function for the Polygon draw function.'''

        for poly in self.polygons:
            poly.draw(color, window, width, fill)


    def calcEnvelope(self):
        '''Calculates the minimum bounding box.'''
        minX = self.polygons[0].envelope[0][0]
        maxX = self.polygons[0].envelope[1][0]
        minY = self.polygons[0].envelope[0][1]
        maxY = self.polygons[0].envelope[1][1]

        for p in self.polygons:
            if p.envelope[0][0] < minX: minX = p.envelope[0][0]
            if p.envelope[1][0] > maxX: maxX = p.envelope[1][0]
            if p.envelope[0][1] < minY: minY = p.envelope[0][1]
            if p.envelope[1][1] > maxY: maxY = p.envelope[1][1]
        self.envelope = [(minX, minY), (maxX, maxY)]









