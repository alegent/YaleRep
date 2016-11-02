# for UNIT in 90420 10328 80691 84397 2285 26487 33778 92404 11000 11001 98343 91518 ; do qsub -v UNIT=$UNIT  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc5_river_newtworkGMTED250.sh ; done 

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
#PBS -q fas_normal
#PBS -l walltime=0:24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# madagascar 
UNIT=90420
TRH=$1

echo $TRH

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9   -projwin    $(getCorners4Gtranslate   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT${UNIT}msk.tif )  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_250m_from_30m4326/GIW_water_250m_bordermsk_ct.tif   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/GIW_water/GWI_UNIT${UNIT}.tif

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9   -projwin    $(getCorners4Gtranslate   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT${UNIT}msk.tif ) /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/dem/be75_grd_LandEnlarge_cond_carv.tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/dem/cond_carv_UNIT${UNIT}.tif  

source /lustre/home/client/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT 

cp  $HOME/.grass7/grass$$     $HOME/.grass7/rc$UNIT


echo create mapset unit$UNIT

rm -fr /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unit$UNIT

g.mapset  -c   mapset=unit$UNIT   location=loc_river   dbase=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb   --quiet --overwrite 

cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT/WIND /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unit$UNIT/WIND

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unit$UNIT/.gislock

g.gisenv 

r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT${UNIT}msk.tif   out=UNIT$UNIT   --overwrite
g.region raster=UNIT$UNIT

r.mask   rast=UNIT$UNIT  --overwrite

echo start r.watershed 

echo starting use treshold $TRH $TRH  $TRH  $TRH                                   # also cal direction 

r.watershed  elevation=be75_grd_LandEnlarge_cond_carv  basin=basin  stream=stream    drainage=drainage    accumulation=accumulation tci=tci  memory=20000  threshold=$TRH   --overwrite   

echo r.stream.basins 

/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.basins  direction=drainage  stream_rast=stream  basins=basin_last  -l  --o memory=20000
/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.basins  direction=drainage  stream_rast=stream  basins=basin_elem  --o     memory=20000

/lustre/home/client/fas/sbsc/ga254/.grass7/addons/bin/r.stream.order   direction=drainage  stream_rast=stream  strahler=strahler horton=horton shreve=shreve hack=hack topo=topo memory=20000
g.list rast 

# NUM_THREADS=number_of_threads/ALL_CPUS

r.out.gdal --overwrite -c  createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32 format=GTiff nodata=0      input=stream output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/stream/stream${UNIT}_trh$TRH.tif

r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=Int16  format=GTiff nodata=-99    input=drainage output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/drainage/drainage${UNIT}_trh$TRH.tif 
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9"             format=GTiff nodata=-999999999      input=accumulation output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/accumulation/accumulation${UNIT}_trh$TRH.tif #in automatic Flat64 and nodata 

r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin/basin${UNIT}_trh$TRH.tif   
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin_last output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin_last/basin_last${UNIT}_trh$TRH.tif
r.out.gdal --overwrite  -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt32       format=GTiff nodata=0 input=basin_elem output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/basin_elem/basin_elem${UNIT}_trh$TRH.tif

r.out.gdal --overwrite -c createopt="COMPRESS=DEFLATE,ZLEVEL=9"        format=GTiff nodata=-1  input=tci output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/tci/tci${UNIT}_trh$TRH.tif

# stream order 

r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=strahler     output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/strahler/strahler${UNIT}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=horton       output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/horton/horton${UNIT}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=shreve       output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/shreve/shreve${UNIT}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=hack         output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/hack/hack${UNIT}_trh$TRH.tif
r.out.gdal --overwrite   -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=UInt16   format=GTiff nodata=0   input=topo         output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/topo/topo${UNIT}_trh$TRH.tif

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/output/*/*trh$TRH.tif.aux.xml 

rm -fr /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river/unit$UNIT
