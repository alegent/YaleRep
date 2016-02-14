# Name:        TextureAna.py
# Purpose:     A modual including functions for generating texture measures
#
# Author:      Mao-Ning Tuanmu
#
# Created:     13/04/2012
# Copyright:   (c) Mao-Ning Tuanmu 2012
# Licence:     <your licence>
#
# Version:     v0.1 - reScale(), GLCM(), calcMetric()
#              v0.2 (04/2012) -
#                   use masked arrays to improve the ability of the functions to
#                       deal with missing data
#                   add functions to calculate the first order texture measures
#                   add functions to calculate multiple texture measures
#              v0.3 (05/2012) -
#                   update GLCM() and associated calcMetric(), so that they calculate
#                       GLCMs with 4 directions
#                   add GLCM2() and associated calcMetric2(), which average GLCMs
#                       of all 4 directions BEFORE calculating metrics (they may
#                       replace GLCM() and calcMetric() in the future)
#              v0.4 (09/2012) -
#                   replace numpy as scipy
#                   add calculation of skewness to Stat and calcStat
#-------------------------------------------------------------------------------

#import numpy
import scipy as sp
import scipy.stats as stats


def reScale(Array, MaxMin=None, level=64, NoData=-9999):
    '''Rescale pixel values

    MaxMin should be a list containing max and min (max,min)
    it will be calculated from the inputed array if it is not provided'''


    if isinstance(Array, sp.ma.MaskedArray):
        Array = Array.astype(float)
    else:
        Array = sp.ma.masked_values(Array, NoData).astype(float)

    if MaxMin == None:
        Max = Array.max()
        Min = Array.min()
        Range = Max-Min
    else:
        Max = MaxMin[0]
        Min = MaxMin[1]
        Range = Max-Min

    Array = sp.where(Array<Min, Min, Array)
    Array = sp.where(Array>Max, Max, Array)
    newArray = ((Array - Min)/Range*(level-1)).round()

    return newArray


def calcPercentile(Array, percentList=[0.025, 0.975], NoData=-9999):
    '''Calculates specified percentiles for a masked array'''

    if isinstance(Array, sp.ma.MaskedArray):
        Array = Array.astype(float)
    else:
        Array = sp.ma.masked_values(Array, NoData).astype(float)

    percent = stats.mstats.mquantiles(Array, prob=percentList)

    return percent


#def GLCM(Array, level, direct='H', NoData=-9999):
#    '''Generates a GLCM from an array with specified direction
#
#    direct can be 'H' for horizontal, 'V' for vertical,
#    'D1' for diagonal (45 degree), or 'D2' for diagonal (135 degree)'''

#    import numpy

#    if type(Array) is not numpy.ma.core.MaskedArray:
#        Array = numpy.ma.masked_values(Array, NoData)

#    newArray = numpy.zeros([level, level])
#    if direct == 'H':
#        for r in range(Array.shape[0]):
#            for c in range(Array.shape[1]-1):
#                if not Array.mask[r,c] and not Array.mask[r,c+1]:
#                    newArray[Array[r,c], Array[r,c+1]] += 1
#                    newArray[Array[r,c+1], Array[r,c]] += 1
#    elif direct == 'V':
#        for r in range(Array.shape[0]-1):
#            for c in range(Array.shape[1]):
#                if not Array.mask[r,c] and not Array.mask[r+1,c]:
#                    newArray[Array[r,c], Array[r+1,c]] += 1
#                    newArray[Array[r+1,c], Array[r,c]] += 1
#    elif direct == 'D1':
#        for r in range(Array.shape[0]-1):
#            for c in range(1, Array.shape[1]):
#                if not Array.mask[r,c] and not Array.mask[r+1,c-1]:
#                    newArray[Array[r,c], Array[r+1,c-1]] += 1
#                    newArray[Array[r+1,c-1], Array[r,c]] += 1
#    elif direct == 'D2':
#        for r in range(Array.shape[0]-1):
#            for c in range(Array.shape[1]-1):
#                if not Array.mask[r,c] and not Array.mask[r+1,c+1]:
#                    newArray[Array[r,c], Array[r+1,c+1]] += 1
#                    newArray[Array[r+1,c+1], Array[r,c]] += 1

#    newArray = newArray/newArray.sum()

#    return newArray


