# qsub /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc4_warp30m_aggregate250m_merge.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export LIST=$LIST
export RAM=/dev/shm

cleanram 

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT


echo max sum | xargs -n 1 -P 2 bash -c $'  
PAR=$1

if [ $PAR = max   ] ; then MVALUE=1 ; fi 
if [ $PAR = sum   ] ; then MVALUE=64 ; fi 

gdalbuildvrt   -te -180 -60 +180 +84   -overwrite  $DIR/tif_250m_from_30m4326/out_${PAR}.vrt  $DIR/tif_250m_from_30m4326_tiles/h??v??_250m_${PAR}.tif
pkcreatect -of GTiff  -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -min 0 -max $MVALUE   -i  $DIR/tif_250m_from_30m4326/out_${PAR}.vrt  -o  $DIR/tif_250m_from_30m4326/GIW_water_250m_${PAR}_ct.tif 
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -nodata $MVALUE  -msknodata 0 -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge.tif  -i  $DIR/tif_250m_from_30m4326/GIW_water_250m_${PAR}_ct.tif -o $DIR/tif_250m_from_30m4326/GIW_water_250m_${PAR}_bordermsk_ct.tif
rm -f  $DIR/tif_250m_from_30m4326/out_${PAR}.vrt

' _ 
