
# qsub /home/fas/sbsc/ga254/scripts/GEOING/sc10_humanHazard.sh  

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces
export RAM=/dev/shm

# rm -f $DIR/GEOING/reg_CRU/1km/*    

# ls  $DIR/GEOING/reg_CRU/cru_ts3.23.????.????.tmp.dat_1.0deg.reg.tif   | xargs -n 1 -P 8 bash -c $'
# file=$1
# filename=$(basename $file .tif )
# gdalwarp -co COMPRESS=DEFLATE -co ZLEVEL=9  -r near  -srcnodata -9999 -dstnodata -9999  -tr 0.0083333333333333333 0.0083333333333333333 $file  $DIR/GEOING/reg_CRU/1km/${filename}_1km.tif  
# ' _ 

# rm -f  $DIR/GEOING/reg_CRU/shp/*  
# rm -f $DIR/GEOING/reg_CRU/txt/* 

# echo 5.5 6.5 7.5 8.5 9.5 | xargs -n 1 -P 8 bash -c $'
# MIN=$1

# for file in $DIR/GEOING/reg_CRU/1km/cru_ts3.23.????.????.tmp.dat_1.0deg.reg_1km.tif  ; do 
# filename=$(basename $file .tif )

# pkextract -r mean -f "ESRI Shapefile" -srcnodata -9999 -polygon  --bname DegMean -s  $DIR/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_shp/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.shp  -i   $DIR/GEOING/reg_CRU/1km/${filename}.tif  -o  $DIR/GEOING/reg_CRU/shp/${filename}_${MIN}Mean.shp  

# pkextract -r stdev  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname DegStev   -s  $DIR/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_shp/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.shp  -i   $DIR/GEOING/reg_CRU/1km/${filename}.tif     -o  $DIR/GEOING/reg_CRU/shp/${filename}_${MIN}Stdev.shp

# pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  \
#             -m $DIR/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif  -msknodata 0 -nodata 0 \
#             -m $file   -msknodata -9999  -nodata 0 \
#             -i $DIR/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif  \
#             -o $RAM/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif    

# oft-stat -i $file  -o $DIR/GEOING/reg_CRU/txt/${filename}_${MIN}mskbin_mean.txt -um  $RAM/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif  -mm 

# rm -f  $RAM/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif    

# done 

# ' _

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING

rm -f  $DIR/reg_models/ensamble/tas/tif_1km/*

# ensamble de regression and resampling to 1 km 
echo 2020-2029 2021-2030 2020-2089 2021-2090 2030-2069 2031-2070 2070-2079 2071-2080 2080-2089 2081-2090 2020-2079 2021-2080  | xargs -n 2 -P 8  bash -c $'
 
year1=${1} 
year2=${2} 

for MOD in G4 rcp45 ; do 

output=$(basename   $(ls $DIR/reg_models/*/tas/tas_oned_Amon_*_${MOD}_ensamble_*-*_mean_${year1}_reg_${year1}.tif 2> /dev/null  | head -1  )  2> /dev/null  )
echo output  $output

if [[ -n $output  ]] ; then   

ls $DIR/reg_models/*/tas/tas_oned_Amon_*_${MOD}_ensamble_*-*_mean_${year1}_reg_${year1}.tif $DIR/reg_models/*/tas/tas_oned_Amon_*_${MOD}_ensamble_*-*_mean_${year2}_reg_${year2}.tif  >   $DIR/reg_models/ensamble/tas/txt/${MOD}_ensamble_mean_reg_${year1}.txt

~/bin/pkcomposite    -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9   -cr mean   $( ls $DIR/reg_models/*/tas/tas_oned_Amon_*_${MOD}_ensamble_*-*_mean_${year1}_reg_${year1}.tif $DIR/reg_models/*/tas/tas_oned_Amon_*_${MOD}_ensamble_*-*_mean_${year2}_reg_${year2}.tif | xargs -n 1  echo  -i) -o  $DIR/reg_models/ensamble/tas/tif/${MOD}_ensamble_mean_reg_${year1}.tif  
gdal_edit.py -a_nodata -9999  $DIR/reg_models/ensamble/tas/tif/${MOD}_ensamble_mean_reg_${year1}.tif 

gdalwarp -co COMPRESS=DEFLATE    -co ZLEVEL=9 -s_srs   EPSG:4326  -t_srs EPSG:4326  -r near  -srcnodata -9999 -dstnodata -9999  -tr 0.0083333333333333333 0.0083333333333333333 $DIR/reg_models/ensamble/tas/tif/${MOD}_ensamble_mean_reg_${year1}.tif     $DIR/reg_models/ensamble/tas/tif_1km/${MOD}_ensamble_mean_reg_${year1}.tif   -overwrite

fi 

done 

' _ 

rm -f $DIR/reg_models/ensamble/shp/*.*  $DIR/reg_models/ensamble/txt/*.*


echo 5.5 6.5 7.5 8.5 9.5 | xargs -n 1 -P 8 bash -c $'

MIN=$1

for file in $DIR/reg_models/ensamble/tas/tif_1km/*_ensamble_mean_reg_????-????.tif  ; do 
filename=$(basename $file .tif )

pkextract -r mean -f "ESRI Shapefile" -srcnodata -9999 -polygon  --bname DegMean -s  $DIR/../GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_shp/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.shp  -i    $DIR/reg_models/ensamble/tas/tif_1km/${filename}.tif  -o   $DIR/reg_models/ensamble/tas/shp/${filename}_${MIN}Mean.shp  

pkextract -r stdev  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname DegStev   -s  $DIR/../GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_shp/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.shp  -i    $DIR/reg_models/ensamble/tas/tif_1km/${filename}.tif  -o   $DIR/reg_models/ensamble/tas/shp/${filename}_${MIN}Stdev.shp  

oft-stat -i  $DIR/reg_models/ensamble/tas/tif_1km/${filename}.tif  -o   $DIR/reg_models/ensamble/tas/txt/${filename}_${MIN}_meanALL.txt -um $DIR/../GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif  -mm
 

# rm -f $DIR/reg_models/ensamble/tas/tif_1km/${filename}_${MIN}mskbin.tif 

done 

' _



exit 
