# calculate different variables for the dem 

# for DIR  in asm ent ; do qsub -v DIR=$DIR /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_geomorf_asm_ent_merge.sh ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=2:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

echo test 
exit 

export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon
export RAM=/dev/shm
rm -f /dev/shm/*

export DIR=$DIR

if [ $DIR = asm ]  ; then type=Float32 ; prefix=ASM   ; fi  
if [ $DIR = ent ]  ; then type=Float32 ; prefix=ENT   ; fi  

echo left tiles center # dimension 4324, 3364
ls $OUTDIR/$DIR/tiles/${prefix}_0_[1-3]_s3.tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ; filename=`basename $file`  ;  xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3360 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   -srcwin  $xoff $yoff $xsize $ysize   $file $RAM/clip$filename
' _ 

echo right tiles center 
ls $OUTDIR/$DIR/tiles/${prefix}_9_[1-3]_s3.tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4322 ; ysize=3360 ; 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -srcwin  $xoff $yoff $xsize $ysize   $file $RAM/clip$filename
' _ 

echo top tiles center  
ls $OUTDIR/$DIR/tiles/${prefix}_[1-8]_0_s3.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ;  xoff=2 ; yoff=0 ;  xsize=4320 ; ysize=3362 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -srcwin  $xoff $yoff $xsize $ysize   $file $RAM/clip$filename
' _ 

echo botton  tiles center  
ls  $OUTDIR/$DIR/tiles/${prefix}_[1-8]_4_s3.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4320 ; ysize=3362 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -srcwin  $xoff $yoff $xsize $ysize   $file  $RAM/clip$filename
' _ 

echo top left 
file=$OUTDIR/$DIR/tiles/${prefix}_0_0_s3.tif ; filename=`basename $file` ; xoff=0 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -srcwin  $xoff $yoff $xsize $ysize   $file  $RAM/clip$filename

echo top right 
file=$OUTDIR/$DIR/tiles/${prefix}_9_0_s3.tif ; filename=`basename $file` ; xoff=2 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -srcwin  $xoff $yoff $xsize $ysize   $file  $RAM/clip$filename

echo botton left 
file=$OUTDIR/$DIR/tiles/${prefix}_0_4_s3.tif ; filename=`basename $file` ; xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -srcwin  $xoff $yoff $xsize $ysize   $file  $RAM/clip$filename

echo botton  right 
file=$OUTDIR/$DIR/tiles/${prefix}_9_4_s3.tif ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -srcwin  $xoff $yoff $xsize $ysize $file  $RAM/clip$filename

echo central immage 
ls  $OUTDIR/$DIR/tiles/${prefix}_[1-8]_[1-3]_s3.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4320 ; ysize=3360 
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -srcwin  $xoff $yoff $xsize $ysize $file  $RAM/clip$filename
' _ 

rm  $RAM/$DIR.vrt
gdalbuildvrt -overwrite  -o  $RAM/$DIR.vrt   $RAM/clip*.tif
gdal_translate   -projwin -180  84 180 -56 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/$DIR.vrt   $OUTDIR/$DIR/geomorphon_${DIR}_be.tif
gdal_edit.py -a_ullr  -180 +84  +180 -56 $OUTDIR/$DIR/geomorphon_${DIR}_be.tif
