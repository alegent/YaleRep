
# for YEAR in `seq 1 13`  ; do qsub -v  YEAR=$YEAR /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc2_merge_lossyear2014.sh  ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=2:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr


INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif_1km
OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear

# md stay for meadian 
# mn for mean 

rm -f /tmp/lossyear${YEAR}_NE.tif  /tmp/lossyear${YEAR}_SE.tif  /tmp/lossyear${YEAR}_NW.tif /tmp/lossyear${YEAR}_SW.tif  /tmp/lossyear${YEAR}.tif 

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_lossyear${YEAR}_??N_???E.tif -o /tmp/lossyear${YEAR}_NE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_lossyear${YEAR}_??S_???E.tif -o /tmp/lossyear${YEAR}_SE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_lossyear${YEAR}_??N_???W.tif -o /tmp/lossyear${YEAR}_NW.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_lossyear${YEAR}_??S_???W.tif -o /tmp/lossyear${YEAR}_SW.tif

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9  /tmp/lossyear${YEAR}_??.tif    -o  /tmp/lossyear${YEAR}.tif

gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9  /tmp/lossyear${YEAR}.tif   $OUTDIR/lossyear${YEAR}_frequency_GFC2014.tif

rm -f /tmp/lossyear${YEAR}.tif /tmp/lossyear${YEAR}_NE.tif  /tmp/lossyear${YEAR}_SE.tif  /tmp/lossyear${YEAR}_NW.tif /tmp/lossyear${YEAR}_SW.tif


YEARL=`expr 2000 + $YEAR`

gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2013 (Hansen 2014)"\
             -mo "Input layer=Year of gross forest cover loss event"\
             -mo "Output=Gross Forest Cover Loss during $YEARL in Frequency(%)"\
             -mo "Offset=0" -mo "Scale=0.01" $OUTDIR/lossyear${YEAR}_frequency_GFC2014.tif
mv  $OUTDIR/lossyear${YEAR}_frequency_GFC2014.tif $OUTDIR/lossyear${YEARL}_frequency_GFC2014.tif

checkjob -v $PBS_JOBID

