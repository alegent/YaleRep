# for DN in Day Nig ; do for SENS in  MYD MOD ; do qsub -v SENS=$SENS,DN=$DN  /home6/gamatull/scripts/LST/mask/sc4_countCumulatLSTobs_MOYD11A2.sh ; done ; done 

# create a mask that is able to identify pixel with no observation in all the temporal series ...inclued cloud areas and sea areas
# this support has to add to the mask sea 

#PBS -S /bin/bash
#PBS -q normal 
#PBS -l select=1:ncpus=1
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

export SENS=$SENS
export DN=$DN
export IN=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/wgs84
export OUT=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/cumulative

export RAMDIR=/dev/shm

# eventualmente cambiare LST con OBS 

cleanram

pksetmask -ot Byte -co COMPRESS=LZW -co ZLEVEL=9 -i $IN/OBS_${SENS}_QC_day001_wgs84_${DN}.tif -m $IN/OBS_${SENS}_QC_day001_wgs84_${DN}.tif  -msknodata 1 -p '>' -nodata 1 -o /dev/shm/${SENS}_sum.tif

gdal_edit.py  -a_nodata -1   /dev/shm/${SENS}_sum.tif  

for file in $IN/OBS_${SENS}_QC_day???_wgs84_${DN}.tif     ; do
gdal_edit.py -a_nodata -1 /dev/shm/${SENS}_sum.tif

echo sum $file
gdal_edit.py -a_nodata -1 $file    
pksetmask -ot Byte -co COMPRESS=LZW -co ZLEVEL=9 -i $file  -m $file   -msknodata 1 -p '>' -nodata 1 -o /dev/shm/$(basename $file ) 
gdal_edit.py  -a_nodata -1 /dev/shm/$(basename $file )
gdal_calc.py --type=Byte --overwrite --type=Byte --creation-option=COMPRESS=LZW --co=ZLEVEL=9 -A  /dev/shm/$(basename $file ) -B /dev/shm/${SENS}_sum.tif --outfile=/dev/shm/${SENS}_sum_post.tif  --calc="(A + B)" 

gdal_edit.py -a_nodata -1 /dev/shm/${SENS}_sum_post.tif

mv /dev/shm/${SENS}_sum_post.tif   /dev/shm/${SENS}_sum.tif
done 

cp /dev/shm/${SENS}_sum.tif   $OUT/${SENS}_${DN}_sumCumulative.tif

cleanram
