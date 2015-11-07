# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# qsub  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5c_dem_geomorfology_notiles.sh


#PBS -S /bin/bash 
#PBS -q fas_long
#PBS -l walltime=3:00:00:00
#PBS -l mem=34gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
export RAM=/dev/shm

export OUTGEO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles

rm -fr /dev/shm/*

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh  $OUTGEO  loc_md75_grd_tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/md75_grd_tif.tif

echo calcuate geoforms 

# /home/fas/sbsc/ga254/.grass7/addons/bin/r.geomorphon   dem=md75_grd_tif  forms=forms_md75_grd_tif  search=3 skip=0 flat=1 dist=0 step=0 start=0 --overwrite

# r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Byte     input=forms_md75_grd_tif         output=$OUTGEO/forms/md75_grd_tif_tmp.tif 
# pkcreatect  -min 0 -max 10   > $RAM/color.txt
# pkcreatect -co  BIGTIFF=YES  -co COMPRESS=LZW -co ZLEVEL=9   -ct   $RAM/color.txt   -i $OUTGEO/forms/md75_grd_tif_tmp.tif   -o  $OUTGEO/forms/md75_grd_tif.tif 
# rm  $OUTGEO/forms/md75_grd_tif_tmp.tif 

# correct 1 pixel border arround    172800 67200

# gdal_translate -srcwin  0 1     172800 1   $OUTGEO/forms/md75_grd_tif.tif   $OUTGEO/forms/md75_grd_tif_up.tif       ;  gdal_edit.py -a_ullr  -180 84  180 $(echo  "84 - 0.002083333333333333"  | bc)     $OUTGEO/forms/md75_grd_tif_up.tif 
# gdal_translate -srcwin  0 67198 172800 1   $OUTGEO/forms/md75_grd_tif.tif   $OUTGEO/forms/md75_grd_tif_down.tif     ;  gdal_edit.py -a_ullr  -180 $(echo  "-56 + 0.002083333333333333"  | bc)  180  -56    $OUTGEO/forms/md75_grd_tif_down.tif

# gdal_translate -srcwin  1 0    1 67200   $OUTGEO/forms/md75_grd_tif.tif   $OUTGEO/forms/md75_grd_tif_left.tif    ; gdal_edit.py -a_ullr  -180 84  $(echo  "-180 + 0.002083333333333333"  | bc)  -56   $OUTGEO/forms/md75_grd_tif_left.tif
# gdal_translate -srcwin  172798 0 1 67200   $OUTGEO/forms/md75_grd_tif.tif   $OUTGEO/forms/md75_grd_tif_right.tif ; gdal_edit.py -a_ullr  $(echo  "180 - 0.002083333333333333"  | bc)  84 180 -56      $OUTGEO/forms/md75_grd_tif_right.tif

# gdalbuildvrt -vrtnodata 255 -srcnodata 255  -overwrite md75_grd_tif.vrt   $OUTGEO/forms/md75_grd_tif.tif   $OUTGEO/forms/md75_grd_tif_up.tif    $OUTGEO/forms/md75_grd_tif_down.tif   $OUTGEO/forms/md75_grd_tif_left.tif   $OUTGEO/forms/md75_grd_tif_right.tif 
# gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 $OUTGEO/forms/md75_grd_tif.vrt $OUTGEO/forms/md75_grd_border.tif 

# # to eliminate 4 pixel in the corners 
# pksetmask  -co COMPRESS=LZW -co ZLEVEL=9   -i  $OUTGEO/forms/md75_grd_border.tif  -m   $OUTGEO/forms/md75_grd_border.tif  -msknodata 255  -nodata 1 -o  $OUTGEO/forms/md75_grd_border_full.tif
# gdal_edit.py -a_nodata 255    $OUTGEO/forms/md75_grd_border_full.tif 

echo calcuate curvature

r.slope.aspect elevation=md75_grd_tif precision=FCELL  pcurv=pcurv_md75_grd_tif tcurv=tcurv_md75_grd_tif dx=dx_md75_grd_tif  dy=dy_md75_grd_tif  dxx=dxx_md75_grd_tif dyy=dyy_md75_grd_tif  --o

echo  pcurv tcurv dx dxx dy dyy | xargs -n 1 -P 8 bash -c $'
type=$1
r.out.gdal nodata=-9999   -c     createopt="COMPRESS=LZW,ZLEVEL=9,BIGTIFF=YES" format=GTiff  type=Float32  input=${type}_md75_grd_tif    output=$OUTGEO/${type}/md75_grd_tif.tif --overwrite 
' _ 

rm -fr /dev/shm/*

exit 



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


