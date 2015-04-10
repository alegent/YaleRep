# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# for file in $(ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/?_?.tif) ; do qsub  -v file=$file  scripts/gmted2010_res_x10/sc6c_geomorfology_aggregation.sh ; done 
# for file in `ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/6_1.tif` ; do bash scripts/gmted2010_res_x10/sc6c_geomorfology_aggregation.sh   $file   ; done 
# file=$1   

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:02:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export file=$file

export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
export RAM=/dev/shm

export IN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms
export OUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon

export filename=`basename $file .tif`

rm -fr /dev/shm/*

echo majority 

     pkfilter  -co COMPRESS=LZW  -co ZLEVEL=9 -ot Byte  -nodata 255  -dx 4 -dy 4  -f mode  -d 4 -i $IN/${filename}_s3.tif   -o $OUT/majority/tiles/${filename}_s3.tif
     pkfilter  -co COMPRESS=LZW  -co ZLEVEL=9 -ot Byte  -nodata 255  -dx 4 -dy 4  -f mode  -d 4 -i $IN/${filename}_s5.tif   -o $OUT/majority/tiles/${filename}_s5.tif

echo countid 
     pkfilter  -co COMPRESS=LZW  -co ZLEVEL=9 -ot Byte  -nodata 255  -dx 4 -dy 4  -f countid  -d 4 -i $IN/${filename}_s3.tif   -o $OUT/count/tiles/${filename}_s3.tif
     pkfilter  -co COMPRESS=LZW  -co ZLEVEL=9 -ot Byte  -nodata 255  -dx 4 -dy 4  -f countid  -d 4 -i $IN/${filename}_s5.tif   -o $OUT/count/tiles/${filename}_s5.tif

seq 1 10 | xargs -n 1 -P 8 bash -c $' 

class=$1
pkfilter    -co COMPRESS=LZW   -co ZLEVEL=9 -ot Byte  -nodata 255   -dx 4 -dy 4   -f density  -class $class   -d 4 -i   $IN/${filename}_s3.tif   -o $OUT/percent/tiles/${filename}_class${class}_s3.tif
pkfilter    -co COMPRESS=LZW   -co ZLEVEL=9 -ot Byte  -nodata 255   -dx 4 -dy 4   -f density  -class $class   -d 4 -i   $IN/${filename}_s5.tif   -o $OUT/percent/tiles/${filename}_class${class}_s3.tif

' _ 


exit 

