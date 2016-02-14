# GISgraphics.py
# Python code implementing classes for the
# graphical display of spatial data. Can
# display vector and raster data.
#
# Requires pygame for the graphics.
# 3/29/2009: updated raster drawing with 'verbose' option
# 3/27/07: fixed glaring georeferencing problem
# 3/25/07: updated to fix floating point issue & raster display problem.
# Written by Ashton Shortridge, 2/2007, 3/2009

import pygame2

class MapWindow:
    '''A class for a graphical window to display GIS data.'''

    def __init__(self, id=1, winXY=(640,480), mapextent=[(0,0),(640,480)]):
        self.window = pygame.display.set_mode(winXY)
        self.caption = ('GIS Window ' + str(id))
        self.screenSize = winXY
        self.mapSize = mapextent
        self.calcXform()   # Creates a dict called self.scale with parameters
                           # Xshift, Yshift, & scalefactor.
        self.bkdColor = (150,150,150)

    def calcXform(self):
        '''Calculates and returns translation & scaling parameters.

        Result is a dictionary with Xshift, Yshift, scaleFactor.'''

        xs = self.mapSize[0][0]      # Translation factors: X is min
        ys = self.mapSize[1][1]      #                      Y is max

        Xextent = self.mapSize[1][0] - self.mapSize[0][0]
        Yextent = self.mapSize[1][1] - self.mapSize[0][1]

        mapRealm = (self.screenSize[0]-10, self.screenSize[1]-10)   # Don't draw to window edge.
        xf = mapRealm[0] / float(Xextent)  # Ratio of screen space to geo space
        yf = mapRealm[1] / float(Yextent)
        if xf > yf:
            scaleFactor = yf
        else: scaleFactor = xf            # This is GIS: scale x and y the SAME!

        self.scale = { 'Xshift'      : xs,
                       'Yshift'      : ys,
                       'scaleFactor' : scaleFactor }


    def display(self):
        '''Actually displays the window in its current state.'''
        pygame.display.set_caption(self.caption)
        pygame.display.flip()


    def clear(self):
        '''Clear the Window'''
        if type(self.bkdColor) == type('colorname'):
            self.window.fill(pygame.color.Color(self.bkdColor))
        else: self.window.fill(self.bkdColor)    # Set background color


    def kill(self):
        '''Get rid of the window.'''
        pygame.display.quit()


    def drawPoints(self, pointList, color, size):
        '''Draws a list of points on the Surface.

        It is also transformed.'''

        for pt in pointList:
            trX = self.scale['scaleFactor'] * \
                  (pt[0] - self.scale['Xshift']) + 5
            trY = self.scale['scaleFactor'] * \
                  (self.scale['Yshift'] - pt[1]) + 5
            pygame.draw.circle(self.window,pygame.color.Color(color),(int(trX),int(trY)),size)


    def drawLines(self, lineList, color, width):
        '''Draws a list of line segments on the Surface.

        This draws a single polyline. The coordinates are also transformed.'''

        scaledList = []
        for pt in lineList:
            trX = self.scale['scaleFactor'] * \
                  (pt[0] - self.scale['Xshift'])
            trY = self.scale['scaleFactor'] * \
                  (self.scale['Yshift'] - pt[1])
            scaledList.append((int(trX) + 5, int(trY) + 5))
        pygame.draw.lines(self.window,pygame.color.Color(color),False,scaledList,width)



    def drawPolygon(self, coordList, color, width=0):
        '''Draws a Polygon on the Surface.

        color can be a named color e.g. 'red' or an RGB tuple.'''
        scaledList = []
        for pt in coordList:
            trX = self.scale['scaleFactor'] * \
                  (pt[0] - self.scale['Xshift'])
            trY = self.scale['scaleFactor'] * \
                  (self.scale['Yshift'] - pt[1])
            scaledList.append((int(trX) + 5, int(trY) + 5))
        if type(color) == type('colorname'):
            pygame.draw.polygon(self.window,pygame.color.Color(color),scaledList,width)
        else: pygame.draw.polygon(self.window,color,scaledList,width)


    def drawRaster(self, raster, verbose=False):
        '''Draws a Raster class object on the Surface.

        raster should be the colorValues thing - a list of lists.
        Color is a list of RGB value tuples.'''

        # Calculate the cell size, in pixels, for the image.
        cspFloat = self.scale['scaleFactor'] * raster.cellsize
        csPixel = int(self.scale['scaleFactor'] * raster.cellsize)
        csPixel = cspFloat

        xll = raster.envelope[0][0]
        yll = raster.envelope[0][1]
        if verbose:
            print 'cell size in pixels is:', csPixel, 'unrounded: ', cspFloat, 'nrows is', raster.nrows

        # Calculate the raster origin, in pixels, for the image
        trY = int(self.scale['scaleFactor'] * (self.scale['Yshift'] - yll)) - ((raster.nrows + 1) * csPixel) + 5
        trX = int(self.scale['scaleFactor'] * (xll - self.scale['Xshift'])) + 5
        if verbose:
            print 'y origin, in pixels:', trY
            print 'x origin, in pixels:', trX
        # Loop through all cells, printing them as rectangles.
        for row in raster.colorValues:
            trY = trY + csPixel
            trX = int(self.scale['scaleFactor'] * (xll - self.scale['Xshift'])) + 5
            for cell in row:
                drawCell = pygame.Rect(trX, trY, int(csPixel)+1, int(csPixel)+1)
                thisColor = raster.colorSet[cell]
                self.window.fill(thisColor, drawCell)
                trX = trX + csPixel
