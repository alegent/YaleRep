
# bash /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc2_merge_treecover_lossyear2014.sh 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr



export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif_1km
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tree_lossyear


seq 2001 2013 | xargs -n 1 -P 8  bash -c $' 

YEAR=$1
YEAR_PREC=$( expr $YEAR - 1 )

gdalbuildvrt -overwrite $OUTDIR/tree${YEAR}_percentage_GFC2014.vrt  $INDIR/1km_mn_Hansen_GFC2014_treecover2000_*_*_loss$YEAR.tif
gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9       $OUTDIR/tree${YEAR}_percentage_GFC2014.vrt   $OUTDIR/tree${YEAR}_percentage_GFC2014.tif 

gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2013 (Hansen 2014)"\
             -mo "Input layer=Tree canopy cover for year $YEAR_PREC (%) ;  Gross Forest Cover Loss during $YEAR"\
             -mo "Output=Mean of Tree cover (%) for the $YEAR"\
             -mo "Offset=0" -mo "Scale=0.01"  \
             -a_nodata "-1" $OUTDIR/tree${YEAR}_percentage_GFC2014.tif 

' _ 
