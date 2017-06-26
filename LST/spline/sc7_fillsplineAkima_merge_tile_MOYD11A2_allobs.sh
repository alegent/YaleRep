# for SENS in MYD MOD ; do for DN in Day Nig ; do  qsub  -v SENS=$SENS,DN=$DN  /u/gamatull/scripts/LST/spline/sc7_fillsplineAkima_merge_tile_MOYD11A2_allobs.sh  ; done ; done 

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=24:model=has
#PBS -l walltime=2:00:00
#PBS -V
#PBS -N sc7_fillsplineAkima_merge_tile_MOYD11A2_allobs.sh
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo $SENS  /u/gamatull/scripts/LST/spline/sc7_fillsplineAkima_merge_tile_MOYD11A2_allobs.sh 

export SENS=$SENS
export DN=$DN

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill_merge
export MSK=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk

export RAMDIR=/dev/shm


cleanram

cat  /nobackup/gamatull/dataproces/LST/geo_file/list_day_nr.txt   | xargs -n 2 -P  24  bash -c $' 
day=$1
band=$2

rm -f $RAMDIR/LST_${SENS}_akima_day${day}.vrt  
gdalbuildvrt  -b $band   -overwrite  $RAMDIR/LST_${SENS}_akima_day${day}.vrt   $INSENS/LST_${SENS}_akima_${DN}_h??v??_allobsB.tif
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/LST_${SENS}_akima_day${day}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${day}_tmp_allobs.tif 

pksetmask -of GTiff -co COMPRESS=LZW -co ZLEVEL=9 \
-m  $MSK/${SENS}_LST3k_count_yessea_ct.tif                             -msknodata 255   -nodata -1   \
-m  $MSK/${SENS}_LST3k_count_yessea_ct.tif                             -msknodata 0     -nodata -1   \
-i $OUTSENS/LST_${SENS}_akima_${DN}_day${day}_tmp_allobs.tif  -o  $OUTSENS/LST_${SENS}_akima_${DN}_day${day}_allobs_Fill5obs_maskoutIndia.tif

# remosso il 
# -m  $MSK/${SENS}_LST3k_mask_daySUM_wgs84_${DN}_allobs_mask5noobs.tif   -msknodata 1     -nodata -1   \

gdalwarp  -srcnodata -1  -dstnodata -1  -t_srs EPSG:4326  -r average  -te -180 -90 +180 +90 -tr 0.08333333333333 0.08333333333333   -multi  -overwrite  -co  COMPRESS=LZW -co ZLEVEL=9   $OUTSENS/LST_${SENS}_akima_${DN}_day${day}_allobs_Fill5obs_maskoutIndia.tif  $OUTSENS/LST_${SENS}_akima_${DN}_day${day}_allobs_Fill5obs_maskoutIndia_10km.tif

rm -f  $OUTSENS/LST_${SENS}_akima_${DN}_day${day}_tmp_allobs.tif 
' _ 

cleanram


# qsub -v SENS=$SENS,DN=$DN  /u/gamatull/scripts/LST/spline/sc8_maskoutIndia_merge.sh
qsub -v SENS=$SENS,DN=$DN  /u/gamatull/scripts/LST/spline/sc8_maskoutIndia-Patag_merge.sh
