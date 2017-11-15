#!/bin/bash
#SBATCH -p scavenge
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 3:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_dem_variables_float_noMult.sh.%A_%a.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_dem_variables_float_noMult.sh.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc03_dem_variables_float_noMult.sh

###SBATCH --array=1-1150

# for file in /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/n30w090_dem.tif  ; do   sbatch --export=file=$file   /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc03_dem_variables_float_noMult.sh  ; done 
# bash /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc03_dem_variables_float_noMult.sh /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/n30w090_dem.tif 
# nodata pixe in 1927385 n30w090_dem.tif 

# 1150 number of files 
# sbatch   /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc03_dem_variables_float_noMult.sh  

# for dir in dx dxx dxy dy dyy pcurv roughness slope tcurv tpi tri vrm ; do join -v  1    -1 1 -2 1 <(ls *.tif | sort ) <( ls        /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/$dir/tiles/  | sort ) ; done | sort | uniq  > /tmp/file_missing.txt 
# for tif in  $( cat /tmp/file_missing.txt )  ; do sbatch  --export=tif=$tif   /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc03_dem_variables_float_noMult.sh   ; done
file=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/$tif 

# file=$(ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/*.tif  | tail -n  $SLURM_ARRAY_TASK_ID | head -1 )
# use this if one file is missing 

MERIT=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT
RAM=/dev/shm
filename=$(basename $file .tif )
echo filename  $filename 
echo file $filename.tif  SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID 

### take the coridinates from the orginal files and increment on 1 pixels

ulx=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $3  - (8 * 0.000833333333333 )) }')
uly=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $4  + (8 * 0.000833333333333 )) }')
lrx=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $3  + (8 * 0.000833333333333 )) }')
lry=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]","") ; printf ("%.16f" ,  $4  - (8 * 0.000833333333333 )) }')

echo $ulx $uly $lrx $lry  # vrt is needed to clip before to create the tif 
gdalbuildvrt -overwrite -te $ulx $lry  $lrx $uly    $RAM/$filename.vrt  $MERIT/input_tif/all_tif.vrt   
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -a_ullr $ulx $uly $lrx $lry  $RAM/$filename.vrt   $RAM/$filename.tif 
pksetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $RAM/$filename.tif   -msknodata -9999 -nodata 0 -i $RAM/$filename.tif -o $RAM/${filename}_0.tif
gdal_edit.py  -a_nodata -9999 $RAM/${filename}_0.tif

# # echo slope with $file

# # -s to consider xy in degree and z in meters
# gdaldem slope    -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${filename}_0.tif   $RAM/slope_${filename}_0.tif 
# gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/slope_${filename}_0.tif $RAM/slope_${filename}_crop.tif     
# pksetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $RAM/$filename.tif  -msknodata -9999 -nodata -9999 -i $RAM/slope_${filename}_crop.tif  -o $MERIT/slope/tiles/${filename}.tif  
# rm -f $RAM/slope_${filename}_crop.tif $RAM/slope_${filename}_0.tif

# echo  aspect  with file $file 

# gdaldem aspect   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND $RAM/${filename}_0.tif   $RAM/aspect_${filename}_0.tif 
# gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/aspect_${filename}_0.tif $RAM/aspect_${filename}_crop.tif
# pksetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $RAM/$filename.tif  -msknodata -9999 -nodata -9999 -i $RAM/aspect_${filename}_crop.tif  -o $MERIT/aspect/tiles/${filename}.tif
# rm -f $RAM/aspect_${filename}_crop.tif $RAM/aspect_${filename}_0.tif

# echo sin and cos of slope and aspect $file 

# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $MERIT/aspect/tiles/${filename}.tif --calc="(sin(A.astype(float) * 3.141592 / 180))" --outfile   $MERIT/aspect/tiles/${filename}_sin.tif --overwrite --type=Float32
# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $MERIT/aspect/tiles/${filename}.tif --calc="(cos(A.astype(float) * 3.141592 / 180))" --outfile   $MERIT/aspect/tiles/${filename}_cos.tif --overwrite --type=Float32
# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $MERIT/slope/tiles/${filename}.tif  --calc="(sin(A.astype(float) * 3.141592 / 180))" --outfile   $MERIT/slope/tiles/${filename}_sin.tif  --overwrite --type=Float32
# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $MERIT/slope/tiles/${filename}.tif  --calc="(cos(A.astype(float) * 3.141592 / 180))" --outfile   $MERIT/slope/tiles/${filename}_cos.tif  --overwrite --type=Float32

# echo   Ew  Nw   median  

# gdal_calc.py --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A $MERIT/slope/tiles/${filename}.tif -B $MERIT/aspect/tiles/${filename}_sin.tif --calc="((sin(A.astype(float) * 3.141592 / 180)) * B.astype(float))" --outfile  $MERIT/aspect/tiles/${filename}_Ew.tif --overwrite --type=Float32
# gdal_calc.py --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A $MERIT/slope/tiles/${filename}.tif -B $MERIT/aspect/tiles/${filename}_cos.tif --calc="((sin(A.astype(float) * 3.141592 / 180)) * B.astype(float))" --outfile  $MERIT/aspect/tiles/${filename}_Nw.tif --overwrite --type=Float32

# echo  generate a Terrain Ruggedness Index TRI  with file   $file 
# gdaldem TRI -co COMPRESS=DEFLATE -co ZLEVEL=9  -co INTERLEAVE=BAND  $RAM/${filename}_0.tif   $RAM/tri_${filename}_0.tif
# gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/tri_${filename}_0.tif $RAM/tri_${filename}_crop.tif
# pksetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $RAM/$filename.tif  -msknodata -9999 -nodata -9999 -i $RAM/tri_${filename}_crop.tif -o $MERIT/tri/tiles/${filename}.tif
# rm -f $RAM/tri_${filename}_crop.tif $RAM/tri_${filename}_0.tif

# echo  generate a Topographic Position Index TPI  with file  $filename.tif
# gdaldem TPI -co COMPRESS=DEFLATE -co ZLEVEL=9  -co INTERLEAVE=BAND  $RAM/${filename}_0.tif   $RAM/tpi_${filename}_0.tif
# gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/tpi_${filename}_0.tif $RAM/tpi_${filename}_crop.tif
# pksetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $RAM/$filename.tif  -msknodata -9999 -nodata -9999 -i $RAM/tpi_${filename}_crop.tif -o $MERIT/tpi/tiles/${filename}.tif
# rm -f $RAM/tpi_${filename}_crop.tif $RAM/tpi_${filename}_0.tif

# echo  generate roughness   with file   $filename.tif
# gdaldem roughness -co COMPRESS=DEFLATE -co ZLEVEL=9  -co INTERLEAVE=BAND  $RAM/${filename}_0.tif   $RAM/roughness_${filename}_0.tif
# gdal_translate   -srcwin 8 8 6000 6000  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/roughness_${filename}_0.tif $RAM/roughness_${filename}_crop.tif
# pksetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -m $RAM/$filename.tif  -msknodata -9999 -nodata -9999 -i $RAM/roughness_${filename}_crop.tif -o $MERIT/roughness/tiles/${filename}.tif
# rm -f $RAM/roughness_${filename}_crop.tif $RAM/roughness_${filename}_0.tif


#  calculate TCI and SPI  https://grass.osgeo.org/grass73/manuals/r.watershed.html 
# TCI  topographic index ln(a / tan(b)) map 
# SPI  Stream power index a * tan(b) 




exit 



# ###############  VRM  ########################################

rm -rf $RAM/loc_$filename 

source /gpfs/home/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2-grace2.sh   $RAM loc_$filename   $RAM/${filename}_0.tif 

filename=$( basename  $file _0.tif )  # necessario per sovrascirve il filename di create location

r.in.gdal in=$RAM/$filename.tif   out=$filename --overwrite  memory=2000 # used later as mask

# /gpfs/home/fas/sbsc/ga254/.grass7/addons/scripts/r.vector.ruggedness elevation=${filename}_0   output=vrm_${filename}  --overwrite 

##   intensity   Rasters containing mean relative elevation of the form
##  exposition   Rasters containing maximum difference between extend and central cell
##       range   Rasters containing difference between max and min elevation of the form extend
##    variance   Rasters containing variance of form boundary
##  elongation   Rasters containing local elongation
##     azimuth   Rasters containing local azimuth of the elongation
##      extend   Rasters containing local extend (area) of the form
##       width   Rasters containing local width of the form


/gpfs/home/fas/sbsc/ga254/.grass7/addons/bin/r.geomorphon  elevation=${filename}_0 forms=forms_$filename  intensity=intensity_$filename  exposition=exposition_$filename  range=range_$filename  variance=variance_$filename  elongation=elongation_$filename azimuth=azimuth_$filename   extend=extend_$filename  width=width_$filename   search=3 skip=0 flat=1 dist=0 step=0 start=0 --overwrite

#  r.slope.aspect elevation=${filename}_0   precision=FCELL  pcurvature=pcurv_$filename tcurvature=tcurv_$filename dx=dx_$filename dxx=dxx_$filename  dy=dy_$filename dyy=dyy_$filename  dxy=dxy_$filename

