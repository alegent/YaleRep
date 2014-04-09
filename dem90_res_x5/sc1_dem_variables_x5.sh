# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html#gdaldem_slope 
# to check ls tif/Smoothed*.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 


# find /mnt/data2/dem_variables/{altitude,aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ; 

# ls /mnt/data/jetzlab/Data/environ/global/dem/tiles/Smoothed_*.bil | xargs -n 1 -P 12 bash  /mnt/data2/dem_variables/scripts/sc1_dem_variables_x5.sh

# scandinavia 
# ls /mnt/data/jetzlab/Data/environ/global/dem/tiles/Smoothed_N{55,60,65,70}E0{05,10,15,20,25,30}.bil | xargs -n 1 -P 12 bash /mnt/data2/dem_variables/scripts/sc1_dem_variables.sh

export INDIR=/mnt/data2/dem_variables
export OUTDIR=/mnt/data2/dem_variables/resol_x5
export file=$1
export filename=`basename $file .bil` 

(

# gdal_translate -ot Int16  -co COMPRESS=LZW  $file $OUTDIR/tif/$filename.tif

echo altitude variables with file    $INDIR/tif/$filename.tif

# median 
pkfilter -m -32768 -dx 5 -dy 5   -f median -d 5 -i  $INDIR/tif/$filename.tif    -o  $OUTDIR/altitude/median/tiles/$filename.tif     -co COMPRESS=LZW -ot Int16  
 
# stdev
pkfilter -m -32768 -dx 5 -dy 5   -f var -d 5 -i $INDIR/tif/$filename.tif   -o  $OUTDIR/altitude/stdev/tiles/tmp_$filename.tif  -co COMPRESS=LZW -ot Int32   # max 1552385.000 sqrt(1245.947)
gdal_calc.py -A  $OUTDIR/altitude/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/altitude/stdev/tiles/$filename.tif
rm -f   $OUTDIR/altitude/stdev/tiles/tmp_$filename
# min 
pkfilter -m -32768  -dx 5 -dy 5   -f min -d 5 -i $INDIR/tif/$filename.tif   -o  $OUTDIR/altitude/min/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16  
# max
pkfilter -m -32768 -dx 5 -dy 5   -f max -d 5 -i $INDIR/tif/$filename.tif   -o  $OUTDIR/altitude/max/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16  
# mean
pkfilter -m -32768 -dx 5 -dy 5   -f mean -d 5 -i $INDIR/tif/$filename.tif   -o  $OUTDIR/altitude/mean/tiles/$filename.tif  -co COMPRESS=LZW  -ot Int16  

# starting to use gdaldem to compute variables. Gdaldem use -9999 as no data. 

echo  slope with file   $INDIR/tif/$filename.tif
gdaldem slope  -s 111120 -co COMPRESS=LZW   $INDIR/tif/$filename.tif  $OUTDIR/slope/tiles/$filename.tif  # -s to consider xy in degree and z in meters
# slope median 
pkfilter -m -9999 -dx 5 -dy 5 -f median  -d 5 -i $OUTDIR/slope/tiles/$filename.tif -o $OUTDIR/slope/median/tiles/$filename.tif -co COMPRESS=LZW -ot Byte
# slope stdev 
pkfilter -m -9999 -dx 5 -dy 5 -f var -d 5 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW -ot Int32
gdal_calc.py -A  $OUTDIR/slope/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/slope/stdev/tiles/$filename.tif
rm -f  $OUTDIR/slope/stdev/tiles/tmp_$filename
# slope min 
pkfilter -m -9999  -dx 5 -dy 5 -f min -d 5 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/min/tiles/$filename.tif -co COMPRESS=LZW   -ot Byte 
# slope max
pkfilter -m -9999 -dx 5 -dy 5 -f max -d 5 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/max/tiles/$filename.tif -co COMPRESS=LZW   -ot Byte 
# slope mean
pkfilter -m -9999 -dx 5 -dy 5 -f mean -d 5 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/mean/tiles/$filename.tif -co COMPRESS=LZW  -ot Byte 

rm -f  $OUTDIR/slope/tiles/$filename.tif

echo  generate a Terrain Ruggedness Index TRI  with file   $file
gdaldem TRI  -co COMPRESS=LZW   $INDIR/tif/$filename.tif  $OUTDIR/tri/tiles/$filename.tif
# tri median 
pkfilter -m -9999 -dx 5 -dy 5 -f median -d 5 -i $OUTDIR/tri/tiles/$filename.tif -o $OUTDIR/tri/median/tiles/$filename.tif -co COMPRESS=LZW -ot Int16  
# tri stdev 
pkfilter -m -9999 -dx 5 -dy 5 -f var -d 5 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW 
gdal_calc.py -A  $OUTDIR/tri/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/tri/stdev/tiles/$filename.tif
rm -f  $OUTDIR/tri/stdev/tiles/tmp_$filename
# tri min 
pkfilter -m -9999 -dx 5 -dy 5 -f min -d 5 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/min/tiles/$filename.tif -co COMPRESS=LZW -ot Int16  
# tri max
pkfilter -m -9999 -dx 5 -dy 5 -f max -d 5 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/max/tiles/$filename.tif -co COMPRESS=LZW -ot Int16
# tri mean
pkfilter -m -9999 -dx 5 -dy 5 -f mean -d 5 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/mean/tiles/$filename.tif -co COMPRESS=LZW -ot Int16

rm -f  $OUTDIR/tri/tiles/$filename.tif

echo  generate a Topographic Position Index TPI  with file   $INDIR/tif/$filename.tif
gdaldem TPI  -co COMPRESS=LZW   $INDIR/tif/$filename.tif  $OUTDIR/tpi/tiles/$filename.tif       # tpi has negative number 
# tpi median 
pkfilter -m -9999 -dx 5 -dy 5 -f median -d 5 -i $OUTDIR/tpi/tiles/$filename.tif -o $OUTDIR/tpi/median/tiles/$filename.tif -co COMPRESS=LZW -ot Int16
echo tpi stdev 
pkfilter -m -9999 -dx 5 -dy 5 -f var -d 5 -i $OUTDIR/tpi/tiles/$filename.tif -o $OUTDIR/tpi/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW 
gdal_calc.py -A  $OUTDIR/tpi/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int32 --overwrite --outfile $OUTDIR/tpi/stdev/tiles/$filename.tif
rm -f  $OUTDIR/tpi/stdev/tiles/tmp_$filename
# tpi min 
pkfilter -m -9999 -dx 5 -dy 5 -f min -d 5 -i $OUTDIR/tpi/tiles/$filename.tif -o $OUTDIR/tpi/min/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16
# tpi max
pkfilter -m -9999 -dx 5 -dy 5 -f max -d 5 -i $OUTDIR/tpi/tiles/$filename.tif -o $OUTDIR/tpi/max/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16
# tpi mean
pkfilter -m -9999 -dx 5 -dy 5 -f mean -d 5 -i $OUTDIR/tpi/tiles/$filename.tif -o $OUTDIR/tpi/mean/tiles/$filename.tif  -co COMPRESS=LZW -ot Int16

rm -f  $OUTDIR/tpi/tiles/$filename.tif

echo  generate roughness   with file   $INDIR/tif/$filename.tif

gdaldem  roughness  -co COMPRESS=LZW   $INDIR/tif/$filename.tif  $OUTDIR/roughness/tiles/$filename.tif

# roughness median 
pkfilter -m -9999 -dx 5 -dy 5 -f median -d 5 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/median/tiles/$filename.tif -co COMPRESS=LZW -ot Int16
echo roughness stdev 
pkfilter -m -9999 -dx 5 -dy 5 -f var  -d 5 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW 
gdal_calc.py -A  $OUTDIR/roughness/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int32 --overwrite --outfile $OUTDIR/roughness/stdev/tiles/$filename.tif

rm -f  $OUTDIR/roughness/stdev/tiles/tmp_$filename

# roughness min 
pkfilter -m -9999 -dx 5 -dy 5 -f min -d 5 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/min/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16
# roughness max
pkfilter -m -9999 -dx 5 -dy 5 -f max -d 5 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/max/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16
# roughness mean
pkfilter -m -9999 -dx 5 -dy 5 -f mean -d 5 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/mean/tiles/$filename.tif  -co COMPRESS=LZW -ot Int16

rm -f   $OUTDIR/roughness/tiles/$filename.tif

) 2>&1 | tee   /mnt/data2/dem_variables/log.txt