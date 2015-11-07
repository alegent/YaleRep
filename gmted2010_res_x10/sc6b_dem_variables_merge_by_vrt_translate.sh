# calculate different variables for the dem 

#  rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/* 

# tri tpi roughness aspect
# for dir1  in slope  aspect tri tpi roughness vrm ; do for dir2 in max mean median min stdev; do  qsub  -v DIR=$dir1/$dir2,mm=md /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate.sh ; done ; done 
# for dir1 in altitude ; do for dir2 in max_of_mx  mean_of_mn median_of_md min_of_mi stdev_of_md stdev_of_mn; do  qsub  -v DIR=$dir1/$dir2,mm=md  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate.sh  ; done ; done 

# for dir1 in altitude ; do for dir2 in max_of_mx  mean_of_mn median_of_md min_of_mi stdev_of_md stdev_of_mn; do  bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate.sh    $dir1/$dir2 md  ; done ; done 
# for dir1 in slope  aspect tri tpi roughness vrm ; do for dir2 in max  mean median min stdev ; do  bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate.sh   $dir1/$dir2 md ; done ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout 
#PBS -e /scratch/fas/sbsc/ga254/stderr


export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010

# export DIR=$1
# export mm=$2

export DIR=$DIR
export mm=md

export dir1=$(echo ${DIR%/*})   # cancel the part after  /
export dir2=$(echo ${DIR#*/})   # cancel the part before /


if [ $dir1 = altitude ]  ; then

echo processing merging tiles for the different aspect variables in $dir1   

rm -f   $OUTDIR/$DIR/$dir1"_"$dir2".vrt" 
gdalbuildvrt -te -180 -56  +180 +84  -srcnodata "-9999" -vrtnodata -9999  $OUTDIR/$DIR/$dir1"_"$dir2".vrt"  $OUTDIR/$DIR/tiles/?_?.tif
gdal_translate -projwin -180 +84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32   $OUTDIR/$DIR/$dir1"_"$dir2".vrt" $OUTDIR/$DIR/${dir1}_${dir2}_tmp.tif
pkreclass -of GTiff  -c -32768 -r  -9999  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32 -i  $OUTDIR/$DIR/$dir1"_"$dir2"_tmp.tif" -o $OUTDIR/$DIR/${dir1}_${dir2}.tif
gdal_edit.py -a_nodata -9999  $OUTDIR/$DIR/${dir1}_${dir2}.tif
rm -f $OUTDIR/$DIR/${dir1}_${dir2}_tmp.tif

fi 

if [ $dir1 = slope ] || [ $dir1 = tri ] ||  [ $dir1 = tpi ] ||  [ $dir1 = roughness  ] ||  [ $dir1 = vrm ]   ;  then

echo processing merging tiles for the different aspect variables in $dir1   

rm -f  $OUTDIR/$DIR/$dir1"_"$dir2".vrt" 
gdalbuildvrt -te -180 -56  +180 +84  -srcnodata -9999 -vrtnodata -9999    $OUTDIR/$DIR/$dir1"_"$dir2".vrt"     $OUTDIR/$DIR/tiles/?_?_${mm}.tif 
gdal_translate -projwin -180 +84  +180 -56  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32   $OUTDIR/$DIR/$dir1"_"$dir2".vrt" $OUTDIR/$DIR/${dir1}_${dir2}_${mm}.tif

fi 


if [ $dir1 = aspect ]; then 

echo processing merging tiles for the different aspect variables in $dir1   

echo  "sin cos Ew Nw" | xargs -n 1 -P 4 bash -c $' 
aspect_var=$1
rm -f  $OUTDIR/$DIR/$dir1"_"$dir2".vrt" 
gdalbuildvrt -te -180 -56  +180 +84   -srcnodata -9999 -vrtnodata -9999    $OUTDIR/$DIR/$dir1"_"$dir2".vrt"     $OUTDIR/$DIR/tiles/?_?_${mm}_${aspect_var}.tif 
gdal_translate -projwin -180 +84  +180 -56  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $OUTDIR/$DIR/$dir1"_"$dir2".vrt" $OUTDIR/$DIR/${dir1}_${dir2}_${mm}_${aspect_var}.tif

' _ 

fi 


exit 

# validation 

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
ls  tpi/*/tpi*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _
ls  tri/*/tri*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _
ls  slope/*/slope*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _
ls  roughness/*/roughness*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _

ls  aspect/*/aspect*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _

ls altitude/{max_of_mx,mean_of_mn,median_of_md,min_of_mi,stdev_of_md,stdev_of_mn}/altitude*.tif | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _

