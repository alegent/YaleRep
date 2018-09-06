#!/bin/bash
#SBATCH -p day 
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 10:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc05_dem_variables_float_noMult_equi7.sh.%A_%a.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc05_dem_variables_float_noMult_equi7.sh.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc05_dem_variables_float_noMult_equi7.sh
#SBATCH --array=1-853

# 853    number of files 
# bash    /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc05_dem_variables_float_noMult_equi7.sh
# sbatch  /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc05_dem_variables_float_noMult_equi7.sh  

module load Apps/GRASS/7.3-beta

# file=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem/EU/EU_048_000.tif

file=$(ls /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem/??/??_???_???.tif | head -n $SLURM_ARRAY_TASK_ID | tail -1 )
# use this if one file is missing

MERIT=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT
SCRATCH=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/MERIT
RAM=/dev/shm
filename=$(basename $file .tif )
CT=${filename:0:2}
echo filename  $filename
echo file $filename.tif  SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID 

ulx=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]"," ") ; printf ("%.16f" ,  $3  - (8 * 100 )) }')
uly=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]"," ") ; printf ("%.16f" ,  $4  + (8 * 100 )) }')
lrx=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]"," ") ; printf ("%.16f" ,  $3  + (8 * 100 )) }')
lry=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]"," ") ; printf ("%.16f" ,  $4  - (8 * 100 )) }')

echo $ulx $uly $lrx $lry
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin  $ulx $uly $lrx $lry  $MERIT/equi7/dem/${CT}/all_${CT}_tif.vrt  $RAM/$filename.tif 
pksetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $RAM/$filename.tif   -msknodata -9999 -nodata 0 -i $RAM/$filename.tif -o $RAM/${filename}_0.tif
gdal_edit.py  -a_nodata -9999 $RAM/${filename}_0.tif



rm -rf $RAM/loc_$filename 

source /gpfs/home/fas/sbsc/ga254/scripts/general/create_location_grass7.3-grace2.sh    $RAM loc_$filename   $RAM/${filename}_0.tif 

filename=$( basename  $file _0.tif )  # necessario per sovrascirve il filename di create location

r.in.gdal in=$RAM/$filename.tif   out=$filename --overwrite  memory=2000 # used later as mask

r.slope.aspect elevation=${filename}_0   precision=FCELL   dx=dx_$filename 

# setting up the g.region to the initial tile size before to exprot 
ulxG=$(echo $ulx  | awk '{  printf ("%.16f" ,  $1  + (8 * 100 )) }')
ulyG=$(echo $uly  | awk '{  printf ("%.16f" ,  $1  - (8 * 100 )) }')
lrxG=$(echo $lrx  | awk '{  printf ("%.16f" ,  $1  - (8 * 100 )) }')
lryG=$(echo $lry  | awk '{  printf ("%.16f" ,  $1  + (8 * 100 )) }')

echo g.region w=$ulxG e=$lrxG n=$ulyG s=$lryG 
g.region      w=$ulxG e=$lrxG n=$ulyG s=$lryG 
r.mask  raster=$filename   --o 

# r.slope.aspect 
for var in  dx  ; do  
r.colors -r map=${var}_${filename} 
r.out.gdal -c -f  -m     createopt="COMPRESS=DEFLATE,ZLEVEL=9,PROFILE=GeoTIFF,INTERLEAVE=BAND" format=GTiff  type=Float32   nodata=-9999  input=${var}_$filename       output=$SCRATCH/${var}/tiles/${filename}.tif   --o
gdal_edit.py  -a_nodata -9999 $SCRATCH/${var}/tiles/${filename}.tif 
rm -f $SCRATCH/${var}/tiles/${filename}.tif.aux.xml
done 


##############################

rm -rf $RAM/loc_$filename   $RAM/${filename}.tif.aux.xml   $RAM/${filename}.tif   $RAM/$filename.vrt   $RAM/${filename}_0.tif 






