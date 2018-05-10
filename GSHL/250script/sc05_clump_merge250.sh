#!/bin/bash
#SBATCH -p day
#SBATCH -J sc05_clump_merge250.sh
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc05_clump_merge250.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc05_clump_merge250.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email


# sbatch  /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc05_clump_merge250.sh 

module load Libs/ARMADILLO/7.700.0 

export DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad
export RAM=/dev/shm

for UNIT in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 573 810 1145 2597 3005 3317 3629 3753 4000 4001 3562_333 497_338 ; do 

    if [ $UNIT = "1"  ] ; then 
	MAX=$( pkstat -max -i  $DIR/ws_clump1.tif | awk '{  print $2 }' ) 
	cp   $DIR/ws_clump1.tif $DIR/ws_clump_sum.tif
    else 
echo MAX $MAX  MAX $MAX  MAX $MAX  MAX $MAX MAX $MAX  MAX $MAX 

echo summ the MAX value 
oft-calc -um  $DIR/ws_clump${UNIT}.tif   $DIR/ws_clump${UNIT}.tif $DIR/ws_clump${UNIT}sumMAX.tif <<EOF
1
#1 $MAX + 1 +
EOF

gdalbuildvrt -separate -overwrite    $DIR/output.vrt  $DIR/ws_clump_sum.tif $DIR/ws_clump${UNIT}sumMAX.tif

echo summ to the overall 
oft-calc   $DIR/output.vrt  $DIR/ws_clump_sum_${UNIT}.tif  <<EOF
1
#1 #2 + 
EOF

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/ws_clump_sum_${UNIT}.tif  $DIR/ws_clump_sum.tif 

rm -f $DIR/ws_clump_sum_${UNIT}.tif $DIR/ws_clump${UNIT}sumMAX.tif  $DIR/output.vrt

MAX=$( pkstat -max -i  $DIR/ws_clump_sum.tif | awk '{  print $2 }' ) 

    fi 

done 

mv $DIR/ws_clump_sum.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_ws_clump.tif 

# gdal_polygonize.py   -f  "ESRI Shapefile"   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_${RES}_v1_0_WGS84_ws_clump.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_ws_clump.shp

exit 

