#!/bin/bash
#SBATCH -p day
#SBATCH -J sc03_watershed_250.sh
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_watershed_250.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_watershed_250.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email


# for UNIT in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 573 810 1145 2597 3005 3317 3629 3753 4000 4001 3562_333 497_338 ; do MEM=$(awk -v UNIT=$UNIT '{ if ($1==UNIT  ) print $2 }'  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/UNIT_MEM_watershad.txt )  ; sbatch --export=UNIT=$UNIT,MEM=$MEM --mem-per-cpu=$MEM  /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc04_watershed_250.sh  ; done 

#  bash /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc04_watershed_250.sh 10
#  following the example at http://insightsoftwareconsortium.github.io/SimpleITK-Notebooks/32_Watersheds_Segmentation.html

module load Libs/ARMADILLO/7.700.0 

export DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL
export PATH=/home/fas/sbsc/ga254/anaconda3/bin:$PATH
export UNIT=$UNIT

rm -f  $DIR/watershed_line_nogeo$UNIT.tif  $DIR/watershed_poly_nogeo$UNIT.tif  

python <<EOF
import os
UNIT=os.environ["UNIT"]

import SimpleITK as sitk
print("import cost")
img  = sitk.ReadImage("/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_cost/costUNIT" + UNIT + ".tif", sitk.sitkFloat32)  

print("import core")
# # to check img.GetPixelIDTypeAsString 32-bit unsigned integer  
core = sitk.ReadImage("/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_core/core" + UNIT + ".tif")

print("create marker_img")
marker_img  = sitk.ConnectedComponent(core, fullyConnected=True)

print("start watershed")
ws_line  = sitk.MorphologicalWatershedFromMarkers( img, marker_img, markWatershedLine=True,  fullyConnected=True)
sitk.WriteImage( sitk.Cast( ws_line  ,  sitk.sitkFloat32  ),        "/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_line_nogeo" + UNIT + ".tif" )
del(ws_line)

ws_poly  = sitk.MorphologicalWatershedFromMarkers( img, marker_img, markWatershedLine=False, fullyConnected=True)
sitk.WriteImage( sitk.Cast( ws_poly  ,  sitk.sitkFloat32  ),        "/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_poly_nogeo" + UNIT + ".tif" )
del(ws_poly)
EOF

export PATH=/gpfs/apps/hpc/Apps/GRASS/7.0.2/bin:/gpfs/apps/hpc.rhel7/Tools/PKTOOLS/2.6.7/bin:/gpfs/apps/hpc/Libs/GSL/2.2/bin:/gpfs/apps/hpc/Libs/OSGEO/1.11.2/bin:/gpfs/apps/hpc/Langs/Python/2.7.10/bin:/gpfs/apps/hpc/Libs/WXPYTHON/3.0.0/bin:/gpfs/apps/hpc/Langs/GCC/5.2.0/bin:/gpfs/apps/hpc/Libs/NUMPY/1.9.2/bin:/gpfs/apps/hpc.rhel7/Libs/GDAL/1.11.2/bin:/gpfs/apps/hpc/Libs/GEOS/3.4.0/bin:/gpfs/apps/hpc.rhel7/Libs/GEOTIFF/1.4.0/bin:/gpfs/apps/hpc.rhel7/Libs/TIFF/4.0.7/bin:/gpfs/apps/hpc/Libs/NetCDF/4.2.1.1-hdf4/bin:/gpfs/apps/hpc/Libs/HDF4/4.2.9-nonetcdf-gcc/bin:/gpfs/apps/hpc/Libs/HDF5/1.8.13-gcc/bin:/gpfs/apps/hpc/Langs/TCLTK/8.5.14/bin:/usr/lib64/qt-3.3/bin:/usr/lib64/ccache:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/ibutils/bin:/home/fas/sbsc/ga254/bin:/home/fas/sbsc/ga254/bin:/home/fas/sbsc/ga254/bin

x=$(gdalinfo -noct   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_unit/UNIT${UNIT}msk4GHS.tif | grep  "Size is" | awk '{gsub (","," " ) ; print $3 }')
y=$(gdalinfo -noct   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_unit/UNIT${UNIT}msk4GHS.tif | grep  "Size is" | awk '{gsub (","," " ) ; print $4 }')

geo_string=$(gdalinfo -noct    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_unit/UNIT${UNIT}msk4GHS.tif  | grep Origin | awk -v x=$x -v y=$y '{ gsub (","," " ) ; gsub ("\\("," " ) ; gsub ("\\)"," " ) ; printf ( "%.14f %.14f %.10f %.10f\n" ,  $3 , $4  , $3 + ( x * 0.002083333333333) , $4 - ( y * 0.002083333333333)) }')

gdal_edit.py -a_srs EPSG:4326 -a_ullr $geo_string  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_line_nogeo$UNIT.tif 
pkgetmask -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9 -min -1 -max 0.5 -i $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_line_nogeo$UNIT.tif -o $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/ws_line$UNIT.tif

rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_line_nogeo$UNIT.tif 

gdal_edit.py -a_srs EPSG:4326 -a_ullr $geo_string $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_poly_nogeo$UNIT.tif  

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_unit/UNIT${UNIT}msk4GHS.tif -msknodata 0 -nodata 0 -i $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_poly_nogeo$UNIT.tif -o $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/ws_clump$UNIT.tif

rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_watershad/watershed_poly_nogeo$UNIT.tif  