ulxG=$(echo $ulx  | awk '{  printf ("%.16f" ,  $1  + (8 * 0.000833333333333 )) }')
ulyG=$(echo $uly  | awk '{  printf ("%.16f" ,  $1  - (8 * 0.000833333333333 )) }')
lrxG=$(echo $lrx  | awk '{  printf ("%.16f" ,  $1  - (8 * 0.000833333333333 )) }')
lryG=$(echo $lry  | awk '{  printf ("%.16f" ,  $1  + (8 * 0.000833333333333 )) }')

echo g.region w=$ulxG e=$lrxG n=$ulyG s=$lryG 
g.region      w=$ulxG e=$lrxG n=$ulyG s=$lryG 
r.mask  raster=$filename   --o 

# # r.vector.ruggedness 
# r.colors -r map=vrm_${filename}  
# r.out.gdal -c  -f  createopt="COMPRESS=DEFLATE,ZLEVEL=9,PROFILE=GeoTIFF,INTERLEAVE=BAND" format=GTiff type=Float32  nodata=-9999  input=vrm_${filename}  output=$MERIT/vrm/tiles/${filename}.tif  --o
# gdal_edit.py  -a_nodata -9999 $MERIT/vrm/tiles/${filename}.tif
# rm -f $MERIT/vrm/tiles/${filename}.tif.aux.xml

# # r.geomorphon forms 
# r.colors -r map=forms_${filename} 
# r.out.gdal -c -f createopt="COMPRESS=DEFLATE,ZLEVEL=9,PROFILE=GeoTIFF,INTERLEAVE=BAND" format=GTiff type=Byte nodata=0 input=forms_$filename  output=$RAM/${filename}.tif 

# pkcreatect  -min 0 -max 10   > $RAM/color${filename}.txt
# pkcreatect   -co COMPRESS=DEFLATE -co ZLEVEL=9   -ct  $RAM/color${filename}.txt   -i $RAM/${filename}.tif  -o $MERIT/forms/tiles/${filename}.tif  
# gdal_edit.py  -a_nodata 0  $MERIT/forms/tiles/${filename}.tif 
# rm $RAM/${filename}.tif   $RAM/color${filename}.txt

# r.geomorphon intensity

for geo in intensity exposition range variance elongation azimuth extend width ; do               
r.colors -r map=${geo}_${filename}
r.out.gdal -c -f createopt="COMPRESS=DEFLATE,ZLEVEL=9,PROFILE=GeoTIFF,INTERLEAVE=BAND" format=GTiff type=Float32 nodata=-9999  input=${geo}_$filename  output=$MERIT/${geo}/tiles/${filename}.tif
gdal_edit.py  -a_nodata -9999  $MERIT/${geo}/tiles/${filename}.tif
rm -f $MERIT/${geo}/tiles/${filename}.tif.aux.xml
done 

# # r.slope.aspect 
# for var in  dx dxx dy dyy dxy tcurv pcurv ; do  
# r.colors -r map=${var}_${filename} 
# r.out.gdal -c -f     createopt="COMPRESS=DEFLATE,ZLEVEL=9,PROFILE=GeoTIFF,INTERLEAVE=BAND" format=GTiff  type=Float32   nodata=-9999  input=${var}_$filename       output=$MERIT/${var}/tiles/${filename}.tif   --o ; 
# gdal_edit.py  -a_nodata -9999 $MERIT/${var}/tiles/${filename}.tif 
# rm -f $MERIT/${var}/tiles/${filename}.tif.aux.xml
# done 

rm -rf $RAM/loc_$filename   $RAM/${filename}.tif.aux.xml   $RAM/${filename}.tif   $RAM/$filename.vrt   $RAM/${filename}_0.tif 

exit 

ls  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/*/tiles/*.tif | xargs -n 1 -P 4  bash -c $' echo $(pkstat  -src_min -9999.5 -src_max -9999  -hist  -i $1) $1     ' _


# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Int16   nodata=-9999  input=ternary_$filename       output=$MERIT/ternary/${filename}.tif   --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Byte    nodata=-9999  input=positive_$filename      output=$MERIT/positive/${filename}.tif  --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Byte    nodata=-9999  input=negative_$filename      output=$MERIT/negative/${filename}.tif  --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=-9999  input=intensity_$filename     output=$MERIT/intensity/${filename}.tif --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Int16   nodata=-9999  input=exposition_$filename    output=$MERIT/exposition/${filename}.tif  --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=UInt16  nodata=-9999  input=range_$filename         output=$MERIT/range/${filename}.tif        --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=-9999  input=variance_$filename      output=$MERIT/variance/${filename}.tif     --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=-9999  input=elongation_$filename    output=$MERIT/elongation/${filename}.tif   --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=-9999  input=azimuth_$filename       output=$MERIT/azimuth/${filename}.tif  --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=-9999  input=extend_$filename        output=$MERIT/extend/${filename}.tif  --o
# r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=-9999  input=with_$filename          output=$MERIT/with/${filename}.tif   --o