def GLCM2(Array, level, NoData=-9999):
    '''Generates a GLCM from an array with all four directions

    '''

    if type(Array) is not sp.ma.core.MaskedArray:
        Array = sp.ma.masked_values(Array, NoData)

    newArray1 = sp.zeros([level, level])
    for r in range(Array.shape[0]):
        for c in range(Array.shape[1]-1):
            if not Array.mask[r,c] and not Array.mask[r,c+1]:
                newArray1[Array[r,c], Array[r,c+1]] += 1
                newArray1[Array[r,c+1], Array[r,c]] += 1
    if newArray1.sum() != 0:
        newArray1 = newArray1/newArray1.sum()

    newArray2 = sp.zeros([level, level])
    for r in range(Array.shape[0]-1):
        for c in range(Array.shape[1]):
            if not Array.mask[r,c] and not Array.mask[r+1,c]:
                newArray2[Array[r,c], Array[r+1,c]] += 1
                newArray2[Array[r+1,c], Array[r,c]] += 1
    if newArray2.sum() != 0:
        newArray2 = newArray2/newArray2.sum()

    newArray3 = sp.zeros([level, level])
    for r in range(Array.shape[0]-1):
        for c in range(Array.shape[1]-1):
            if not Array.mask[r,c] and not Array.mask[r+1,c+1]:
                newArray3[Array[r,c], Array[r+1,c+1]] += 1
                newArray3[Array[r+1,c+1], Array[r,c]] += 1
    if newArray3.sum() != 0:
        newArray3 = newArray3/newArray3.sum()

    newArray4 = sp.zeros([level, level])
    for r in range(Array.shape[0]-1):
        for c in range(1, Array.shape[1]):
            if not Array.mask[r,c] and not Array.mask[r+1,c-1]:
                newArray4[Array[r,c], Array[r+1,c-1]] += 1
                newArray4[Array[r+1,c-1], Array[r,c]] += 1
    if newArray4.sum() != 0:
        newArray4 = newArray4/newArray4.sum()

    newArray = (newArray1 + newArray2 + newArray3 + newArray4)/4.0

    return newArray



def CON(glcm):
    '''Calculates Contrast from a GLCM'''

    value = 0
    for r in range(len(glcm[0])):
        for c in range(len(glcm[1])):
            if glcm[r,c] != 0:
                value += glcm[r,c]*((r-c)**2)

    return value


def DIS(glcm):
    '''Calculates Dissimilarity from a GLCM'''

    value = 0
    for r in range(len(glcm[0])):
        for c in range(len(glcm[1])):
            if glcm[r,c] != 0:
                value += glcm[r,c]*abs(r-c)

    return value


def HOM(glcm):
    '''Calculates Homogeneity from a GLCM'''

    value = 0
    for r in range(len(glcm[0])):
        for c in range(len(glcm[1])):
            if glcm[r,c] != 0:
                value += glcm[r,c]/((r-c)**2 + 1)

    return value



def ASM(glcm):
    '''Calculates Angular Second Moment from a GLCM'''

    value = 0
    for r in range(len(glcm[0])):
        for c in range(len(glcm[1])):
            if glcm[r,c] != 0:
                value += glcm[r,c]**2

    return value


def GLCMMAX(glcm):
    '''Calculates Maximum Probability from a GLCM'''

    return glcm.max()


def ENT(glcm):
    '''Calculates Entropy from a GLCM'''

    import math
    value = 0
    for r in range(len(glcm[0])):
        for c in range(len(glcm[1])):
            if glcm[r,c] != 0:
                value += glcm[r,c]*(math.log(glcm[r,c])*(-1))

    return value


def GLCMMEAN(glcm):
    '''Calculates GLCM Mean from a GLCM'''

    value = 0
    for r in range(len(glcm[0])):
        for c in range(len(glcm[1])):
            if glcm[r,c] != 0:
                value += glcm[r,c]*r

    return value


def GLCMVAR(glcm):
    '''Calculates GLCM Variance from a GLCM'''

    m = GLCMMEAN(glcm)
    value = 0
    for r in range(len(glcm[0])):
        for c in range(len(glcm[1])):
            if glcm[r,c] != 0:
                value += glcm[r,c]*(r-m)**2

    return value


def GLCMSD(glcm):
    '''Calculates GLCM SD from a GLCM'''

    return GLCMVAR(glcm)**0.5


