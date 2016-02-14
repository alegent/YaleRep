# calculate different variables for the dem 

#  rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/* 


# for dir1  in altitude slope  aspect tri tpi roughness vrm ; do for dir2 in max mean median min stdev; do  qsub  -v dir1=$dir1,dir2=$dir2 /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc4a_dem_variables_merge_by_vrt_translate_resKM.sh ; done ; done 
# for dir1  in altitude slope  aspect tri tpi roughness vrm ; do for dir2 in max mean median min stdev; do  bash /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc4a_dem_variables_merge_by_vrt_translate_resKM.sh $dir1 $dir2 ; done ; done 
# bash /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc4a_dem_variables_merge_by_vrt_translate_resKM.sh  altitude max 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout 
#PBS -e /scratch/fas/sbsc/ga254/stderr


export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM

export dir1=$dir1 
export dir2=$dir2

export RAM=/dev/shm

echo 1 5 10 50 100   | xargs -n 1 -P 8 bash -c $'
km=$1

if [ $dir1 = altitude  ] ||  [ $dir1 = slope ] || [ $dir1 = tri ] ||  [ $dir1 = tpi ] ||  [ $dir1 = roughness  ] ||  [ $dir1 = vrm ]   ;  then

echo processing merging tiles for the different aspect variables in $dir1 $dir2 $km   

rm -f   $OUTDIR/${dir1}/${dir2}/km$km.vrt 
gdalbuildvrt -te -180 -60  +180 +60  -srcnodata -9999 -vrtnodata -9999      $OUTDIR/${dir1}/${dir2}/km$km.vrt    $OUTDIR/$dir1/$dir2/tiles/tiles_*_*_km$km.tif 
gdal_translate -a_nodata  "none"  -projwin -180 +60  +180 -60   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $OUTDIR/${dir1}/${dir2}/km$km.vrt  $RAM/${dir1}_${dir2}_km$km.tif

# reclass the value not cover by tiles 

if [ $dir1 = altitude  ] ; then rec=0 ; fi 
if [ $dir1 = slope ]     ; then rec=0 ; fi 
if [ $dir1 = tri ]       ; then rec=0 ; fi 
if [ $dir1 = tpi ]       ; then rec=0 ; fi 
if [ $dir1 = roughness ] ; then rec=0 ; fi 
if [ $dir1 = vrm ]       ; then rec=-0.125 ;  fi 

pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND  -ot Float32  -c -9999  -r $rec  -i  $RAM/${dir1}_${dir2}_km$km.tif -o  $OUTDIR/${dir1}/${dir2}/${dir1}_${dir2}_km$km.tif

rm -f  $OUTDIR/${dir1}/${dir2}/km$km.vrt  $RAM/${dir1}_${dir2}_km$km.tif 
fi 

if [ $dir1 = aspect ]; then 

for aspect_var in sin cos Ew Nw ; do  
echo processing merging tiles for the different aspect variables in $dir1 $dir2 $km $aspect_var
rm -f  $OUTDIR/$DIR/${dir1}_${dir2}_km$km.vrt  

gdalbuildvrt -te -180 -60  +180 +60  -srcnodata -9999 -vrtnodata -9999      $OUTDIR/${dir1}/${dir2}/km$km.vrt    $OUTDIR/$dir1/$dir2/tiles/tiles_*_*_${aspect_var}_km$km.tif 
gdal_translate -projwin -180 +60  +180 -60   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $OUTDIR/${dir1}/${dir2}/km$km.vrt  $RAM/${dir1}_${dir2}_km$km.tif
pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND  -ot Float32  -c -9999  -r 0 -i  $RAM/${dir1}_${dir2}_km$km.tif -o  $OUTDIR/${dir1}/${dir2}/${dir1}_${dir2}_${aspect_var}_km$km.tif
rm -f  $OUTDIR/${dir1}/${dir2}/km$km.vrt  $RAM/${dir1}_${dir2}_km$km.tif 

done 

fi 

' _ 

