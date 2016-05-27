# qsub /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc9_renameTif.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=10:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/final

echo 1 5 10 50 100 | xargs -n 1 -P 8 bash -c $'

km=$1

if [ $km -eq 1 ] ; then res="30 arc-seconds" ; fi   
if [ $km -eq 5 ] ; then res="2.5 arc-minute " ; fi   
if [ $km -eq 10 ] ; then res="5 arc-minute" ; fi   
if [ $km -eq 50 ] ; then res="25 arc-minute" ; fi   
if [ $km -eq 100 ] ; then res="50 arc-minute" ; fi   

for DIR in altitude roughness slope tpi tri vrm ; do 

if [ $DIR = altitude  ] ; then DIR2="elevation" ; fi   
if [ $DIR = roughness  ] ; then DIR2="roughness" ; fi   
if [ $DIR = slope  ] ; then DIR2="slope" ; fi   
if [ $DIR = tri  ] ; then DIR2="tri" ; fi   
if [ $DIR = tpi  ] ; then DIR2="tpi" ; fi   
if [ $DIR = vrm  ] ; then DIR2="vrm" ; fi   

for dir in max mean  median min stdev ; do  

if [ $dir = min ] ; then dir2="mi" ; fi   
if [ $dir = max ] ; then dir2="ma" ; fi   
if [ $dir = mean ] ; then dir2="mn" ; fi   
if [ $dir = median ] ; then dir2="md" ; fi   
if [ $dir = stdev ] ; then dir2="sd" ; fi   

gdal_translate   -projwin -180 +60  +180 -60  -co COMPRESS=DEFLATE  -co ZLEVEL=9  $INDIR/$DIR/$dir/${DIR}_${dir}_km${km}.tif   $OUTDIR/$DIR/${DIR2}_${km}KM${dir2}_SRTM.tif

echo gdal_edit  $OUTDIR/$DIR/${DIR2}_${km}KM${dir2}_SRTM.tif 
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME= ${res} ${dir}  ${DIR2}" \
-mo "TIFFTAG_IMAGEDESCRIPTION= $res $DIR2  ${dir}  derived from SRTM4.1dev" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.6.4 & GRASS7" \
-a_ullr -180 +60  +180 -60  \
-a_nodata -32768 $OUTDIR/$DIR/${DIR2}_${km}KM${dir2}_SRTM.tif

done 
done 

echo  aspect 

for dir in max mean  median min stdev ; do  

if [ $dir = min ] ; then dir2="mi" ; fi   
if [ $dir = max ] ; then dir2="ma" ; fi   
if [ $dir = mean ] ; then dir2="mn" ; fi   
if [ $dir = median ] ; then dir2="md" ; fi   
if [ $dir = stdev ] ; then dir2="sd" ; fi   

for var in cos sin Ew Nw ; do

if [ $var  = cos ] ; then var2="aspect-cosine" ; fi   
if [ $var = sin ] ; then var2="aspect-sine" ; fi   
if [ $var = Ew  ] ; then var2="eastness" ; fi   
if [ $var = Nw  ] ; then var2="northness" ; fi   


gdal_translate   -projwin -180 +60  +180 -60  -co COMPRESS=DEFLATE  -co ZLEVEL=9  $INDIR/aspect/$dir/aspect_${dir}_${var}_km${km}.tif   $OUTDIR/aspect/${var2}_${km}KM${dir2}_SRTM.tif

echo gdal_edit    $OUTDIR/aspect/${var2}_${km}KM${dir2}_SRTM.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME= ${res} ${dir}  ${var2}" \
-mo "TIFFTAG_IMAGEDESCRIPTION ${res} ${dir}  ${var2} derived from SRTM4.1dev" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.6.4 & GRASS7" \
-a_ullr -180 +60  +180 -60  \
-a_nodata -32768 $OUTDIR/aspect/${var2}_${km}KM${dir2}_SRTM.tif

done 
done


' _ 

exit 

