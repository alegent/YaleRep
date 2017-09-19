# bsub  -W 24:00 -M 30000  -R "rusage[mem=30000]"  -R "span[hosts=1]" -n 16     -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc11_continentisland_merge_oft-calc.sh.%J.out   -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc11_continentisland_merge_oft-calc.sh.%J.err   bash  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc11_continentisland_merge_oft-calc.sh  3
# bsub  -W 24:00 -M 30000  -R "rusage[mem=30000]"  -R "span[hosts=1]" -n 16     -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc11_continentisland_merge_oft-calc.sh.%J.out   -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc11_continentisland_merge_oft-calc.sh.%J.err   bash  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc11_continentisland_merge_oft-calc.sh  4 
# bsub  -W 24:00 -M 30000  -R "rusage[mem=30000]"  -R "span[hosts=1]" -n 16   -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc11_continentisland_merge_oft-calc.sh.%J.out   -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc11_continentisland_merge_oft-calc.sh.%J.err   bash  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc11_continentisland_merge_oft-calc.sh  10
# bsub  -W 24:00 -M 30000  -R "rusage[mem=30000]"  -R "span[hosts=1]" -n 16   -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc11_continentisland_merge_oft-calc.sh.%J.out   -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc11_continentisland_merge_oft-calc.sh.%J.err   bash  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc11_continentisland_merge_oft-calc.sh  100

# 90420 11750011      MADAGASCAR        
# 10328 12535192      canada island 
# 80691 13772932      indonesia 
# 84397 14731200      guinea 
# 2285  22431475      canada island 
# 26487 26414813      canada island 
# 33778 150020638     greenland      
# 92404 158200595     AUSTRALIA
# 11000 350855901     south america 
# 11001 576136081     africa 
# 98343 596887982     north america 
# 91518 1474765872    EUROASIA    
# madagascar  90420

export TRH=$1

export DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/output
export RAM=/dev/shm

# cleanram 

echo 0         0  21600 34560 1  > $RAM/tiles_xoff_yoff.txt
echo 21600     0  21600 34560 2 >> $RAM/tiles_xoff_yoff.txt
echo 43200     0  21600 34560 3 >> $RAM/tiles_xoff_yoff.txt
echo 64800     0  21600 34560 4 >> $RAM/tiles_xoff_yoff.txt
echo 86400     0  21600 34560 5 >> $RAM/tiles_xoff_yoff.txt
echo 108000    0  21600 34560 6 >> $RAM/tiles_xoff_yoff.txt
echo 129600    0  21600 34560 7 >> $RAM/tiles_xoff_yoff.txt
echo 151200    0  21600 34560 8 >> $RAM/tiles_xoff_yoff.txt
echo 0         34560  21600 34560 9  >> $RAM/tiles_xoff_yoff.txt
echo 21600     34560  21600 34560 10 >> $RAM/tiles_xoff_yoff.txt
echo 43200     34560  21600 34560 11 >> $RAM/tiles_xoff_yoff.txt
echo 64800     34560  21600 34560 12 >> $RAM/tiles_xoff_yoff.txt
echo 86400     34560  21600 34560 13 >> $RAM/tiles_xoff_yoff.txt
echo 108000    34560  21600 34560 14 >> $RAM/tiles_xoff_yoff.txt
echo 129600    34560  21600 34560 15 >> $RAM/tiles_xoff_yoff.txt
echo 151200    34560  21600 34560 16 >> $RAM/tiles_xoff_yoff.txt

gdalbuildvrt -separate    -te -180 -60 180 84   -overwrite   $RAM/stream01_globe_trh${TRH}.vrt   $DIR/stream/stream01_{1,2,3,4,5,6,7,8,9,10,11,12,13,14,90420,10328,80691,84397,2285,26487,33778,92404,11000,11001,98343}_trh${TRH}.tif  $DIR/stream/stream01_91518_MERGEleft_clip_trh${TRH}_ct.tif    $DIR/stream/stream01_91518_MERGEright_clip_trh${TRH}_ct.tif 

export BANDN=$(gdalinfo $RAM/stream01_globe_trh${TRH}.vrt  | grep Band  | tail -1 | awk '{  print $2  }' )

pkcreatect -min 0 -max 1 > /tmp/color.txt 

cat  $RAM/tiles_xoff_yoff.txt | xargs -n 5 -P 16 bash -c $' 

gdal_translate -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co BIGTIFF=YES   -srcwin $1 $2 $3 $4  $RAM/stream01_globe_trh${TRH}.vrt  $RAM/stream01_globe_${5}_trh${TRH}.tif 

echo calculate min and max for each band  $BANDN  $RAM/stream01_globe_${5}_trh${TRH}.tif

