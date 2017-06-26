# growing the lst of 1 pixel
# qsub  -v SENS=MOD /u/gamatull/scripts/LST/spline/sc3_enlargeLST4fill4spline_MOYD11A2.sh

#PBS -S /bin/bash
#PBS -q normal 
#PBS -l select=1:ncpus=1
#PBS -l walltime=4:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo  /u/gamatull/scripts/LST/sc3_enlargeLST4fill4spline_MOYD11A2.sh 

export LST=/nobackupp8/gamatull/dataproces/LST
export RAMDIR=/dev/shm
export SENS=$SENS
rm -f /dev/shm/*

rm -f /dev/shm/*

ls  $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_day[0-9]??_wgs84.tif  | xargs -n 1 -P 24 bash -c  $' 
file=$1
filename=$(basename $file .tif)
# growing the mask of 1 pixel than mask by the sea
pkfilter -ot Byte -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0 -f smoothnodata -dx 3 -dy 3  -interp linear -i  $file -o $RAMDIR/${filename}_grow1p_tmp.tif  

# mask ou the sea and also some sporadic pixel coming from an LST zero observation
pksetmask -co COMPRESS=LZW -co ZLEVEL=9  -msknodata 255 -nodata -1 -m /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif   \
                                         -msknodata 0   -nodata -1 -m /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif  \
-i $RAMDIR/${filename}_grow1p_tmp.tif   -o $LST/${SENS}11A2_mean_msk/${filename}_grow1p.tif
gdal_edit.py -a_nodata -1 $LST/${SENS}11A2_mean_msk/${filename}_grow1p.tif
rm -f  $RAMDIR/${filename}_grow1p_tmp.tif
' _ 
 
# create a new Observation tif considering the enlargment

cp $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_day001_wgs84_grow1p.tif  /dev/shm/${SENS}_sum.tif
gdal_edit.py  -a_nodata -1   $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_day001_wgs84_grow1p.tif

for file in $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_day[0-9]??_wgs84_grow1p.tif     ; do
gdal_edit.py -a_nodata -1 /dev/shm/${SENS}_sum.tif
echo sum $file
gdal_edit.py -a_nodata -1 $file    
gdal_calc.py --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A $file -B /dev/shm/${SENS}_sum.tif --outfile=/dev/shm/${SENS}_sum_post.tif  --calc="(A + B)"  
gdal_edit.py -a_nodata -1 /dev/shm/${SENS}_sum_post.tif
mv /dev/shm/${SENS}_sum_post.tif   /dev/shm/${SENS}_sum.tif 
done 

gdal_calc.py --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A /dev/shm/${SENS}_sum.tif --outfile=$LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_grow1p.tif   --calc="(A -1 )"
pkcreatect  -min 0 -max 46   > /tmp/color.txt
pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct  /tmp/color.txt   -i $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_grow1p.tif -o   $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_grow1p_ct.tif
 
# the max value is considered as 1 ; max <= 5  ; this is used in combination of the sea mask to select only pixel with more than 5 obs.
pkgetmask   -min -1 -max 5 -data 1 -nodata 0 -co COMPRESS=LZW -co ZLEVEL=9   -i $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_grow1p_ct.tif -o   $LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask5noobs_wgs84_grow1p_ct.tif

rm -f /dev/shm/*

