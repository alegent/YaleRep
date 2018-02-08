# MYDATML2.A2006013.0915.051.2009051005947.hdf

for FILE  in *.hdf ; do 

X=$(gdalinfo HDF4_SDS:UNKNOWN:"$FILE":26 | grep "Size is"| awk   '{  gsub(","," ") ; print $3 -1 }')
Y=$(gdalinfo HDF4_SDS:UNKNOWN:"$FILE":26 | grep "Size is"| awk   '{  gsub(","," ") ; print $4 -1 }')




XUL=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":26 0 0 ) / 100 | bc -l   )
YUL=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":25 0 0 ) / 100 | bc -l   )

XLL=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":26 0 $Y ) / 100 | bc -l   )
YLL=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":25 0 $Y ) / 100 | bc -l   )

XUR=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":26 $X 0 ) / 100 | bc -l   )
YUR=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":25 $X 0 ) / 100 | bc -l   )

XLR=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":26 $X $Y ) / 100 | bc -l   )
YLR=$( echo $(gdallocationinfo -valonly  HDF4_SDS:UNKNOWN:"$FILE":25 $X $Y ) / 100 | bc -l   )


gdal_translate  -a_nodata  -9999  -gcp 0 0 $XUL $YUL -gcp 0 $Y $XLL $YLL -gcp $X 0 $XUR $YUR -gcp $X $Y $XLR $YLR  -a_srs EPSG:4326    HDF4_EOS:EOS_SWATH:"$FILE":atml2:Deep_Blue_Aerosol_Optical_Depth_550_Land   $FILE.tif 

gdalwarp  -srcnodata -9999 -dstnodata -9999  -rpc   -t_srs EPSG:4326    -overwrite  $FILE.tif   warp$FILE.tif 

done 




gdalbuildvrt -srcnodata -9999 -vrtnodata -9999 -overwrite  -hidenodata   year_day.vrt    warp*.tif 
gdal_translate  -a_nodata -9999   -co  COMPRESS=LZW -co ZLEVEL=9      year_day.vrt  Deep_Blue_Aerosol_Optical_year_day.tif



gdalbuildvrt -srcnodata -9999 -vrtnodata -9999 -overwrite  -hidenodata   $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*.tif
gdal_translate  -a_nodata -9999   -co  COMPRESS=LZW -co ZLEVEL=9       $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR/Deep_Blue_Aerosol_Optical_year${YEAR}_day$DAY.tif
