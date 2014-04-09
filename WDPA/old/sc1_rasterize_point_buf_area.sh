
module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0


# rasterize buffer 

export RASTERIZE=/lustre0/scratch/ga254/dem_bj/WDPA/rasterize_all 
export SHP=/lustre0/scratch/ga254/dem_bj/WDPA

gdal_rasterize -ot Byte -a_srs EPSG:4326 -l WDPA_point_Jan2014EPSG4326Buf \
-burn 1   -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te  $(getCorners4Gwarp /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif )  -co COMPRESS=LZW \
-co ZLEVEL=9  $SHP/shp_buf/WDPA_point_Jan2014EPSG4326Buf.shp    $RASTERIZE/WDPA_point_Jan2014EPSG4326Buf.tif
 
# rasterize point 
rm -f $RASTERIZE/WDPA_point_Jan2014.tif 

gdal_rasterize -ot Byte -a_srs EPSG:4326 -l WDPA_point_Jan2014  -burn 1   -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te  $(getCorners4Gwarp /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif )  -co COMPRESS=LZW \
-co ZLEVEL=9   $SHP/shp_input/WDPA_Jan2014.shp/WDPA_point_Jan2014.shp   $RASTERIZE/WDPA_point_Jan2014.tif 


# rasterize areas 

gdal_rasterize -ot Byte -a_srs EPSG:4326 -l  -burn 1   -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te  $(getCorners4Gwarp /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif )  -co COMPRESS=LZW \
-co ZLEVEL=9   $SHP/shp_input/WDPA_Jan2014.shp/WDPA_poly_Jan2014.shp    $RASTERIZE/WDPA_poly_Jan2014.tif 


# merge all of them using gdal_mosaic


