# growing the lst of 1 pixel
# qsub  -v SENS=MYD /u/gamatull/scripts/LST/spline/sc3_sc4_more1observation_noenlarge4spline_MOYD11A2.sh

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=23
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo   /u/gamatull/scripts/LST/spline/sc3_sc4_more1observation_noenlarge4spline_MOYD11A2.sh
export SENS=$SENS
export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export MSK=/nobackup/gamatull/dataproces/LST/${SENS}11A2_mean_msk
export RAMDIR=/dev/shm

rm -f /dev/shm/*

cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  | xargs -n 1 -P  23   bash -c $'
DAY=$1
echo masking $DAY  $SENS
# 0 for the cloud and -1 for the sea  and -1 also for the pixel with less than 5 observation
# 0 lst with 0 value
# OBS_${SENS}_QC_day${DAY}_wgs84.tif  exclude pixel with less then one observation over 12 years

pksetmask -co COMPRESS=LZW -co ZLEVEL=9  \
-msknodata 0   -nodata  0    -m  $MSK/${SENS}_CLOUD3k_day${DAY}_wgs84.tif \
-msknodata 255 -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif   \
-msknodata 0   -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif   \
-msknodata 1   -nodata  0    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/OBS_${SENS}_QC_day${DAY}_wgs84.tif \
-i  $INSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif  -o  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_more1obs.tif

oft-calc -ot Byte  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_more1obs.tif  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_more1obsBolean.tif <<EOF
1
#1 1 > 0 1 ?
EOF

' _

rm -f   $RAMDIR/LST_${SENS}.vrt
gdalbuildvrt -overwrite -separate  $RAMDIR/LST_${SENS}.vrt  $OUTSENS/LST_${SENS}_QC_day???_wgs84_more1obsBolean.tif 

oft-calc -ot Byte  $RAMDIR/LST_${SENS}.vrt  $RAMDIR/${SENS}_LST3k_count.tif   <<EOF
1
#1 #2 #3 #4 #5 #6 #7 #8 #9 #10 #11 #12 #13 #14 #15 #16 #17 #18 #19 #20 #21 #22 #23 #24 #25 #26 #27 #28 #29 #30 #31 #32 #33 #34 #35 #36 #37 #38 #39 #40 #41 #42 #43 #44 #45 #46 + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
EOF

pkcreatect  -min 0 -max 46   > /tmp/color.txt
pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct  /tmp/color.txt   -i     $RAMDIR/${SENS}_LST3k_count.tif  -o  $MSK/${SENS}_LST3k_mask_daySUM_wgs84_more1obs.tif
 
# the max value is considered as 1 ; max <= 5  ; this is used in combination of the sea mask to select only pixel with more than 5 obs.
pkgetmask -min -1 -max 5 -data 1 -nodata 0 -co COMPRESS=LZW -co ZLEVEL=9   -i  $MSK/${SENS}_LST3k_mask_daySUM_wgs84_more1obs.tif -o $MSK/${SENS}_LST3k_mask_daySUM_wgs84_more1obs_mask5noobs.tif
# mask all pixel with les than 5 obs in the year

cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  | xargs -n 1 -P  23   bash -c $'
DAY=$1
echo masking $DAY  $SENS
# 0 for the cloud and -1 for the sea  and -1 also for the pixel with less than 5 observation
# 0 lst with 0 value
# OBS_${SENS}_QC_day${DAY}_wgs84.tif  exclude pixel with less then one observation over 12 years

pksetmask -co COMPRESS=LZW -co ZLEVEL=9  \
-msknodata 0   -nodata  0    -m  $MSK/${SENS}_CLOUD3k_day${DAY}_wgs84.tif \
-msknodata 255 -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif   \
-msknodata 0   -nodata -1    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif   \
-msknodata 1   -nodata  0    -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/OBS_${SENS}_QC_day${DAY}_wgs84.tif \
-msknodata 1   -nodata -1    -m  $MSK/${SENS}_LST3k_mask_daySUM_wgs84_more1obs_mask5noobs.tif \
-i  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif  -o  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_more1obs_mask5noobs.tif

' _

rm  -f /dev/shm/*

qsub -v SENS=$SENS  /u/gamatull/scripts/LST/spline/sc5_fillsplineAkima_MOYD11A2_more1obs.sh
