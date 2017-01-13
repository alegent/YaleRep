# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc2_ReconditioningHydrodemCarving.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:04:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb
#  rm -r   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river
#  source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb loc_river /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge.tif 

source /lustre/home/client/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT 

# gdal_edit.py  -a_nodata  0  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge.tif
# gdal_edit.py  -a_nodata -1  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m_from_30m4326/GIW_water_250m_max_bordermsk_ct.tif 

# r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge.tif                    out=land_mask250m_enlarge     memory=2000  --overwrite
# r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m_from_30m4326/GIW_water_250m_max_bordermsk_ct.tif  out=GIW_water_250m_bordermsk  memory=2000  --overwrite

# echo start r.hydridem 
# g.region  raster=land_mask250m_enlarge --o
# r.mask -r 
# r.mask -r raster=land_mask250m_enlarge --o

# # /lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.hydrodem   input=be75_grd_LandEnlarge   output=be75_grd_LandEnlarge_cond  memory=25000  --overwrite 

# echo filter the GIW_water_250m_bordermsk

# r.mapcalc "GIW_water_250m_bordermsk_null = if ( GIW_water_250m_bordermsk ==  0 , null() , 2    )"   --overwrite
# r.grow  input=GIW_water_250m_bordermsk_null  output=GIW_water_250m_bordermsk_grow    radius=1.01    old=1 new=2     --overwrite 
# g.remove -f  type=rast name=GIW_water_250m_bordermsk_null

# r.mapcalc "GIW_water_250m_bordermsk_grow012  = if ( isnull(GIW_water_250m_bordermsk_grow) , 0 , GIW_water_250m_bordermsk_grow    )"   --overwrite
# # 0 land , 1 water , 2 enlarge 
# echo start r.mapcalc

# r.mapcalc "be75_grd_LandEnlarge_cond_carv100  = be75_grd_LandEnlarge_cond  - ( GIW_water_250m_bordermsk  * 100 )"  --overwrite

# r.neighbors input=be75_grd_LandEnlarge_cond_carv100 output=be75_grd_LandEnlarge_cond_carv100filter  method=average

# #   if(x,a,b,c)             a if x > 0, b if x is zero, c if x < 0
                                                                                                 #  if is 0  normal dem     , if 1 average  , if 2 carved100   
# r.mapcalc "be75_grd_LandEnlarge_cond_carv100smoth = if(GIW_water_250m_bordermsk_grow012 > 1, be75_grd_LandEnlarge_cond_carv100filter, be75_grd_LandEnlarge_cond_carv100, be75_grd_LandEnlarge_cond)"  --overwrite

g.region res=0.0083333333333333333333  -a 
r.resamp.stats -nw input=be75_grd_LandEnlarge_cond_carv100smoth  output=be75_grd_LandEnlarge_cond_carv100smoth_km method=average
g.region rast=be75_grd_LandEnlarge_cond_carv100smoth

exit 

r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9,NUM_THREADS=ALL_CPUS" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_cond_carv100smoth  output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_cond_carv100smoth.tif

r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9,NUM_THREADS=ALL_CPUS" format=GTiff nodata=-9999 type=Int16 input=be75_grd_LandEnlarge_cond  output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_cond.tif 

r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif    out=compUNIT3 memory=2000  --overwrite
r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp/island_areas_ct.tif    out=islandUNIT memory=2000  --overwrite


for UNIT in 1 2 3 4 5 6 7 8 90420 10328 80691 84397 2285 26487 33778 92404 11000 11001 98343 91518 ; do qsub -v UNIT=$UNIT  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc5_river_newtworkGMTED250.sh; done