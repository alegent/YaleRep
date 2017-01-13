
# for TRH in 10 100 ; do bsub  -J  sc9_river_newtworkGMTED250_mergeEUROASIA.sh   -W 24:00  -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc9_river_newtworkGMTED250_mergeEUROASIA.sh.%J.out  -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc9_river_newtworkGMTED250_mergeEUROASIA.sh.%J.err   -J sc9_river_newtworkGMTED250_mergeEUROASIA.sh   bash  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc9_river_newtworkGMTED250_mergeEUROASIA.sh $TRH ;  done 

# /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc9_river_newtworkGMTED250_mergeEUROASIA.sh
# qsub -v TRH=10 /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc9_river_newtworkGMTED250_borderCutEUROASIA.sh

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:04:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

TRH=$TRH

cleanram
DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK

xoff=$(gdalinfo $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif | grep "Size is" | awk '{  print $3 -1 }' )
yoff=0
xsize=1
ysize=$(gdalinfo $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif | grep "Size is" | awk '{  print $4 }' )

gdal_translate  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif  /dev/shm/basin_last91518_LEFT_trh${TRH}.tif

echo pkstat 
pkstat  --hist -i   /dev/shm/basin_last91518_LEFT_trh${TRH}.tif   | grep -v " 0" | awk '{ print $1 , 0 }'  >  /dev/shm/basin_last91518_LEFT_trh${TRH}.txt 

pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -code   /dev/shm/basin_last91518_LEFT_trh${TRH}.txt  -i  $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif   -o $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}_clean.tif

pkgetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9   -ot Byte   -min 0.5   -max  9999999999999  -data 255   -i $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}_clean.tif  -o $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}_cleanmsk.tif


cleanram

# CENTER 

xoff=$(gdalinfo $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}.tif | grep "Size is" | awk '{  print $3 -1 }' )
yoff=0
xsize=1
ysize=$(gdalinfo $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}.tif | grep "Size is" | awk '{  print $4 }' )

gdal_translate  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}.tif  /dev/shm/basin_last91518_CENTER_trh${TRH}.tif

pkstat --hist -i   /dev/shm/basin_last91518_CENTER_trh${TRH}.tif   | grep -v " 0" | awk '{ print $1 , 0 }'  >  /dev/shm/basin_last91518_CENTER_trh${TRH}.txt 

xoff=0
yoff=0
xsize=1
ysize=$(gdalinfo $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}.tif | grep "Size is" | awk '{  print $4 }' )

gdal_translate  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}.tif  /dev/shm/basin_last91518_CENTER_trh${TRH}.tif

pkstat --hist -i   /dev/shm/basin_last91518_CENTER_trh${TRH}.tif   | grep -v " 0" | awk '{ print $1 , 0 }'  >>  /dev/shm/basin_last91518_CENTER_trh${TRH}.txt 

pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -code  /dev/shm/basin_last91518_CENTER_trh${TRH}.txt  -i  $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}.tif  -o $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}_clean.tif
pkgetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9   -ot Byte   -min 0.5   -max  9999999999999  -data 255   -i $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}_clean.tif  -o $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}_cleanmsk.tif

cleanram

# RIGHT 

xoff=0
yoff=0
xsize=1
ysize=$(gdalinfo $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif | grep "Size is" | awk '{  print $4 }' )

gdal_translate  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif  /dev/shm/basin_last91518_RIGHT_trh${TRH}.tif

pkstat --hist -i   /dev/shm/basin_last91518_RIGHT_trh${TRH}.tif   | grep -v " 0" | awk '{ print $1 , 0 }'  >  /dev/shm/basin_last91518_RIGHT_trh${TRH}.txt 

pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -code   /dev/shm/basin_last91518_RIGHT_trh${TRH}.txt  -i  $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif   -o $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}_clean.tif

pkgetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9   -ot Byte   -min 0.5   -max  999999999  -data 255   -i $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}_clean.tif  -o $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}_cleanmsk.tif

cleanram



gdalbuildvrt -overwrite    $DIR/output/basin_last/basin_last91518_trh${TRH}_cleanmsk.vrt  $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}_cleanmsk.tif   $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}_cleanmsk.tif   $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}_cleanmsk.tif 

pkcomposite -of GTiff  -ot Byte -cr max -srcnodata 0 -dstnodata 0 -co COMPRESS=DEFLATE  -co ZLEVEL=9  -i  $DIR/output/basin_last/basin_last91518_trh${TRH}_cleanmsk.vrt  -o  $DIR/output/basin_last/basin_last91518_trh${TRH}_cleanmsk.tif 
rm -f   $DIR/output/basin_last/basin_last91518_trh${TRH}_cleanmsk.vrt 

