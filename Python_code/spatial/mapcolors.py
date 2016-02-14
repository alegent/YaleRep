# mapcolors.py
# This code provides some color ramps for use 
# with raster and vector maps.
# Uses a ColorBrewer ramp or two.
# ColorBrewer Reference: 
# Brewer, Cynthia A., 2007. http://www.ColorBrewer.org, 
# last accessed in March, 2009
#
# Written by A. Shortridge, 1-3/2007. 3/2009
# Modified 3/2007 to add more classes and extend monoshade support.

# One approach is to hardcode some classes, like these Yellow-Green ones.
# The 3-pair tuple are R G B values, ranging from 0 (none) to 255 (saturated)

YlGn7 = [(255,255,204),(217,240,163),(173,221,142),
         (120,198,121),(65,171,93),(35,132,67),(0,90,50)]

YlGn4 = [(255,255,204),(194,230,153),(120,198,121),(35,132,67)]

############################################
# A better approach is to call a function  #
# Here are several that return the correct #
# number of colors for 1 - 7 classes.      #
############################################

def BrewerYG(nclasses):
    '''Returns a list of Yellow-Green RGB tuples for map shades.
    
    Figures out the best set of values. Only handles 
    up to 7 colors.'''
    
    if nclasses < 4:
        return [(247,252,185),(173,221,142),(49,163,84)]
    if nclasses == 4:
        return [(255,255,204),(194,230,153),(120,198,121),(35,132,67)]
    if nclasses == 5:
        return [(255,255,204),(194,230,153),(120,198,121),
                (49,163,84),(0,104,55)]
    if nclasses == 6:
        return [(255,255,204),(217,240,163),(173,221,142),
         (120,198,121),(49,163,84),(0,104,55)]
    else:
        return [(255,255,204),(217,240,163),(173,221,142),
         (120,198,121),(65,171,93),(35,132,67),(0,90,50)]

def BrewerGB(nclasses):
    '''Returns a list of Green-Blue RGB tuples for map shades.
    
    Figures out the best set of values. Only handles 
    up to 7 colors.'''
    
    if nclasses < 4:
        return [(224,243,219),(168,221,181),(67,162,202)]
    if nclasses == 4:
        return [(240,249,232),(186,228,188),(123,204,196),(43,140,190)]
    if nclasses == 5: 
        return [(240,249,232),(186,228,188),(123,204,196),
                (67,162,202),(8,104,172)]
    if nclasses == 6:
        return [(240,249,232),(204,235,197),(168,221,181),
                (123,204,196),(67,162,202),(8,104,172)]
    else:
        return [(240,249,232),(204,235,197),(168,221,181),
        (123,204,196),(78,179,211),(43,140,190),(8,88,158)]

def BrewerPurp(nclasses):
    '''A sequential ramp from white to purple.'''
    if nclasses < 4:
        return [(239,237,245),(188,189,220),(117,107,177)]
    if nclasses == 4:
        return [(242,240,247),(203,201,226),(158,154,200),(106,81,163)]
    if nclasses == 5: 
        return [(242,240,247),(203,201,226),(158,154,200),(117,107,177), (84,39,143)]
    if nclasses == 6:
        return [(242,240,247),(218,218,235),(188,189,220),(158,154,200), (117,107,177),(84,39,143)]
    else:
        return [(242,240,247),(218,218,235),(188,189,220),(158,154,200), (128,125,186),(106,81,163),(74,20,134)]

def BrewerBR(nclasses):
    '''A diverging ramp from blue to red.'''
    if nclasses < 4:
        return [(145,191,219),(255,255,191),(252,141,89)]
    if nclasses == 4:
        return [(44,123,182),(171,217,233),(253,174,97),(215,25,28)]
    if nclasses == 5: 
        return [(44,123,182),(171,217,233),(255,255,191), 
                (253,174,97),(215,25,28)]
    if nclasses == 6:
        return [(69,117,180),(145,191,219),(224,243,248),(254,224,144),           (252,141,89),(215,48,39)]
    else:
        return [(69,117,180),(145,191,219),(224,243,248),(255,255,191), 
                (254,224,144),(252,141,89),(215,48,39)]

def BrewerPG(nclasses):
    '''A diverging ramp from purple to green.'''
    if nclasses < 4:
        return [(175,141,195),(247,247,247),(127,191,123)]
    if nclasses == 4:
        return [(123,50,148),(194,165,207),(168,216,183),(0,136,55)]
    if nclasses == 5: 
        return [(123,50,148),(194,165,207),(247,247,247),                         (168,216,183),(0,136,55)]
    if nclasses == 6:
        return [(118,42,131),(175,141,195),(231,212,232),(217,240,211),           (127,191,123),(27,120,55)]
    else:
        return [(118,42,131),(175,141,195),(231,212,232),(247,247,247),           (217,240,211), (127,191,123),(27,120,55)]

def BrewerQual(nclasses=7):
    '''A qualitative ramp for categorical data.'''
    return [(228,26,28),(55,126,184),(77,175,74),(152,78,163),           (255,127,0), (255,255,51),(166,86,40)]

###################################################
# For greater flexibility, here's a function that #
# returns a monoscale ramp for any number of      #
# classes - at least less than 254 classes.       #
###################################################
def monoShade(nclasses, color='gray'):
    '''Calculates and returns RGB grayshades.
    
    Possible color codes include 'gray', 'red', 'green', and 'blue'.
    Works on any reasonable number of classes(?).'''
    
    indexBreaks = range(0, 255, (255 / (nclasses-1)))
    shades = []
    for i in range(0, nclasses):
        if color == 'red':
            shades.append((indexBreaks[i],0,0))
        elif color == 'green':
            shades.append((0,indexBreaks[i],0))
        elif color == 'blue':
            shades.append((0,0,indexBreaks[i]))
        else:
            shades.append((indexBreaks[i],indexBreaks[i],indexBreaks[i]))
    return shades

##########################################################
# A nominal Shadeset designed for National Landcover     #
# Datasets (NLCD) using Anderson Level 2 Classification. #
##########################################################

def nlcdColor(nodata_number):
    '''USGS shades for NLCD land cover Anderson Level II.'''
    nlcdShades = {nodata_number:(0,0,0), 11:(102,140,191), 12:(255,255,255), 21:(252,227,22), 22:(247,171,158), 23:(230,87,77), 31:(209,204,191), 32:(176,176,176), 33:(81,60,117), 41:(135,199,128), 42:(56,130,79), 43:(211,232,176), 51:(219,201,117), 61:(186,173,117), 71:(252,232,171), 81:(252,247,94), 82:(201,145,71), 83:(121,107,73), 84:(245,237,204), 85:(240,156,54), 91:(201,230,250), 92:(145,191,217)}
    
    return nlcdShades
