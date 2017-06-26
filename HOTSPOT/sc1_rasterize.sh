# for GROUP in BIRDS TERRESTRIAL_MAMMALS REPTILES AMPHIBIANS MANGROVES MARINE_MAMMALS CORALS MARINEFISH  ; do  qsub -v GROUP=$GROUP  /lustre/home/client/fas/sbsc/ga254/scripts/HOTSPOT/sc1_rasterize.sh  ; done 

# for GROUP in AMPHIBIANS MANGROVES  MARINE_MAMMALS  TERRESTRIAL_MAMMALS REPTILES CORALS MARINEFISH  BIRDS ; do  bash   /lustre/home/client/fas/sbsc/ga254/scripts/HOTSPOT/sc1_rasterize.sh $GROUP; done 

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
#              19395                     75                        347                            39395                 
if [ $GROUP = AMPHIBIANS ] || [ $GROUP = MANGROVES ] || [ $GROUP = MARINE_MAMMALS ] || [ $GROUP = TERRESTRIAL_MAMMALS ]   ; then   
rm -f $DIR/tif_{0.25d,1d}/$GROUP/*   $DIR/tif_{0.25d,1d}_stack/$GROUP/*  
echo start group $GROUP
cp  $DIR/shp/$GROUP/*.*  $RAM

ogrinfo -al -geom=NO  $RAM/${GROUP}.shp  | grep id_no | awk ' {  print $4 }'   | sort | uniq  > $RAM/${GROUP}.txt 

cat $RAM/${GROUP}.txt  | xargs -n 20 -P 8  bash -c $' 

for FID in ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20}  ; do 
echo species ID $FID 
rm -f  $RAM/shp$FID.*
ogr2ogr  -where  " id_no = $FID  "     $RAM/shp$FID.shp  $RAM/${GROUP}.shp

#               -at to allow the small species to appear 
# gdal_rasterize -of netCDF  -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.008333333333333 0.008333333333333 $RAM/shp$FID.shp $DIR/tif_1km/$GROUP/shp$FID.nc 

gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1 $RAM/shp$FID.shp $RAM/tif_1d_shp$FID.nc
gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.25 0.25  $RAM/shp$FID.shp $RAM/tif_0.25d_shp$FID.nc  

rm -f  $RAM/shp$FID.*

done 

echo start the sum ensamble of the first 20 nc  
for RES in 1d 0.25d  ; do
rm -f  $DIR/tif_${RES}/$GROUP/${GROUP}_sum$1_${RES}.nc 
cdo -z zip_9 -f nc4 enssum   $(ls  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc  2> /dev/null  )  $DIR/tif_${RES}/$GROUP/${GROUP}_sum$1_${RES}.nc 
rm -f  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc 
done  

' _ 

cleanram 
fi 


if   [ $GROUP = REPTILES ]  ; then   
rm -f $DIR/tif_{0.25d,1d}/TERRESTRIAL_REPTILES/*   $DIR/tif_{0.25d,1d}_stack/TERRESTRIAL_REPTILES/*  
echo start group TERRESTRIAL_REPTILES
cp  $DIR/shp/$GROUP/*.*  $RAM

awk '{  if($3==0) print $2 }'  $DIR/shp/REPTILES/REPTILES_id_no_binomial_marine.txt | xargs -n 20 -P 8  bash -c $' 

for FID in ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20}  ; do 
echo species ID $FID 
rm -f  $RAM/shp$FID.*
ogr2ogr  -where  " id_no = $FID  "     $RAM/shp$FID.shp  $RAM/${GROUP}.shp

gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1 $RAM/shp$FID.shp $RAM/tif_1d_shp$FID.nc
gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.25 0.25  $RAM/shp$FID.shp $RAM/tif_0.25d_shp$FID.nc  

rm -f  $RAM/shp$FID.*

done 

echo start the sum ensamble of the first 20 nc  
for RES in 1d 0.25d  ; do
rm -f  $DIR/tif_${RES}/TERRESTRIAL_REPTILES/TERRESTRIAL_REPTILES_sum$1_${RES}.nc 
cdo -z zip_9 -f nc4 enssum   $(ls  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc  2> /dev/null  )  $DIR/tif_${RES}/TERRESTRIAL_REPTILES/TERRESTRIAL_REPTILES_sum$1_${RES}.nc 
rm -f  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc 
done  

' _ 

cleanram 

rm -f $DIR/tif_{0.25d,1d}/MARINE_REPTILES/*   $DIR/tif_{0.25d,1d}_stack/MARINE_REPTILES/*  
echo start group MARINE_REPTILES
cp  $DIR/shp/$GROUP/*.*  $RAM

awk '{  if($3==1) print $2 }'  $DIR/shp/REPTILES/REPTILES_id_no_binomial_marine.txt | xargs -n 20 -P 8  bash -c $' 

for FID in ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20}  ; do 
echo species ID $FID 
rm -f  $RAM/shp$FID.*
ogr2ogr  -where  " id_no = $FID  "     $RAM/shp$FID.shp  $RAM/${GROUP}.shp

gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1 $RAM/shp$FID.shp $RAM/tif_1d_shp$FID.nc
gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.25 0.25  $RAM/shp$FID.shp $RAM/tif_0.25d_shp$FID.nc  

rm -f  $RAM/shp$FID.*

done 

echo start the sum ensamble of the first 20 nc  
for RES in 1d 0.25d  ; do
rm -f  $DIR/tif_${RES}/MARINE_REPTILES/MARINE_REPTILES_sum$1_${RES}.nc 
cdo -z zip_9 -f nc4 enssum   $(ls  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc  2> /dev/null  )  $DIR/tif_${RES}/MARINE_REPTILES/MARINE_REPTILES_sum$1_${RES}.nc 
rm -f  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc 
done  

' _ 




fi 


cleanram 
                # 843                   1190
if [ $GROUP = CORALS ] || [ $GROUP = MARINEFISH ]  ; then   
 
echo start group $GROUP
cp  $DIR/shp/$GROUP/*.*  $RAM

rm -f $DIR/tif_{0.25d,1d}/$GROUP/*   $DIR/tif_{0.25d,1d}_stack/$GROUP/*  

for PART in PART1 PART2 PART3 ; do 
export GROUP=$GROUP 
export PART=$PART

ogrinfo -al -geom=NO   $RAM/${GROUP}_${PART}.shp   | grep id_no | awk ' {  print $4 }'   | sort | uniq  >  $RAM/${GROUP}_${PART}.txt

cat  $RAM/${GROUP}_${PART}.txt     | xargs -n 20  -P 8  bash -c $' 

echo start rasterize 

for FID in ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20}  ; do 

echo species ID $FID 

rm -f   $RAM/shp$FID.*

ogr2ogr  -where  " id_no = $FID  "   $RAM/shp$FID.shp  $RAM/${GROUP}_${PART}.shp  

# gdal_rasterize  -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID  -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.008333333333333 0.008333333333333  $RAM/shp$FID.shp  $DIR/tif_1km/$GROUP/shp$FID.nc 

gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1       $RAM/shp$FID.shp $RAM/tif_1d_shp$FID.nc  
gdal_rasterize -of netCDF -at -ot Byte -a_srs EPSG:4326 -l shp$FID -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.25 0.25 $RAM/shp$FID.shp $RAM/tif_0.25d_shp$FID.nc  

rm -f   $RAM/shp$FID.*
done 

echo start ensamble 

for RES in 1d 0.25d  ; do
rm -f   $DIR/tif_${RES}/$GROUP/${GROUP}_sum${FID}_${RES}.nc 
cdo -z zip_9 -f nc4 enssum   $(ls  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc  2> /dev/null  )  $DIR/tif_${RES}/$GROUP/${GROUP}_sum${FID}_${RES}.nc 
rm -f  $RAM/tif_${RES}_shp{${1},${2},${3},${4},${5},${6},${7},${8},${9},${10},${11},${12},${13},${14},${15},${16},${17},${18},${19},${20}}.nc 
done  

' _ 

done
cleanram  
fi

cleanram 

#             10423 
if [ $GROUP = BIRDS ] ; then   
rm -f $DIR/tif_{0.25d,1d}/$GROUP/*   $DIR/tif_{0.25d,1d}_stack/$GROUP/*  

echo start group $GROUP
cd   $DIR/shp/$GROUP
find  .  -name "*.shp"    | xargs -n 20 -P 8  bash -c $' 

for FID in ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20}  ; do 
file=$(basename $FID )
filename=$(basename $FID  .shp )
echo $file
# gdal_rasterize -at -ot Byte -a_srs EPSG:4326 -l $filename -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.008333333333333 0.008333333333333  $DIR/hsp/$FID  $DIR/tif_1km/$GROUP/${filename}.nc

gdal_rasterize  -of netCDF  -at -ot Byte -a_srs EPSG:4326 -l $filename -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 1 1          $DIR/shp/$GROUP/$file $RAM/${filename}_1d.nc
gdal_rasterize  -of netCDF  -at -ot Byte -a_srs EPSG:4326 -l $filename -burn 1 -a_nodata 0 -tap -te -180 -90 180 +90 -tr 0.25 0.25    $DIR/shp/$GROUP/$file $RAM/${filename}_0.25d.nc

done 

echo start ensamble  


for RES in 1d 0.25d  ; do
rm -f   $DIR/tif_${RES}/$GROUP/${GROUP}_sum${filename}_${RES}.nc 
cd $RAM
cdo -z zip_9 -f nc4  enssum  $(echo ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} | awk -v RES=$RES  \'{  gsub (".shp" , "_"RES".nc" );  gsub ("./" , "");  print  }\')   $DIR/tif_${RES}/$GROUP/${GROUP}_sum${filename}_${RES}.nc 

rm -f  $(echo ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20}   | awk -v RES=$RES  \'{  gsub (".shp" ,   "_"RES".nc" ) ;  gsub ("./" , "")  ;  print  }\'  ) 
done  


' _ 
fi 


