
# qsub /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc2_merge_datamask.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

INDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/datamask/tif_1km
OUTDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/datamask


rm -f $OUTDIR/water_perc_NE.tif  $OUTDIR/water_perc_SE.tif  $OUTDIR/water_perc_NW.tif $OUTDIR/water_perc_SW.tif 

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2013_datamask_??N_???E.tif -o $OUTDIR/water_perc_NE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2013_datamask_??S_???E.tif -o $OUTDIR/water_perc_SE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2013_datamask_??N_???W.tif -o $OUTDIR/water_perc_NW.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2013_datamask_??S_???W.tif -o $OUTDIR/water_perc_SW.tif

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9 $OUTDIR/water_perc_??.tif -o   $OUTDIR/land_frequency_Hansen_GFC2013.tif



gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2012 (Hansen 2013)" \
             -mo "Input layer=Data mask"\
             -mo "Output=Land Frequency(%)"\
             -mo "Offset=0" -mo "Scale=0.01" $OUTDIR/land_frequency_GFC2013.tif
