 
# for DAY in $(cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  ) ; do qsub -v DAY=$DAY,SENS=MOD /u/gamatull/scripts/LST/preprocess/sc2_mean_yesQC_MOYD11A2.sh  ; done

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=16
#PBS -l walltime=6:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

export DAY=$DAY
export SENS=$SENS
export INSENS=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.005/${SENS}11A2
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean

export RAMDIR=/dev/shm

rm -f $RAMDIR/*.tif 


echo start the pkcomposite for $DAY $SENS

echo 0         0 5400 10800 a  >  $RAMDIR/tiles_xoff_yoff.txt
echo 5400      0 5400 10800 b  >> $RAMDIR/tiles_xoff_yoff.txt
echo 10800     0 5400 10800 c  >> $RAMDIR/tiles_xoff_yoff.txt
echo 16200     0 5400 10800 d  >> $RAMDIR/tiles_xoff_yoff.txt
echo 21600     0 5400 10800 e  >> $RAMDIR/tiles_xoff_yoff.txt
echo 27000     0 5400 10800 f  >> $RAMDIR/tiles_xoff_yoff.txt
echo 32400     0 5400 10800 g  >> $RAMDIR/tiles_xoff_yoff.txt
echo 37800     0 5400 10800 h  >> $RAMDIR/tiles_xoff_yoff.txt
echo 0      10800 5400 10800 i  >> $RAMDIR/tiles_xoff_yoff.txt
echo 5400   10800 5400 10800 l  >> $RAMDIR/tiles_xoff_yoff.txt
echo 10800  10800 5400 10800 m  >> $RAMDIR/tiles_xoff_yoff.txt
echo 16200  10800 5400 10800 n  >> $RAMDIR/tiles_xoff_yoff.txt
echo 21600  10800 5400 10800 o  >> $RAMDIR/tiles_xoff_yoff.txt
echo 27000  10800 5400 10800 p  >> $RAMDIR/tiles_xoff_yoff.txt
echo 32400  10800 5400 10800 q  >> $RAMDIR/tiles_xoff_yoff.txt
echo 37800  10800 5400 10800 r  >> $RAMDIR/tiles_xoff_yoff.txt

cat $RAMDIR/tiles_xoff_yoff.txt  | xargs -n 5 -P 16 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4
tile=$5

for file in $INSENS/*/${SENS}11A2.A*${DAY}.tif ; do 

filename=$(basename $file .tif)
gdal_translate    -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin  $xoff $yoff $xsize $ysize   $file   $RAMDIR/${filename}_tile${tile}.tif
done 

echo start the pcomposite sens ${SENS} day ${DAY} tile ${tile}

# -b not usede if not the b2 can not be used   see fir qc /nobackupp8/gamatull/dataproces/LST/MYD11A2/QC_decimal_bynary.txt 
#  in this case  -bndnodata 1 e la 2 banda

pkcomposite $(ls $RAMDIR/${SENS}11A2.A*${DAY}_tile${tile}.tif | xargs -n 1 echo -i )  -file 1  -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0  -bndnodata 1 \
-srcnodata 2 -srcnodata 3  -srcnodata  193 -srcnodata 209 -srcnodata 225       -o $RAMDIR/LST_${SENS}_QC_day${DAY}_tile${tile}.tif 

' _ 

rm -f $RAMDIR/tiles_xoff_yoff.txt

gdalbuildvrt  -overwrite  -b 1 -b 3      $RAMDIR/LST_${SENS}_QC_day${DAY}.vrt      $RAMDIR/LST_${SENS}_QC_day${DAY}_tile?.tif
gdal_translate  -srcwin 0 0 43200 21600     -co  COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/LST_${SENS}_QC_day$DAY.vrt    $OUTSENS/LST_${SENS}_QC_day$DAY.tif 
rm -f $RAMDIR/LST_${SENS}_QC_day${DAY}_tile?.tif

echo warp the lst  yes qc

gdalbuildvrt  -overwrite  -b 1  $OUTSENS/LST_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  

gdalwarp  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90  -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day$DAY.vrt     $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif 
rm -f $OUTSENS/LST_${SENS}_QC_day$DAY.vrt  

gdalwarp  -srcnodata 0 -dstnodata 0  -t_srs EPSG:4326  -r average  -te -180 -90 +180 +90 -tr 0.08333333333333 0.08333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10t.tif

gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif     $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10t.tif  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10.tif
rm -f $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10t.tif 

echo warp the obs yes  qc

gdalbuildvrt  -overwrite  -b 2  $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  
gdalwarp  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90   -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif

rm -f $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt

gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif  $OUTSENS/OBS_${SENS}_QC_day${DAY}_wgs84.tif

rm -f  $RAMDIR/*.tif $OUTSENS/LST_${SENS}_QC_day$DAY.vrt    $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   
