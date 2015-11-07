# calculate different variables for the dem 

# for DIR  in majority count shannon  percent  ; do  bash  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_geomorfology_shanon_merge.sh $DIR   ; done 
# for DIR  in percent  ; do for CLASS in 1 2 3 4 5 6 7 8 9 10 ; do  bash  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_geomorfology_shanon_merge.sh $DIR $CLASS    ; done ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=2:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon
export RAM=/dev/shm
rm -f /dev/shm/*

export DIR=$1
export CLASS=$2

export dir1=$(echo ${DIR%/*})   # cancel the part after  /

if [ $DIR = majority ]  ; then type=Byte    ; postfix=_s3                 ; fi  
if [ $DIR = count ]     ; then type=Byte    ; postfix=_s3                 ; fi  
if [ $DIR = shannon ]   ; then type=Float32 ; postfix=_class_s3_shannon   ; fi  
if [ $DIR = percent ]   ; then type=Float32 ; postfix=_class$CLASS"_s3"   ; fi  

echo processing merging tiles in $dir1
         
rm -f  $RAM/$DIR.vrt
gdalbuildvrt -overwrite  -o  $RAM/$DIR.vrt   $OUTDIR/$DIR/tiles/*$postfix.tif
gdal_translate -projwin  -180  84 180 -56   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  $RAM/$DIR.vrt  $OUTDIR/$DIR/geomorphon_${DIR}_be.tif
gdal_edit.py -a_ullr  -180 +84  +180 -56 $OUTDIR/$DIR/geomorphon_${DIR}.tif

if [ $DIR = percent ]   ; then mv   $OUTDIR/$DIR/geomorphon_$DIR.tif   $OUTDIR/$DIR/geomorphon_${DIR}_class$CLASS".tif"   ; fi

exit 

# probabilmente il clip non serve piu

echo clipping tiles in $dir1    $OUTDIR/$DIR/tiles/[0-1]_?.tif 

echo left tiles center # dimension 4324, 3364
ls $OUTDIR/$DIR/tiles/0_[1-3]$postfix.tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ; filename=`basename $file`  ;  xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3360 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $RAM/clip$filename
' _ 

echo right tiles center 
ls $OUTDIR/$DIR/tiles/9_[1-3]$postfix.tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4322 ; ysize=3360 ; 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $RAM/clip$filename
' _ 

echo top tiles center  
ls $OUTDIR/$DIR/tiles/[1-8]_0$postfix.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ;  xoff=2 ; yoff=0 ;  xsize=4320 ; ysize=3362 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $RAM/clip$filename
' _ 

echo botton  tiles center  
ls  $OUTDIR/$DIR/tiles/[1-8]_4$postfix.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4320 ; ysize=3362 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file  $RAM/clip$filename
' _ 


echo top left 
file=$OUTDIR/$DIR/tiles/0_0$postfix.tif ; filename=`basename $file` ; xoff=0 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file  $RAM/clip$filename

echo top right 
file=$OUTDIR/$DIR/tiles/9_0$postfix.tif ; filename=`basename $file` ; xoff=2 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file  $RAM/clip$filename

echo botton left 
file=$OUTDIR/$DIR/tiles/0_4$postfix.tif ; filename=`basename $file` ; xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file  $RAM/clip$filename

echo botton  right 
file=$OUTDIR/$DIR/tiles/9_4$postfix.tif ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file  $RAM/clip$filename

echo central immage 
ls  $OUTDIR/$DIR/tiles/[1-8]_[1-3]$postfix.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4320 ; ysize=3360 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file  $RAM/clip$filename

' _ 

rm  $RAM/$DIR.vrt
gdalbuildvrt -overwrite  -o  $RAM/$DIR.vrt   $RAM/clip*.tif
gdal_translate   -projwin     -180  84 180 -56   -co  COMPRESS=LZW  -co ZLEVEL=9   $RAM/$DIR.vrt   $OUTDIR/$DIR/geomorphon_${DIR}_be.tif
gdal_edit.py -a_ullr  -180 +84  +180 -56 $OUTDIR/$DIR/geomorphon_${DIR}_be.tif

if [ $DIR = percent ]   ; then mv   $OUTDIR/$DIR/geomorphon_$DIR.tif   $OUTDIR/$DIR/geomorphon_${DIR}_class$CLASS".tif"   ; fi

