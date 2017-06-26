# qsub -v SENS=MOD /u/gamatull/scripts/LST/mask/sc3_createmaskLSTcommonmask_MOYD11A2.sh 

# create a mask that is able to identify pixel with no observation in all the temporal series ...inclued cloud areas and sea areas
# this support has to add to the mask sea 

#PBS -S /bin/bash
#PBS -q normal 
#PBS -l select=1:ncpus=1
#PBS -l walltime=3:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

export SENS=${SENS}
export IN=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean
export OUT=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk

export RAMDIR=/dev/shm

# eventualmente cambiare LST con OBS 

rm /dev/shm/*.tif 

cp $IN/LST_${SENS}_QC_day001_wgs84.tif  /dev/shm/${SENS}_sum.tif  
gdal_edit.py  -a_nodata -1   /dev/shm/${SENS}_sum.tif  

for file in $IN/LST_${SENS}_QC_day???_wgs84.tif     ; do
gdal_edit.py -a_nodata -1 /dev/shm/${SENS}_sum.tif
echo sum $file
gdal_edit.py -a_nodata -1 $file    
gdal_calc.py --type=UInt32  --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A $file -B /dev/shm/${SENS}_sum.tif --outfile=/dev/shm/${SENS}_sum_post.tif  --calc="(A + B)" 
gdal_edit.py -a_nodata -1 /dev/shm/${SENS}_sum_post.tif
mv /dev/shm/${SENS}_sum_post.tif   /dev/shm/${SENS}_sum.tif 
done 

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  /dev/shm/${SENS}_sum.tif $OUT/${SENS}_LST0_mask_daySUM_wgs84_ct.tif
# 0 mare e values with no ls observation, 255 pixel with lst value. 

# create the rclass 

rm /dev/shm/*.tif 

