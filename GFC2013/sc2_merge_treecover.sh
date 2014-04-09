
# for PAR in mn md ; do qsub -v  PAR=$PAR /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc2_merge_treecover.sh ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=2
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

INDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif_1km
OUTDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000

# md stay for meadian 
# mn for mean 

rm -f /tmp/treecover_${PAR}_NE.tif  /tmp/treecover_${PAR}_SE.tif  /tmp/treecover_${PAR}_NW.tif /tmp/treecover_${PAR}_SW.tif 

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_${PAR}_Hansen_GFC2013_treecover2000_??N_???E.tif -o /tmp/treecover_${PAR}_NE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_${PAR}_Hansen_GFC2013_treecover2000_??S_???E.tif -o /tmp/treecover_${PAR}_SE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_${PAR}_Hansen_GFC2013_treecover2000_??N_???W.tif -o /tmp/treecover_${PAR}_NW.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_${PAR}_Hansen_GFC2013_treecover2000_??S_???W.tif -o /tmp/treecover_${PAR}_SW.tif

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9  /tmp/treecover_${PAR}_??.tif  -o  /tmp/tree_${PAR}_frequency_GFC2013.tif

gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9  /tmp/tree_${PAR}_frequency_GFC2013.tif  $OUTDIR/tree_${PAR}_frequency_GFC2013.tif

rm -f /tmp/tree_${PAR}_frequency_GFC2013.tif

if [ $PAR = 'mn'  ] ; then PAR1=Mean   ; fi 
if [ $PAR = 'md'  ] ; then PAR1=Median ; fi 
 

gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2012 (Hansen 2013)"\
             -mo "Input layer=Tree canopy cover for year 2000 (%)"\
             -mo "Output=$PAR1 of Tree cover (%)"\
             -mo "Offset=0" -mo "Scale=0.01" $OUTDIR/tree_${PAR}_percentage_GFC2013.tif

