#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 4 -N 1  
#SBATCH -t 2:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc01_dif_derivative.sh.%A_%a.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc01_dif_derivative.sh.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc01_dif_derivative.sh
#SBATCH --array=1-193

# # bash /gpfs/home/fas/sbsc/ga254/scripts/NED_MERIT/sc01_dif_derivative.sh /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED/input_tif/n10w095.tif

# 197 number of files 
# sbatch   /gpfs/home/fas/sbsc/ga254/scripts/NED_MERIT/sc01_dif_derivative.sh

module load Apps/GRASS/7.3-beta

## create  vrt 
## cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED
## cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT 
## for VAR in dx dxx dxy dy dyy pcurv roughness  tcurv  tpi  tri vrm spi tci convergence  intensity exposition range variance elongation azimuth extend width   ; do   gdalbuildvrt $VAR/tiles/all_tif.vrt $VAR/tiles/*.tif ; done

file=$(ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED/input_tif/*.tif  | head  -n  $SLURM_ARRAY_TASK_ID | tail  -1 )
#  file=$1
# use this if one file is missing 

export  NED=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED
export  MERIT=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT
export     NM=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED_MERIT
export    RAM=/dev/shm

export filename=$(basename $file .tif )

echo filename  $filename 
echo file $filename.tif  SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID 

### take the coridinates from the orginal files and increment on 8  pixels

export ulx=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $3  - (8 * 0.000833333333333 )) }')
export uly=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $4  + (8 * 0.000833333333333 )) }')
export lrx=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $3  + (8 * 0.000833333333333 )) }')
export lry=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $4  - (8 * 0.000833333333333 )) }')

# echo slope dx dxx dxy dy dyy pcurv roughness tcurv tpi tri vrm spi tci convergence  intensity exposition range variance elongation azimuth extend width | xargs -n 1 -P 4 bash -c $'

# VAR=$1

# gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin $ulx $uly $lrx $lry   $MERIT/$VAR/tiles/all_tif.vrt $RAM/${filename}_${VAR}_M.tif 
# gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin $ulx $uly $lrx $lry   $NED/$VAR/tiles/all_tif.vrt   $RAM/${filename}_${VAR}_N.tif 

# echo slope with $file

# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A   $RAM/${filename}_${VAR}_M.tif -B   $RAM/${filename}_${VAR}_N.tif \
# --calc="( A.astype(float) - B.astype(float) )" --outfile   $RAM/${filename}_${VAR}_dif.tif --overwrite --type=Float32

# gdaldem slope -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${filename}_${VAR}_dif.tif $RAM/${filename}_${VAR}_der.tif 
# gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND $RAM/${filename}_${VAR}_der.tif $NM/${VAR}/tiles/${filename}.tif  

# rm -f  $RAM/${filename}_${VAR}_?.tif   $RAM/${filename}_${VAR}_dif.tif  $RAM/${filename}_${VAR}_der.tif      

# ' _ 


# echo sin cos Nw Ew  | xargs -n 1 -P 4 bash -c $'

# VAR=$1

# gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin $ulx $uly $lrx $lry $MERIT/aspect/tiles/all_tif_$VAR.vrt $RAM/${filename}_${VAR}_M.tif 
# gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin $ulx $uly $lrx $lry   $NED/aspect/tiles/all_tif_$VAR.vrt $RAM/${filename}_${VAR}_N.tif 

# echo slope with $file

# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A   $RAM/${filename}_${VAR}_M.tif -B   $RAM/${filename}_${VAR}_N.tif \
# --calc="( A.astype(float) - B.astype(float) )" --outfile   $RAM/${filename}_${VAR}_dif.tif --overwrite --type=Float32

# gdaldem slope -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${filename}_${VAR}_dif.tif $RAM/${filename}_${VAR}_der.tif 
# gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND $RAM/${filename}_${VAR}_der.tif $NM/aspect/tiles/${filename}_$VAR.tif  

# rm -f  $RAM/${filename}_${VAR}_?.tif   $RAM/${filename}_${VAR}_dif.tif  $RAM/${filename}_${VAR}_der.tif      

# ' _ 


# just the elevation  
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin $ulx $uly $lrx $lry $MERIT/input_tif/all_tif.vrt $RAM/${filename}_M.tif
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin $ulx $uly $lrx $lry   $NED/input_tif/all_tif.vrt $RAM/${filename}_N.tif

echo slope with $file

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A   $RAM/${filename}_M.tif -B   $RAM/${filename}_N.tif \
--calc="( A.astype(float) - B.astype(float) )" --outfile   $RAM/${filename}_dif.tif --overwrite --type=Float32

gdaldem slope -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${filename}_dif.tif $RAM/${filename}_der.tif
gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND $RAM/${filename}_dif.tif $NM/input_tif/tiles/${filename}_dif.tif
gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND $RAM/${filename}_der.tif $NM/input_tif/tiles/${filename}.tif

rm -f  $RAM/${filename}_?.tif   $RAM/${filename}_dif.tif  $RAM/${filename}_der.tif
