
# qsub   -W depend=afterany$(qstat -u $USER  | grep sc1_rasterize.sh   | awk -F . '{  printf (":%i" ,  $1 ) }' | awk '{   printf ("%s\n" , $1 ) }')  /lustre/home/client/fas/sbsc/ga254/scripts/HOTSPOT/sc2_2netcdfSUM.sh  

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

module load Tools/CDO/1.6.4 

export RAM=/dev/shm
export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT
export LIST=$1


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/
rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/*/*/shp.nc  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/*

for GROUP in AMPHIBIANS MANGROVES  MARINE_MAMMALS  TERRESTRIAL_MAMMALS REPTILES CORALS MARINEFISH  BIRDS ; do 

export GROUP=$GROUP 

find  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_1km/$GROUP/   -name "*.nc"   > /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/tiflist_1km.txt 
awk 'NR%1000==1 {x="F"++i;}{ print >   "tiflist"x"_1km.txt" }'  tiflist_1km.txt 

find  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_1d/$GROUP/  -name "*.nc"   > /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/tiflist_1d.txt 
awk 'NR%1000==1 {x="F"++i;}{ print >   "tiflist"x"_1d.txt" }'  tiflist_1d.txt 

find  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_0.25d/$GROUP/  -name "*.nc"   > /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/tiflist_0.25d.txt 
awk 'NR%1000==1 {x="F"++i;}{ print >   "tiflist"x"_0.25d.txt" }'  tiflist_0.25d.txt 


cleanram 


for RES in 1d 0.25d 1km ; do

export RES=$RES

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}_stack/*

ls $DIR/geo_file/tiflistF*_${RES}.txt   | xargs -n 1  -P 8 bash -c $' 
LISTname=$(basename $1 .txt)

# for NC in $(cat $1) ; do cdo infov $NC ; done 

rm -f  $DIR/tif_${RES}_stack/${LISTname}_sum.nc 
cdo enssum   $(cat $1  )   $DIR/tif_${RES}_stack/${LISTname}_sum.nc 

' _ 

rm -f  $DIR/tif_${RES}_stack/species_sum_${RES}.nc 
cdo enssum   $(ls  $DIR/tif_${RES}_stack/tiflistF*_${RES}_sum.nc   )   $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.nc 
rm -f  $DIR/tif_${RES}_stack/tiflistF*_${RES}_sum.nc
gdal_translate  -ot UInt32  -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.nc  $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.tif

rm -f    $DIR/tif_${RES}_stack/$GROUP/360x114global_${GROUP}_sum_${RES}.*
pkextract -r mean  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname Nsp_Mean  -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/tif_${RES}_stack/$GROUP/${GROUP}_sum_${RES}.tif   -o   $DIR/tif_${RES}_stack/$GROUP/360x114global_${GROUP}_sum_${RES}.shp
 
done 

rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/geo_file/*.txt 

done 

# overall sum 

for RES in 1d 0.25d 1km ; do
cdo enssum  $(ls $DIR/tif_${RES}_stack/*/*_sum_${RES}.nc)  $DIR/tif_${RES}_stack/allgroup_sum_${RES}.nc 
gdal_translate  -ot UInt32  -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/tif_${RES}_stack/allgroup_sum_${RES}.nc  $DIR/tif_${RES}_stack/allgroup_sum_${RES}.tif 

rm -f   $DIR/tif_${RES}_stack/$GROUP/360x114global_allgroup_sum_${RES}.*
pkextract -r mean  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname Nsp_Mean  -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i  $DIR/tif_${RES}_stack/allgroup_sum_${RES}.tif  -o $DIR/tif_${RES}_stack/360x114global_allgroup_sum_${RES}.shp

done 

