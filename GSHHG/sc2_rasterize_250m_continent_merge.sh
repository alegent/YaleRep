# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/GSHHG/sc2_rasterize_250m_continent_merge.sh  
# transferire grassdb in /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m_continent_merge
#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=12:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# 0-E EUROASIA EAST
# 0-W EUROASIA WEST
# 1 africa 
# 2 NA
# 3 SA
# 4 ?
# 5 ?
# 6 AU
# 7 GL
# 8 NZ
# 9 BR
# 10 MG


echo start 

echo   0-W 0-E 1 2 3 6 7  | xargs -n 1 -P 8 bash -c $' 

ID=$1

TIFIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m_continent/
TIFOUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m_continent_merge 

echo $ID 

# gdalbuildvrt -overwrite -o  $TIFIN/continent$ID.vrt    $TIFIN/h*v*_250m_continen$ID.tif

# put color table to visualize better in openev 

# pkcreatect  -min 0 -max 1 > /tmp/color.txt
# pkcreatect -of  GTiff  -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9    -ct /tmp/color.txt -i  $TIFIN/continent$ID.vrt  -o  $TIFOUT/continent${ID}_ct.tif 

echo start oft-bb
geo_string=$( oft-bb  $TIFOUT/continent${ID}_ct.tif 1  |  grep "Band 1"  |  awk \'{ print $6 , $7 , $8-$6 , $9-$7  }\'   ) 

echo geo_string  $geo_string 

gdal_translate  -srcwin $geo_string      -co COMPRESS=DEFLATE -co ZLEVEL=9    $TIFOUT/continent${ID}_ct.tif    $TIFOUT/continent${ID}_ct_crop.tif 

rm -rf /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/grassdb/loc_cont$ID
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/grassdb loc_cont$ID   $TIFOUT/continent${ID}_ct_crop.tif 
r.grow  input=continent${ID}_ct_crop   output=continent${ID}_ct_crop_enlarge4    radius=4.01
r.out.gdal  --overwrite -f  -c  createopt="COMPRESS=LZW,BIGTIFF=YES" format=GTiff type=Byte  input=continent${ID}_ct_crop  output=$TIFOUT/continent${ID}_crop_enlarge4.tif 

rm -rf  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/grassdb/loc_cont$ID

pkcreatect  -min 0 -max 1 > /tmp/color.txt
pkcreatect -of  GTiff  -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /tmp/color.txt -i  $TIFOUT/continent${ID}_crop_enlarge4.tif -o $TIFOUT/continent${ID}_crop_enlarge4_ct.tif 

' _ 

