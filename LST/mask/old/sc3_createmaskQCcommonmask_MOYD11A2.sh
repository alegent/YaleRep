# for DAY in $(cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  ) ; do qsub -v DAY=$DAY,SENS=MOD /u/gamatull/scripts/LST/mask/sc3_createmaskQCcommonmask_MOYD11A2.sh   ; done

# reclassification based on the qc of the yearly data 46 *12 

#PBS -S /bin/bash
#PBS -q normal 
#PBS -l select=1:ncpus=8
#PBS -l walltime=6:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

export DAY=$DAY
export SENS=$SENS
export DN=$DN
export INSENS=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.005/${SENS}11A2
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk 

export RAMDIR=/dev/shm

echo start the mask  for $DAY 

rm -f  $RAMDIR/*.tif

echo  reclass the water sea 

ls $INSENS/*/${SENS}11A2.A*${DAY}_${DN}.tif | xargs -n 1 -P 20 bash -c $' 
file=$1
YEAR=$(basename $(dirname $file)) 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9  -ot Byte  -b 2 $file   $RAMDIR/${SENS}${YEAR}_b2SEA_day${DAY}.tif
/home6/gamatull/pktools-2.6.2/bin/pkreclass  -code  /nobackupp8/gamatull/dataproces/LST/geo_file/reclas_mask_sea.txt    -nodata 0 -ot Byte -co  COMPRESS=LZW -co ZLEVEL=9 -i  $RAMDIR/${SENS}${YEAR}_b2SEA_day${DAY}.tif -o  $RAMDIR/${SENS}${YEAR}_SEA_day${DAY}.tif 
rm -f  $RAMDIR/${SENS}${YEAR}_b2SEA_day${DAY}.tif
' _

pkcomposite $(ls $RAMDIR/${SENS}????_SEA_day${DAY}.tif  | xargs -n 1 echo -i )   -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -cr min  -o $RAMDIR/${SENS}_SEA_mask_day${DAY}.tif 
gdal_translate   -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin 0 0 43200 21600  $RAMDIR/${SENS}_SEA_mask_day${DAY}.tif   $OUTSENS/${SENS}_SEA_mask_day${DAY}_${DN}.tif 

rm -f $RAMDIR/${SENS}????_SEA_day${DAY}.tif 

echo  reclass the lst 

