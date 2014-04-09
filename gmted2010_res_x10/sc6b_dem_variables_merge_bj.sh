# calculate different variables for the dem 

#  rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/* 

# for dir1  in slope tri tpi roughness aspect ; do for dir2 in max mean median min stdev; do  qsub  -v DIR=$dir1/$dir2,mm=md  /lustre0/scratch/ga254/scripts_bj_bk/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc6b_dem_variables_merge_bj.sh ; done ; done 

# for dir1 in tri  ; do for dir2 in max ; do  bash  /lustre0/scratch/ga254/scripts_bj_bk/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc6b_dem_variables_merge_bj.sh  $dir1/$dir2 md  ; done ; done 

# for dir1  in altitude ; do for dir2 in max_of_mx  mean_of_mn median_of_md min_of_mi stdev_of_md stdev_of_mn; do  qsub  -v DIR=$dir1/$dir2,mm=md  /lustre0/scratch/ga254/scripts_bj_bk/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc6b_dem_variables_merge_bj.sh ; done ; done 

# for dir1  in altitude ; do for dir2 in max_of_mx  mean_of_mn median_of_md min_of_mi stdev_of_md stdev_of_mn; do  bash   /lustre0/scratch/ga254/scripts_bj_bk/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc6b_dem_variables_merge_bj.sh   $dir1/$dir2 md  ; done ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=10gb
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0

