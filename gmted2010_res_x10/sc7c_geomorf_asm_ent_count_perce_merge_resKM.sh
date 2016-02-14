# calculate different variables for the dem 

# for DIR  in count majority percent shannon asm ent  ; do qsub -v DIR=$DIR  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_geomorf_asm_ent_count_perce_merge_resKM.sh  ; done 
# bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_geomorf_asm_ent_count_perce_merge_resKM.sh  asm

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=2:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon
export RAM=/dev/shm
rm -f /dev/shm/*

export DIR=$DIR

if [ $DIR != percent  ] ; then
echo 1 5 10 50 100   | xargs -n 1 -P 8 bash -c $'
km=$1

if [ $DIR = asm ]  ; then  type=Float32 ;   prefix=HOM_ ; postfix="" ; nodata=1 ; fi  
if [ $DIR = ent ]  ; then  type=Float32 ;   prefix=ENT_ ; postfix="" ; nodata=0 ; fi  
if [ $DIR = count ]  ; then  type=Byte ;    prefix="" ;   postfix="" ; nodata=1 ; fi  
if [ $DIR = majority ]  ; then  type=Byte ; prefix="" ;   postfix="" ; nodata=1 ; fi  
if [ $DIR = shannon ]  ; then  type=Float32 ; prefix=""  ;   postfix="shannon_" ; nodata=1 ; fi  

gdalbuildvrt -overwrite   -o  $RAM/${DIR}_km${km}.vrt $OUTDIR/$DIR/tiles/${prefix}x*_y*_${postfix}km${km}.tif

gdal_translate -ot $type   -projwin -180  84 180 -56 -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${DIR}_km${km}.vrt       $RAM/geomorphon_${DIR}_km${km}.tif  

pksetmask  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND  -msknodata 255 -nodata  $nodata -i  $RAM/geomorphon_${DIR}_km${km}.tif    -m  $RAM/geomorphon_${DIR}_km${km}.tif   -o $OUTDIR/$DIR/geomorphon_${DIR}_km${km}.tif  
gdal_edit.py -a_nodata -9999  $OUTDIR/$DIR/geomorphon_${DIR}_km${km}.tif  
rm  $RAM/${DIR}_km${km}.vrt       $RAM/geomorphon_${DIR}_km${km}.tif  

' _ 
fi 


if [ $DIR = percent  ] ; then

echo 1 5 10 50 100   | xargs -n 1 -P 8 bash -c $'

for class in $(seq 1 10) ; do 

km=$1

if [ $DIR = percent ]  ; then type=UInt16 ;   prefix="" ; postfix="class${class}_" ; nodata=10000 ; fi  

gdalbuildvrt -overwrite   -o  $RAM/${DIR}_km${km}.vrt $OUTDIR/$DIR/tiles/${prefix}x*_y*_${postfix}km${km}.tif

gdal_translate -ot $type   -projwin -180  84 180 -56 -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${DIR}_km${km}.vrt       $RAM/geomorphon_${DIR}_km${km}.tif  

if [ $class -eq 1   ] ; then 
pksetmask  -msknodata 0 -nodata  $nodata -i  $RAM/geomorphon_${DIR}_km${km}.tif    -m  $RAM/geomorphon_${DIR}_km${km}.tif   -o $OUTDIR/$DIR/geomorphon_class${class}_km${km}.tif  
else
pksetmask  -msknodata 255 -nodata  $nodata -i  $RAM/geomorphon_${DIR}_km${km}.tif    -m  $RAM/geomorphon_${DIR}_km${km}.tif   -o $OUTDIR/$DIR/geomorphon_class${class}_km${km}.tif  
fi


gdal_edit.py -a_nodata -9999  $OUTDIR/$DIR/geomorphon_class${class}_km${km}.tif  
rm  $RAM/${DIR}_km${km}.vrt       $RAM/geomorphon_${DIR}_km${km}.tif  

done 

' _ 

fi 

exit 

