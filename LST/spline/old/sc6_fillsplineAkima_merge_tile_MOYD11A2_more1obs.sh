
#  qsub -v SENS=MYD  /u/gamatull/scripts/LST/spline/sc6_fillsplineAkima_merge_tile_MOYD11A2_more1obs.sh

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=24
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo $SENS  /u/gamatull/scripts/LST/sc5_fillsplineAkima_merge_tile_MOYD11A2.sh

export  SENS=$SENS

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill_merge

export RAMDIR=/dev/shm


rm -f /dev/shm/*

cat  /nobackup/gamatull/dataproces/LST/geo_file/list_day_nr.txt   | xargs -n 2 -P  24  bash -c $' 
day=$1
band=$2

gdalbuildvrt  -b $band   -overwrite  $RAMDIR/LST_${SENS}_akima_day${day}.vrt   $INSENS/LST_${SENS}_akima_h??v??_more1obs.tif     
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/LST_${SENS}_akima_day${day}.vrt  $OUTSENS/LST_${SENS}_akima_day${day}_tmp_more1obs.tif 

pksetmask -of GTiff -co COMPRESS=LZW -co ZLEVEL=9 \
-msknodata 1   -nodata -1 -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_more1obs_mask5noobs.tif   \
-msknodata 255 -nodata -1 -m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif \
-i $OUTSENS/LST_${SENS}_akima_day${day}_tmp_more1obs.tif  -o  $OUTSENS/LST_${SENS}_akima_day${day}_more1obs.tif     
rm -f  $OUTSENS/LST_${SENS}_akima_day${day}_tmp_more1obs.tif 
' _ 

rm -f /dev/shm/*
