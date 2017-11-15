#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc26_reclass_lbasin_broken.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc26_reclass_lbasin_broken.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc26_reclass_lbasin_broken.sh

# sbatch   /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc26_reclass_lbasin_broken.sh

MERIT=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK_MERIT
GRASS=/tmp
RAM=/dev/shm

find  /tmp/     -user $USER  -mtime +1  2>/dev/null  | xargs -n 1 -P 1 rm -ifr  
find  /dev/shm  -user $USER  -mtime +1  2>/dev/null  | xargs -n 1 -P 1 rm -ifr  

# Upper Left  (-180.0000000,  85.0000000) (180d 0' 0.00"W, 85d 0' 0.00"N)
# Lower Left  (-180.0000000, -60.0000000) (180d 0' 0.00"W, 60d 0' 0.00"S)
# Upper Right ( 180.0000000,  85.0000000) (180d 0' 0.00"E, 85d 0' 0.00"N)
# Lower Right ( 180.0000000, -60.0000000) (180d 0' 0.00"E, 60d 0' 0.00"S)

# get the last max from the intire basin tiles 
lastmax=$( gdalinfo -mm $(ls  -rt  lbasin_h0*.tif | tail -1 ) | grep Comp | awk -F , '{ print int($2)   }' )

for file in $MERIT/lbasin_unit_large/lbasin_brokb*.tif ; do 
filename=$(basename  $file .tif )
pkstat -hist -i $file   | grep -v " 0" | awk -v lastmax=$lastmax '{ if ($1==0) { print $1 , 0  } else { lastmax=1+lastmax   ; print $1 , lastmax }   }' >  $RAM/$filename.txt   
lastmax=$(tail -1   $RAM/$filename.txt     | awk '{ print $2  }')
pkreclass -ot UInt32  -code  $RAM/$filename.txt      -co COMPRESS=DEFLATE -co ZLEVEL=9  -i $file -o $MERIT/lbasin_unit_large_reclass/$filename.tif 
rm  $RAM/$filename.txt    
done 


