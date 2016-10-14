# for GROUP in AMPHIBIANS MANGROVES  MARINE_MAMMALS  TERRESTRIAL_MAMMALS REPTILES CORALS MARINEFISH  BIRDS ; do  qsub -v GROUP=$GROUP  /lustre/home/client/fas/sbsc/ga254/scripts/HOTSPOT/sc1_rasterize.sh  ; done 

# for GROUP in AMPHIBIANS MANGROVES  MARINE_MAMMALS  TERRESTRIAL_MAMMALS REPTILES CORALS MARINEFISH  BIRDS ; do  bash   /lustre/home/client/fas/sbsc/ga254/scripts/HOTSPOT/sc1_rasterize.sh $GROUP  ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export RAM=/dev/shm
export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT
export GROUP=$GROUP

module load Tools/CDO/1.6.4

cleanram 

# creati dei netcdf aggiustare l'if condition con il tif 

# rasterize at 1 degre resolution and at 1 km resolution 
#              19395                     75                        347                            39395                         17916 
if [ $GROUP = AMPHIBIANS ] || [ $GROUP = MANGROVES ] || [ $GROUP = MARINE_MAMMALS ] || [ $GROUP = TERRESTRIAL_MAMMALS ] || [ $GROUP = REPTILES ]  ; then   

echo start group $GROUP
cp  $DIR/shp/$GROUP/*.*  $RAM
seq 1 $(ogrinfo -al  -so $RAM/${GROUP}.shp | grep Feature | awk '{ print $NF  }' )   | xargs -n 1 -P 8  bash -c $' 
FID=$1

if [ !  -f  $DIR/tif_1km/$GROUP/shp$FID.nc   ] ; then 
rm -f  $RAM/shp$FID.*
ogr2ogr -fid $FID  $RAM/shp$FID.shp  $RAM/${GROUP}.shp

#               -at to allow the small species to appear 

# gdal_rasterize -of netCDF  -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.008333333333333 0.008333333333333 $RAM/shp$FID.shp $DIR/tif_1km/$GROUP/shp$FID.nc 

gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1 $RAM/shp$FID.shp $DIR/tif_1d/$GROUP/shp$FID.nc

gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.25 0.25  $RAM/shp$FID.shp $DIR/tif_0.25d/$GROUP/shp$FID.nc  

rm -f  $RAM/shp$FID.*


fi 

' _ 
cleanram 
fi 
                # 843                   1190
if [ $GROUP = CORALS ] || [ $GROUP = MARINEFISH ]  ; then   
 
echo start group $GROUP
cp  $DIR/shp/$GROUP/*.*  $RAM

for PART in PART1 PART2 PART3 ; do 
export GROUP=$GROUP 
export PART=$PART

seq 1 $(ogrinfo -al  -so $RAM/${GROUP}_${PART}.shp | grep Feature | awk '{ print $NF  }' )    | xargs -n 1 -P 8  bash -c $' 

FID=$1
if [ $PART = PART1 ] ; then FIDname=$( expr $FID + 0 ) ; fi 
if [ $PART = PART2 ] ; then FIDname=$( expr $FID + 1000 ) ; fi 
if [ $PART = PART2 ] ; then FIDname=$( expr $FID + 2000 ) ; fi 

if [ !  -f $DIR/tif_1km/$GROUP/shp$FIDname.nc    ] ; then 

rm -f   $RAM/shp$FIDname.shp
ogr2ogr -fid $FID  $RAM/shp$FIDname.shp  $RAM/${GROUP}_${PART}.shp 

# gdal_rasterize  -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FIDname  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.008333333333333 0.008333333333333  $RAM/shp$FIDname.shp  $DIR/tif_1km/$GROUP/shp$FIDname.nc 

gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FIDname -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1     $RAM/shp$FIDname.shp $DIR/tif_1d/$GROUP/shp$FIDname.nc 
gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FIDname -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.5 0.5 $RAM/shp$FIDname.shp $DIR/tif_0.25d/$GROUP/shp$FIDname.nc  

rm -f   $RAM/shp$FIDname.shp

fi 

' _ 

done
cleanram  
fi



cleanram 
#             10423 
if [ $GROUP = BIRDS ] ; then   

echo start group $GROUP
find  $DIR/shp/$GROUP -name "*.shp"  | xargs -n 1 -P 8  bash -c $' 

file=$1
filename=$(basename $file .shp )

if [ ! -f $DIR/tif_1km/$GROUP/${filename}.nc  ] ; then 

# gdal_rasterize -at -ot Byte -a_srs EPSG:4326 -l $filename -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.008333333333333 0.008333333333333  $file $DIR/tif_1km/$GROUP/${filename}.nc

gdal_rasterize  -of netCDF  -at -ot Byte -a_srs EPSG:4326 -l $filename -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1   $file $DIR/tif_1d/$GROUP/${filename}.nc 

gdal_rasterize  -of netCDF  -at -ot Byte -a_srs EPSG:4326 -l $filename -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.5 0.5    $file $DIR/tif_0.25d/$GROUP/${filename}.nc  

fi 

' _ 
fi 

cleanram 

echo start the SUM   start the SUM   start the SUM start the SUM start the SUM start the SUM start the SUM start the SUM start the SUM start the SUM start the SUM start the SUM 

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/$GROUP
rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/*/*/shp.nc

