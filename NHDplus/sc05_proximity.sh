#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 2 -N 1
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc05_proximity.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc05_proximity.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc05_proximity.sh


# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NHDplus/sc05_proximity.sh



export DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NHDplus

# Upper Left  (-126.0000000,  51.0000000) (126d 0' 0.00"W, 51d 0' 0.00"N)
# Lower Left  (-126.0000000,  25.0000000) (126d 0' 0.00"W, 25d 0' 0.00"N)
# Upper Right ( -66.0000000,  51.0000000) ( 66d 0' 0.00"W, 51d 0' 0.00"N)
# Lower Right ( -66.0000000,  25.0000000) ( 66d 0' 0.00"W, 25d 0' 0.00"N)

echo east west | xargs -n 1 -P 2 bash -c $' 
zone=$1 
if [ $zone = "east" ] ; then geostring=" -97 25 -66 51" ; fi 
if [ $zone = "west" ] ; then geostring="-126 25 -95 51" ; fi 

gdalbuildvrt  -overwrite   -te   $geostring  $DIR/tif_merge/NHDplus_90m_$1.vrt    $DIR/tif_merge/NHDplus_90m.tif

gdal_proximity.py -of  GTiff   -ot  Int16  -distunits PIXEL  -values 1 -nodata 0  -maxdist 10   $DIR/tif_merge/NHDplus_90m_$1.vrt $DIR/tif_merge/NHDplus_90m_$1.tif

if [ $zone = "east" ] ; then geostring=" -96 25 -66 51" ; fi 
if [ $zone = "west" ] ; then geostring="-126 25 -96 51" ; fi 

gdalbuildvrt  -overwrite    -te   $geostring  $DIR/tif_merge/NHDplus_90m_$1.vrt   $DIR/tif_merge/NHDplus_90m_$1.tif

' _ 

gdalbuildvrt  -overwrite  $DIR/tif_merge/NHDplus_90m.vrt        $DIR/tif_merge/NHDplus_90m_west.vrt  $DIR/tif_merge/NHDplus_90m_east.vrt
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9    $DIR/tif_merge/NHDplus_90m.vrt     $DIR/tif_merge/NHDplus_90m_proximity.tif 

rm   $DIR/tif_merge/NHDplus_90m.vrt     $DIR/tif_merge/NHDplus_90m_west.vrt  $DIR/tif_merge/NHDplus_90m_east.vrt $DIR/tif_merge/NHDplus_90m_{east,west}.tif
