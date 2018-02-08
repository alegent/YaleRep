#!/bin/bash
#SBATCH -p scavenge 
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 4:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc40_create_lbasin_single.sh%A_%a.err
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc40_create_lbasin_single.sh.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc40_create_lbasin_single.sh
#SBATCH --array=2-4994

# start from 2 and end to wc -l   $MERIT/lbasin_tiles_final20d/lbasin_all_hist.txt   499496 
# sbatch   /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc40_create_lbasin_single.sh

# cat  $MERIT/lbasin_tiles_final20d/lbasin_h??v??_hist.txt | sort -g  | uniq >   $MERIT/lbasin_tiles_final20d/lbasin_all_hist.txt 
# SLURM_ARRAY_TASK_ID=2

MERIT=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT
RAM=/dev/shm

ID=$( head -n  $SLURM_ARRAY_TASK_ID $MERIT/lbasin_tiles_final20d/lbasin_all_hist.txt  | tail  -1 )

cd $MERIT/lbasin_tiles_final20d/


gdalbuildvrt -overwrite   -srcnodata 0 -vrtnodata 0 $MERIT/lbasin_tiles_final20d/ID$ID.vrt  $(  grep ^$ID$ lbasin_h??v??_hist.txt | awk '{ gsub("_hist.txt", " ") ; printf ("%s.tif ",$1 ) }' )

echo oft-bb for $( grep ^$ID$  lbasin_h??v??_hist.txt | awk '{ gsub("_hist.txt", " ") ; printf ("%s.tif ",$1 ) }' ) 
# confermat per oft-bb seguito da gdal_translate ci vuole +1 
geo_string=$( oft-bb   $MERIT/lbasin_tiles_final20d/ID$ID.vrt  $ID  | grep BB | awk '{ print $6,$7 ,$8-$6+1,$9-$7+1}' ) 

echo $geo_string for ID $ID

gdal_translate    -co COMPRESS=DEFLATE -co ZLEVEL=9   -srcwin  $geo_string $MERIT/lbasin_tiles_final20d/ID$ID.vrt  $RAM/ID$ID.tif 

echo pkgetmast of  $MERIT/lbasin_single_tif/lbasin_ID$ID.tif
pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9    -ot UInt32  -min $(echo $ID - .5 | bc ) -max $(echo $ID + .5 | bc )  -data $ID  -nodata 0 -i  $RAM/ID$ID.tif  -o  $MERIT/lbasin_single_tif/lbasin_ID$ID.tif 
rm   $RAM/ID$ID.tif  $MERIT/lbasin_tiles_final20d/ID$ID.vrt 
