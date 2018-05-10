#!/bin/bash
#SBATCH -p scavenge
#SBATCH -J sc01_Nemision_cdo.sh
#SBATCH -n 1 -c 8 -N 1  
#SBATCH -t 24:00:00  
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc01_Nemision_cdo.sh.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc01_Nemision_cdo.sh.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --mem-per-cpu=5000

# sbatch  /gpfs/home/fas/sbsc/ga254/scripts/NP/sc01_Nemision_cdo.sh

module load Tools/CDO/1.7.2
export DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/FLOK1

# cdo -P 8 timmax   $DIR/FLO1K.ts.1960.2015.qmi.nc   $DIR/FLO1K.ts.1960.2015.qma_maxCDO.nc
# cdo -P 8 timmean  $DIR/FLO1K.ts.1960.2015.qmi.nc   $DIR/FLO1K.ts.1960.2015.qav_meanCDO.nc

cdo -P 8 timmin  $DIR/FLO1K.ts.1960.2015.qmi.nc   $DIR/FLO1K.ts.1960.2015.qmi_minCDO.nc

cdo  -P 8  invertlat    $DIR/FLO1K.ts.1960.2015.qav_meanCDO.nc   $DIR/FLO1K.ts.1960.2015.qav_meanCDO_invertlat.nc
cdo  -P 8  invertlat    $DIR/FLO1K.ts.1960.2015.qma_maxCDO.nc    $DIR/FLO1K.ts.1960.2015.qma_maxCDO_invertlat.nc
cdo  -P 8  invertlat    $DIR/FLO1K.ts.1960.2015.qmi_minCDO.nc    $DIR/FLO1K.ts.1960.2015.qmi_minCDO_invertlat.nc


# export GDAL_NETCDF_BOTTOMUP=NO 

gdal_translate --config GDAL_CACHEMAX 30000  -co NUM_THREADS=8  -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/FLO1K.ts.1960.2015.qav_meanCDO_invertlat.nc  $DIR/FLO1K.ts.1960.2015.qav_mean.tif  
gdal_translate --config GDAL_CACHEMAX 30000  -co NUM_THREADS=8  -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/FLO1K.ts.1960.2015.qma_maxCDO_invertlat.nc   $DIR/FLO1K.ts.1960.2015.qma_max.tif  
gdal_translate --config GDAL_CACHEMAX 30000  -co NUM_THREADS=8  -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/FLO1K.ts.1960.2015.qmi_minCDO_invertlat.nc   $DIR/FLO1K.ts.1960.2015.qmi_min.tif  

rm  $DIR/FLO1K.ts.1960.2015.qav_meanCDO_invertlat.nc $DIR/FLO1K.ts.1960.2015.qma_maxCDO_invertlat.nc  $DIR/FLO1K.ts.1960.2015.qmi_minCDO_invertlat.nc 
exit 