# find  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_1km/$GROUP/   -name "*.nc"   > /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/tiflist_1km.txt 
# awk 'NR%1000==1 {x="F"++i;}{ print >   "list"x"_1km.txt" }'  tiflist_1km.txt 

find  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_1d/$GROUP/  -name "*.nc"   > /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/$GROUP/${GROUP}list_1d.txt 
awk -v  GROUP=$GROUP  'NR%1000==1 {x="F"++i;}{ print >  GROUP"list"x"_1d.txt" }'  ${GROUP}list_1d.txt 

find  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_0.25d/$GROUP/  -name "*.nc"   > /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/$GROUP/${GROUP}list_0.25d.txt 
awk   -v  GROUP=$GROUP  'NR%1000==1 {x="F"++i;}{ print > GROUP"list"x"_0.25d.txt" }'  ${GROUP}list_0.25d.txt 


for RES in 1d 0.25d  ; do

export RES=$RES

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}_stack/$GROUP/*

echo start partial sum 

ls $DIR/geo_file/$GROUP/${GROUP}listF*_${RES}.txt   | xargs -n 1  -P 8 bash -c $' 
LISTname=$(basename $1 .txt)

rm -f  $DIR/tif_${RES}_stack/${LISTname}_sum.nc 
cdo enssum   $(cat $1  )   $DIR/tif_${RES}_stack/${LISTname}_sum.nc 
rm -f  $(cat $1 )

' _ 

echo start group sum 
rm -f  $DIR/tif_${RES}_stack/species_sum_${RES}.nc 
cdo enssum   $(ls  $DIR/tif_${RES}_stack/*listF*_${RES}_sum.nc   )   $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.nc 
rm -f  $DIR/tif_${RES}_stack/*listF*_${RES}_sum.nc  
gdal_translate  -ot UInt32  -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.nc  $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.tif

rm -f    $DIR/tif_${RES}_stack/$GROUP/360x114global_${GROUP}_sum_${RES}.*
pkextract -r mean  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname Nsp_Mean  -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.tif   -o   $DIR/tif_${RES}_stack/$GROUP/360x114global_${GROUP}_sum_${RES}.shp
 
done 
 

# overall sum 

# for RES in 1d 0.25d 1km ; do
# cdo enssum  $(ls $DIR/tif_${RES}_stack/*/*_sum_${RES}.nc)  $DIR/tif_${RES}_stack/allgroup_sum_${RES}.nc 
# gdal_translate  -ot UInt32  -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/tif_${RES}_stack/allgroup_sum_${RES}.nc  $DIR/tif_${RES}_stack/allgroup_sum_${RES}.tif 

# rm -f   $DIR/tif_${RES}_stack/$GROUP/360x114global_allgroup_sum_${RES}.*
# pkextract -r mean  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname Nsp_Mean  -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i  $DIR/tif_${RES}_stack/allgroup_sum_${RES}.tif  -o $DIR/tif_${RES}_stack/360x114global_allgroup_sum_${RES}.shp

# done 


