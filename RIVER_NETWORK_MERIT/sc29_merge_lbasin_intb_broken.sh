#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 2:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc29_merge_lbasin_intb_broken.sh.%A_%a.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc29_merge_lbasin_intb_broken.sh.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc29_merge_lbasin_intb_broken.sh
#SBATCH --array=1-36

####    sbatch  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc29_merge_lbasin_intb_broken.sh

MERIT=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT
GRASS=/tmp
RAM=/dev/shm

# find  /tmp/     -user $USER    2>/dev/null  | xargs -n 1 -P 1 rm -ifr  
# find  /dev/shm  -user $USER    2>/dev/null  | xargs -n 1 -P 1 rm -ifr  

# Upper Left  (-180.0000000,  85.0000000) (180d 0' 0.00"W, 85d 0' 0.00"N)
# Lower Left  (-180.0000000, -60.0000000) (180d 0' 0.00"W, 60d 0' 0.00"S)
# Upper Right ( 180.0000000,  85.0000000) (180d 0' 0.00"E, 85d 0' 0.00"N)
# Lower Right ( 180.0000000, -60.0000000) (180d 0' 0.00"E, 60d 0' 0.00"S)

# SLURM_ARRAY_TASK_ID=17

export tile=$( awk -v AR=$SLURM_ARRAY_TASK_ID '{ if(NR==AR)  print $1      }' /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/tile_files/tile_lat_long_40d_MERIT_noheader.txt )

pkcomposite  -min 0 -cr maxndvi  -co COMPRESS=DEFLATE -co ZLEVEL=9   -i $MERIT/lbasin_unit_tile/${tile}.tif  -i $MERIT/lbasin_tiles_intb_reclass/lbasin_${tile}.tif -o  $MERIT/lbasin_tiles_merge/${tile}.tif 
exit 



