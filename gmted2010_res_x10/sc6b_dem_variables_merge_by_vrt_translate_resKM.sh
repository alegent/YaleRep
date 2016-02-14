# calculate different variables for the dem 

#  rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/* 

# tri tpi roughness aspect

# for dir1  in slope  aspect tri tpi roughness vrm ; do for dir2 in max mean median min stdev; do  qsub  -v DIR=$dir1/$dir2,mm=md /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate_resKM.sh ; done ; done 

# for dir1 in altitude ; do for dir2 in max_of_mx  mean_of_mn median_of_md min_of_mi stdev_of_md stdev_of_mn stdev_pulled   ; do  qsub  -v DIR=$dir1/$dir2,mm=md  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate_resKM.sh  ; done ; done 

# for dir1 in altitude ; do for dir2 in max_of_mx  mean_of_mn median_of_md min_of_mi stdev_of_md stdev_of_mn; do  bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate_resKM.sh    $dir1/$dir2 md  ; done ; done 
# for dir1 in slope  aspect tri tpi roughness vrm ; do for dir2 in max  mean median min stdev ; do  bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate_resKM.sh   $dir1/$dir2 md ; done ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
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


echo 1 5 10 50 100   | xargs -n 1 -P 8 bash -c $'
km=$1
if [ $dir1 = altitude ] && [ $dir2 != stdev_pulled  ] ; then

echo processing merging tiles for the different aspect variables in $dir1   

rm -f   $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt 
gdalbuildvrt -te -180 -56  +180 +84  -srcnodata "-9999" -vrtnodata -9999   $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt   $OUTDIR/$DIR/tiles/x*_y*_km$km.tif
gdal_translate -projwin -180 +84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32   $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt  $OUTDIR/$DIR/${dir1}_${dir2}_tmp$km.tif
pkreclass -of GTiff  -c -32768 -r  -9999  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32 -i  $OUTDIR/$DIR/${dir1}_${dir2}_tmp$km.tif -o $OUTDIR/$DIR/${dir1}_${dir2}_km$km.tif
gdal_edit.py -a_nodata -9999  $OUTDIR/$DIR/${dir1}_${dir2}_km$km.tif
rm -f  $OUTDIR/$DIR/${dir1}_${dir2}_tmp$km.tif $OUTDIR/$DIR/${dir1}_${dir2}.vrt   $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt

fi

# merge the pulled standard deviation
 
if [ $dir1 = altitude ] && [ $dir2 = stdev_pulled  ] ; then

export res=$( expr $km \\* 4)
export P=$( expr $res \\* $res)  # dividend for the pulled SD
export p=$( expr $P - 1 )       # dividend for the pulled SD 

rm -f $OUTDIR$DIR/tiles/${dir1}_p${P}sd_km${km}.vrt 
gdalbuildvrt -te -180 -56  +180 +84  -srcnodata "-9999" -vrtnodata -9999   $OUTDIR/$DIR/tiles/${dir1}_p${P}sd_km${km}.vrt      $OUTDIR/$DIR/tiles/x*_y*_p${P}sd_km${km}.tif
gdal_translate -projwin -180 +84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $OUTDIR/$DIR/tiles/${dir1}_p${P}sd_km${km}.vrt  $OUTDIR/$DIR/${dir1}_p${P}sd_km${km}.tif
rm -f $OUTDIR/$DIR/tiles/${dir1}_p${P}sd_km${km}.vrt 

rm -f $OUTDIR/$DIR/tiles/${dir1}_p${p}sd_km${km}.vrt 
gdalbuildvrt -te -180 -56  +180 +84  -srcnodata "-9999" -vrtnodata -9999   $OUTDIR/$DIR/tiles/${dir1}_p${p}sd_km${km}.vrt      $OUTDIR/$DIR/tiles/x*_y*_p${p}sd_km${km}.tif
gdal_translate -projwin -180 +84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $OUTDIR/$DIR/tiles/${dir1}_p${p}sd_km${km}.vrt  $OUTDIR/$DIR/${dir1}_p${p}sd_km${km}.tif
rm -f $OUTDIR/$DIR/tiles/${dir1}_p${p}sd_km${km}.vrt 

rm -f $OUTDIR/$DIR/tiles/${dir1}_sd_km${km}.vrt 
gdalbuildvrt -te -180 -56  +180 +84  -srcnodata "-9999" -vrtnodata -9999   $OUTDIR/$DIR/tiles/${dir1}_sd_km${km}.vrt           $OUTDIR/$DIR/tiles/x*_y*_sd_km${km}.tif
gdal_translate -projwin -180 +84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $OUTDIR/$DIR/tiles/${dir1}_sd_km${km}.vrt  $OUTDIR/$DIR/${dir1}_sd_km${km}.tif
rm -f $OUTDIR/$DIR/tiles/${dir1}_sd_km${km}.vrt
fi
 

if [ $dir1 = slope ] || [ $dir1 = tri ] ||  [ $dir1 = tpi ] ||  [ $dir1 = roughness  ] ||  [ $dir1 = vrm ]   ;  then

echo processing merging tiles for the different aspect variables in $dir1   

rm -f   $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt 
gdalbuildvrt -te -180 -56  +180 +84  -srcnodata -9999 -vrtnodata -9999      $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt    $OUTDIR/$DIR/tiles/x*_y*_km$km.tif 
gdal_translate -projwin -180 +84  +180 -56  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt  $OUTDIR/$DIR/${dir1}_${dir2}_km$km.tif
rm -f  $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt 
fi 


if [ $dir1 = aspect ]; then 

echo processing merging tiles for the different aspect variables in $dir1   

for aspect_var in sin cos Ew Nw ; do  

rm -f  $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt  
gdalbuildvrt -te -180 -56  +180 +84   -srcnodata -9999 -vrtnodata -9999    $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt      $OUTDIR/$DIR/tiles/${aspect_var}_x*_y*_km$km.tif 
gdal_translate -projwin -180 +84  +180 -56  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32   $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt    $OUTDIR/$DIR/${dir1}_${dir2}_${aspect_var}_km$km.tif

done 


fi 

' _ 




exit 

# validation 

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
ls  tpi/*/tpi*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _
ls  tri/*/tri*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _
ls  slope/*/slope*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _
ls  roughness/*/roughness*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _

ls  aspect/*/aspect*.tif  | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _

ls altitude/{max_of_mx,mean_of_mn,median_of_md,min_of_mi,stdev_of_md,stdev_of_mn}/altitude*.tif | xargs -n 1 -P 6 bash -c $' echo $1 $(gdalinfo -mm $1 | grep Compu )  ' _

