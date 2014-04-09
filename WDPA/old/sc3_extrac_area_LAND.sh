
OUTDIR=/lustre0/scratch/ga254/dem_bj/WDPA/rasterize_land
DIR=/lustre0/scratch/ga254/dem_bj/WDPA/


pkmosaic   $( for class in 11 12 2 20 21 3 4 5 6; do echo -i  rasterize/$class/IUCN$class.tif ; done ) -cr max  -o $OUTDIR/WDPA_landpoly.tif  

gdal_translate -a_ullr   $(getCorners4Gtranslate   rasterize/6/IUCN6.tif)    -co COMPRESS=LZW -co ZLEVEL=9  -a_srs EPSG:4326 $OUTDIR/WDPA_landpoly.tif   $OUTDIR/WDPA_landpoly2.tif  

# rasterize point 
gdal_rasterize -ot Byte -a_srs EPSG:4326 -l WDPA_point_Jan2014  -sql   "SELECT * FROM WDPA_point_Jan2014   WHERE   MARINE = '0'" \
-burn 1   -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te  $(getCorners4Gwarp /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif )  -co COMPRESS=LZW \
-co ZLEVEL=9  /lustre0/scratch/ga254/dem_bj/WDPA/shp_input/WDPA_Jan2014.shp/WDPA_point_Jan2014.shp    $OUTDIR/WDPA_point_Jan2014EPSG4326.tif

# rasterize buffer 
gdal_rasterize -ot Byte -a_srs EPSG:4326 -l WDPA_point_Jan2014EPSG4326Buf  -sql   "SELECT * FROM WDPA_point_Jan2014EPSG4326Buf   WHERE   MARINE = '0'" \
-burn 1   -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te  $(getCorners4Gwarp /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif )  -co COMPRESS=LZW \
-co ZLEVEL=9  /lustre0/scratch/ga254/dem_bj/WDPA/shp_buf/WDPA_point_Jan2014EPSG4326Buf.shp     $OUTDIR/WDPA_point_Jan2014EPSG4326BufLAND.tif

# merge point buffer poly 

pkmosaic -i $OUTDIR/WDPA_point_Jan2014EPSG4326BufLAND.tif -i $OUTDIR/WDPA_point_Jan2014EPSG4326.tif -i $OUTDIR/WDPA_landpoly2.tif -cr max -o $OUTDIR/WDPA_land_all.tif
gdal_translate -a_ullr   $(getCorners4Gtranslate   rasterize/6/IUCN6.tif)     -co COMPRESS=LZW -co ZLEVEL=9  -a_srs EPSG:4326 $OUTDIR/WDPA_land_all.tif  $OUTDIR/WDPA_land_all2.tif


# extract the area for each cell 


TIF_GRID=/lustre0/scratch/ga254/dem_bj/WDPA/tif_grid
IUCN=$1
ulx=-180
uly=$(getCorners4Gtranslate /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif | awk '{print $2}')
lrx=+180
lry=$(getCorners4Gtranslate /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif | awk '{print $4}')

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   -projwin  $ulx $uly $lrx $lry  $TIF_GRID/360x114globalID.tif  $TIF_GRID/360x114globalIDclip.tif
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   -projwin  $ulx $uly $lrx $lry  /lustre0/scratch/ga254/dem_bj/GEO_AREA/area_tif/30arc-sec-Area_prj6974.tif   $TIF_GRID/30arc-sec-Area_prj6974clip.tif


pksetmask  -co COMPRESS=LZW -co ZLEVEL=9   -i $TIF_GRID/360x114globalIDclip.tif -m  $OUTDIR/WDPA_land_all2.tif  -msknodata 0 -nodata 0 -o $TIF_GRID/360x114globalIDland.tif


INDIR=/lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat

oft-stat-sum   -nostd  -i /lustre0/scratch/ga254/dem_bj/WDPA/tif_grid/30arc-sec-Area_prj6974clip.tif    -o $INDIR/ID_area_stat.txt  -um $TIF_GRID/360x114globalIDclip.tif
oft-stat-sum   -nostd  -i /lustre0/scratch/ga254/dem_bj/WDPA/tif_grid/30arc-sec-Area_prj6974clip.tif    -o $INDIR/land_stat.txt     -um $TIF_GRID/360x114globalIDland.tif 

# calculate the percentage 




echo join 
join -1 1 -2 1 -a 1   <(sort -k 1,1  $INDIR/ID_area_stat.txt)   <(sort -k 1,1 $INDIR/land_stat.txt) >  $INDIR/stat_sum_j.txt
echo perc
awk '{  if (NF==5) {print $1 , (100/$3)*$5 } else { print $1 , "0" }   }'  $INDIR/stat_sum_j.txt >  $INDIR/stat_perc.txt

# start to merge with the existing shapefile  

# copy the spafile to a new one 
rm -f shp_grid/360x114global/360x114global_land.*
ogr2ogr   shp_grid/360x114global/360x114global_land.shp  shp_grid/360x114global/360x114global.shp
oft-addattr-new.py /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global_land.shp ID LAND Float $INDIR/stat_perc.txt 0 



openev /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global_land.shp $TIF_GRID/360x114globalIDland.tif 


