
from raster import *
rast = Raster(testRast)
print rast

sumrast = rast.focalSum()
print sumrast

meanfilter = [[1/9.0, 1/9.0,1/9.0],[1/9.0, 1/9.0,1/9.0],[1/9.0, 1/9.0,1/9.0]]

meanrast = rast.focalSum(meanfilter)
print meanrast

threshrast = sumrast.reclass('> 30', 1, 0)

print threshrast