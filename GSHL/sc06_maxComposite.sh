# qsub   ~/scripts/GSHL/sc06_maxComposite.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export RAM=/dev/shm    

echo 0          0 5400 10800 a  >  $RAM/tiles_xoff_yoff.txt
echo 5400       0 5400 10800 b  >> $RAM/tiles_xoff_yoff.txt
echo 10800      0 5400 10800 c  >> $RAM/tiles_xoff_yoff.txt
echo 16200      0 5400 10800 d  >> $RAM/tiles_xoff_yoff.txt
echo 21600      0 5400 10800 e  >> $RAM/tiles_xoff_yoff.txt
echo 30000      0 5400 10800 f  >> $RAM/tiles_xoff_yoff.txt
echo 32400      0 5400 10800 g  >> $RAM/tiles_xoff_yoff.txt
echo 37800      0 5400 10800 h  >> $RAM/tiles_xoff_yoff.txt
echo 0      10800 5400 10800 i  >> $RAM/tiles_xoff_yoff.txt
echo 5400   10800 5400 10800 l  >> $RAM/tiles_xoff_yoff.txt
echo 10800  10800 5400 10800 m  >> $RAM/tiles_xoff_yoff.txt
echo 16200  10800 5400 10800 n  >> $RAM/tiles_xoff_yoff.txt
echo 21600  10800 5400 10800 o  >> $RAM/tiles_xoff_yoff.txt
echo 27000  10800 5400 10800 p  >> $RAM/tiles_xoff_yoff.txt
echo 32400  10800 5400 10800 q  >> $RAM/tiles_xoff_yoff.txt
echo 37800  10800 5400 10800 r  >> $RAM/tiles_xoff_yoff.txt


export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/MYOD11A2_celsiusmean

cat  $RAM/tiles_xoff_yoff.txt   | xargs -n 5 -P 8 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4
tile=$5

for file in $DIR/LST_MOYDmax_Day_spline_month{1,2,3,4,5,6,7,8,9,10,11,12}.tif  ; do 
filename=$(basename $file .tif)
gdal_translate    -co  COMPRESS=DEFLATE  -co ZLEVEL=9   -srcwin  $xoff $yoff $xsize $ysize   $file   $RAM/${filename}_${tile}.tif
done 

pkcomposite -srcnodata -9999 -dstnodata -9999 -co COMPRESS=DEFLATE -co ZLEVEL=9 -cr maxband -file 2  $(ls $RAM/LST_MOYDmax_Day_spline_month{1,2,3,4,5,6,7,8,9,10,11,12}.tif  | xargs -n 1 echo -i )  -o $RAM/LST_MOYDmax_Day_${tile}.tif 
# rm  -f   $RAM/LST_MOYDmax_Day_spline_month{1,2,3,4,5,6,7,8,9,10,11,12}_${tile}.tif 

' _ 


gdalbuildvrt    $RAM/LST_MOYDmax_Day.vrt  $RAM/LST_MOYDmax_Day_*.tif 
gdal_translate -a_nodata -9999  -b 1              -co  COMPRESS=DEFLATE   -co ZLEVEL=9     $RAM/LST_MOYDmax_Day.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/LST_max/LST_MOYDmax_Day_value.tif
gdal_translate -ot Byte  -a_nodata -9999  -b 2    -co  COMPRESS=DEFLATE   -co ZLEVEL=9     $RAM/LST_MOYDmax_Day.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/LST_max/LST_MOYDmax_Day_month.tif

rm -f $RAM/*.tif   $RAM/*.vrt  

cat  $RAM/tiles_xoff_yoff.txt   | xargs -n 5 -P 8 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4
tile=$5

for file in $DIR/LST_MOYDmax_Nig_spline_month{1,2,3,4,5,6,7,8,9,10,11,12}.tif  ; do 
filename=$(basename $file .tif)
gdal_translate    -co  COMPRESS=DEFLATE  -co ZLEVEL=9   -srcwin  $xoff $yoff $xsize $ysize   $file   $RAM/${filename}_${tile}.tif
done 

pkcomposite -srcnodata -9999 -dstnodata -9999 -co COMPRESS=DEFLATE -co ZLEVEL=9 -cr maxband -file 2 $(ls $RAM/LST_MOYDmax_Nig_spline_month{1,2,3,4,5,6,7,8,9,10,11,12}.tif | xargs -n 1 echo -i )  -o $RAM/LST_MOYDmax_Nig_${tile}.tif 
rm  -f   $RAM/LST_MOYDmax_Nig_spline_month{1,2,3,4,5,6,7,8,9,10,11,12}_${tile}.tif 

' _ 

gdalbuildvrt    $RAM/LST_MOYDmax_Nig.vrt  $RAM/LST_MOYDmax_Nig_*.tif 
gdal_translate            -a_nodata -9999  -b 1    -co  COMPRESS=DEFLATE   -co ZLEVEL=9     $RAM/LST_MOYDmax_Nig.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/LST_max/LST_MOYDmax_Nig_value.tif
gdal_translate -ot Byte   -a_nodata -9999  -b 2    -co  COMPRESS=DEFLATE   -co ZLEVEL=9     $RAM/LST_MOYDmax_Nig.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/LST_max/LST_MOYDmax_Nig_month.tif

rm -f $RAM/*.tif   $RAM/*.vrt  

