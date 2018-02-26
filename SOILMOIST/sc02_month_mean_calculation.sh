


gdalbuildvrt -separate  test.vrt *.tif 
pkstatprofile  -i  test.vrt   -f median --nodata -9999 -o test.tif
