# qsub /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/scripts/sc03_enlarge_cost.sh

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# full process more than 4 our

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad
# # rm -rf DIR/grassdb/cost
# source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  $DIR/grassdb cost  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct.tif

source /lustre/home/client/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh  $DIR/grassdb/cost/PERMANENT

# g.rename   raster=GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct,core

# r.in.gdal in=$DIR/../GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84.tif   output=impervius    --overwrite
# r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_1km_v2.3.0/land_mask_m10fltGSHHS_f_L1.tif    output=mask         --overwrite

r.grow  input=mask   output=mask_enlarge   old=1 new=1   radius=4.01

g.region rast=impervius
#  g.region n=50 s=30 w=-100 e=-80 
r.mask raster=mask_enlarge  --overwrite

r.grow  input=core   output=core_enlarge   old=1 new=1   radius=1.01

# r.mapcalc " impervius_neg =  ( 1 - impervius )   "  --overwrite

r.cost -k input=impervius_neg output=impervius_cost start_raster=core_enlarge  --overwrite

r.out.gdal --overwrite   -c  -f   createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=Float32 format=GTiff nodata=-1 input=impervius_cost  output=$DIR/impervius_cost.tif 
r.out.gdal --overwrite   -c  -f   createopt="COMPRESS=DEFLATE,ZLEVEL=9" type=Byte    format=GTiff nodata=0  input=core_enlarge    output=$DIR/markers.tif 


