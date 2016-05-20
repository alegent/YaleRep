# qsub /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc30_croptstudyregion_gmted_srtm_simplify.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export SRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/final
export GMTED=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED

# andes borneo 

# 100 km 
# Upper Left  (   5.8333333,  48.1666667) (  5d50' 0.00"E, 48d10' 0.00"N)
# Lower Left  (   5.8333333,  44.8333333) (  5d50' 0.00"E, 44d50' 0.00"N)
# Upper Right (  10.8333333,  48.1666667) ( 10d50' 0.00"E, 48d10' 0.00"N)
# Lower Right (  10.8333333,  44.8333333) ( 10d50' 0.00"E, 44d50' 0.00"N)

# 1km 
# Upper Left  (   6.0000000,  48.0000000) (  6d 0' 0.00"E, 48d 0' 0.00"N)
# Lower Left  (   6.0000000,  45.0000000) (  6d 0' 0.00"E, 45d 0' 0.00"N)
# Upper Right (  11.0000000,  48.0000000) ( 11d 0' 0.00"E, 48d 0' 0.00"N)
# Lower Right (  11.0000000,  45.0000000) ( 11d 0' 0.00"E, 45d 0' 0.00"N)

echo  andes borneo

for AREA in alps  andes borneo   ; do 

export AREA=$AREA

if [  $AREA = "alps"  ] ; then export geo_string="5.83333333333333  48.166666666666666 10.83333333333333333333333 44.833333333333333333333333" ; fi 
if [  $AREA = "andes"  ] ; then export geo_string="-80 -4 -75 -7" ; fi 
if [  $AREA = "borneo"  ] ; then export geo_string="114 6 117 0" ; fi 

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -a_nodata "none" -co COMPRESS=LZW -co ZLEVEL=9 -projwin ${geo_string}  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/md75_grd_tif.vrt  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif

# crop GMTED

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/*/*.tif  | xargs -n 1 -P 8  bash -c $'
file=$1
filename=$(basename $file .tif )
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9    -a_nodata "none" -projwin $geo_string  -co COMPRESS=LZW  -co ZLEVEL=9  $file $OUTDIR/GMTED/$AREA/$filename.tif 
' _ 

# crop srtm 

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/final/*/*.tif  | xargs -n 1 -P 8  bash -c $'
file=$1
filename=$(basename $file .tif )
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -a_nodata "none" -projwin $geo_string  -co COMPRESS=LZW  -co ZLEVEL=9  $file $OUTDIR/SRTM/$AREA/$filename.tif 
' _ 


echo  orignal resolution GMTED  $AREA   orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA  

gdal_translate -co COMPRESS=LZW    -projwin  $geo_string $GMTED/../tiles/md75_grd_tif/md75_grd_tif.vrt    $OUTDIR/GMTED/$AREA/GMTED_250/elevation_250M_GMTED.tif

for dir in   aspect  roughness  slope  tpi  tri vrm  ; do    
     gdal_translate  -projwin  $geo_string  $GMTED/../${dir}/tiles/${dir}_md.vrt    $OUTDIR/GMTED/$AREA/GMTED_250/${dir}_250M_GMTED.tif
done 

for var in cos sin Ew Nw ; do 
 	if [ $var = "cos" ]  ; then var2=aspect-cosine    ; fi 
 	if [ $var = "sin" ]  ; then var2=aspect-sine      ; fi 
 	if [ $var = "Ew" ]   ; then var2=eastness         ; fi 
 	if [ $var = "Nw" ]   ; then var2=northness        ; fi

    gdal_translate -co COMPRESS=LZW    -projwin  $geo_string  $GMTED/../aspect/tiles/${var}_md.vrt    $OUTDIR/GMTED/$AREA/GMTED_250/${var2}_250M_GMTED.tif
done 

gdal_translate  -co COMPRESS=LZW    -projwin  $geo_string   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms/geomorphic250_GMTED2010_md.tif $OUTDIR/GMTED/$AREA/GMTED_250/geomorphic250_GMTED2010_md.tif
gdal_translate  -co COMPRESS=LZW    -projwin  $geo_string   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/shannon/geom_1KMsha_GMTEDmd.tif /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/geom_1KMsha_GMTEDmd_small.tif

echo  original resolution SRTM  $AREA    original resolution SRTM  $AREA    original resolution SRTM  $AREA    original resolution SRTM  $AREA     original resolution SRTM  $AREA    original resolution SRTM  $AREA   

for dir in  altitude  aspect  roughness  slope  tpi  tri  vrm ; do
 
     	if [ $dir = "altitude" ]   ; then dir2=elevation    ; fi 
 	if [ $dir = "roughness" ]  ; then dir2=roughness    ; fi 
 	if [ $dir = "slope" ]      ; then dir2=slope        ; fi 
 	if [ $dir = "tpi" ]        ; then dir2=tpi          ; fi
 	if [ $dir = "tri" ]        ; then dir2=tri          ; fi
 	if [ $dir = "vrm" ]        ; then dir2=vrm          ; fi

    gdalbuildvrt -overwrite  /tmp/$AREA.vrt   $SRTM/../${dir}/tiles/tiles_*_*.tif  
    gdal_translate  -co COMPRESS=LZW    -projwin   $geo_string  /tmp/$AREA.vrt $OUTDIR/SRTM/$AREA/SRTM_90/${dir2}_90M_SRTM.tif 
done 
rm  /tmp/$AREA.vrt


for var in cos sin Ew Nw ; do 
 	if [ $var = "cos" ]  ; then var2=aspect-cosine    ; fi 
 	if [ $var = "sin" ]  ; then var2=aspect-sine      ; fi 
 	if [ $var = "Ew" ]   ; then var2=eastness         ; fi 
 	if [ $var = "Nw" ]   ; then var2=northness        ; fi

     gdalbuildvrt -overwrite   /tmp/$AREA.vrt    $SRTM/../aspect/tiles/tiles_*_*_${var}.tif  
     gdal_translate  -co COMPRESS=LZW   -projwin  $geo_string   /tmp/$AREA.vrt  $OUTDIR/SRTM/$AREA/SRTM_90/${var2}_90M_SRTM.tif 
done 
rm  /tmp/$AREA.vrt 





done 



