# for UNIT in 1 2 3 4 5 6 7 8 90420 10328 80691 84397 2285 26487 33778 92404 11000 11001 98343 91518  ; do qsub -v UNIT=$UNIT,TRH=100  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc5_river_newtworkGMTED250.sh ; done  

# for TRH  in $(seq 100 100 1000)   ; do bash   /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc5_river_newtworkGMTED250.sh  $TRH  ; done 

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

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:12:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# madagascar  90420
UNIT=$UNIT
TRH=$TRH

echo $TRH

source /lustre/home/client/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT 

cp  $HOME/.grass7/grass$$     $HOME/.grass7/rc$UNIT

echo create mapset unitKM$UNIT

rm -fr /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unitKM$UNIT

g.mapset  -c   mapset=unitKM$UNIT   location=loc_river   dbase=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb   --quiet --overwrite 

cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT/WIND /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unitKM$UNIT/WIND

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unitKM$UNIT/.gislock

g.gisenv 

r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNITK{UNIT}msk.tif   out=UNIT$UNIT   --overwrite
g.region raster=UNIT$UNIT

r.mask   rast=UNIT$UNIT  --overwrite

echo start r.watershed 

echo starting use treshold $TRH $TRH  $TRH  $TRH                                   # also cal direction 

r.watershed -b  elevation=be75_grd_LandEnlarge_cond_carv100smoth  basin=basin  stream=stream    drainage=drainage    accumulation=accumulation tci=tci  memory=20000  threshold=$TRH   --overwrite   

echo r.stream.basins l option basin_last 

/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.basins  direction=drainage  stream_rast=stream  basins=basin_last  -l  --o memory=20000

echo r.stream.basins l option basin_elem # create error under 100  

# /lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.basins  direction=drainage  stream_rast=stream  basins=basin_elem  --o     memory=20000

echo r.stream.order 

/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.order   direction=drainage  stream_rast=stream  strahler=strahler horton=horton shreve=shreve hack=hack topo=topo memory=20000
g.list rast 



r.out.gdal --overwrite -c  createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32 format=GTiff nodata=0      input=stream output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/streamKM/stream${UNIT}_trh$TRH.tif

r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=Int16  format=GTiff nodata=-99    input=drainage output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/drainageKM/drainage${UNIT}_trh$TRH.tif 
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9"             format=GTiff nodata=-999999999      input=accumulation output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/accumulationKM/accumulation${UNIT}_trh$TRH.tif #in automatic Flat64 and nodata 

r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin/basinKM${UNIT}_trh$TRH.tif   
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin_last output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin_last/basin_lastKM${UNIT}_trh$TRH.tif
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin_elem output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin_elem/basin_elemKM${UNIT}_trh$TRH.tif

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/*/*trh$TRH.tif.aux.xml 

# rm -fr /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unitKM$UNIT
