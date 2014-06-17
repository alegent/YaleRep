
# bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_C6_L2/sc2_mean_C51_C6.sh  001 7

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=10:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

DAYc=$1
WIND=$2

export INDIRC51=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/mean_${WIND}/tif
export INDIRC6=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/mean_${WIND}_C6/tif
export OUTDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_C6_L2/mean_${WIND}/tif
export DAYc=$DAYc
export WIND=$WIND

echo merge the two dataset AE_C51_MOD04_L2_MYD04_L2 and AE_C6_MYD04_L2 

pkcomposite -i $INDIRC51/AOD_550_mean_day$DAYc.tif -i $INDIRC6/AOD_550_Dark_Target_Deep_Blue_day$DAYc.tif  -min -1 -max 5001 -cr mean -dstnodata -9999  -srcnodata -9999  -ot Int16   -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_550_mean_day${DAYc}.tif
pkgetmask  -min -1 --max 5001 -data 1 -nodata 0    -i  $OUTDIR/AOD_550_mean_day${DAYc}.tif  -o   $OUTDIR/AOD_550_mean_day${DAYc}_mask.tif

pkfillnodata  -m  $OUTDIR/AOD_550_mean_day${DAYc}_mask.tif    -d 1 -it 1   -i $OUTDIR/AOD_550_mean_day${DAYc}.tif -o  $OUTDIR/AOD_550_mean_day${DAYc}_fill.tif 