time (
export OUTDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010

# export DIR=$1
# export mm=$2

export DIR=$DIR
export mm=md

export dir1=$(echo ${DIR%/*})   # cancel the part after  /
export dir2=$(echo ${DIR#*/})   # cancel the part before /


if [ $dir1 = altitude ]  ; then type=Int16 ; fi 
if [ $dir1 = aspect ]    ; then type=Int16 ; fi  
if [ $dir1 = slope ]     ; then type=Byte  ; fi  
if [ $dir1 = tri ]       ; then type=Int16 ; fi 
if [ $dir1 = tpi ]       ; then type=Int16 ; fi   
if [ $dir1 = roughness ] ; then type=Int16 ; fi 

if [ $dir1 != aspect ]; then 

echo processing merging tiles in $dir1  $dir2  
         
rm -f $OUTDIR/$DIR/$dir1"_"$dir2.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_a".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_b".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_c".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_d".tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_e".tif


if [ $dir1 = altitude ]  ; then

echo clipping tiles in $dir1  $dir2   $OUTDIR/$DIR/tiles/[0-1]_?.tif 

echo left tiles center 
ls $OUTDIR/$DIR/tiles/0_[1-3].tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ; filename=`basename $file`  ;  xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3360 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo right tiles center 
ls $OUTDIR/$DIR/tiles/9_[1-3].tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4322 ; ysize=3360 ; 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo top tiles center  
ls $OUTDIR/$DIR/tiles/[1-8]_0.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ;  xoff=2 ; yoff=0 ;  xsize=4320 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo botton  tiles center  
ls  $OUTDIR/$DIR/tiles/[1-8]_4.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4320 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo top left 
file=$OUTDIR/$DIR/tiles/0_0.tif ; filename=`basename $file` ; xoff=0 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo top right 
file=$OUTDIR/$DIR/tiles/9_0.tif ; filename=`basename $file` ; xoff=2 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo botton left 
file=$OUTDIR/$DIR/tiles/0_4.tif ; filename=`basename $file` ; xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo botton  right 
file=$OUTDIR/$DIR/tiles/9_4.tif ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo central immage 
ls  $OUTDIR/$DIR/tiles/[1-8]_[1-3].tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4320 ; ysize=3360 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

' _ 


    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_a".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[0-1]_?.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_b".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[2-3]_?.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_c".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[4-5]_?.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_d".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[6-7]_?.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_e".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[8-9]_?.tif

else

echo  left tiles center 
ls $OUTDIR/$DIR/tiles/0_[1-3]_${mm}.tif | xargs -n 1  -P 3  bash -c $' 
file=$1  ; filename=`basename $file` ;  xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3360 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo  right tiles center 
ls $OUTDIR/$DIR/tiles/9_[1-3]_${mm}.tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ;filename=`basename $file` ;  xoff=2 ; yoff=2 ;  xsize=4322 ; ysize=3360 ; 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo top tiles center  
ls $OUTDIR/$DIR/tiles/[1-8]_0_${mm}.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ;filename=`basename $file` ; xoff=2 ; yoff=0 ;  xsize=4320 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo  botton  tiles center  
ls  $OUTDIR/$DIR/tiles/[1-8]_4_${mm}.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ;filename=`basename $file` ;  xoff=2 ; yoff=2 ;  xsize=4320 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

echo  top left 
file=$OUTDIR/$DIR/tiles/0_0_${mm}.tif ; filename=`basename $file` ; xoff=0 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo  top right 
file=$OUTDIR/$DIR/tiles/9_0_${mm}.tif ;filename=`basename $file` ; xoff=2 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo  botton left 
file=$OUTDIR/$DIR/tiles/0_4_${mm}.tif ;filename=`basename $file` ; xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo  botton  right 
file=$OUTDIR/$DIR/tiles/9_4_${mm}.tif ;filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

echo central immage 
ls  $OUTDIR/$DIR/tiles/[1-8]_[1-3]_${mm}.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4320 ; ysize=3360 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

' _ 


    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_a".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[0-1]_?_${mm}.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_b".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[2-3]_?_${mm}.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_c".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[4-5]_?_${mm}.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_d".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[6-7]_?_${mm}.tif
    /home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_e".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[8-9]_?_${mm}.tif

fi

rm -f  $OUTDIR/$DIR/$dir1"_"$dir2.tif

/home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/$dir1"_"$dir2"_a".tif  $OUTDIR/$DIR/$dir1"_"$dir2"_b".tif  $OUTDIR/$DIR/$dir1"_"$dir2"_c".tif  $OUTDIR/$DIR/$dir1"_"$dir2"_d".tif   $OUTDIR/$DIR/$dir1"_"$dir2"_e".tif 

rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_a".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_b".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_c".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_d".tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_e".tif

gdal_translate -co COMPRESS=LZW  -co ZLEVEL=9 $OUTDIR/$DIR/$dir1"_"$dir2.tif $OUTDIR/$DIR/${dir1}_${dir2}_${mm}.tif
rm -f  $OUTDIR/$DIR/$dir1"_"$dir2.tif  

else  # just applaied to the aspect variables 

echo processing merging tiles for the different aspect variables in $dir1   

for aspect_var in "_sin_t10k" "_cos_t10k" "_Ew_t10k" "_Nw_t10k" ; do 

# left tiles center 
ls $OUTDIR/$DIR/tiles/0_[1-3]_${mm}$aspect_var.tif | xargs -n 1  -P 3  bash -c $' 
file=$1  ; filename=`basename $file` ;  xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3360 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

# right tiles center 
ls $OUTDIR/$DIR/tiles/9_[1-3]_${mm}$aspect_var.tif | xargs -n 1  -P 3  bash -c $' 
file=$1 ;filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4322 ; ysize=3360 ; 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

# top tiles center  
ls $OUTDIR/$DIR/tiles/[1-8]_0_${mm}$aspect_var.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ;filename=`basename $file` ; xoff=2 ; yoff=0 ;  xsize=4320 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

# botton  tiles center  
ls  $OUTDIR/$DIR/tiles/[1-8]_4_${mm}$aspect_var.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ;filename=`basename $file` ; xoff=2 ; yoff=2 ;  xsize=4320 ; ysize=3362
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename
' _ 

# top left 
file=$OUTDIR/$DIR/tiles/0_0_${mm}$aspect_var.tif ;filename=`basename $file` ; xoff=0 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

# top right 
file=$OUTDIR/$DIR/tiles/9_0_${mm}$aspect_var.tif ;filename=`basename $file` ; xoff=2 ; yoff=0 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

# botton left 
file=$OUTDIR/$DIR/tiles/0_4_${mm}$aspect_var.tif ;filename=`basename $file` ; xoff=0 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

# botton  right 
file=$OUTDIR/$DIR/tiles/9_4_${mm}$aspect_var.tif ;filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4322 ; ysize=3362 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

# central immage 
ls  $OUTDIR/$DIR/tiles/[1-8]_[1-3]_${mm}$aspect_var.tif  | xargs -n 1  -P 8  bash -c $'
file=$1 ; filename=`basename $file` ; xoff=2 ; yoff=2 ; xsize=4320 ; ysize=3360 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $file $OUTDIR/$DIR/tiles/clip$filename

' _ 


rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_a"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_b"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_c"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_d"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_e"$aspect_var.tif

/home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_a"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[0-1]_?_${mm}$aspect_var.tif
/home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_b"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[2-3]_?_${mm}$aspect_var.tif 
/home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_c"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[4-5]_?_${mm}$aspect_var.tif
/home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_d"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[6-7]_?_${mm}$aspect_var.tif
/home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_e"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/clip[8-9]_?_${mm}$aspect_var.tif

rm -f  $OUTDIR/$DIR/$dir1"_"$dir2$aspect_var.tif

/home2/ga254/bin/gdal_merge_bylines.py -o $OUTDIR/$DIR/$dir1"_"$dir2$aspect_var.tif -ot $type -co COMPRESS=LZW   $OUTDIR/$DIR/$dir1"_"$dir2"_a"$aspect_var.tif  $OUTDIR/$DIR/$dir1"_"$dir2"_b"$aspect_var.tif $OUTDIR/$DIR/$dir1"_"$dir2"_c"$aspect_var.tif   $OUTDIR/$DIR/$dir1"_"$dir2"_d"$aspect_var.tif $OUTDIR/$DIR/$dir1"_"$dir2"_e"$aspect_var.tif

gdal_translate -co COMPRESS=LZW  -co ZLEVEL=9  $OUTDIR/$DIR/$dir1"_"$dir2$aspect_var.tif $OUTDIR/$DIR/${dir1}_${dir2}_${mm}_${aspect_var}.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2$aspect_var.tif

rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_a"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_b"$aspect_var.tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_c"$aspect_var.tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_d"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_e"$aspect_var.tif

done

fi 

) 

checkjob -v $PBS_JOBID



