#  for EUROASIA in LEFT RIGHT do ;  qsub  -v  TRH=100,EUROASIA=$EUROASIA  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc6_river_newtworkGMTED250_swap_EUROASIA.sh  ; done 

# 90420 11750011      MADAGASCAR        
# 10328 12535192      canada island 
# 80691 13772932     indonesia 
# 84397 14731200     guinea 
# 2285 22431475      canada island 
# 26487 26414813     canada island 
# 33778 150020638    greenland      
# 92404 158200595     AUSTRALIA
# 11000 350855901     south america 
# 11001 576136081     africa 
# 98343 596887982     north america 
# 91518 1474765872    EUROASIA    
# 19899               EUROASIA camptacha


#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

TRH=$TRH

# euroasia camptacha data preparation 

DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/

source /lustre/home/client/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river_EUROASIA/PERMANENT  

cp  $HOME/.grass7/grass$$     $HOME/.grass7/rc$UNIT

UNIT=91518

echo create mapset unit$UNIT

rm -fr /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unit${UNIT}_$EUROASIA

g.mapset -c  mapset=unit${UNIT}_$EUROASIA  location=loc_river_EUROASIA  dbase=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb   --quiet --overwrite 

cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river_EUROASIA/PERMANENT/WIND /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river_EUROASIA/unit${UNIT}_$EUROASIA/WIND

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river_EUROASIA/unit${UNIT}_$EUROASIA/.gislock

g.gisenv 

g.region raster=be75_grd_LandEnlarge_cond_carv100smoth_EUROASIA
if [ $EUROASIA = LEFT ]   ; then  g.region  e=25 ; fi 
if [ $EUROASIA = RIGHT ]  ; then  g.region  w=20 ; fi 

r.mask   rast=be75_grd_LandEnlarge_cond_carv100smoth_EUROASIA   --overwrite

echo start r.watershed 

echo starting use treshold $TRH $TRH  $TRH  $TRH                                   # also cal direction 

r.watershed  elevation=be75_grd_LandEnlarge_cond_carv100smoth_EUROASIA  basin=basin  stream=stream drainage=drainage  accumulation=accumulation tci=tci  memory=32000  threshold=$TRH   --overwrite   

echo r.stream.basins l option basin_last 

/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.basins   direction=drainage  stream_rast=stream  basins=basin_last  -l  --o memory=33000

echo r.stream.basins l option basin_elem # create error under 100  

# /lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.basins  direction=drainage  stream_rast=stream  basins=basin_elem  --o     memory=20000

echo r.stream.order 

/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.order  direction=drainage stream_rast=stream strahler=strahler horton=horton shreve=shreve hack=hack topo=topo memory=32000
g.list rast 

r.out.gdal --overwrite -c  createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32 format=GTiff nodata=0      input=stream output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/stream/stream${UNIT}_${EUROASIA}_trh$TRH.tif

r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=Int16  format=GTiff nodata=-99    input=drainage output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/drainage/drainage${UNIT}_${EUROASIA}_trh$TRH.tif 
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9"             format=GTiff nodata=-999999999      input=accumulation output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/accumulation/accumulation${UNIT}_${EUROASIA}_trh$TRH.tif #in automatic Flat64 and nodata 

r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin/basin${UNIT}_${EUROASIA}_trh$TRH.tif   
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin_last output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin_last/basin_last${UNIT}_${EUROASIA}_trh$TRH.tif
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin_elem output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin_elem/basin_elem${UNIT}_${EUROASIA}_trh$TRH.tif

r.out.gdal --overwrite -c createopt="COMPRESS=DEFLATE,ZLEVEL=9"        format=GTiff nodata=-1  input=tci output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/tci/tci${UNIT}_${EUROASIA}_trh$TRH.tif

# stream order 

r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=strahler     output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/strahler/strahler${UNIT}_${EUROASIA}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=horton       output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/horton/horton${UNIT}_${EUROASIA}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=shreve       output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/shreve/shreve${UNIT}_${EUROASIA}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=hack         output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/hack/hack${UNIT}_${EUROASIA}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=topo         output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/topo/topo${UNIT}_${EUROASIA}_trh$TRH.tif

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/*/*trh$TRH.tif.aux.xml 

# rm -fr /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unit$UNIT
