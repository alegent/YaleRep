#!/bin/bash

# qsub /lustre/scratch/client/fas/sbsc/ga254/dataproces/Range_map/sister/script/sc1_rasterize_stat.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal            
#PBS -l walltime=1:00:00:00   
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout 
#PBS -e /scratch/fas/sbsc/ga254/stderr  


export INDIR=/scratch/fas/sbsc/ga254/dataproces/Range_map/sister/Range_maps
export OUTDIR=/scratch/fas/sbsc/ga254/dataproces/Range_map/sister/tif_sql
export OUT_TXT=/scratch/fas/sbsc/ga254/dataproces/Range_map/sister/txt_sql
export OUT_AREA=/scratch/fas/sbsc/ga254/dataproces/Range_map/sister/tif_area_sql

# rasterize the shapefile

ls   $INDIR/*.shp   | xargs -n 1  -P 1 bash -c   $'  

file=$1

echo processing $file

filename=$(basename $file .shp )
rm -f  $OUTDIR/$filename.tif

# isert querry 
rm -f   $OUTDIR/$filename.tif 
gdal_rasterize -ot Byte  -a_srs EPSG:4326     -burn 1   -a_nodata 0  -tap   -tr   0.008333333333333 0.008333333333333    -co COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2  \
-sql   "SELECT * FROM $filename   WHERE  ( OccCode  != 3 )  AND (  Origin  = 1)    "    $INDIR/$filename.shp    $OUTDIR/$filename.tif

' _


#  calculate area for each poligon 

ls   $OUTDIR/*.tif    | xargs -n 1  -P 8  bash -c   $'  
file=$1
filename=$(basename $file .tif )
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  -projwin $(getCorners4Gtranslate  $file)  /scratch/fas/sbsc/ga254/dataproces/Range_map/sister/30arc-sec-Area_prj6842.tif  $OUT_AREA/area_$filename.tif 
oft-stat-sum  -i  $OUT_AREA/area_$filename.tif   -o $OUT_TXT/$filename.txt  -um    $OUTDIR/$filename.tif  -nostd   &> /dev/null
' _

# follwoed by /lustre0/scratch/ga254/dem_bj/Range_map/sister/script/sc2_overala_stat.sh









