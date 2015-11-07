# rasterize poly

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:02:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN/urban_conus/shp
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN/urban_conus/tif
export RAM=/dev/shm

rm -f $OUTDIR/*.tif

ogrinfo -al -geom=no $INDIR/tl_2010_us_uac10_conus_wgs84UA.shp  | grep UACE10  | awk '{if (NR>1)  print $4 }' > $INDIR/UACE10.txt

cp $INDIR/tl_2010_us_uac10_conus_wgs84UA.*   $RAM/

cat  $INDIR/UACE10.txt      | xargs -n 1  -P 8  bash -c  $'

ID=$1

echo select a single poly   and create $INDIR/UA_${ID}.shp

rm  -rf  $OUTDIR/UA_${ID}.*
ogr2ogr -sql "SELECT UACE10 FROM tl_2010_us_uac10_conus_wgs84UA  WHERE   ( UACE10  = \'${ID}\' )"   $RAM/UA_${ID}.shp   $RAM/tl_2010_us_uac10_conus_wgs84UA.shp

rm -f  $INDIR/wdpa2014_id${id}.tif
gdal_rasterize -at -ot  UInt32 -a_srs EPSG:4326 -l UA_${ID}  -a UACE10  -a_nodata 0 -tap -tr  0.000250000000000 0.000250000000000  -co COMPRESS=LZW -co ZLEVEL=9    $RAM/UA_${ID}.shp  $OUTDIR/UA_${ID}.tif

rm -f    $RAM/UA_${ID}.{shx,dbf,prj,shp}
' _

rm -f $RAM/tl_2010_us_uac10_conus_wgs84UA.*