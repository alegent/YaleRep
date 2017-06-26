# crea il clump delle are con meno di 5 osservazioni. fatto girare solo per MYD
# qsub  /u/gamatull/scripts/LST/sc2_val_area_selection_clump.sh


#PBS -S /bin/bash
#PBS -q devel
#PBS -l select=1:ncpus=1
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo  /u/gamatull/scripts/LST/sc1_val_area_selection.sh

export LST=/nobackupp8/gamatull/dataproces/LST
export RAMDIR=/dev/shm
export SENS=MYD

rm -f /dev/shm/*

# sum up area with lst value in order to have area with full observation; the area with 47 area will full data cover 

seq 0 10  | xargs -n 1 -P 11  bash -c $'  
min=$1
max=$1
pkgetmask   -co COMPRESS=LZW -co ZLEVEL=9  -min $1 -max $1  -i  $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_ct.tif -o  $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM${1}_wgs84_ct.tif 
oft-clump    -i $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM${1}_wgs84_ct.tif  -um $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM${1}_wgs84_ct.tif  -o  $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_dayCLUMP${1}_wgs84_ct_tmp.tif 
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_dayCLUMP${1}_wgs84_ct_tmp.tif   $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_dayCLUMP${1}_wgs84_ct.tif 
' _ 


rm -f /dev/shm/*

