
# for TRH in 10 100 ; do bsub  -J  sc9_river_newtworkGMTED250_mergeEUROASIA.sh   -W 24:00  -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc9_river_newtworkGMTED250_mergeEUROASIA.sh.%J.out  -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc9_river_newtworkGMTED250_mergeEUROASIA.sh.%J.err   -J sc9_river_newtworkGMTED250_mergeEUROASIA.sh   bash  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc9_river_newtworkGMTED250_mergeEUROASIA.sh $TRH ;  done 

TRH=$1

cleanram
DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK

xoff=$(gdalinfo $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif | grep "Size is" | awk '{  print $3 -1 }' )
yoff=0
xsize=1
ysize=$(gdalinfo $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif | grep "Size is" | awk '{  print $4 }' )

gdal_translate  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif  /dev/shm/basin_last91518_LEFT_trh${TRH}.tif

echo pkstat 
/gpfs/apps/hpc/Tools/PKTOOLS/2.5.2/bin/pkinfo  --hist -i   /dev/shm/basin_last91518_LEFT_trh${TRH}.tif   | grep -v " 0" | awk '{ print $1 , 0 }'  >  /dev/shm/basin_last91518_LEFT_trh${TRH}.txt 

/gpfs/apps/hpc/Tools/PKTOOLS/2.5.2/bin/pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -code   /dev/shm/basin_last91518_LEFT_trh${TRH}.txt  -i  $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}.tif   -o $DIR/output/basin_last/basin_last91518_LEFT_trh${TRH}_clean.tif

cleanram

exit 

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
ysize=$(gdalinfo $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif | grep "Size is" | awk '{  print $4 }' )

gdal_translate  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif  /dev/shm/basin_last91518_RIGHT_trh${TRH}.tif

pkstat --hist -i   /dev/shm/basin_last91518_RIGHT_trh${TRH}.tif   | grep -v " 0" | awk '{ print $1 , 0 }'  >>  /dev/shm/basin_last91518_RIGHT_trh${TRH}.txt 

pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -code  /dev/shm/basin_last91518_CENTER_trh${TRH}.txt  -i  $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}.tif  -o $DIR/output/basin_last/basin_last91518_CENTER_trh${TRH}_clean.tif

cleanram

# RIGHT 

xoff=0
yoff=0
xsize=1
ysize=$(gdalinfo $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif | grep "Size is" | awk '{  print $4 }' )

gdal_translate -srcwin $xoff $yoff $xsize $ysize $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif /dev/shm/basin_last91518_RIGHT_trh${TRH}.tif

pkstat --hist -i   /dev/shm/basin_last91518_RIGHT_trh${TRH}.tif | grep -v " 0" | awk '{ print $1 , 0 }' > /dev/shm/basin_last91518_RIGHT_trh${TRH}.txt 

pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -code   /dev/shm/basin_last91518_RIGHT_trh${TRH}.txt  -i  $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}.tif   -o $DIR/output/basin_last/basin_last91518_RIGHT_trh${TRH}_clean.tif

cleanram