# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc2_ReconditioningHydrodemCarving.sh

#PBS -S /bin/bash 
#PBS -q fas_long
#PBS -l walltime=3:00:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


cd     /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb
rm -r   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river



source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb loc_river /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge.tif 

gdal_edit.py  -a_nodata  0  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge.tif
gdal_edit.py  -a_nodata -1  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m_from_30m4326/GIW_water_250m_bordermsk_ct.tif

r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge.tif                 out=land_mask250m_enlarge     memory=2000  --overwrite
r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m_from_30m4326/GIW_water_250m_bordermsk_ct.tif   out=GIW_water_250m_bordermsk  memory=2000  --overwrite

echo start r.hydridem 
r.mask raster=land_mask250m_enlarge

/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.hydrodem  input=be75_grd_LandEnlarge   output=be75_grd_LandEnlarge_cond  memory=25000  --overwrite 

echo start r.mapcalc

r.mapcalc "be75_grd_LandEnlarge_cond_carv  = be75_grd_LandEnlarge_cond  - ( GIW_water_250m_bordermsk  * 22 )"  --overwrite
r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_cond_carv  output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_cond_carv.tif

r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16 input=be75_grd_LandEnlarge_cond  output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_cond.tif 

r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif    out=compUNIT3 memory=2000  --overwrite