for B in $(seq 0  $(expr $BANDN  \-  1 )) ; do echo  $(expr $B + 1 )  $( pkstat -max -b $B -i  $RAM/stream01_globe_${5}_trh${TRH}.tif | awk \'{ print $2  }\' ) ; done >  /tmp/stream01_globe_${5}_trh${TRH}.txt

echo  select only bands that have max = 1 
gdal_translate -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9  $(grep -v " 0" /tmp/stream01_globe_${5}_trh${TRH}.txt | awk \'{  printf("-b %s "  , $1 )  }\' )  $RAM/stream01_globe_${5}_trh${TRH}.tif  $RAM/stream01_globe_${5}_trh${TRH}_lessb.tif 

rm -f   $RAM/stream01_globe_${5}_trh${TRH}.tif  /tmp/stream01_globe_${5}_trh${TRH}.txt

BANDN=$( gdalinfo  $RAM/stream01_globe_${5}_trh${TRH}_lessb.tif  | grep Band  | tail -1 | awk \'{ print $2 }\' )

echo fot-calc on $RAM/stream01_globe_${5}_trh${TRH}_lessb.tif that has $BANDN band

EQUATION=$(for band in $(seq 1 $BANDN); do echo -ne "#$band " ; done ; for band in $(seq 1 $(expr $BANDN  \-  1 )) ; do echo -ne   " +"  ; done )

echo $EQUATION 

oft-calc -ot Byte  $RAM/stream01_globe_${5}_trh${TRH}_lessb.tif     $DIR/stream/tmp/stream01_globe_${5}_trh${TRH}-oft.tif <<EOF
1
$EQUATION
EOF

rm -f  $RAM/stream01_globe_${5}_trh${TRH}_lessb.tif /tmp/stream01_globe_${5}_trh${TRH}.txt 

pkgetmask -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -ct /tmp/color.txt -min 0.5 -max 9999 -data 1 -nodata 0 -i  $DIR/stream/tmp/stream01_globe_${5}_trh${TRH}-oft.tif -o $RAM/stream01_globe_${5}_trh${TRH}-oft_ct.tif
rm  $DIR/stream/tmp/stream01_globe_${5}_trh${TRH}-oft.tif

gdalwarp -overwrite   -co COMPRESS=DEFLATE -co ZLEVEL=9   -of GTiff -srcnodata 0 -dstalpha  $RAM/stream01_globe_${5}_trh${TRH}-oft_ct.tif  $RAM/stream01_globe_${5}_trh${TRH}_tr.tif 

' _ 

gdalbuildvrt  -te -180 -60 180 84   -overwrite     $RAM/stream01_globe_trh${TRH}.vrt  $RAM/stream01_globe_?_trh${TRH}-oft_ct.tif $RAM/stream01_globe_??_trh${TRH}-oft_ct.tif
pkcreatect -ot Byte   -co COMPRESS=DEFLATE -co ZLEVEL=9 -ct  /tmp/color.txt    -i  $RAM/stream01_globe_trh${TRH}.vrt   -o   $DIR/stream/stream01_globe01_trh${TRH}_ct.tif 
rm -f   $RAM/stream01_globe_trh${TRH}.vrt  $RAM/stream01_globe_?_trh${TRH}-oft_ct.tif $RAM/stream01_globe_??_trh${TRH}-oft_ct.tif

gdalbuildvrt  -te -180 -60 180 84   -overwrite     $RAM/stream01_globe_trh${TRH}.vrt  $RAM/stream01_globe_?_trh${TRH}_tr.tif    $RAM/stream01_globe_??_trh${TRH}_tr.tif 
gdal_translate -ot Byte  -ot Byte   -co COMPRESS=DEFLATE -co ZLEVEL=9    $RAM/stream01_globe_trh${TRH}.vrt $DIR/stream/stream01_globe01_trh${TRH}_tr.tif 

cleanram 
rm -f rm  /tmp/color.txt 

exit 

# controllare il sottostante 
cat  $RAM/tiles_xoff_yoff.txt | xargs -n 5 -P 16 bash -c $'

gdal_translate -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co BIGTIFF=YES   -srcwin $1 $2 $3 $4  $DIR/stream/stream01_globe01_trh${TRH}_ct.tif $RAM/stream01_globe_${5}_trh${TRH}-oft_ct.tif

gdalwarp -overwrite   -co COMPRESS=DEFLATE -co ZLEVEL=9   -of GTiff -srcnodata 0 -dstalpha  $RAM/stream01_globe_${5}_trh${TRH}-oft_ct.tif  $RAM/stream01_globe_${5}_trh${TRH}_tr.tif 

rm   $RAM/stream01_globe_${5}_trh${TRH}-oft_ct.tif 

' _ 



gdalbuildvrt  -te -180 -60 180 84   -overwrite     $RAM/stream01_globe_trh${TRH}.vrt  $RAM/stream01_globe_?_trh${TRH}_tr.tif    $RAM/stream01_globe_??_trh${TRH}_tr.tif 
gdal_translate -ot Byte  -ot Byte   -co COMPRESS=DEFLATE -co ZLEVEL=9    $RAM/stream01_globe_trh${TRH}.vrt $DIR/stream/stream01_globe01_trh${TRH}_tr.tif 

cleanram 
rm -f rm  /tmp/color.txt 


