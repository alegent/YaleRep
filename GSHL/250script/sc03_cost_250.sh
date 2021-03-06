#!/bin/bash
#SBATCH -p scavenge
#SBATCH -J sc03_cost_250.sh
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_cost_250.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_cost_250.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

#  costUNIT497_338.tif valori infinit nel cost 

# costUNIT3562_333.tif costUNIT3.tif costUNIT4000.tif costUNIT497_338.tif costUNIT573.tif
# sbatch --export=UNIT=3,RAM=50000 /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc03_cost_250.sh
# cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_unit

# for UNIT in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 1145 154 2597 3005 3317 3629 3753 4000 4001 573 810 497_338 3562_333 ; do 
#      echo $UNIT $(gdalinfo UNIT${UNIT}msk4GHS.tif | grep "Size is" | awk  '{ gsub(","," ") ;     print int($3 * $4 / 30000 + 2000 ) }')
# done > /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_cost/UNIT_MEM_cost.txt  

# for UNIT in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 1145 154 2597 3005 3317 3629 3753 4000 4001 573 810 497_338 3562_333 ; do  MEM=$( awk -v UNIT=$UNIT '{ if ($1==UNIT  ) print $2 }' /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_cost/UNIT_MEM_cost.txt )  ;   sbatch --export=UNIT=$UNIT,MEM=$MEM  --mem-per-cpu=$MEM  /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc03_cost_250.sh  ; done

# for UNIT in 3 4000 3562_333 ; do  MEM=$( awk -v UNIT=$UNIT '{ if ($1==UNIT  ) print $2 }'  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_cost/UNIT_MEM_cost.txt )  ;   sbatch  --mem-per-cpu=$MEM --export=UNIT=$UNIT,MEM=$MEM  /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc03_cost_250.sh  ; done

module load Libs/ARMADILLO/7.700.0 

export DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSHL
export DIRPRO=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL
export RAM=/dev/shm
export UNIT=$UNIT
export MEM=$( expr $MEM - 2000 )

echo UNIT $UNIT with MEM $MEM 

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -projwin $(getCorners4Gtranslate $DIRPRO/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_unit/UNIT${UNIT}msk4GHS.tif) $DIRPRO/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_core.tif $RAM/core${UNIT}_tmp.tif 

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIRPRO/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_unit/UNIT${UNIT}msk4GHS.tif -msknodata 0 -nodata 0 -i $RAM/core${UNIT}_tmp.tif -o $RAM/core${UNIT}.tif 
# fatto perche itk dava problemi  vector of 8-bit unsigned integer itk 

oft-calc -ot Byte  $RAM/core${UNIT}.tif   $RAM/core${UNIT}_tmp.tif <<EOF 
1
#1 1 *
EOF

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 $RAM/core${UNIT}.tif $DIRPRO/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_core/core${UNIT}.tif 
rm -f $RAM/core${UNIT}.tif   $RAM/core${UNIT}_tmp.tif

MAX=$(pkstat -max -i $DIRPRO/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_core/core$UNIT.tif | awk '{  print $2  }')

if [ $MAX -eq 0 ] ; then 
rm    $DIRPRO/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_core/core$UNIT.tif 
else 

source /gpfs/home/fas/sbsc/ga254/scripts/general/enter_grass7.0.2-grace2.sh  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSHL/grassdb/cost250/PERMANENT 
rm -f  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSHL/grassdb/cost250/PERMANENT/.gislock

cp  $HOME/.grass7/grass$$  $HOME/.grass7/rc${UNIT}
export GISRC=$HOME/.grass7/rc${UNIT}

rm -fr  $DIR/grassdb/cost250/UNIT${UNIT}
g.mapset  -c  mapset=UNIT${UNIT}  location=cost250  dbase=$DIR/grassdb   --quiet --overwrite 

echo create mapset   UNIT${UNIT}
cp $DIR/grassdb/cost250/PERMANENT/WIND $DIR/grassdb/cost250/UNIT${UNIT}/WIND

g.mapsets   mapset=UNIT${UNIT}   operation=add

rm -f  $DIR/grassdb/cost250/UNIT${UNIT}/.gislock

g.gisenv 

g.region   raster=UNIT${UNIT}   --o 
r.mask -r  --quiet 
# r.mask     raster=UNIT${UNIT}   --o

echo start to calculate the cost for $UNIT 
r.cost  -k input=impervius_neg output=impervius_cost start_raster=core  --overwrite  memory=$MEM 

r.colors -r map=impervius_cost

r.out.gdal  nodata=-1  --overwrite -c -f createopt="COMPRESS=DEFLATE,ZLEVEL=9,BIGTIFF=YES" type=Float32 format=GTiff  input=impervius_cost  output=$DIRPRO/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_cost/costUNIT${UNIT}.tif

# rm -rf   $DIR/grassdb/cost250/UNIT${UNIT}

fi 
