# for DN in Day Nig ;  do  qsub -v DN=$DN,SEQ=$SEQ /u/gamatull/scripts/LST/spline/sc11_celsius_MOYD11A2mean.sh  ; done 


#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=24:model=has
#PBS -l walltime=4:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr
#PBS -N sc11_celsius_MOYD11A2mean.sh

echo /u/gamatull/scripts/LST/spline/sc11_celsius_MOYD11A2mean.sh

export MOD=/nobackupp8/gamatull/dataproces/LST/MOD11A2_spline15_merge_celsius  
export MYD=/nobackupp8/gamatull/dataproces/LST/MYD11A2_spline15_merge_celsius  
export DN=$DN

export OUTDIR=/nobackupp8/gamatull/dataproces/LST/MYOD11A2_celsiusmean
export RAMDIR=/dev/shm

cleanram

seq 1 13   | xargs -n 1 -P  13 bash -c $'  

band=$1 

echo processing the dayly mean for $1

gdal_calc.py  --NoDataValue=-9999 --overwrite  --type=Float32  --creation-option=COMPRESS=DEFLATE  --co=ZLEVEL=9  -A $MOD/LST_MOD_${DN}_spline_month${band}.tif   -B $MYD/LST_MYD_${DN}_spline_month${band}.tif  \
--calc="( (A + B ) / 2  )"    --outfile=$OUTDIR/LST_MOYDmean_${DN}_spline_month${band}_tmp.tif

echo normalize  the mean for $1

gdal_calc.py --NoDataValue=-9999 --overwrite  --type=Float32  --creation-option=COMPRESS=DEFLATE  --co=ZLEVEL=9   -A $MOD/LST_MOD_${DN}_spline_month${band}.tif   -B $MYD/LST_MYD_${DN}_spline_month${band}.tif  \
--calc="( (A - B ) /  (A + B +  0.00000001 )  )" --outfile=$OUTDIR/LST_MOYDnorm_${DN}_spline_month${band}_tmp.tif

echo masking the mean for $1

pksetmask -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot=Float32 \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-i $OUTDIR/LST_MOYDmean_${DN}_spline_month${band}_tmp.tif     -o $OUTDIR/LST_MOYDmean_${DN}_spline_month${band}.tif

echo masking the normal for $1

pksetmask -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot=Float32 \
-msknodata 255 -nodata -2 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -2 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 255 -nodata -2 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -2 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-i $OUTDIR/LST_MOYDnorm_${DN}_spline_month${band}_tmp.tif     -o $OUTDIR/LST_MOYDnorm_${DN}_spline_month${band}.tif

rm  $OUTDIR/LST_MOYDmean_${DN}_spline_month${band}_tmp.tif  $OUTDIR/LST_MOYDnorm_${DN}_spline_month${band}_tmp.tif

echo processing  the max  for $1

pkcomposite  -cr  maxband  -srcnodata -9999 -dstnodata -9999 -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9  -i $MOD/LST_MOD_${DN}_spline_month${band}.tif -i $MYD/LST_MYD_${DN}_spline_month${band}.tif  -o $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}_tmp.tif

pksetmask -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot=Float32 \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-i $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}_tmp.tif    -o $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}.tif

rm $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}_tmp.tif

echo processing  the min  for $1

pkcomposite  -cr  minband  -srcnodata -9999 -dstnodata -9999 -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9  -i $MOD/LST_MOD_${DN}_spline_month${band}.tif -i $MYD/LST_MYD_${DN}_spline_month${band}.tif  -o $OUTDIR/LST_MOYDmin_${DN}_spline_month${band}_tmp.tif

pksetmask -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot=Float32 \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-i $OUTDIR/LST_MOYDmin_${DN}_spline_month${band}_tmp.tif    -o $OUTDIR/LST_MOYDmin_${DN}_spline_month${band}.tif

rm $OUTDIR/LST_MOYDmin_${DN}_spline_month${band}_tmp.tif 

echo processing  the max  for $1

pkcomposite  -cr  maxband  -srcnodata -9999 -dstnodata -9999 -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9  -i $MOD/LST_MOD_${DN}_spline_month${band}.tif -i $MYD/LST_MYD_${DN}_spline_month${band}.tif  -o $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}_tmp.tif

pksetmask -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot=Float32 \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif \
-msknodata 255 -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-msknodata 0   -nodata -9999 -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif \
-i $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}_tmp.tif    -o $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}.tif

rm $OUTDIR/LST_MOYDmax_${DN}_spline_month${band}_tmp.tif 

' _

cleanram
