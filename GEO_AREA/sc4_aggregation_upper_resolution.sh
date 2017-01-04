
#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/area_tif
export RAM=/dev/shm

cleanram


for file in 30arc-sec-Area_prj28.tif 30arc-sec-Area_prj6842.tif 30arc-sec-Area_prj6965.tif 30arc-sec-Area_prj6974.tif ; do 

export file=$file
export proj=$(echo $file | awk '{ gsub("_", " " ) ; print $2  }')

awk 'NR>1'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tile_lat_long_90d.txt  | xargs -n 13  -P 8  bash -c $' 

TILE=$1
XMIN=$4
YMIN=$7
XMAX=$6
YMAX=$5

gdalbuildvrt -overwrite   -te $XMIN $YMIN $XMAX $YMAX $RAM/$TILE.vrt  $DIR/$file  

echo start pkfilter
pkfilter -of GTiff    -dx 120 -dy 120 -f sum -d 120   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  -ot Float32  -i $RAM/$TILE.vrt -o  $RAM/${TILE}_1.00deg.tif

if [ $7 -eq -90 ] ; then YMIN=-89.9999999999999 ; fi 
gdal_edit.py   -a_ullr  $4 $5 $6 $YMIN  $RAM/${TILE}_1.00deg.tif

pkfilter -of GTiff    -dx  60 -dy  60 -f sum -d  60   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  -ot Float32  -i $RAM/$TILE.vrt -o  $RAM/${TILE}_0.50deg.tif
gdal_edit.py   -a_ullr  $4 $5 $6 $YMIN  $RAM/${TILE}_0.50deg.tif

pkfilter -of GTiff    -dx  30 -dy  30 -f sum -d  30   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  -ot Float32  -i $RAM/$TILE.vrt -o  $RAM/${TILE}_0.25deg.tif
gdal_edit.py   -a_ullr  $4 $5 $6 $YMIN  $RAM/${TILE}_0.25deg.tif

' _ 

gdalbuildvrt -overwrite   -te -180 -90  180 90  $RAM/out.vrt    $RAM/*_1.00deg.tif 
gdal_calc.py --NoDataValue=-9999 --type=Float32 --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --outfile=$DIR/1.00deg-Area_$proj  -A  $RAM/out.vrt --calc="( A / 1000000 )" 

gdalbuildvrt -overwrite   -te -180 -90  180 90  $RAM/out.vrt    $RAM/*_0.50deg.tif 
gdal_calc.py --NoDataValue=-9999 --type=Float32 --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --outfile=$DIR/0.50deg-Area_$proj  -A  $RAM/out.vrt --calc="( A / 1000000 )" 

gdalbuildvrt -overwrite   -te -180 -90  180 90  $RAM/out.vrt    $RAM/*_0.25deg.tif 
gdal_calc.py --NoDataValue=-9999 --type=Float32 --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --outfile=$DIR/0.25deg-Area_$proj  -A  $RAM/out.vrt --calc="( A / 1000000 )" 

done


