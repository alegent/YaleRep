#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 10:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc27_tiling_lbasin_broken.sh.%A_%a.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc27_tiling_lbasin_broken.sh.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc27_tiling_lbasin_broken.sh
#SBATCH --array=1-36

####    sbatch  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc27_tiling_lbasin_broken.sh 

MERIT=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT
GRASS=/tmp
RAM=/dev/shm

find  /tmp/     -user $USER    2>/dev/null  | xargs -n 1 -P 1 rm -ifr  
find  /dev/shm  -user $USER    2>/dev/null  | xargs -n 1 -P 1 rm -ifr  

# Upper Left  (-180.0000000,  85.0000000) (180d 0' 0.00"W, 85d 0' 0.00"N)
# Lower Left  (-180.0000000, -60.0000000) (180d 0' 0.00"W, 60d 0' 0.00"S)
# Upper Right ( 180.0000000,  85.0000000) (180d 0' 0.00"E, 85d 0' 0.00"N)
# Lower Right ( 180.0000000, -60.0000000) (180d 0' 0.00"E, 60d 0' 0.00"S)

# SLURM_ARRAY_TASK_ID=17

export tile=$( awk -v AR=$SLURM_ARRAY_TASK_ID '{ if(NR==AR)  print $1      }' /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/tile_files/tile_lat_long_40d_MERIT_noheader.txt )
export  ulx=$( awk -v AR=$SLURM_ARRAY_TASK_ID '{ if(NR==AR)  print int($2) }' /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/tile_files/tile_lat_long_40d_MERIT_noheader.txt )
export  uly=$( awk -v AR=$SLURM_ARRAY_TASK_ID '{ if(NR==AR)  print int($3) }' /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/tile_files/tile_lat_long_40d_MERIT_noheader.txt )
export  lrx=$( awk -v AR=$SLURM_ARRAY_TASK_ID '{ if(NR==AR)  print int($4) }' /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/tile_files/tile_lat_long_40d_MERIT_noheader.txt )
export  lry=$( awk -v AR=$SLURM_ARRAY_TASK_ID '{ if(NR==AR)  print int($5) }' /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/tile_files/tile_lat_long_40d_MERIT_noheader.txt )

echo $ulx $uly $lrx $lry

if [ $(echo " $ulx < -180 "  | bc ) -eq 1 ] ; then ulx=-180 ; fi  ; if [ $ulx -lt  -180 ] ; then ulx=-180 ; fi  
if [ $(echo " $uly >  85 "   | bc ) -eq 1 ] ; then uly=85   ; fi  ; if [ $uly -gt   85  ] ; then uly=85   ; fi 
if [ $(echo " $lrx >  180"   | bc ) -eq 1 ] ; then lrx=180  ; fi  ; if [ $lrx -gt   180 ] ; then lrx=180  ; fi  
if [ $(echo " $lry <  -60"   | bc ) -eq 1 ] ; then lry=-60  ; fi  ; if [ $lry -lt  -60  ] ; then lry=-60  ; fi  

echo $ulx $uly $lrx $lry 
for file in  $MERIT/lbasin_unit_large_reclass/lbasin_brokb*.tif ; do 
filename=$( basename $file .tif )
gdal_translate -ot UInt32  -eco   -co COMPRESS=DEFLATE -co ZLEVEL=9    -projwin $ulx $uly $lrx $lry   $MERIT/lbasin_unit_large_reclass/$filename.tif    $MERIT/tmp/${filename}_${tile}.tif 
if [ -f  $MERIT/tmp/${filename}_${tile}.tif  ] ; then 
MAX=$(pkstat -max -i  $MERIT/tmp/${filename}_${tile}.tif    | awk '{  print $2  }' )
echo max value $MAX for file   $MERIT/tmp/${filename}_${tile}.tif 
if [ $MAX = "0" ] ; then rm   -f   $MERIT/tmp/${filename}_${tile}.tif   ; fi 
fi 
done 

gdalbuildvrt -separate -overwrite    $MERIT/tmp/${tile}.vrt      $MERIT/tmp/lbasin_brokb*_${tile}.tif 
pkstatprofile    -co COMPRESS=DEFLATE -co ZLEVEL=9    -nodata 0 -f max -i  $MERIT/tmp/${tile}.vrt   -o    $MERIT/lbasin_unit_tile/${tile}_tmp.tif
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9     $MERIT/lbasin_unit_tile/${tile}_tmp.tif      $MERIT/lbasin_unit_tile/$tile.tif
rm  $MERIT/tmp/${tile}.vrt  $MERIT/tmp/lbasin_brokb*_${tile}.tif   $MERIT/lbasin_unit_tile/${tile}_tmp.tif
exit 


