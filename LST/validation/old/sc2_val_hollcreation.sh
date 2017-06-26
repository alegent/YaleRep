
#  qsub  -q normal   -l walltime=2:00:00   -v SENS=MYD  /u/gamatull/scripts/LST/sc2_val_hollcreation.sh

#PBS -S /bin/bash
#PBS -l select=1:ncpus=23
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo sc4_fill4spline_MOYD11A2.sh 

export SENS=$1
export INSENS=/nobackupp8/gamatull/dataproces/LST/MOD11A2_val/${SENS}11A2_mean
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/MOD11A2_val/${SENS}11A2_spline4fill
export MSK=/nobackup/gamatull/dataproces/LST/${SENS}11A2_mean_msk
export RAMDIR=/dev/shm

rm -f /dev/shm/*

# the same to /u/gamatull/scripts/LST/sc4_fill4spline_MOYD11A2.sh but small study area

# cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt   | xargs -n 1 -P  23   bash -c $' 
# DAY=$1

# echo masking $DAY  $SENS
# # 0 for the cloud and -1 for the sea

# gdalbuildvrt -overwrite   -te  60  -10 100 30    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.vrt  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/LST_${SENS}_QC_day${DAY}_wgs84.tif 

# pksetmask -of GTiff   -co COMPRESS=LZW -co ZLEVEL=9   -msknodata 0 -nodata 0    -m  $MSK/${SENS}_CLOUD3k_day${DAY}_wgs84.tif   -msknodata 1 -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_mask_wgs84.tif    -i   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.vrt -o  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif

# # spatial interpolation......done for cloud and see than mask out the sea 

# pkfilter -of GTiff  -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0 -f smoothnodata -dx 3 -dy 3 -interp  cspline -i $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.vrt  -o $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_tmp.tif  
# # 0 for the cloud and -1 for the sea ; the 0 is coming from the lst refilled 
# pksetmask -co COMPRESS=LZW -co ZLEVEL=9    -msknodata 1 -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_mask_wgs84.tif    -i  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_tmp.tif  -o   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_fillspat.tif

# rm -f  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_tmp.tif 
# rm -f $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.vrt 
# ' _ 

echo start to create holl in the day with observation


rm -f /dev/shm/*


echo 193 1  > /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 193 2  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 2  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 185 3  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 193 3  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 3  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 185 4  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 193 4  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 4  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 209 4  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 177 5  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 185 5  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 193 5  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 5  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 209 5  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 177 6  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 185 6  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 193 6  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 6  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 209 6  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 217 6  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 169 7  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 177 7  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 185 7  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 193 7  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 7  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 209 7  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 217 7  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 169 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 177 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 185 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 193 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 209 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 217 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 225 8  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb

echo 161 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 169 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 177 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 185 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 193 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 201 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 209 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 217 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb
echo 225 9  >> /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb


cat /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/day_holl_numb     | xargs -n 2 -P  23   bash -c $' 

DAY=$1
HOLDAY=$2

echo masking $DAY  $SENS
# 0 for the cloud and -1 for the sea

gdalbuildvrt -overwrite   -te  60  -10 100 30    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.vrt  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/LST_${SENS}_QC_day${DAY}_wgs84.tif 

pksetmask -of GTiff   -co COMPRESS=LZW -co ZLEVEL=9   -msknodata 0 -nodata 0    -m  $MSK/${SENS}_CLOUD3k_day${DAY}_wgs84.tif   -msknodata 1 -nodata 0  -m /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/MOD_area4holl.tif    -msknodata 1 -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_mask_wgs84.tif    -i   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.vrt -o  ${OUTSENS}_${HOLDAY}hole/LST_${SENS}_QC_day${DAY}_wgs84.tif


# spatial interpolation......done for cloud and see than mask out the sea 

pkfilter -of GTiff  -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0 -f smoothnodata -dx 3 -dy 3 -interp  cspline -i $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.vrt  -o ${OUTSENS}_${HOLDAY}hole/LST_${SENS}_QC_day${DAY}_wgs84_tmp.tif  
# 0 for the cloud and -1 for the sea ; the 0 is coming from the lst refilled 
pksetmask -co COMPRESS=LZW -co ZLEVEL=9    -msknodata 1 -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_mask_wgs84.tif  -i  ${OUTSENS}_${HOLDAY}hole/LST_${SENS}_QC_day${DAY}_wgs84_tmp.tif  -o  ${OUTSENS}_${HOLDAY}hole/LST_${SENS}_QC_day${DAY}_wgs84_fillspat.tif



' _ 

rm -f $OUTSENS/LST_${SENS}_QC_day???_wgs84.vrt 
rm -f  ${OUTSENS}_${HOLDAY}hole/LST_${SENS}_QC_day???_wgs84_tmp.tif 
rm -f /dev/shm/*
