
# for YEAR in `seq 1 12`  ; do qsub -v  YEAR=$YEAR /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc2_merge_lossyear.sh  ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=2gb
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


INDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tif_1km
OUTDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear

# md stay for meadian 
# mn for mean 

rm -f /tmp/lossyear${YEAR}_NE.tif  /tmp/lossyear${YEAR}_SE.tif  /tmp/lossyear${YEAR}_NW.tif /tmp/lossyear${YEAR}_SW.tif  /tmp/lossyear${YEAR}.tif 

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_y${YEAR}_Hansen_GFC2013_lossyear_??N_???E.tif -o /tmp/lossyear${YEAR}_NE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_y${YEAR}_Hansen_GFC2013_lossyear_??S_???E.tif -o /tmp/lossyear${YEAR}_SE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_y${YEAR}_Hansen_GFC2013_lossyear_??N_???W.tif -o /tmp/lossyear${YEAR}_NW.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_y${YEAR}_Hansen_GFC2013_lossyear_??S_???W.tif -o /tmp/lossyear${YEAR}_SW.tif

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9  /tmp/lossyear${YEAR}_??.tif    -o  /tmp/lossyear${YEAR}.tif

gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9  /tmp/lossyear${YEAR}.tif   $OUTDIR/lossyear${YEAR}_frequency_GFC2013.tif

rm -f /tmp/lossyear${YEAR}.tif /tmp/lossyear${YEAR}_NE.tif  /tmp/lossyear${YEAR}_SE.tif  /tmp/lossyear${YEAR}_NW.tif /tmp/lossyear${YEAR}_SW.tif


YEARL=`expr 2000 + $YEAR`

gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2012 (Hansen 2013)"\
             -mo "Input layer=Year of gross forest cover loss event"\
             -mo "Output=Gross Forest Cover Loss during $YEARL in Frequency(%)"\
             -mo "Offset=0" -mo "Scale=0.01" $OUTDIR/lossyear${YEAR}_frequency_GFC2013.tif
mv  $OUTDIR/lossyear${YEAR}_frequency_GFC2013.tif $OUTDIR/lossyear${YEARL}_frequency_GFC2013.tif

checkjob -v $PBS_JOBID

