
gdal_rasterize -ot UInt16 -a_srs EPSG:4326 -l 360x114global -a ID -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te -180 -90 +180 +90  -co COMPRESS=LZW \
-co ZLEVEL=9 /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global.shp /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114globalID.tif 

gdal_rasterize -ot UInt16 -a_srs EPSG:4326 -l 360x114global -a ID_1 -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te -180 -90 +180 +90  -co COMPRESS=LZW \
-co ZLEVEL=9 /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global.shp /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114globalID_1.tif 

gdal_rasterize -ot UInt16 -a_srs EPSG:4326 -l 360x114global -a HBWID  -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te -180 -90 +180 +90  -co COMPRESS=LZW \
-co ZLEVEL=9 /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global.shp /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114globalHBWID.tif 
