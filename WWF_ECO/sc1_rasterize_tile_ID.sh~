
# for file in    /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/*.tif     ; do qsub -v file=$file  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WWF_ECO/sc1_rasterize_tile_ID.sh  ; sleep 60  ; done 

#  bash   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WWF_ECO/sc1_rasterize_tile_ID.sh   /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_50N_000E.tif

# qsub -v file=/lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_30N_120E.tif  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WWF_ECO/sc1_rasterize_tile_ID.sh
# qsub -v file=/lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_50N_010E.tif  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WWF_ECO/sc1_rasterize_tile_ID.sh

# taiwan 30N_120E.tif
# italy  50N_010E.tif

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=0:10:00 
#PBS -l nodes=1:ppn=1
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
filename=$(basename $file .tif)
tile=${filename:29:8}

echo processing tile  $tile 



INSHP=/lustre0/scratch/ga254/dem_bj/WWF_ECO/shp_input
OUTTIF=/lustre0/scratch/ga254/dem_bj/WWF_ECO/tif_output
OUTSHP=/lustre0/scratch/ga254/dem_bj/WWF_ECO/shp_clip
OUTTXT=/lustre0/scratch/ga254/dem_bj/WWF_ECO/txt_output

TIFGAIN=/lustre0/scratch/ga254/dem_bj/GFC2013/gain/tif
TIFLOSS=/lustre0/scratch/ga254/dem_bj/GFC2013/loss/tif

geo_string=$(getCorners4Gtranslate  $file)
ulx=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $1 )}')  # round the number to rounded cordinates
uly=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $2 )}')
lrx=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $3 )}')
lry=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $4 )}')

# soutest tile smoler
if [ ${filename:29:3} = '50S' ] ; then  ysize=25200 ; else ysize=36000 ; fi

echo  clip the tif based on the  $geo_string
gdal_translate -srcwin 0 0 36000 $ysize  -a_ullr  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9  $file                                      $OUTTIF/tree_${tile}_cut.tif 
gdal_translate -srcwin 0 0 36000 $ysize  -a_ullr  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9  $TIFGAIN/Hansen_GFC2013_gain_${tile}.tif   $OUTTIF/gain_${tile}_cut.tif 
gdal_translate -srcwin 0 0 36000 $ysize  -a_ullr  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9  $TIFLOSS/Hansen_GFC2013_loss_${tile}.tif   $OUTTIF/loss_${tile}_cut.tif 

gdalbuildvrt -separate  -overwrite   $OUTTIF/${tile}.vrt   $OUTTIF/{tree,gain,loss}_${tile}_cut.tif
gdal_translate   -co  COMPRESS=LZW -co ZLEVEL=9    $OUTTIF/${tile}.vrt  $OUTTIF/${tile}.tif 

geo_string=$( getCorners4Gwarp  $OUTTIF/tree_${tile}_cut.tif   )  # recalculate geo string based on the clipped tif  

rm -f $OUTTIF/tree_${tile}_cut.tif  $OUTTIF/gain_${tile}_cut.tif   $OUTTIF/loss_${tile}_cut.tif   $OUTTIF/${tile}.vrt 
echo  clip the large shp by $geo_string

rm -f  $OUTSHP/wwf_eco_${tile}*

ogr2ogr -skipfailures   -spat   $geo_string    $OUTSHP/wwf_eco_${tile}.shp     $INSHP/wwf_terr_ecos.shp
gdal_rasterize -ot Byte -a_srs EPSG:4326   -l  wwf_eco_${tile}   -a 'OBJECTID'   -a_nodata 0  -tr 0.000277777777778  0.000277777777778   -te  $geo_string  -co COMPRESS=LZW -co ZLEVEL=9   $OUTSHP/wwf_eco_${tile}.shp   $OUTTIF/wwf_eco_${tile}.tif 
rm -r $OUTSHP/wwf_eco_${tile}.shp

rm -f $OUTTXT/wwf_eco_${tile}.txt
oft-stat-sum  -i    $OUTTIF/${tile}.tif    -o   $OUTTXT/wwf_eco_${tile}.txt  -um   $OUTTIF/wwf_eco_${tile}.tif  -nostd 

rm -f $OUTTIF/wwf_eco_${tile}.tif $OUTTIF/${tile}.tif 
