ls $INSENS/*/${SENS}11A2.A*${DAY}_${DN}.tif | xargs -n 1 -P 20 bash -c $' 
file=$1
YEAR=$(basename $(dirname $file)) 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9  -ot Byte  -b 2 $file   $RAMDIR/${SENS}${YEAR}_b2LST3k_day${DAY}.tif
/home6/gamatull/pktools-2.6.2/bin/pkreclass  -code /nobackupp8/gamatull/dataproces/LST/geo_file/reclas_mask_lst3k.txt        -nodata 0 -ot Byte -co  COMPRESS=LZW -co ZLEVEL=9 -i  $RAMDIR/${SENS}${YEAR}_b2LST3k_day${DAY}.tif -o  $RAMDIR/${SENS}${YEAR}_LST3k_day${DAY}.tif
rm -f $RAMDIR/${SENS}${YEAR}_b2LST3k_day${DAY}.tif 
' _

echo start the composite for LST

pkcomposite $(ls $RAMDIR/${SENS}????_LST3k_day${DAY}.tif  | xargs -n 1 echo -i ) -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -cr min   -o $RAMDIR/${SENS}_LST3k_mask_day${DAY}.tif  
gdal_translate   -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin 0 0 43200 21600  $RAMDIR/${SENS}_LST3k_mask_day${DAY}.tif  $OUTSENS/${SENS}_LST3k_mask_day${DAY}_${DN}.tif 

rm -f $RAMDIR/${SENS}????_LST3k_day${DAY}.tif rm -f $RAMDIR/*.tif 

echo combine 

pkcomposite   -i $OUTSENS/${SENS}_LST3k_mask_day${DAY}_${DN}.tif  -i  $OUTSENS/${SENS}_SEA_mask_day${DAY}_${DN}.tif  -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -cr max   -o $OUTSENS/${SENS}_CLOUD3k_day${DAY}_${DN}.tif
 

# warp section 
gdalwarp -overwrite   -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90   -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9 \
$OUTSENS/${SENS}_CLOUD3k_day${DAY}_${DN}.tif   $RAMDIR/${SENS}_CLOUD3k_day${DAY}_wgs84.tif
gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9      $RAMDIR/${SENS}_CLOUD3k_day${DAY}_wgs84.tif   $OUTSENS/${SENS}_CLOUD3k_day${DAY}_wgs84_${DN}.tif
rm -f   $RAMDIR/${SENS}_CLOUD3k_day${DAY}_wgs84.tif

gdalwarp -overwrite   -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90   -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9 \
$OUTSENS/${SENS}_LST3k_mask_day${DAY}_${DN}.tif   $RAMDIR/${SENS}_LST3k_mask_day${DAY}_wgs84.tif
gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9      $RAMDIR/${SENS}_LST3k_mask_day${DAY}_wgs84.tif   $OUTSENS/${SENS}_LST3k_mask_day${DAY}_wgs84_${DN}.tif
rm -f   $RAMDIR/${SENS}_LST3k_mask_day${DAY}_wgs84.tif

gdalwarp -overwrite   -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90   -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9 \
$OUTSENS/${SENS}_SEA_mask_day${DAY}.tif   $RAMDIR/${SENS}_SEA_mask_day${DAY}_wgs84_${DN}.tif
gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9      $RAMDIR/${SENS}_SEA_mask_day${DAY}_wgs84.tif   $OUTSENS/${SENS}_SEA_mask_day${DAY}_wgs84_${DN}.tif
rm -f   $RAMDIR/${SENS}_SEA_mask_day${DAY}_wgs84.tif

# ${SENS}_SEA_mask_day${DAY}_wgs84.tif  have a constant number of pixel they all the same and they are the same for MYD and MOD
# maskin ghe modis path 

exit 

# fatta correre a mano dopo il processamento

mv /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_mask_day001_wgs84.tif /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_mask_wgs84.tif
# remove all the sea maks because they all the same.
pksetmask -i /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_mask_wgs84.tif   -m /nobackupp8/gamatull/dataproces/LST/geo_file/shp/mask_path_modis_lst.tif   -msknodata 1 -nodata 1 -o test.tif 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9  test.tif  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_mask_wgs84.tif
rm test.tif 
cp /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_mask_wgs84.tif  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MOD_SEA_mask_wgs84.tif



# apply the path mask to the lst_mask

OUTSENS=/nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk
ls  $OUTSENS/MOD_LST3k_mask_day[0-9]??_wgs84_orig.tif | xargs -n 1 -P 20 bash -c $' 
file=$1
filename=$(basename $file _orig.tif)
pksetmask -i $file   -m /nobackupp8/gamatull/dataproces/LST/geo_file/shp/mask_path_modis_lst.tif   -msknodata 1 -nodata 0 -o ${filename}_tmp.tif
mv $file ${filename}_orig.tif
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9  ${filename}_tmp.tif ${filename}.tif

' _ 

OUTSENS=/nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk
ls  $OUTSENS/MYD_LST3k_mask_day[0-9]??_wgs84_orig.tif | xargs -n 1 -P 20  bash -c $' 
file=$1 
filename=$(basename $file _orig.tif) 
pksetmask -i $file   -m /nobackupp8/gamatull/dataproces/LST/geo_file/shp/mask_path_modis_lst.tif   -msknodata 1 -nodata 0 -o ${filename}_tmp.tif
mv $file ${filename}_orig.tif 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9  ${filename}_tmp.tif ${filename}.tif
' _ 


cp MOD_SEA_mask_day001_wgs84.tif   /dev/shm/MOD_sum.tif 


for file in MOD_SEA_mask_day???_wgs84.tif   ; do 
echo sum $file
gdal_edit.py -a_nodata -1 $file    
gdal_calc.py --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A $file -B /dev/shm/MOD_sum.tif --outfile=/dev/shm/MOD_sum_post.tif --calc="(A + B)"  
mv /dev/shm/MOD_sum_post.tif   /dev/shm/MOD_sum.tif 
done




