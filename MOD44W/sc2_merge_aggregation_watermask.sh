
#  for tile in $(  awk '{  if (NR>1 ) print $1 }'  /lustre0/scratch/ga254/dem_bj/MOD44W/geo_file/tile_lat_long_10d.txt  ) ; do qsub -v tile=$tile  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MOD44W/sc2_merge_aggregation_watermask.sh ; done 
#  for tile in $(  awk '{  if (NR>1 ) print $1 }'  /lustre0/scratch/ga254/dem_bj/MOD44W/geo_file/tile_lat_long_10d.txt | head -10 | tail -1  ) ; do bash   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MOD44W/sc2_merge_aggregation_watermask.sh $tile ; done 


# bash     /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MOD44W/sc2_merge_aggregation_watermask.sh  
# qsub     /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MOD44W/sc2_merge_aggregation_watermask.sh  

# awk '{  if (NR>1 ) print $1 }'  /lustre0/scratch/ga254/dem_bj/MOD44W/geo_file/tile_lat_long_10d.txt   | xargs -n 1 -P 20  bash   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MOD44W/sc2_merge_aggregation_watermask.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=1gb
#PBS -l walltime=0:20:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Libraries/OSGEO/1.10.0

TILE=$1

INDIR=/lustre0/scratch/ga254/dem_bj/MOD44W/tiles
OUTDIR=/lustre0/scratch/ga254/dem_bj/MOD44W/tif_1km

xmin=$( awk -v TILE=$TILE '{ if($1==TILE) print $4   }' /lustre0/scratch/ga254/dem_bj/MOD44W/geo_file/tile_lat_long_10d.txt) 
ymin=$( awk -v TILE=$TILE '{ if($1==TILE) print $9   }' /lustre0/scratch/ga254/dem_bj/MOD44W/geo_file/tile_lat_long_10d.txt) 
xmax=$( awk -v TILE=$TILE '{ if($1==TILE) print $10  }' /lustre0/scratch/ga254/dem_bj/MOD44W/geo_file/tile_lat_long_10d.txt)  
ymax=$( awk -v TILE=$TILE '{ if($1==TILE) print $5   }' /lustre0/scratch/ga254/dem_bj/MOD44W/geo_file/tile_lat_long_10d.txt)


echo create the vrt for  $TILE

gdalbuildvrt -srcnodata 1 -vrtnodata 1  -resolution user  -te $xmin  $ymin  $xmax  $ymax   -tr  0.002083333333333 0.002083333333333  -overwrite /tmp/$TILE"_MOD44W_Water_2000.vrt"   $INDIR/*.tif 
gdal_translate    -co COMPRESS=LZW -co ZLEVEL=9  /tmp/$TILE"_MOD44W_Water_2000.vrt"  /tmp/$TILE"_MOD44W_Water_2000.tif" 
pkfilter   -co COMPRESS=LZW -ot  Float32   -class 0  -dx 4 -dy 4   -f density -d 4  -i   /tmp/$TILE"_MOD44W_Water_2000.tif"    -o  /tmp/$TILE"_MOD44W_Water_2000_tmp.tif"
gdal_calc.py  -A /tmp/$TILE"_MOD44W_Water_2000_tmp.tif"  --type=Int16   --calc="( A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9    --overwrite  --outfile $OUTDIR/$TILE"_MOD44W_Water_2000_1km.tif"
rm -f  /tmp/$TILE"_MOD44W_Water_2000.tif"  /tmp/$TILE"_MOD44W_Water_2000_tmp.tif"  /tmp/$TILE"_MOD44W_Water_2000.vrt" 

# checkjob -v $PBS_JOBID 

# in the end of the script run for the merging 
# gdalbuildvrt  -resolution user  -te -180 -90 +180 +90   -tr 0.0083333333333333 0.0083333333333333  -overwrite $OUTDIR/land_frequency_MOD44W.vrt   $OUTDIR/*"_MOD44W_Water_2000_1km.tif"   
# gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9  -a_ullr  -180 +90 +180 -90    $OUTDIR/land_frequency_MOD44W.vrt     $OUTDIR/land_frequency_MOD44W.tif 
