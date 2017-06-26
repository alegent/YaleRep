
# for SENS in MYD MOD ; do for DN in Day Nig ; do  qsub   -v SENS=$SENS,DN=$DN  /u/gamatull/scripts/LST/spline/sc10_kelvin2celsius_MOYD11A2.sh ; done ; done 

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=13:model=has
#PBS -l walltime=4:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo /u/gamatull/scripts/LST/spline/sc10_kelvin2celsius_MOYD11A2.sh 

export  SENS=$SENS
export  DN=$DN

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline15_merge
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline15_merge_celsius

export RAMDIR=/dev/shm


seq 1 13  | xargs -n 1 -P  13 bash -c $'  

band=$1 

gdal_calc.py --overwrite  --type=Float32  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A   $INSENS/LST_${SENS}_${DN}_spline_month${band}.tif    --outfile=$OUTSENS/LST_${SENS}_${DN}_spline_month${band}_tmp.tif   --calc="(( A * 0.02 )  - 272.15 )"

pksetmask -of GTiff -co COMPRESS=LZW -co ZLEVEL=9 -ot=Float32 \
-m /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif       -msknodata 255   -nodata -9999 \
-m /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif       -msknodata 0     -nodata -9999 \
-i $OUTSENS/LST_${SENS}_${DN}_spline_month${band}_tmp.tif   -o $OUTSENS/LST_${SENS}_${DN}_spline_month${band}.tif

# rimosso 
# -m /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_${DN}_allobs_mask5noobs.tif   -msknodata 1     -nodata -9999 \

rm  $OUTSENS/LST_${SENS}_${DN}_spline_month${band}_tmp.tif

' _

if [ $SENS = "MYD" ] ; then 
    qsub -v DN=$DN -W depend=afterany:$(qstat | grep sc10_kelvin2celsius_MOYD11A2.sh | awk  '{ORS = ":" ; print $1  }' |  sed 's/.$//' ) /u/gamatull/scripts/LST/spline/sc11_celsius_MOYD11A2mean.sh
fi 
