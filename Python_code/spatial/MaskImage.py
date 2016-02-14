# Name:        MaskImage.py
# Purpose:     A modual including functions for generating a masked image
#
# Author:      Mao-Ning Tuanmu
#
# Created:     24/04/2012
# Copyright:   (c) Mao-Ning Tuanmu 2012
# Licence:     <your licence>
#
#-------------------------------------------------------------------------------

def isFlag(INT, bitLoc, flag='1', bitType='16S'):
    '''Checks if the specified bit in an integer indicates a flag and
        returns a Boolean (True or False)

        bitType is the bit type of the input INT, which is something like:
            '16S' (16-bit signed)
            '8U' (8-bit unsigned)
        bitLoc is counted from the right and starts from 0'''

    signed = bitType[-1] == 'S'
    bits = bitType[:-1]

    bitStr = bin(INT)
    if signed and bitStr[0] == '-':
        bitStr = bitStr[3:].rjust(int(bits),'0')
    else:
        bitStr = bitStr[2:].rjust(int(bits),'0')

    YN = bitStr[len(bitStr)-(bitLoc+1)] == flag
    return YN


def raiseFlag(INT, bitLoc, flag='1', bitType='16S'):
    '''Raises a flag at the specified bit and returns the number'''

    signed = bitType[-1] == 'S'
    bits = int(bitType[:-1])

    bitStr = bin(INT)
    if signed and bitStr[0] == '-':
        head = bitStr[:2]
        zeroOne = bitStr[3:].rjust(bits,'0')
    else:
        head = bitStr[:1]
        zeroOne = bitStr[3:].rjust(bits,'0')

    newLoc = bits - (bitLoc+1)
    newStr = head + zeroOne[:newLoc] + flag + zeroOne[(newLoc+1):]

    return int(newStr, 2)



def createMask(Array, bitLocList, flags, bitType='16S'):
    '''Creates a Boolean array as a mask

        bitLocList is a list of all locations which will be checked for flags
        flags is a list of flags ('1' or '0'), which has the same length of bitLocList'''

    import numpy

    if type(Array) is not numpy.ndarray or not numpy.ma.core.MaskedArray:
        Array = numpy.array(Array)

    if type(Array) is numpy.ma.core.MaskedArray:
        allValues = list(set(Array.data.flatten()))
    else:
        allValues = list(set(Array.flatten()))

    allFlags = []
    for value in allValues:
        for i in range(len(bitLocList)):
            if isFlag(value, bitLocList[i], flags[i], bitType):
                allFlags.append(value)

    for f in allFlags:
        Array = numpy.ma.masked_values(Array, f)

    return Array.mask


def modifyQA(QA, bitLoc, flag, mask):
    '''Modifies the flags in a QA (quality assessment) band

        QA should be an array and flag should be either '1' or '0'
        currently only for modifying an unused bit location'''


    if flag == 1:
        newQA = QA + (mask * 2**bitLoc)
    else:
        newQA = QA - (mask * 2**bitLoc)

    return newQA



### below could be removed later ###
def createMask2(Array, bitLocList, flags, bitType='16S'):
    '''Creates a Boolean array as a mask

        bitLocList is a list of all locations which will be checked for flags
        flags is a list of flags ('1' or '0'), which has the same length of bitLocList'''

    import numpy
    if type(Array) is not numpy.ndarray or not numpy.ma.core.MaskedArray:
        Array = numpy.array(Array)

    rowArray = []
    for r in range(Array.shape[0]):
        colArray = []
        for c in range(Array.shape[1]):
            YN = False
            for i in range(len(bitLocList)):
                if isFlag(Array[r,c], bitLocList[i], flags[i], bitType):
                    YN = True
                    break
            colArray.append(YN)
        rowArray.append(colArray)
#    return rowArray

    mk = numpy.ma.make_mask(rowArray)
    return mk


