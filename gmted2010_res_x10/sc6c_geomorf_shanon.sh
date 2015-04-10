# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# for file in $(ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/?_?.tif) ; do qsub  -v file=$file  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_shanon.sh   ; done 
# for file in `ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/6_1.tif` ; do bash /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_shanon.sh   $file   ; done 
# file=$1   

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:02:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export file=${file}

export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/
export RAM=/dev/shm


export IN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms
export OUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon




export filename=`basename $file .tif`


rm -fr /dev/shm/*



seq 1 10 | xargs -n 1 -P 10 bash -c $' 

class=$1

# use the id to count the number of pixel in 4 x 4 for each class 

pkfilter  -co COMPRESS=LZW  -co ZLEVEL=9 -ot Float32  -nodata 0  -dx 4 -dy 4  -class  $class  -f density  -d 4    -i  $IN/${filename}_s3.tif    -o $OUT/shannon/tiles/${filename}_class${class}_s3_count.tif

pksetmask  -msknodata 0  -nodata 255  -m $OUT/shannon/tiles/${filename}_class${class}_s3_count.tif  -i  $OUT/shannon/tiles/${filename}_class${class}_s3_count.tif  -o  $OUT/shannon/tiles/${filename}_class${class}_s3_count255.tif

gdal_calc.py  --co=COMPRESS=LZW --co=ZLEVEL=9 --NoDataValue=0     --type=Float32  --overwrite   -A  $OUT/shannon/tiles/${filename}_class${class}_s3_count.tif  -B  $OUT/shannon/tiles/${filename}_class${class}_s3_count255.tif  --calc="( (log ( B  / 100 )) * ( A / 100 )  )"  --outfile $OUT/shannon/tiles/${filename}_class${class}_s3_countH.tif

rm $OUT/shannon/tiles/${filename}_class${class}_s3_count255.tif $OUT/shannon/tiles/${filename}_class${class}_s3_count.tif

' _ 

rm -f  $OUT/shannon/tiles/${filename}_class${class}_s3_shannon.vrt
gdalbuildvrt  -separate    -overwrite    $OUT/shannon/tiles/${filename}_class${class}_s3_shannon.vrt  $OUT/shannon/tiles/${filename}_class*_s3_countH.tif 
# controllato il risultato manualmente 
oft-calc -inv  -ot  Float32  $OUT/shannon/tiles/${filename}_class${class}_s3_shannon.vrt    $OUT/shannon/tiles/${filename}_class${class}_s3_shannon.tif <<EOF
1
#1 #2 + #3 + #4 + #5 + #6 + #7 + #8 + #9 + #10 + -1 *
EOF

# Evenness = shannon / log 16  

rm  $OUT/shannon/tiles/${filename}_class${class}_s3_shannon.vrt   $OUT/shannon/tiles/${filename}_class*_s3_countH.tif 

rm -fr /dev/shm/*

