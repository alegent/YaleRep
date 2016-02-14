# raster.py
# A raster class, with graphical methods
# for display of geographic raster data.
# Requires pygame and mapcolors (homebrew).
#
# written by A. Shortridge, 1/2007, 2/2007, 3/2009
# extended by Mao-Ning Tuanmu, 2009, 2011, 2012

# versions
# 0.4.9 (7/12/12) - The function of reScale is updated to improve this efficiency
# 0.4.8 (5/22/12) - An attribute 'proj', which is a string of projection information, is added
#
# 0.4.7 (4/5/12) - the function mapAlgebra() is disabled and re-written as an independent module
#                   A new function reScale() is added
#
# 0.4.6 (8/12/11) - A new function, pointExtract(), which extract the pixel value
#                   for a point, is added
# 0.4.5 (7/8/09) - A new function, mapAlgebra(), which deals with operations among
#                  Rasters, is added
# 0.4.4 (6/4/09) - A new function countCells(), which counts the number of cells
#                 whose values satisfying specified conditions, is added.
# 0.4.3 (4/24/09) - The function reclass is modified, so it can deal with several classes.
# 0.4.2 (4/23/09) - Functions for basic operation is improved. The operand can be a Raster.
# 0.4.1 (4/22/09) - The function focalSum() is renamed as filter().
#                  A new function localStat(), which calculates some statistics
#                  within a window and returns a Raster, is added.
# 				   Problems of assigning colorValues have been solved.
# 0.4 (4/6/09) - The Raster.elements is changed to an instance of numpy.ma,
#                 so that the code can deal with nodata values.
#                 The focalSum() is modifed for the new data type.
#                 The reclass() and classValues(), modifed from Shortridge's code, are added.
# 0.3 (4/5/09) - The Raster.elements is changed to an instance of numpy.ndarray.
#                Functions of basic operations are added.
#                One attribute containing some global statistics is added.
# 0.28 (3/30/09) - Lots more color ramps are defined
# 0.25 (3/30/09) - NoData values are colored appropriately
# 0.2 (2/24/07)  - Better documented, integrated with GISgraphics.py
# 0.1 (2/18/07) -  It lives! Draws a decent raster.


#import GISgraphics    # A homebrew module for drawing the raster
#import mapcolors      # A homebrew module with color shades

# A few small test raster things to experiment with.
testRast = [[1,2,3],[2,3,4],[4,6,7],[5,6,8]]
biggerRast = [[20,24,36,-9999,21,16,12],
              [26,31,38,35,31,25,20],
              [25,28,35,31,36,27,24],
              [21,24,31,35,40,34,31],
              [19,23,26,28,37,29,26]]

class Raster:
    '''A class for Raster data.'''

    def __init__(self, twoDArray=[[1,1],[2,2],[3,3]], \
        cellsize=1, Xll=0, Yll=0, nodata=-9999, proj=''):

        from numpy import ma
        self.elements = ma.masked_values(twoDArray, nodata)  # changes the array to a masked array
        self.nrows = len(self.elements)
        self.ncols = len(self.elements[0])
        self.cellsize = cellsize
        self.nodata = nodata
        self.proj = proj
        self.Xll = Xll
        self.Yll = Yll
#        self.envelope = [(Xll, Yll), (Xll + (cellsize * (self.ncols+1)), Yll + (cellsize * (self.nrows+1)))]
        self.envelope = [(Xll, Yll), (Xll + (self.cellsize * self.ncols), Yll + (self.cellsize * self.nrows))]  # changed on 8/12/2011
