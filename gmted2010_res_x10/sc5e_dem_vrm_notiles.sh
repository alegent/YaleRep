# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# qsub  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5e_dem_vrm_notiles.sh


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00
#PBS -l mem=34gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
export RAM=/dev/shm

export OUTGEO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/vrm/tiles 

rm -fr /dev/shm/*

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh  $OUTGEO  loc_md75_grd_tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/md75_grd_tif.tif

echo calcuate vrm

~/.grass7/addons/bin/r.vector.ruggedness.py      elevation=md75_grd_tif   output=md75_grd_tif_vrm 

r.out.gdal -c   createopt="COMPRESS=LZW,ZLEVEL=9,BIGTIFF=YES" format=GTiff  type=Float32    input=md75_grd_tif_vrm         output=$OUTGEO/md75_grd_vrm32.tif 
r.out.gdal -c   createopt="COMPRESS=LZW,ZLEVEL=9,BIGTIFF=YES" format=GTiff  type=Float64    input=md75_grd_tif_vrm         output=$OUTGEO/md75_grd_vrm64.tif 

exit 



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



# correct the data becouse 1 line on top and last line has -nan 

export OUTGEO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles
echo  pcurv tcurv dx dxx dy dyy | xargs -n 1 -P 8 bash -c $' 
type=$1                                                                                                                                                                                                             

gdal_translate    -srcwin 0 0 172800 1       $OUTGEO/${type}/md75_grd_tif.tif /dev/shm/${type}_top.tif
gdal_translate    -srcwin 0 67199 172800 1   $OUTGEO/${type}/md75_grd_tif.tif /dev/shm/${type}_bot.tif

pkgetmask -ot Float32  -min 3 -max 6  -i /dev/shm/${type}_top.tif -o /dev/shm/${type}_top0.tif
pkgetmask -ot Float32  -min 3 -max 6  -i /dev/shm/${type}_bot.tif -o /dev/shm/${type}_bot0.tif

pkcomposite -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND  -co  BIGTIFF=YES  -co  BIGTIFF=YES -i $OUTGEO/${type}/md75_grd_tif.tif -i  /dev/shm/${type}_top0.tif -i /dev/shm/${type}_bot0.tif  -o $OUTGEO/${type}/md75_grd_tif0.tif
rm -f /dev/shm/${type}_top0.tif  /dev/shm/${type}_bot0.tif 

' _


# gdalbuildvrt  -te -180 -56  -179.9  +84   -overwrite  -o  /dev/shm/${type}.vrt        $OUTGEO/${type}/md75_grd_tif.tif  /dev/shm/${type}_top0.tif /dev/shm/${type}_bot0.tif 
# gdal_translate -projwin -180 +84  -179.9   -56   -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND  /dev/shm/${type}.vrt /dev/shm/${type}.tif
# pkcrop -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -co  BIGTIFF=YES -i $OUTGEO/${type}/md75_grd_tif.tif -i  /dev/shm/${type}_top0.tif -i /dev/shm/${type}_bot0.tif  -o $OUTGEO/${type}/md75_grd_tif0.tif




