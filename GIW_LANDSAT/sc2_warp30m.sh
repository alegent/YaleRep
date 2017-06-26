# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/geo_file ;  for LIST in list_fileF*.txt ; do  qsub -v LIST=$LIST  /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc2_warp30m.sh ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export RAM=/dev/shm

# 1 arc sec is 30 metri . 1 arc sec * 7.5 = 250m 

# Value Label
# 0     No Data
# 1 Land
# 2 Water           Consider only this for river network 
# 4 Snow/Ice
# 200 Cloud shadow
# 201 Cloud

LIST=$1

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT

cleanram 
RAM=/dev/shm

# 8746 file 
cat $DIR/geo_file/$LIST   | xargs -n 1 -P 8  bash -c $' 

filename=$(basename $1 .tif)

#   0.008333333333333333333 = 120 arcsec    = 1km 
#   0.000277777777777777777 = 1 arcsec      = 30m 
#   0.0008333333333333      = 3 arc second  = 90m - 100 m 
#   0.002083333333333       = 7.5 arc sec   = 250m
#   0.002083333333333 / 8 =   0.000260417  # this allow the aggregation at 8 * 8 and rich the 250 

if [ ! -f  $DIR/tif_30m4326/${filename}_EPSG4326_w.tif  ] ; then 

gdalwarp  -srcnodata 0 -dstnodata 0   -tr 0.00026041666666666666666  0.00026041666666666666666 -tap  -t_srs EPSG:4326 -r near  -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/tif/$1 $RAM/${filename}_EPSG4326.tif  -overwrite
pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9    -min 2 -max 2 -data 1 -nodata 0 -i  $RAM/${filename}_EPSG4326.tif   -o   $DIR/tif_30m4326/${filename}_EPSG4326_w.tif  
rm -f $RAM/${filename}_EPSG4326.tif

fi 

' _
cleanram 

