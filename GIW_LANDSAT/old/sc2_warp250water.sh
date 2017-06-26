# qsub /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc2_warp250water.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export RAM=/dev/shm

cleanram 

find    /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif -name "*.tif"   | xargs -n 1 -P 8  bash -c $' 

filename=$(basename $1 .tif)
dirname=$(dirname $1)

pkgetmask -min 2 -max 2 -data 1 -nodata 0 -i $1  -o $RAM/${filename}_w.tif  
gdalwarp -srcnodata 0 -tr 0.002083333333333333333 0.00208333333333333333 -t_srs EPSG:4326 -r mode -co COMPRESS=DEFLATE -co ZLEVEL=9 $RAM/${filename}_w.tif /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m/${filename}_EPSG4326.tif   -overwrite

rm -f $RAM/${filename}_w.tif  

' _

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m/output.vrt
gdalbuildvrt  -overwrite  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m/output.vrt /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m/*.tif  

cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/ 
for LIST in tiles16_listF*.txt ; do qsub -v LIST=$LIST   /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc3_warp250water_composite.sh  ; done 