#        self.color()
#        self.setColor('BrewerYG')
        self.stat = Raster.calcStat(self)  # calculates some statistics



    def __str__(self):
        return self.elements.__str__()


    def __add__(self, operand):
        '''Adds the operand to each cell of the raster and returns a raster

        operand should be a scaler or a Raster instance'''
        if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
            return Raster(self.elements+operand, self.cellsize, self.Xll, self.Yll, self.nodata)
        elif isinstance(operand, Raster):
            return Raster(self.elements+operand.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        else:
            print 'This type of operands cannot be operated'
            return


    def __radd__(self, operand):
        if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
            return Raster(operand+self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        elif isinstance(operand, Raster):
            return Raster(operand.elements+self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        else:
            print 'This type of operands cannot be operated'
            return


    def __sub__(self, operand):
        '''Substracts the operand from each cell of the raster'''
        if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
            return Raster(self.elements-operand, self.cellsize, self.Xll, self.Yll, self.nodata)
        elif isinstance(operand, Raster):
            return Raster(self.elements-operand.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        else:
            print 'This type of operands cannot be operated'
            return


    def __rsub__(self, operand):
        if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
            return Raster(operand-self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        elif isinstance(operand, Raster):
            return Raster(operand.elements-self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        else:
            print 'This type of operands cannot be operated'
            return


    def __mul__(self, operand):
        if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
            return Raster(self.elements*operand, self.cellsize, self.Xll, self.Yll, self.nodata)
        elif isinstance(operand, Raster):
            return Raster(self.elements*operand.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        else:
            print 'This type of operands cannot be operated'
            return


    def __rmul__(self, operand):
        if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
            return Raster(operand*self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        elif isinstance(operand, Raster):
            return Raster(operand.elements*self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
        else:
            print 'This type of operands cannot be operated'
            return


    def __div__(self, operand):
        if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
            if operand != 0:
                return Raster(self.elements/operand, self.cellsize, self.Xll, self.Yll, self.nodata)
            else:
                print 'A divisor cannot be 0'
                return

        elif isinstance(operand, Raster):
            if not 0 in operand.elements:
                return Raster(self.elements/operand.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
            else:
                print 'A divisor cannot be 0'
                return
        else:
            print 'This type of operands cannot be operated'
            return


    def __rdiv__(self, operand):
        if 0 in self.elements:
            print 'A divisor cannot be 0'
            return
        else:
            if isinstance(operand, int) or isinstance(operand, float) or isinstance(operand, long):
                return Raster(operand/self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
            elif isinstance(operand, Raster):
                return Raster(operand.elements/self.elements, self.cellsize, self.Xll, self.Yll, self.nodata)
            else:
                print 'This type of operands cannot be operanted'
                return


    def calcStat(self):
        '''Calculates global statistics, including mean, max, min, and sd.
        and returns them as a dict'''

        mean = self.elements.mean()
        max = self.elements.max()
        min = self.elements.min()
        std = self.elements.std()
        sum = self.elements.sum()
        stat = {'mean':mean, 'max':max, 'min':min, 'std':std, 'sum':sum}
        return stat



    def filter(self, window):
        '''Generate a new Raster by passing a moving window over
        self, summing the (weighted) values.

        the moving window should be a list of lists and have an odd number of
        rows and columns.'''

        import numpy
        omitCell = len(window)/2  # the number of rows and cols which are on the edge
        newArray = numpy.empty([self.nrows, self.ncols])
        newArray.fill(self.nodata)  # let cells on the edge have values of nodata
        for r in range(omitCell, self.nrows - omitCell):
            for c in range(omitCell, self.ncols - omitCell):
                subset = self.elements[(r-omitCell):(r+omitCell+1), (c-omitCell):(c+omitCell+1)].copy()  # subset from original raster
                weighted = subset * window
                newArray[r,c] = weighted.sum()
        return Raster(newArray, self.cellsize, self.Xll, self.Yll, self.nodata)


    def localStat(self, stat, window):
        '''Calculate some statistics within a window and returns a Raster with
        the statistic.

        The window should be a list of lists with 0 and 1, which indicate whether
        corresponding pixels are used for calculating the statistic.
        The window should have an odd number of rows and columns and the statistic
        is assigned as the value of the center pixel.'''

        import numpy
        omitCell = len(window)/2
        newArray = numpy.empty([self.nrows, self.ncols])
        newArray.fill(self.nodata)
        for r in range(omitCell, self.nrows - omitCell):
            for c in range(omitCell, self.ncols - omitCell):
                subset = self.elements[(r-omitCell):(r+omitCell+1), (c-omitCell):(c+omitCell+1)].copy()
                for wr in range(len(window)):
                    for wc in range(len(window[0])):
                        if window[wr][wc] == 0:
                            subset.mask[wr,wc] = True    # mask out the values corresponding to 0 values in the window
                if stat == 'mean':
                    newArray[r,c] = subset.mean()
                elif stat == 'sum':
                    newArray[r,c] = subset.sum()
                elif stat == 'max':
                    newArray[r,c] = subset.max()
                elif stat == 'min':
                    newArray[r,c] = subset.min()
                elif stat == 'std':
                    newArray[r,c] = subset.std()
                else:
                    print stat, 'cannot be calculated'
                    return

        return Raster(newArray, self.cellsize, self.Xll, self.Yll, self.nodata)


    def reclass(self, conditions):
        '''A conditional function for rasters. Creates and returns a new raster.

        The conditions should be a list of tuples.  Each tuple contains three values:
        the lower boundary, upper boundary, and new value.
        If the old values are larger than or equal to the lower boundary and are smaller
        than the higher boundary, the old values will be changed to the corresponding
        new values.
        e.g. for the conditions: [(0, 10, 1), (10, 20, 2)]
        5 will be changed to 1, 10 will be changed to 2, and 20 will be still 20.'''

        newArray = self.elements.copy()

        for r in range(self.nrows):
            for c in range(self.ncols):
                for con in conditions:  # loop through each condition
                    if con[0] <= newArray[r,c] < con[1]:
                         newArray[r,c] = con[2]
                         break

        return Raster(newArray, self.cellsize, self.Xll, self.Yll, self.nodata)


    def countNeighbor(self, condition, neighborLevel=1):
        '''Count the number of neighbors whose values satisfy the input condition, and return a Raster

        neighborLevel = 1: the surrounding 8 cells
        neighborLevel = 2: the surrounding 8 cells and their neighbors (total 24)
        condition should be a string representing a conditional function,
        e.g. '< 2.5', '== 3'  '''

        import numpy
        omitCell = neighborLevel
        newArray = numpy.empty([self.nrows, self.ncols])
        newArray.fill(self.nodata)
        for r in range(omitCell, self.nrows - omitCell):
            for c in range(omitCell, self.ncols - omitCell):
                subset = self.elements[(r-omitCell):(r+omitCell+1), (c-omitCell):(c+omitCell+1)].copy()
                subset[omitCell, omitCell] = self.nodata
                flatArray = subset.flatten()
                count = 0
                for cell in flatArray.data:
                    con = eval(str(cell) + condition)
                    if con:
                        count += 1
                newArray[r,c] = int(count)

        return Raster(newArray, self.cellsize, self.Xll, self.Yll, self.nodata)



    def getElements(self):
        return self.elements.data.tolist()


    def countCells(self, condition):
        '''Count the number of cells whose values satisfy the specified condition
           and return an integer indicating the number

        condition should be a string representing a conditional function,
        e.g. '< 2.5', '== 3'  '''

        count = 0
        for r in range(self.nrows):
            for c in range(self.ncols):
                try:
                    con = eval(str(self.elements.data[r,c]) + condition)
                except:
                    print 'invalid conditional.'
                    return 0
                if con:
                    count += 1
        return count

    def pointExtract(self, pt):
        '''Extract the pixel value based on the coordinate (x,y) of a point

        pt should be a tuple composed of x and y coordinates '''

        c = int((pt[0] - self.Xll)/self.cellsize)
        r = self.nrows - int((pt[1] - self.Yll)/self.cellsize) - 1
        value = self.elements.data[r,c]
        return value

    def reScale(self, MaxMin=None, bit=4):
        '''Rescale pixel values'''

        Array = self.elements.astype(float)

        if MaxMin == None:
            Max = Array.max()
            Min = Array.min()
        else:
            Max = MaxMin[0]
            Min = MaxMin[1]

        Range = Max-Min

        Array = numpy.where(Array<Min, Min, Array)
        Array = numpy.where(Array>Max, Max, Array)
        newArray = ((Array - Min)/Range*(2**bit-1)).round()

        return newArray



###  below is not used now ###
    def setBreaks(self, nclasses):
        '''Set the number of classes to color or shade.

        Actually, this creates a new set of elements
        broken into the requisite number of classes.'''
        self.colorBreaks = nclasses
        self.colorValues = Raster.rampValues(self)


    def setColor(self, shadeset, monoColor='gray'):
        '''Sets the color ramp and number of classes.

        Currently there are 5 continuous ramps, 1 continuous
        grayscale (or monoshade), and one unordered ramp.
        The zero'th element in each ramp is black, for nodata.'''
        if shadeset == 'BrewerYG':
            self.colorSet = mapcolors.BrewerYG(self.colorBreaks)
        elif shadeset == 'BrewerGB':
            self.colorSet = mapcolors.BrewerGB(self.colorBreaks)
        elif shadeset == 'BrewerPurp':
            self.colorSet = mapcolors.BrewerPurp(self.colorBreaks)
        elif shadeset == 'BrewerBR':
            self.colorSet = mapcolors.BrewerBR(self.colorBreaks)
        elif shadeset == 'BrewerPG':
            self.colorSet = mapcolors.BrewerPG(self.colorBreaks)
        elif shadeset == 'BrewerQual':
            self.colorSet = mapcolors.BrewerQual(self.colorBreaks)
        else:
            self.colorSet = mapcolors.monoShade(self.colorBreaks, monoColor)

        self.colorSet.insert(0, (0 , 0, 0))  # Put black on the front


    def color(self):
        '''Assign colorValues to the Raster depending on types of data (categorical or continuous)'''

        cells = self.elements.flatten()
        unique = len(set(cells))
        if unique < 7:
            self.colorBreaks = unique
            self.colorValues = self.classValues()
        else:
            self.colorBreaks = 7
            self.colorValues = self.rampValues()


    def classValues(self):
        '''Calculates & returns a list of color vals for the raster.

        For categorical rasters only - e.g. land cover class maps.'''
        cells = self.elements.flatten()  # First flatten the array to a list.
        cells.sort()
        cellValues = list(set(cells))   # unique values

        breaks = []
        level = 1
        for v in cellValues:
            breaks.append((level, v))
            level = level + 1

        colorValues = []
        for row in self.elements.data:
            colorRow = []
            for cell in row:
                for val in breaks:
                    if cell == val[1]:
                        colorRow.append(val[0])
                        break
            colorValues.append(colorRow)
        return colorValues


    def rampValues(self):
        '''Calculates & returns a list of color vals for the raster.

        A lot happens here. Cell values are sorted, and this sort
        is divided into a total of n (colorBreaks) classes. Then
        a new raster '2D array' called colorValues is created.
        In fact the values in this raster are not colors; they
        are quantile values. They are matched with RGB values
        elsewhere, at draw time.'''

        flatArray = self.elements.flatten() # First flatten the array to a list.
        flatArray.sort()  # order lowest to highest.
        cells = [c for c in flatArray.data if c != self.nodata]  # get rid of the nodata values

        # Now create a list of bins into which the values will go.
        indexBreaks = range(0, len(cells), (len(cells) / \
                            (self.colorBreaks-1)))
        breaks = []
        level = 1
        for i in indexBreaks[1:]:
            breaks.append((level, cells[i]))
            level = level + 1
        breaks.append((level, (max(cells)+1)))

        colorValues = []
        for row in self.elements.data: # Create new array w/ quantile values
            colorRow = []
            for cell in row:
                if cell == self.nodata: # insert nodata value (0)
                    colorRow.append(0)
                else:
                    for val in breaks:
                        if cell < val[1]:
                            colorRow.append(val[0]) # Put right quantile
                            break
            colorValues.append(colorRow)
        return colorValues


    def draw(self, window):
        '''Uses GISgraphics for a graphical display of the raster.'''

        window.drawRaster(self)




#def mapAlgebra(function, rasterList):
#    '''Applies the specified function to a list of Rasters and returns the result
#       as a Raster
#
#    following functions can be calculated:
#       sum, mean, max, min, std
#    rasterList should be a list of Raster instances which have the same size and location'''

#    import numpy
#    newArray = rasterList[0].elements.copy()
#    for r in range(rasterList[0].nrows):
#        for c in range(rasterList[0].ncols):
#            oneDList = []
#            for rast in rasterList:
#                oneDList.append(rast.elements[r,c])
#            oneDArray = numpy.ma.masked_array(oneDList)
#            if function == 'sum':
#                newArray[r,c] = oneDArray.sum()
#            elif function == 'mean':
#                newArray[r,c] = oneDArray.mean()
#            elif function == 'max':
#                newArray[r,c] = oneDArray.max()
#            elif function == 'min':
#                newArray[r,c] = oneDArray.min()
#            elif function == 'std':
#                newArray[r,c] = oneDArray.std()
#            else:
#                print 'This function cannot be operated'
#                return
#    return Raster(newArray, rasterList[0].cellsize, rasterList[0].Xll, rasterList[0].Yll, rasterList[0].nodata)