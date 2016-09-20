# rasterize the shapefile

ls   $INDIR/*.shp   | xargs -n 1  -P 16 bash -c   $'  
file=$1
filename=$(basename $file .shp )
rm -f  $OUTDIR/$filename.tif
gdal_rasterize   -ot Byte    -a_srs EPSG:4326  -l $filename   -burn 1   -a_nodata 0  -tap   -tr   0.008333333333333 0.008333333333333    -co COMPRESS=L
ZW -co ZLEVEL=9    -co PREDICTOR=2   $INDIR/$filename.shp    $OUTDIR/$filename.tif
' _


