# qsub   -v TRH=100  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc6_continentisland_merge_oft-calc.sh
# qsub  -W depend=afterany$(qstat -u $USER  | grep sc5_river_newtwo     | awk -F . '{  printf (":%i" ,  $1 ) }' | awk '{   printf ("%s\n" , $1 ) } ' )  -v TRH=100   /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc6_continentisland_merge_oft-calc.sh

# 90420 11750011      MADAGASCAR        
# 10328 12535192      canada island 
# 80691 13772932      indonesia 
# 84397 14731200      guinea 
# 2285 22431475       canada island 
# 26487 26414813      canada island 
# 33778 150020638     greenland      
# 92404 158200595     AUSTRALIA
# 11000 350855901     south america 
# 11001 576136081     africa 
# 98343 596887982     north america 
# 91518 1474765872    EUROASIA    

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:12:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# madagascar  90420

export TRH=10

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output
RAM=/dev/shm

echo 0         0  43200 34560 1  > $RAM/tiles_xoff_yoff.txt
echo 43200     0  43200 34560 2 >> $RAM/tiles_xoff_yoff.txt
echo 86400     0  43200 34560 3 >> $RAM/tiles_xoff_yoff.txt
echo 129600    0  43200 34560 4 >> $RAM/tiles_xoff_yoff.txt
echo 0      34560 43200 34560 5 >> $RAM/tiles_xoff_yoff.txt
echo 43200  34560 43200 34560 6 >> $RAM/tiles_xoff_yoff.txt
echo 86400  34560 43200 34560 7 >> $RAM/tiles_xoff_yoff.txt
echo 129600 34560 43200 34560 8 >> $RAM/tiles_xoff_yoff.txt

# rm  -f   $DIR/stream/stream_globe_trh${TRH}.tif  
gdalbuildvrt -separate    -te -180 -60 180 84   -overwrite   $DIR/stream/stream_globe_trh${TRH}.vrt   $DIR/stream/stream[0-9]*_trh${TRH}.tif 

export BANDN=$(gdalinfo $DIR/stream/stream_globe_trh${TRH}.vrt  | grep Band  | tail -1 | awk '{  print $2  }' )

cat  $RAM/tiles_xoff_yoff.txt | xargs -n 5 -P 8 bash -c $' 

gdal_translate -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9   -srcwin $1 $2 $3 $4  $DIR/stream/stream_globe_trh${TRH}.vrt  $DIR/stream/stream_globe_${5}_trh${TRH}.tif 

for B in $(seq 0  $(expr $BANDN  \-  1 ) ; do echo  $(expr $B + 1 )    $( pkstat  -max  -b $B  -i  $DIR/stream/stream_globe_${5}_trh${TRH}.tif  | awk \'{ $2  }\' )   ; done > /tmp/stream_globe_${5}_trh${TRH}.txt

gdal_translate -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9  $(grep -v " 0" /tmp/stream_globe_${5}_trh${TRH}.txt    | awk \'{  printf("-b %s "  , $1 )  }\'  $DIR/stream/stream_globe_${5}_trh${TRH}.tif  $DIR/stream/stream_globe_${5}_trh${TRH}_lessb.tif 

rm -f  $DIR/stream/stream_globe_${5}_trh${TRH}-oft.tif  $DIR/stream/stream_globe_${5}_trh${TRH}.tif

BANDN=$( gdalinfo  $DIR/stream/stream_globe_${5}_trh${TRH}_lessb.tif  | grep Band  | tail -1 | awk '{  print $2  }' )

EQUATION=$(for band in $(seq 1 $BANDN); do echo -ne "#$band " ; done ; for band in $(seq 1 $(expr $BANDN  \-  1 )) ; do echo -ne   " +"  ; done )

echo $EQUATION 

oft-calc -ot Byte  $DIR/stream/stream_globe_${5}_trh${TRH}_lessb.tif     $DIR/stream/stream_globe_${5}_trh${TRH}-oft.tif <<EOF
1
$EQUATION
EOF
# rm -f  $DIR/stream/stream_globe_${5}_trh${TRH}_lessb.tif

' _ 

gdalbuildvrt  -te -180 -60 180 84   -overwrite     $DIR/stream/stream_globe_trh${TRH}.vrt    $DIR/stream/stream_globe_?_trh${TRH}-oft.tif
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/stream/stream_globe_trh${TRH}.vrt    $DIR/stream/stream_globe_trh${TRH}.tif

pkcreatect -min 0 -max 1 > /tmp/color.txt 
pkgetmask -ot Byte   -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /tmp/color.txt     -min 0.5 -max 9999  -data 1 -nodata 0     -i  $DIR/stream/stream_globe_trh${TRH}.tif -o   $DIR/stream/stream_globe01_trh${TRH}.tif 
pkcreatect -ot Byte   -co COMPRESS=DEFLATE -co ZLEVEL=9 -min -max 1  -i  $DIR/stream/stream_globe01_trh${TRH}.tif -o   $DIR/stream/stream_globe01_trh${TRH}_ct.tif 
rm $DIR/stream/stream_globe01_trh${TRH}.tif   $DIR/stream/stream_globe_trh${TRH}.tif 
rm /tmp/color.txt

# rm -f  $DIR/stream/stream_globe_?_trh${TRH}-oft.tif

