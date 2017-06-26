# for DAY in $(cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  ) ; do qsub -v DAY=$DAY,SENS=MOD /u/gamatull/scripts/LST/sc2_mean_MOYD11A2.sh  ; done

#PBS -S /bin/bash
#PBS -q long
#PBS -l select=1:ncpus=1
#PBS -l walltime=18:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr


export DAY=$DAY
export SENS=$SENS
export INSENS=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.005/${SENS}11A2
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean

export RAMDIR=/dev/shm

echo start the pkcomposite for $DAY 

# non piu processate perche si e' deciso di usare il qc 
# no quality  -b 0 the b1 is cancelled from the begin of the operation 
# pkcomposite $(ls $INSENS/*/${SENS}11A2.A*${DAY}.tif | xargs -n 1 echo -i ) -b 0 -file  -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0 -srcnodata 0 -o $RAMDIR/LST_${SENS}_day$DAY.tif 

# gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9 -ot Float32    -srcwin 0 0 43200 21600  $RAMDIR/LST_${SENS}_day$DAY.tif    $OUTSENS/LST_${SENS}_day$DAY.tif 

# rm -f   $RAMDIR/LST_${SENS}_day$DAY.tif   

# echo warp the LST  no qc

# gdalbuildvrt  -overwrite  -b 1   $OUTSENS/LST_${SENS}_day$DAY.vrt      $OUTSENS/LST_${SENS}_day$DAY.tif  

# gdalwarp  -overwrite  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r cubic -te -180 -90 +180 +90  -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES   -co  COMPRESS=LZW -co ZLEVEL=9   $OUTSENS/LST_${SENS}_day$DAY.vrt    $RAMDIR/LST_${SENS}_day${DAY}_wgs84.tif 

# gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/LST_${SENS}_day${DAY}_wgs84.tif   $OUTSENS/LST_${SENS}_day${DAY}_wgs84.tif 

# rm    $RAMDIR/LST_${SENS}_day${DAY}_wgs84.tif 

# echo warp the OBS  no qc 

# gdalbuildvrt  -overwrite  -b 2   $OUTSENS/OBS_${SENS}_day$DAY.vrt      $OUTSENS/LST_${SENS}_day$DAY.tif  

# gdalwarp  -overwrite   -srcnodata 0 -dstnodata 0  -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90  -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES   -co  COMPRESS=LZW -co ZLEVEL=9   $OUTSENS/OBS_${SENS}_day$DAY.vrt    $RAMDIR/OBS_${SENS}_day${DAY}_wgs84.tif 

# gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/OBS_${SENS}_day${DAY}_wgs84.tif   $OUTSENS/OBS_${SENS}_day${DAY}_wgs84.tif 

# rm -f $RAMDIR/OBS_${SENS}_day${DAY}_wgs84.tif 


# -b not usede if not the b2 can not be used   see fir qc /nobackupp8/gamatull/dataproces/LST/MYD11A2/QC_decimal_bynary.txt 

# in this case  -bndnodata 1 e' la 2 banda
pkcomposite $(ls $INSENS/*/${SENS}11A2.A*${DAY}.tif | xargs -n 1 echo -i )  -file   -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0  -bndnodata 1 \
-srcnodata 2 -srcnodata 3  -srcnodata  193 -srcnodata 209 -srcnodata 225       -o $RAMDIR/LST_${SENS}_QC_day$DAY.tif 

gdal_translate  -srcwin 0 0 43200 21600     -b 1 -b 3      -co  COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/LST_${SENS}_QC_day$DAY.tif    $OUTSENS/LST_${SENS}_QC_day$DAY.tif 

echo warp the lst  yes qc

gdalbuildvrt  -overwrite  -b 1  $OUTSENS/LST_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  

gdalwarp -overwrite  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r cubic  -te -180 -90 +180 +90  -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day$DAY.vrt   $RAMDIR/LST_${SENS}_QC_day${DAY}_wgs84.tif 
rm -f $OUTSENS/LST_${SENS}_QC_day$DAY.vrt  
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/LST_${SENS}_QC_day${DAY}_wgs84.tif $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif

rm -f $RAMDIR/LST_${SENS}_QC_day${DAY}_wgs84.tif

echo warp the obs yes  qc

gdalbuildvrt  -overwrite  -b 2  $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  
gdalwarp -overwrite   -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90   -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif
rm -f $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt

gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif  $OUTSENS/OBS_${SENS}_QC_day${DAY}_wgs84.tif

rm -f  $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif

rm -f  $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day$DAY.vrt   $OUTSENS/OBS_${SENS}_day$DAY.vrt   $OUTSENS/LST_${SENS}_day$DAY.vrt

# valory <= 3 are set as 0