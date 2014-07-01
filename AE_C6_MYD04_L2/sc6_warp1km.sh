
# to prepare the dataset for testing 
# for DAY in $(seq 1 365)  ; do qsub -v  DAY=$DAY  /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc6_warp1km.sh  ; done  

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=01:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export INDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/temp_smoth
export OUTDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/temp_smoth_1km

# export DAY=$1

DAY=$DAY

rm -f  $OUTDIR/merge$DAY.vrt  $OUTDIR/merge$DAY.tif 
gdalbuildvrt  -overwrite  $OUTDIR/merge$DAY.vrt    $INDIR/smoth_mean_alldays??_band$DAY.tif

echo warping   $OUTDIR/merge$DAY.tif 
gdalwarp  -ot   Float32  -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9   -r cubicspline -tr 0.008333333333333333  0.008333333333333333  $OUTDIR/merge$DAY.vrt    $OUTDIR/merge$DAY.tif 
gdal_translate -ot Int16    -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/merge$DAY.tif  $OUTDIR/AOD_day$DAY.tif
rm -f  $OUTDIR/merge$DAY.tif  

exit


# questa parte la sposto in grass

rm -f $OUTDIR/tmp_AOD_day$DAY.tif
gdal_calc.py   --co=BIGTIFF=YES,COMPRESS=LZW,ZLEVEL=9       -A  $OUTDIR/comp_merge$DAY.tif     --calc="(  1-(2.718281828 ^ ( 0 - ( A ) ) )   )"     --outfile=$OUTDIR/tmp_AOD_day$DAY.tif

gdal_translate   -ot   Float32   -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/tmp_AOD_day$DAY.tif $OUTDIR/AOD_day$DAY.tif


