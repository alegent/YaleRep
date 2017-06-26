# qsub /lustre/home/client/fas/sbsc/ga254/scripts/GSHL/sc2_population_bin.sh

#PBS -S /bin/bash 
#PBS -q fas_normal 
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

module purge 
module unload Libs/GDAL/1.11.2 
module load Langs/Python/2.7.3
module load Libs/GDAL/1.10.0
# module load Libraries/OSGEO/1.10.0
module load Libraries/ARMADILLO

exit 



export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL

# gdalwarp -overwrite -te -180 -90 +180 +90 -tr 0.008333333333333333333 0.008333333333333333333 -tap -t_srs EPSG:4326 -r bilinear -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0.tif  $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0_WGS84.tif


# echo 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5 | xargs -n 1 -P 8 bash -c $'
# MIN=$1
# oft-stat -i $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0_WGS84.tif -o $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/AVG_bin$MIN.txt  -um    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin$MIN.tif -nostd

# oft-stat-sum -i $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0_WGS84.tif -o $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/SUM_bin$MIN.txt  -um    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin$MIN.tif -nostd

# oft-stat -i $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0_WGS84.tif -o $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/AVG_clump_bin$MIN.txt  -um    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}_clump.tif -nostd

# oft-stat-sum -i $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0_WGS84.tif -o $DIR/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0/SUM_clump_bin$MIN.txt  -um    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}_clump.tif -nostd

# ' _ 


# rm -f   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_shp/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin*.*

# echo 5.5 6.5 7.5 8.5 9.5 | xargs -n 1 -P 8 bash -c $'
# MIN=$1
# rm -f  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_shp/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.*
# gdal_polygonize.py -f "ESRI Shapefile" -mask   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_shp/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}.shp  
 
# ' _ 


# next script  /home/fas/sbsc/ga254/scripts/GEOING/sc10_humanHazard.sh 
exit 


