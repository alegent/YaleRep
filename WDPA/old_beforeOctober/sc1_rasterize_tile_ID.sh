
# for file in /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif  ; do qsub -v file=$file /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WDPA/sc1_rasterize_tile_ID.sh  ; done 

#  bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WDPA/sc1_rasterize_tile_ID.sh    /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_50N_000E.tif

# qsub -v file=/lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_30N_120E.tif   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WDPA/sc1_rasterize_tile_ID.sh  
# qsub -v file=/lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_50N_010E.tif   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WDPA/sc1_rasterize_tile_ID.sh  

# taiwan 30N_120E.tif
# italy  50N_010E.tif

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=10gb
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


# load moduels 


module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2   # exclued to load the pktools from the $HOME/bin
module load Libraries/OSGEO/1.10.0
module load Libraries/GSL
module load Libraries/ARMADILLO


# file=$1
tile=$(basename $file .tif)

INSHP=/lustre0/scratch/ga254/dem_bj/WDPA/shp_input
OUTTIF=/lustre0/scratch/ga254/dem_bj/WDPA/tif_output
OUTSHP=/lustre0/scratch/ga254/dem_bj/WDPA/shp_clip

export geo_string=$( getCorners4Gwarp  $file  ) 

echo  clip the large shp by $geo_string

rm -f  $OUTSHP/${tile}*
                                                       # $tile
ogr2ogr -skipfailures   -spat   $geo_string    $OUTSHP/${tile}_fgdb.shp     $INSHP/WDPA_Jan2014.shp/WDPA_poly_Jan2014.shp   
ogr2ogr -skipfailures   -spat   $geo_string    $OUTSHP/${tile}_shp.shp     $INSHP/WDPA_protect_april2014/selvaje-search-1396640206107.shp 


exit 

rm -f $RASTERIZE/${tile}.tif  
gdal_rasterize -ot Byte -a_srs EPSG:4326 -l  WDPA_poly_Jan2014_$tile  -burn 1   -a_nodata 0  -tr   0.008333333333333 0.008333333333333 \
-te  $geo_string  -co COMPRESS=LZW -co ZLEVEL=9  $SHP/shp_input/WDPA_Jan2014.shp/shp_clip/WDPA_poly_Jan2014_$tile.shp   $RASTERIZE/${tile}.tif 







