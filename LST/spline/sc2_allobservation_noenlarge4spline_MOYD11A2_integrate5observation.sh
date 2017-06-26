# growing the lst of 1 pixel
# for SENS in MYD MOD ; do for DN in Day Nig ; do  qsub  -v SENS=$SENS,DN=$DN   /u/gamatull/scripts/LST/spline/sc2_allobservation_noenlarge4spline_MOYD11A2_integrate5observation.sh ; done ; done 
# bash sc2_allobservation_noenlarge4spline_MOYD11A2_integrate5observation.sh MYD Day

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=23:model=has
#PBS -l walltime=4:00:00
#PBS -V
#PBS -N sc2_allobservation_noenlarge4spline_MOYD11A2_integrate5observation.sh
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo   /u/gamatull/scripts/LST/spline/sc2_allobservation_noenlarge4spline_MOYD11A2_integrate5observation.sh

export DN=$DN
export SENS=$SENS

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/wgs84
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export MSK=/nobackup/gamatull/dataproces/LST/${SENS}11A2_mean_msk
export RAMDIR=/dev/shm
echo $DN $SENS 

cleanram 



cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  | xargs -n 1 -P  23   bash -c $'
export DAY=$1

if [ $DN = Day ] ; then rule=maxband ; fi
if [ $DN = Nig ] ; then rule=minband ; fi  

# create a composite as a max or min  of the other immages 
SENSDN=${SENS}_$DN
pkcomposite -srcnodata -5 -srcnodata -1 -srcnodata 0 -dstnodata -5  -co BIGTIFF=YES  -co COMPRESS=LZW  -cr $rule  $( echo "MYD_Day MYD_Nig MOD_Day MOD_Nig" | awk -v SENSDN=$SENSDN \'{ gsub ( SENSDN , "") ; gsub ( "_" , " ") ;  print    }\'  | xargs -n 2  bash -c $\'  echo -n  "-i $OUTSENS/../${1}11A2_spline4fill/LST_${1}_QC_day${DAY}_wgs84_${2}_allobs_mask5noobs.tif "   \' _ )  -o $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_$rule.tif 

# mask all the values expet the ones in -5 in input mask 
pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9   -co BIGTIFF=YES   -m   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs.tif -msknodata -5  -p "!"    -nodata -5  -i  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_$rule.tif   -o  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_${rule}Select.tif 

rm -f $RAMDIR/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_$rule.tif 

pkcomposite -srcnodata -5 -srcnodata -1   -dstnodata 0 -co COMPRESS=LZW    -cr overwrite  -i  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs.tif -i $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_${rule}Select.tif  -o    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_Fill5obs_tmp.tif 

pksetmask -co COMPRESS=LZW -co ZLEVEL=9  \
-m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif      -msknodata 255   -nodata -1   \
-m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif      -msknodata 0     -nodata -1   \
-i  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_Fill5obs_tmp.tif  \
-o  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_Fill5obs.tif 

rm -f $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_${rule}Select.tif  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_${DN}_allobs_mask5noobs_Fill5obs_tmp.tif  

' _ 

cleanram 

# this run the computation including  india
qsub -v SENS=$SENS,DN=$DN   /u/gamatull/scripts/LST/spline/sc3_fillsplineAkima_MOYD11A2_allobs.sh
