#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 1:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc22_broken_basin_clumping.sh.%J.out  
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc22_broken_basin_clumping.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc22_broken_basin_clumping.sh


# 122  number of files  ( one is missing ; in the other folder are 123 ) 
# sbatch  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc22_broken_basin_clumping.sh

MERIT=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT
GRASS=/tmp
RAM=/dev/shm

# gdalbuildvrt -overwrite    /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT/lbasin_tiles_brokb_msk1km/all_tif.vrt    /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT/lbasin_tiles_brokb_msk1km/lbasin_h??v??.tif  

# gdalbuildvrt -overwrite  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT/lbasin_tiles_brokb_msk/all_tif.vrt  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT/lbasin_tiles_brokb_msk/lbasin_h??v??.tif 

# rm  -f     /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT/lbasin_tiles_brokb_msk1km/all_tif_shp.*
# gdaltindex     /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT/lbasin_tiles_brokb_msk1km/all_tif_shp.shp     /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT/lbasin_tiles_brokb_msk1km/lbasin_h??v??.tif  

# gdal_translate  -a_nodata 0  -co COMPRESS=DEFLATE -co ZLEVEL=9  $MERIT/lbasin_tiles_brokb_msk1km/all_tif.vrt  $MERIT/lbasin_tiles_brokb_msk1km/all_tif.tif 


source /gpfs/home/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2-grace2.sh /tmp/  loc_$tile  $MERIT/lbasin_tiles_brokb_msk1km/all_tif.tif 

r.clump -d  --overwrite    input=all_tif     output=brokb_msk1km_clump 
r.colors -r map=brokb_msk1km_clump 
r.out.gdal nodata=0 --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff type=UInt32  input=brokb_msk1km_clump   output=$MERIT/lbasin_tiles_brokb_msk1km/brokb_msk1km_clump.tif 
rm -fr  /tmp/loc_$tile 


pkstat -hist -i  $MERIT/lbasin_tiles_brokb_msk1km/brokb_msk1km_clump.tif | sort -k 1,1 -g  > $MERIT/lbasin_tiles_brokb_msk1km/brokb_msk1km_clump_hist0.txt  
awk '{ if (NR>1) print  }'  $MERIT/lbasin_tiles_brokb_msk1km/brokb_msk1km_clump_hist0.txt  > $MERIT/lbasin_tiles_brokb_msk1km/brokb_msk1km_clump_hist1.txt


