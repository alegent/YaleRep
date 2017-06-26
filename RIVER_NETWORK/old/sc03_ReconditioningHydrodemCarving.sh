# bsub   -q  week    -W 168:00 -M 30000  -R "rusage[mem=30000]" -n 1  -R "span[hosts=1]"    -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_ReconditioningHydrodemCarving.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_ReconditioningHydrodemCarving.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc03_ReconditioningHydrodemCarving.sh 

cd /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb 

# re insert if 
rm -rf   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river
source /gpfs/home/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb loc_river /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge.tif 

# source  /gpfs/home/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT 
# # 100 water ; 0 land ; 255 no data > transformed to 0 

gdal_edit.py  -a_nodata  -1   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSW/input/occurrence_250m.tif 
r.in.gdal in=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSW/input/occurrence_250m.tif  out=occurrence_250m  memory=2047  --overwrite

g.list rast 

g.region   raster=be75_grd_LandEnlarge  --o #   n=35 s=30 e=0 w=-10  #  
r.mask -r 
r.mask     raster=be75_grd_LandEnlarge   --o

echo log transform the water layer 

# # plot ( wa ,  100  * log(wa+1) / ( max(log(0+1)) -  min (log(100+1)))   )  ; log(1)=0
r.mapcalc "occurrence_250m_log = if ( occurrence_250m < 101  ,   100  * log(occurrence_250m + 1) /  4.615121 / 5  , 0    )"   --overwrite

echo  carving 
r.mapcalc "be75_grd_LandEnlarge_carv100  = be75_grd_LandEnlarge  -  occurrence_250m_log  "  --overwrite

echo  procedure to smoth the border 
r.mapcalc "occurrence_250m_0_1 = if ( occurrence_250m == 0 ||  occurrence_250m == 255 ,  null()  , 1     )"   --overwrite

echo r.grow  0 land , 1 water , 2 enlarge 
r.grow  input=occurrence_250m_0_1   output=occurrence_250m_null_1_2    radius=3.01    old=1 new=2     --overwrite 
r.mapcalc "occurrence_250m_0_1_2  = if ( isnull(occurrence_250m_null_1_2)  , 0 , occurrence_250m_null_1_2  )"   --overwrite

echo start r.neighbors 
r.neighbors -c  input=be75_grd_LandEnlarge_carv100 output=be75_grd_LandEnlarge_carv100filter  method=average  size=5

# #   if(x,a,b,c)             a if x > 0, b if x is zero, c if x < 0
# #                                                                            if is 2 use the r.neightors   , if is 1 use the carved      , if 0 orignal dem 
r.mapcalc "be75_grd_LandEnlarge_carv100smoth = if(occurrence_250m_0_1_2 > 1, be75_grd_LandEnlarge_carv100filter, be75_grd_LandEnlarge_carv100, be75_grd_LandEnlarge)"  --overwrite

r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_carv100smoth  output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_carv100smoth.tif
r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_carv100       output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_carv100.tif

echo start r.hydridem 
/gpfs/home/fas/sbsc/ga254/.grass7/addons/bin/r.hydrodem    input=be75_grd_LandEnlarge_carv100smoth   output=be75_grd_LandEnlarge_cond  memory=25000  --overwrite 

echo start the output 
r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_cond          output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_cond.tif 

r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16 input=occurrence_250m_log           output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/occurrence_250m_log.tif 

exit 



