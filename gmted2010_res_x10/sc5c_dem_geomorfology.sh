# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# for file in $(ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/?_?.tif) ; do qsub  -v file=$file  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5c_dem_geomorfology.sh  ; done
# for file in $(ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/?_?.tif) ; do qsub  -v file=$file  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5c_dem_geomorfology.sh  ; done 
# for file in `ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/6_1.tif` ; do bash /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5c_dem_geomorfology.sh  $file   ; done 
# file=$1   

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:08:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export file=$file

export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif
export RAM=/dev/shm

export OUTGEO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles
export OUTPARAM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/param.scale/tiles

export filename=`basename $file .tif`


rm -fr /dev/shm/*

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh   /dev/shm loc_$filename  $file

# /home/fas/sbsc/ga254/.grass7/addons/bin/r.geomorphon   dem=$filename  forms=forms_$filename ternary=ternary_$filename positive=positive_$filename negative=negative_$filename \
              intensity=intensity_$filename exposition=exposition_$filename range=range_$filename variance=variance_$filename \
              elongation=elongation_$filename azimuth=azimuth_$filename extend=extend_$filename width=with_$filename \
              search=3 skip=0 flat=1 dist=0 step=0 start=0 --overwrite

r.slope.aspect elevation=$filename precision=FCELL  pcurvature=pcurv_$filename tcurvature=tcurv_$filename dx=dx_$filename dx=dx_$filename



r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Byte     input=forms_$filename         output=$OUTGEO/forms/${filename}_tmp.tif 
pkcreatect  -min 0 -max 10   > $RAM/color.txt
pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct   $RAM/color.txt   -i $OUTGEO/forms/${filename}_tmp.tif  -o  $OUTGEO/forms/${filename}_bes3.tif  
rm $OUTGEO/forms/${filename}_tmp.tif 

exit 

r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Int16    input=ternary_$filename       output=$OUTGEO/ternary/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Byte     input=positive_$filename      output=$OUTGEO/positive/${filename}_s3.tif  
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Byte     input=negative_$filename      output=$OUTGEO/negative/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Float32  input=intensity_$filename     output=$OUTGEO/intensity/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Int16    input=exposition_$filename    output=$OUTGEO/exposition/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=UInt16   input=range_$filename         output=$OUTGEO/range/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Float32  input=variance_$filename      output=$OUTGEO/variance/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Float32  input=elongation_$filename    output=$OUTGEO/elongation/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Float32  input=azimuth_$filename       output=$OUTGEO/azimuth/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Float32  input=extend_$filename        output=$OUTGEO/extend/${filename}_s3.tif 
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Float32  input=with_$filename          output=$OUTGEO/with/${filename}_s3.tif  

rm -r /dev/shm/*

# crop all the tiles with 4 pixels arround due 
# the border has 1 pix of  255 no data 
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms
# ls  ?_?_s3.tif  |  xargs -n 1 -P 8 bash -c $' gdal_translate  -co COMPRESS=DEFLATE  -co ZLEVEL=9  -co INTERLEAVE=BAND    -srcwin 4 4 17288 13448  $1 crop_$1  ' _



exit

echo profc planc longc crosc minic maxic feature | xargs -n 1 -P 7 bash -c $' 
method=$1
r.param.scale  param=$method  input=$filename output=${method}_$filename 
r.out.gdal -c  createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Int32 input=${method}_$filename  output=$OUTPARAM/${method}/$filename  
ERROR: Lat/Long locations are not supported by this module
' _  



cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms/ 

pkcreatect  -min 1 -max 10   > /dev/shm/color.txt

ls    /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms/*.tif  | xargs -n 1 -P 20 bash -c $' 
filename=$(basename $1 .tif  )
pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct   /dev/shm/color.txt   -i $1   -o  ${filename}_ct.tif  

' _ 


