# qsub  -W depend=afterany$(qstat -u $USER  | grep sc3_warp30m_aggr     | awk -F . '{  printf (":%i" ,  $1 ) }' | awk '{   printf ("%s\n" , $1 ) } ' )  /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc4_warp30m_30m_merge.sh 
# merge the 30 min composite 
#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export LIST=$LIST
export RAM=/dev/shm

cleanram 

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT

echo -180 0 0 +84 NW 0 0 +180 +84 NE -180 -60 0 0 SW 0 -60 +180 0 SE | xargs -n 5 -P 4 bash -c $' 
rm -f  $DIR/tif_30m4326_merge/out$5.vrt
gdalbuildvrt   -te $1 $2 $3 $4  -overwrite  $DIR/tif_30m4326_merge/out$5.vrt  $DIR/tif_30m4326_tiles/h*v*_30m.tif
pkcreatect -of GTiff   -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9 -min 0  -max 1   -i  $DIR/tif_30m4326_merge/out$5.vrt -o  $DIR/tif_30m4326_merge/GIW_${5}_water_30m_ct.tif
rm -f  $DIR/tif_30m4326_merge/out$5.vrt

' _ 






