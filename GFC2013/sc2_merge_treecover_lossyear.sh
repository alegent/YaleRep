
# bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc2_merge_treecover_lossyear.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=2
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr



export INDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tif_1km
export OUTDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tree_lossyear


seq 2001 2012 | xargs -n 1 -P 12  bash -c $' 

YEAR=$1
YEAR_PREC=$( expr $YEAR - 1 )

gdalbuildvrt -overwrite $OUTDIR/tree${YEAR}_percentage_GFC2013.vrt  $INDIR/1km_mn_Hansen_GFC2013_treecover2000_*_*_loss$YEAR.tif
gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9       $OUTDIR/tree${YEAR}_percentage_GFC2013.vrt   $OUTDIR/tree${YEAR}_percentage_GFC2013.tif 

gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2012 (Hansen 2013)"\
             -mo "Input layer=Tree canopy cover for year $YEAR_PREC (%) ;  Gross Forest Cover Loss during $YEAR"\
             -mo "Output=Mean of Tree cover (%) for the $YEAR"\
             -mo "Offset=0" -mo "Scale=0.01"  \
             -a_nodata "-1" $OUTDIR/tree${YEAR}_percentage_GFC2013.tif 

' _ 
