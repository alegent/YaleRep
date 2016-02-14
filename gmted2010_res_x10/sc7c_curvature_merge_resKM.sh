# calculate different variables for the dem 

#  rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/* 

# tri tpi roughness aspect

# for dir1  in dx dxx dy dyy pcurv tcurv  ; do for dir2 in max mean median min stdev; do  qsub  -v dir1=$dir1,dir2=$dir2   /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_curvature_merge_resKM.sh   ; done ; done 
# for dir1 in  dx dxx dy dyy pcurv tcurv  ; do for dir2 in max  mean median min stdev ; do  bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_curvature_merge_resKM.sh   $dir1 $dir2 ; done ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=2:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout 
#PBS -e /scratch/fas/sbsc/ga254/stderr


export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles

# export dir1=$1
# export dir2=$2

export dir1=$dir1
export dir2=$dir2

export RAM=/dev/shm 

rm -f /dev/shm/*

echo 1 5 10 50 100   | xargs -n 1 -P 8 bash -c $'
km=$1
echo processing merging tiles for the different curvature  variables in $dir1 $dir2 $km

rm -f   $RAM/${dir1}_${dir2}_km$km.vrt 

gdalbuildvrt -te -180 -56  +180 +84  -srcnodata "-9999" -vrtnodata -9999  $RAM/${dir1}_${dir2}_km$km.vrt  $OUTDIR/$dir1/$dir2/tiles/x*_y*_km$km.tif
gdal_translate -projwin -180 +84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32  $RAM/${dir1}_${dir2}_km$km.vrt     $OUTDIR/$dir1/$dir2/${dir1}_${dir2}_km$km.tif
gdal_edit.py -a_nodata -9999    $OUTDIR/$dir1/$dir2/${dir1}_${dir2}_km$km.tif

rm -f   $RAM/${dir1}_${dir2}_km$km.vrt 

' _ 


