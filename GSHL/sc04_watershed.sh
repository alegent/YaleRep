# qsub   /lustre/home/client/fas/sbsc/ga254/scripts/GSHL/sc04_watershed.sh

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# full process more than 4 our

DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad

# module purge 
export PATH="/home/fas/sbsc/ga254/anaconda3/bin:$PATH"

python <<EOF

import SimpleITK as sitk
print("importing image")
img  = sitk.ReadImage("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/impervius_cost.tif" , sitk.sitkFloat32  )  
# # to check img.GetPixelIDTypeAsString 32-bit unsigned integer  
core = sitk.ReadImage("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/markers.tif")

marker_img  = sitk.ConnectedComponent(core, fullyConnected=True)

print("start watershed")
ws_line  = sitk.MorphologicalWatershedFromMarkers( img, marker_img, markWatershedLine=True,  fullyConnected=True)
ws_poly  = sitk.MorphologicalWatershedFromMarkers( img, marker_img, markWatershedLine=False, fullyConnected=True)

sitk.WriteImage( sitk.Cast( ws_line  ,  sitk.sitkFloat32  ),        '/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/watershed_line_nogeo.tif' )
sitk.WriteImage( sitk.Cast( ws_poly  ,  sitk.sitkFloat32  ),        '/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/watershed_poly_nogeo.tif' )

EOF


module load Langs/Python/2.7.3
module load Libs/GDAL/1.11.2
module load Libraries/OSGEO/1.10.0
module load Libraries/ARMADILLO
module load Tools/PKTOOLS/2.6.7
module load Applications/GRASS/7.0.2


gdal_edit.py  -a_srs EPSG:4326     -a_ullr $(getCorners4Gtranslate $DIR/impervius_cost.tif  ) $DIR/watershed_line_nogeo.tif 
pkgetmask -ot Byte   -co COMPRESS=DEFLATE -co ZLEVEL=9    -min -1 -max 0.5    -i    $DIR/watershed_line_nogeo.tif  -o   $DIR/watershed_line.tif 


gdal_edit.py  -a_srs EPSG:4326     -a_ullr $(getCorners4Gtranslate  $DIR/impervius_cost.tif  ) $DIR/watershed_poly_nogeo.tif  
pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9   -m $DIR/impervius_cost.tif -msknodata -1 -nodata 0 -i    $DIR/watershed_poly_nogeo.tif  -o    $DIR/watershed_poly.tif   


rm -f   $DIR/watershed_poly_shp.* 
gdal_polygonize.py   -f  "ESRI Shapefile"   $DIR/watershed_poly.tif     $DIR/watershed_poly_shp.shp 

