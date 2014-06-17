# qsub  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc2_AODxQF.sh  

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=2:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr


export INDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2
echo multiply the AOD for the quality flag

ls $INDIR/2*/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year*.tif  |  xargs -n 1  -P 16  bash -c $' 

file=$1
DIR=$(dirname $file)
YEARDIR=$(dirname $DIR)
filename=$(basename  $file .tif)
firstpart=${filename:0:38}
secondpart=${filename:39:20}
# gdal_info -mm -50.000,5000.000

gdal_calc.py -A $file  -B $YEARDIR/tif/${firstpart}_QA_Flag_${secondpart}.tif --calc="( A * B)" --type Int16  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --overwrite --outfile=$YEARDIR/tif/${firstpart}_mult_QA_${secondpart}.tif


' _ 