def COR(glcm):
    '''Calculates Correlation from a GLCM'''

    m = GLCMMEAN(glcm)
    v = GLCMVAR(glcm)
    value = 0
    if v != 0:
        for r in range(len(glcm[0])):
            for c in range(len(glcm[1])):
                if glcm[r,c] != 0:
                    value += glcm[r,c] * (((r-m)*(c-m))/v)

    return value


def calcGLCM(Array, level, direct, NoData=-9999):
    '''Generates GLCMs with multiple directions

        direct is a list of directions
        it could be a subset of ['H','V','D1','D2']
        return a dictionary'''

    glcmDic = {}
    for d in direct:
        glcmDic[d] = GLCM(Array, level, d, NoData)

    return glcmDic

'''
def calcMetric(glcmDic, metric, avg=False):
    Calculates multiple texture measures based on multiple GLCMs

        glcmDic is a dictionary generated by using calcGLCM

        metric is a list of the name of texture measures
        it could be a subset of ['CON','DIS','HOM','ASM',
        'MAX','ENT','GLCMMEAN','GLCMVAR','GLCMSD','COR']

    metricDic = {}
    for d in glcmDic.iterkeys():
        valueDic = {}
        for m in metric:
            valueDic[m] = eval(m + "(glcmDic[d])")
        metricDic[d] = valueDic

    if avg:
        metricDic['A'] = {}
        for m in metric:
            average = (metricDic['H'][m] + metricDic['V'][m] + metricDic['D1'][m] + metricDic['D2'][m])/4.0
            metricDic['A'][m] = average

    return metricDic
'''

def calcMetric2(glcm, metric):
    '''Calculates multiple texture measures based on the GLCM calculated with all directions

        glcm is an array generated by using GLCM2

        metric is a list of the name of texture measures
        it could be a subset of ['CON','DIS','HOM','ASM',
        'MAX','ENT','GLCMMEAN','GLCMVAR','GLCMSD','COR']

        returns a dictionary of metrics'''

    metricDic = {}

    for m in metric:
        metricDic[m] = eval(m + "(glcm)")

    return metricDic

#            if m == 'CON':
#                valueDic[m] = (CON(glcm))
#        elif m == 'DIS':
#            valueList.append(DIS(glcm))
#        elif m == 'HOM':
#            valueList.append(HOM(glcm))
#        elif m == 'ASM':
#            valueList.append(ASM(glcm))
#        elif m == 'MAX':
#            valueList.append(MAX(glcm))
#        elif m == 'ENT':
#            valueList.append(ENT(glcm))
#        elif m == 'GLCMMEAN':
#            valueList.append(GLCMMEAN(glcm))
#        elif m == 'GLCMVAR':
#            valueList.append(GLCMVAR(glcm))
#        elif m == 'GLCMSD':
#            valueList.append(GLCMSD(glcm))
#        elif m == 'COR':
#            valueList.append(COR(glcm))
#        else:
#            valueList.append(None)

#    return valueList


def Stat(Array, stat, NoData=-9999):
    '''Calculates a statistic from an array and returns the statistic.

        stat='mean': mean
        stat='sum': sum
        stat='max': maximum
        stat='min': minimum
        stat='std': standard deviation
        stat='cv': coefficient of variation
        stat='range': range (maximum-minimum)
        stat='skew': skewness
        stat='qt0.XX': 0.XX quantile (e.g., 0.95)
        '''

    if type(Array) is not sp.ma.core.MaskedArray:
        Array = sp.ma.masked_values(Array, NoData)

    if stat == 'mean' or stat == 'sum' or stat == 'max' or stat == 'min' or stat == 'std':
        value = eval('Array.' + stat + '()')
    elif stat == 'cv':
        if Array.mean() != 0:
            value = Array.std() / Array.mean()
        else:
            value = -9999
    elif stat == 'range':
        value = Array.max() - Array.min()
    elif stat == 'skew':
        value = float(stats.mstats.skew(Array, axis=None).data)
    elif stat.startswith('qt'):
        value = float(stats.mstats.mquantiles(Array, [float(stat[2:])]))

    return value


def calcStat(Array, statList, NoData=-9999):
    '''Calculates multiple statistics from an array and returns
        the statistics as a dictionary

        statList can be a subset of ['mean','sum','max','min','std','cv','range','skew','qt0.05'...]'''

    valueDic = {}
    for stat in statList:
        valueDic[stat] = Stat(Array, stat, NoData)

    return valueDic


