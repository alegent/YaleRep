
#  qsub  -q devel   -l walltime=2:00:00   -v SENS=MYD  /u/gamatull/scripts/LST/spline/sc4_fill4spline_MOYD11A2.sh 

#PBS -S /bin/bash
#PBS -l select=1:ncpus=23
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo sc4_fill4spline_MOYD11A2.sh 

export SENS=${SENS}
export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export MSK=/nobackup/gamatull/dataproces/LST/${SENS}11A2_mean_msk
export RAMDIR=/dev/shm

rm -f /dev/shm/*

# cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  | xargs -n 1 -P  23   bash -c $' 
echo 209   | xargs -n 1 -P  23   bash -c $' 
DAY=$1

echo masking $DAY  $SENS
# 0 for the cloud and -1 for the sea  and -1 also for the pixel with less than 5 observation

# 255 sea 
# 0 lst with 0 value
# OBS_${SENS}_QC_day${DAY}_wgs84.tif  exclude pixel with less then one observation over 12 years 

#  e stata introdotta l c per differenziarla dall altra

pksetmask -co COMPRESS=LZW -co ZLEVEL=9  \
-msknodata 0   -nodata  0    -m  $MSK/${SENS}_CLOUD3k_day${DAY}_wgs84.tif \
-msknodata 255 -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif   \
-msknodata 0   -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif   \
-msknodata 1   -nodata  0    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/OBS_${SENS}_QC_day${DAY}_wgs84.tif \
-i  $INSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif  -o  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84c.tif

# spatial interpolation......done for cloud and see than mask out the sea 

pkfilter -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0 -f smoothnodata -dx 3 -dy 3 -interp akima -i  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84c.tif -o $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_tmpc.tif  

# 0 for the cloud and -1 for the sea ; the 0 is coming from the lst refilled 

obsmin=5

pksetmask -co COMPRESS=LZW -co ZLEVEL=9 \
-msknodata 1   -nodata -1 -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask${obsmin}noobs_wgs84_grow1p_ct.tif  \
-msknodata 255 -nodata -1 -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif  \
-msknodata 0   -nodata -1 -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif  \
-i  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_tmpc.tif      -o   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_fillspatc.tif
rm -f  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_tmpc.tif 

' _ 

rm -f /dev/shm/*
