#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 16  -N 1  
#SBATCH -t 24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc09_equi_warp_wgs84_continue_90M.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc09_equi_warp_wgs84_continue_90M.sh.%J.err


# for TOPO in deviation multirough stdev aspect dx dxx dxy dy dyy pcurv roughness slope tcurv tpi tri vrm tci spi convergence intensity exposition range variance elongation azimuth extend width ; do sbatch --export=TOPO=$TOPO  /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc09_equi_warp_wgs84_continue_90M.sh ; done 

# sbatch  --export=TOPO=dx /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc09_equi_warp_wgs84_continue_90M.sh

echo "############################################################"
sstat  -j   $SLURM_JOB_ID.batch   --format=JobID,MaxVMSize
echo "############################################################"
sacct  -j   $SLURM_JOB_ID  --format=jobid,MaxVMSize,start,end,CPUTImeRaw,NodeList,ReqCPUS,ReqMem,Elapsed,Timelimit 
echo "############################################################"

export MERIT=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT
export SCRATCH=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/MERIT
export EQUI=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/EQUI7/grids
export RAM=/dev/shm
export TOPO=$TOPO
export RES=0.00083333333333333333333333333


if [ $TOPO != "aspect" ]   &&  [ $TOPO != "deviation" ] &&  [ $TOPO != "multirough" ]  ; then 

for CT in  AF AN AS EU NA OC SA ; do 
export CT 
gdalbuildvrt  -overwrite    $SCRATCH/$TOPO/tiles/all_${CT}_tif.vrt   $SCRATCH/$TOPO/tiles/${CT}_???_???.tif

