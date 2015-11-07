
# for PAR in mn ;  do qsub -v  PAR=$PAR /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc2_merge_treecover2014.sh   ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif_1km
OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000
RAM=/dev/shm
# md stay for meadian 
# mn for mean 

rm -rf $RAM/*

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_treecover2000_??N_???E.tif -o $RAM/treecover_${PAR}_NE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_treecover2000_??S_???E.tif -o $RAM/treecover_${PAR}_SE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_treecover2000_??N_???W.tif -o $RAM/treecover_${PAR}_NW.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_treecover2000_??S_???W.tif -o $RAM/treecover_${PAR}_SW.tif

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9  $RAM/treecover_${PAR}_??.tif  -o  $RAM/tree_${PAR}_frequency_GFC2014.tif

gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9  $RAM/tree_${PAR}_frequency_GFC2014.tif  $OUTDIR/tree_${PAR}_frequency_GFC2014.tif

rm -f $RAM/*

if [ $PAR = 'mn'  ] ; then PAR1=Mean   ; fi 
if [ $PAR = 'md'  ] ; then PAR1=Median ; fi 
 

gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2013 (Hansen 2014)"\
             -mo "Input layer=Tree canopy cover for year 2000 (%)"\
             -mo "Output=$PAR1 of Tree cover (%)"\
             -mo "Offset=0" -mo "Scale=0.01" $OUTDIR/tree_${PAR}_percentage_GFC2014.tif

