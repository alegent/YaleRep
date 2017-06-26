# bsub   -q   shared   -W 24:00 -M 30000  -R "rusage[mem=30000]" -n 1  -R "span[hosts=1]"    -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_ReconditioningHydrodemCarving.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_ReconditioningHydrodemCarving.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc03_ReconditioningHydrodemCarvingENDwatershed.sh 

cd /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb 

# re insert if 
# rm -rf   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_test
# source /gpfs/home/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb loc_river_test  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge.tif 

source  /gpfs/home/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_test/PERMANENT 

# gdal_edit.py  -a_nodata  0  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clumpMSK.tif 
# r.in.gdal in=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/unit/UNIT20000msk.tif   out=UNIT20000msk     memory=2047 --overwrite

# # 100 water ; 0 land ; 255 no data > transformed to 0 
# gdal_edit.py  -a_nodata  -1 /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSW/input/occurrence_250m.tif 
# r.in.gdal in=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSW/input/occurrence_250m.tif  out=occurrence_250m  memory=2047  --overwrite

g.list rast 


g.region    raster=land_mask250m_enlarge --o #     n=12.46 s=12.48 e=-81.3 w=-81.4   #   raster=UNIT20000msk  #  
r.mask -r 
r.mask  raster=UNIT20000msk  --o

# r.mapcalc "occurrence_250m_0_1  = if ( occurrence_250m < 101 &&  occurrence_250m > 0.5   ,   1 , 0    )"   --overwrite
# r.cost -k -n  input=be75_grd_LandEnlarge    output=cost  nearest=neares outdir=movement  start_raster=occurrence_250m_0_1  --overwrite 
# r.to.vect -b  input=occurrence_250m_0_1  output=occurrence_250m_0_1_p  type=point --overwrite
# r.drain   input=cost   output=drain   start_points=occurrence_250m_0_1_p  --overwrite  

# echo log transform the water layer 

# # plot ( wa ,  100  * log(wa+1) / ( max(log(0+1)) -  min (log(100+1)))   )  ; log(1)=0
# r.mapcalc "occurrence_250m_log = if ( occurrence_250m < 101  ,   100  * log(occurrence_250m + 1) /  4.615121 / 5  , 0    )"   --overwrite

# echo  carving 
# r.mapcalc "be75_grd_LandEnlarge_carv100  = be75_grd_LandEnlarge  -  occurrence_250m_log  "  --overwrite

# echo  procedure to smoth the border 
# r.mapcalc "occurrence_250m_0_1 = if ( occurrence_250m == 0 ||  occurrence_250m == 255 ,  null()  , 1     )"   --overwrite

# echo r.grow  0 land , 1 water , 2 enlarge 
# r.grow  input=occurrence_250m_0_1   output=occurrence_250m_null_1_2    radius=1.01    old=1 new=2     --overwrite 
# r.mapcalc "occurrence_250m_0_1_2  = if ( isnull(occurrence_250m_null_1_2)  , 0 , occurrence_250m_null_1_2  )"   --overwrite

# echo start r.neighbors 
# r.neighbors input=be75_grd_LandEnlarge_carv100 output=be75_grd_LandEnlarge_carv100filter  method=average

# #   if(x,a,b,c)             a if x > 0, b if x is zero, c if x < 0
# #                                                                            if is 2 use the r.neightors   , if is 1 use the carved      , if 0 orignal dem 
# r.mapcalc "be75_grd_LandEnlarge_carv100smoth = if(occurrence_250m_0_1_2 > 1, be75_grd_LandEnlarge_carv100filter, be75_grd_LandEnlarge_carv100, be75_grd_LandEnlarge)"  --overwrite

# r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_carv100smoth  output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/SA_LandEnlarge_carv100smoth.tif
# r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_carv100       output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/SA_LandEnlarge_carv100.tif

# r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=0 type=Float32  input=occurrence_250m_log       output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/output/GSW/SA_occurrence_250m_log.tif 

echo start r.hydridem 
/gpfs/home/fas/sbsc/ga254/.grass7/addons/bin/r.hydrodem    input=be75_grd_LandEnlarge_carv100smoth   output=be75_grd_LandEnlarge_cond  memory=25000  --overwrite 
r.out.gdal --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff nodata=-9999 type=Int16  input=be75_grd_LandEnlarge_cond          output=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/dem/SA_LandEnlarge_cond.tif 
echo start the output 

r.watershed  elevation=be75_grd_LandEnlarge_cond  basin=basin  stream=stream drainage=drainage  accumulation=accumulation  memory=65000 threshold=10   --overwrite

r.out.gdal --overwrite -c  createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32 format=GTiff nodata=0      input=stream output=$DIR/output/stream/stream_SA4.tif

pkcreatect -min 0 -max 1 > /tmp/color.txt 
pkgetmask -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -ct /tmp/color.txt -min 0.5 -max 99999999999999999  -data 1 -nodata 0 -i  $DIR/output/stream/stream_test4.tif  $DIR/output/stream/stream_SA4_ct.tif




rm  /tmp/color.txt

exit 