# warp each single equi7 tile to wgs84
ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/*_dem.tif  | xargs -n 1 -P 20 bash -c $'
file=$1 
filename=$(basename $file _dem.tif)
geostring=$(getCorners4Gwarp $file)

gdalwarp -overwrite --config GDAL_CACHEMAX 1500 -overwrite -wm 1500 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -r bilinear -srcnodata -9999 -dstnodata -9999 -tr ${RES:0:22} ${RES:0:22} -te $geostring  -s_srs  $EQUI/${CT}/PROJ/EQUI7_V13_${CT}_PROJ_ZONE.prj -t_srs $EQUI/${CT}/GEOG/EQUI7_V13_${CT}_GEOG_ZONE.prj $SCRATCH/$TOPO/tiles/all_${CT}_tif.vrt $RAM/${TOPO}_${CT}_${filename}.tif

pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $EQUI/$CT/GEOG/EQUI7_V13_${CT}_GEOG_ZONE_KM0.1.tif  -msknodata 0 -nodata -9999 -i $RAM/${TOPO}_${CT}_${filename}.tif  -o $RAM/${TOPO}_${CT}_${filename}_msk.tif
rm -f $RAM/${TOPO}_${CT}_${filename}.tif

MAX=$(pkstat -max -i $RAM/${TOPO}_${CT}_${filename}_msk.tif  | awk \'{ print $2 }\'  )
if [ $MAX = "-9999"  ] ; then 
rm -f $RAM/${TOPO}_${CT}_${filename}_msk.tif 
else 
mv $RAM/${TOPO}_${CT}_${filename}_msk.tif  $SCRATCH/$TOPO/tiles/${TOPO}_${CT}_${filename}.tif ; rm -f  $RAM/${TOPO}_${CT}_${filename}_msk.tif
fi 

' _ 

done 

# cp to final dir  or get mean of the overlapping tiles 
ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/*_dem.tif  | xargs -n 1 -P 20  bash -c $'
file=$1 
filename=$(basename $file _dem.tif)
gdalbuildvrt  -overwrite  -separate  $RAM/${TOPO}_CT_${filename}.vrt  $SCRATCH/$TOPO/tiles/${TOPO}_??_${filename}.tif
BAND=$(pkinfo -nb -i  $RAM/${TOPO}_CT_${filename}.vrt     | awk \'{ print $2 }\' ) 

if [ $BAND -eq 1 ] ; then 
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  $RAM/${TOPO}_CT_${filename}.vrt $MERIT/$TOPO/tiles/${filename}_E7.tif ;  rm -f $RAM/${TOPO}_CT_${filename}.vrt 
else 
echo start statporfile
pkstatprofile -nodata -9999 -of GTiff  -f mean -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -i $RAM/${TOPO}_CT_${filename}.vrt -o $MERIT/$TOPO/tiles/${filename}_E7_tmp.tif
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  $MERIT/$TOPO/tiles/${filename}_E7_tmp.tif   $MERIT/$TOPO/tiles/${filename}_E7.tif
rm -f $RAM/${TOPO}_CT_${filename}.vrt  $MERIT/$TOPO/tiles/${filename}_E7_tmp.tif
fi 

' _ 

fi 



if [ $TOPO = "aspect"   ] ; then 
for FUN in sin cos Ew Nw ; do
export FUN

for CT in  AF AN AS EU NA OC SA ; do 
export CT   
gdalbuildvrt  -overwrite    $SCRATCH/$TOPO/tiles/all_${CT}_${FUN}_tif.vrt   $SCRATCH/$TOPO/tiles/${CT}_???_???_$FUN.tif

# warp each single equi7 tile to wgs84
ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/*_dem.tif  | xargs -n 1 -P 20 bash -c $'
file=$1 
filename=$(basename $file _dem.tif)
geostring=$(getCorners4Gwarp $file)

gdalwarp -overwrite --config GDAL_CACHEMAX 1500 -overwrite -wm 1500 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -r bilinear -srcnodata -9999 -dstnodata -9999 -tr ${RES:0:22} ${RES:0:22} -te $geostring  -s_srs  $EQUI/${CT}/PROJ/EQUI7_V13_${CT}_PROJ_ZONE.prj -t_srs $EQUI/${CT}/GEOG/EQUI7_V13_${CT}_GEOG_ZONE.prj $SCRATCH/$TOPO/tiles/all_${CT}_${FUN}_tif.vrt $RAM/${TOPO}_${CT}_${FUN}_${filename}.tif

pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $EQUI/$CT/GEOG/EQUI7_V13_${CT}_GEOG_ZONE_KM0.1.tif  -msknodata 0 -nodata -9999 -i $RAM/${TOPO}_${CT}_${FUN}_${filename}.tif  -o $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif
rm -f $RAM/${TOPO}_${CT}_${FUN}_${filename}.tif

MAX=$(pkstat -max -i $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif  | awk \'{ print $2 }\'  )
if [ $MAX = "-9999"  ] ; then 
rm -f $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif 
else 
mv $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif  $SCRATCH/$TOPO/tiles/${TOPO}_${CT}_${FUN}_${filename}.tif ; rm -f  $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif
fi 
' _ 
done 

# cp to final dir  or get mean of the overlapping tiles 
ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/*_dem.tif  | xargs -n 1 -P 20  bash -c $'
file=$1
filename=$(basename $file _dem.tif)
gdalbuildvrt  -overwrite  -separate  $RAM/${TOPO}_CT_${FUN}_${filename}.vrt  $SCRATCH/$TOPO/tiles/${TOPO}_??_${FUN}_${filename}.tif
BAND=$(pkinfo -nb -i  $RAM/${TOPO}_CT_${FUN}_${filename}.vrt     | awk \'{ print $2 }\' ) 
if [ $BAND -eq 1 ] ; then
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  $RAM/${TOPO}_CT_${FUN}_${filename}.vrt $MERIT/$TOPO/tiles/${filename}_E7_${FUN}.tif ;  rm -f $RAM/${TOPO}_CT_${FUN}_${filename}.vrt 
else
echo start statporfile
pkstatprofile -nodata -9999 -of GTiff  -f mean -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -i $RAM/${TOPO}_CT_${FUN}_${filename}.vrt -o $MERIT/$TOPO/tiles/${filename}_E7_${FUN}_tmp.tif
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  $MERIT/$TOPO/tiles/${filename}_E7_${FUN}_tmp.tif   $MERIT/$TOPO/tiles/${filename}_E7_${FUN}.tif
rm -f $RAM/${TOPO}_CT_${FUN}_${filename}.vrt  $MERIT/$TOPO/tiles/${filename}_E7_${FUN}_tmp.tif
fi

' _ 
done
fi


if [ $TOPO = "deviation" ] || [ $TOPO = "multirough" ]  ; then 

if [ $TOPO = "deviation" ]   ; then   TOPON=devi ; fi 
if [ $TOPO = "multirough" ]  ; then   TOPON=roug ; fi 

for FUN in mag sca ; do
export FUN

for CT in  AF AN AS EU NA OC SA ; do 
export CT   
gdalbuildvrt  -overwrite  $SCRATCH/$TOPO/tiles/all_${CT}_${FUN}_tif.vrt   $SCRATCH/$TOPO/tiles/${CT}_???_???_${TOPON}_$FUN.tif

# warp each single equi7 tile to wgs84
ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/*_dem.tif  | xargs -n 1 -P 16 bash -c $'
file=$1 
filename=$(basename $file _dem.tif)
geostring=$(getCorners4Gwarp $file)

gdalwarp -overwrite --config GDAL_CACHEMAX 1000 -overwrite -wm 1000 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -r bilinear -srcnodata -9999 -dstnodata -9999 -tr ${RES:0:22} ${RES:0:22} -te $geostring  -s_srs  $EQUI/${CT}/PROJ/EQUI7_V13_${CT}_PROJ_ZONE.prj -t_srs $EQUI/${CT}/GEOG/EQUI7_V13_${CT}_GEOG_ZONE.prj $SCRATCH/$TOPO/tiles/all_${CT}_${FUN}_tif.vrt $RAM/${TOPO}_${CT}_${FUN}_${filename}.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $EQUI/$CT/GEOG/EQUI7_V13_${CT}_GEOG_ZONE_KM0.1.tif -msknodata 0 -nodata -9999 -i $RAM/${TOPO}_${CT}_${FUN}_${filename}.tif -o $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif
rm -f $RAM/${TOPO}_${CT}_${FUN}_${filename}.tif

MAX=$(pkstat -max -i $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif  | awk \'{ print $2 }\'  )
if [ $MAX = "-9999"  ] ; then 
rm -f $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif 
else 
mv $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif  $SCRATCH/$TOPO/tiles/${TOPO}_${CT}_${FUN}_${filename}.tif ; rm -f  $RAM/${TOPO}_${CT}_${FUN}_${filename}_msk.tif
fi 
' _ 
done 

# cp to final dir  or get mean of the overlapping tiles 
ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/*_dem.tif  | xargs -n 1 -P 16  bash -c $'
file=$1
filename=$(basename $file _dem.tif)
gdalbuildvrt  -overwrite  -separate  $RAM/${TOPO}_CT_${FUN}_${filename}.vrt  $SCRATCH/$TOPO/tiles/${TOPO}_??_${FUN}_${filename}.tif
BAND=$(pkinfo -nb -i  $RAM/${TOPO}_CT_${FUN}_${filename}.vrt     | awk \'{ print $2 }\' ) 
if [ $BAND -eq 1 ] ; then
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  $RAM/${TOPO}_CT_${FUN}_${filename}.vrt $MERIT/$TOPO/tiles/${filename}_E7_${FUN}.tif ;  rm -f $RAM/${TOPO}_CT_${FUN}_${filename}.vrt 
else
echo start statporfile
pkstatprofile -nodata -9999 -of GTiff  -f mean -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -i $RAM/${TOPO}_CT_${FUN}_${filename}.vrt -o $MERIT/$TOPO/tiles/${filename}_E7_${FUN}_tmp.tif
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  $MERIT/$TOPO/tiles/${filename}_E7_${FUN}_tmp.tif   $MERIT/$TOPO/tiles/${filename}_E7_${FUN}.tif
rm -f $RAM/${TOPO}_CT_${FUN}_${filename}.vrt  $MERIT/$TOPO/tiles/${filename}_E7_${FUN}_tmp.tif
fi
' _ 
done
fi


echo "############################################################"
sstat  -j   $SLURM_JOB_ID.batch   --format=JobID,MaxVMSize
echo "############################################################"
sacct  -j   $SLURM_JOB_ID  --format=jobid,MaxVMSize,start,end,CPUTImeRaw,NodeList,ReqCPUS,ReqMem,Elapsed,Timelimit 
echo "############################################################"
