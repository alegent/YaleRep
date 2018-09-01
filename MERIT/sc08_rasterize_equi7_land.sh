#!/bin/bash
#SBATCH -p scavenge
#SBATCH -n 1 -c 1  -N 1  
#SBATCH -t 1:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --mem-per-cpu=5000
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc08_rasterize_equi7_land.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc08_rasterize_equi7_land.sh.%J.err

# for CT  in  AF  AN  AS  EU  NA  OC  SA ; do for  KM in 0.1 1 5 10 50 100 ; do  sbatch    --export=CT=$CT,KM=$KM /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc08_rasterize_equi7_land.sh   ; done ; done 


echo "############################################################"
sstat  -j   $SLURM_JOB_ID.batch   --format=JobID,MaxVMSize
echo "############################################################"
sacct  -j   $SLURM_JOB_ID  --format=jobid,MaxVMSize,start,end,CPUTImeRaw,NodeList,ReqCPUS,ReqMem,Elapsed,Timelimit 
echo "############################################################"



export EQUI=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/EQUI7/grids
export MERIT=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem
export RAM=/dev/shm
export res=$( echo  $KM \* 1000 | bc )
export RES=$(echo  0.00083333333333333333333333333 \* 10 \* $KM | bc -l ) 


# the extend is bounded by the tiles so some tiles could be deleted due to no data. 

rm -f $EQUI/$CT/PROJ/EQUI7_V13_${CT}_PROJ_ZONE_KM$KM.tif   
gdal_rasterize -at  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -burn 255  -l "EQUI7_V13_${CT}_PROJ_ZONE" -tap  -a_nodata 0 -ot Byte \
-te $( getCorners4Gwarp $MERIT/$CT/all_${CT}_tif.vrt )  -tr $res $res  $EQUI/$CT/PROJ/EQUI7_V13_${CT}_PROJ_ZONE.shp $EQUI/$CT/PROJ/EQUI7_V13_${CT}_PROJ_ZONE_KM$KM.tif   
gdal_edit.py -a_nodata 0 $EQUI/$CT/PROJ/EQUI7_V13_${CT}_PROJ_ZONE_KM$KM.tif   


rm -f $EQUI/$CT/GEOG/EQUI7_V13_${CT}_GEOG_ZONE_KM$KM.tif   
gdal_rasterize -at  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -burn 255  -l "EQUI7_V13_${CT}_GEOG_ZONE"  -a_nodata 0 -ot Byte \
-te -180 -60 180 85  -tr  ${RES:0:22} ${RES:0:22}  $EQUI/$CT/GEOG/EQUI7_V13_${CT}_GEOG_ZONE.shp $EQUI/$CT/GEOG/EQUI7_V13_${CT}_GEOG_ZONE_KM$KM.tif   
gdal_edit.py -a_nodata 0 $EQUI/$CT/GEOG/EQUI7_V13_${CT}_GEOG_ZONE_KM$KM.tif   
