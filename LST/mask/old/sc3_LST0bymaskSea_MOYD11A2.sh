# qsub -v SENS=MOD /u/gamatull/scripts/LST/sc3_createmaskLSTcommonmask_MOYD11A2.sh 

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



# 1 sea 0 land ( this is constant in MYD and MOD and all over the image - land include lst > 0 but also LST == 0 )

# pkinfo -hist -i /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_mask_wgs84.tif
# 0 311773586
# 1 621346414
# pkinfo -hist -i /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_mask_wgs84.tif
# 0 311773586
# 1 621346414

# 0 sea  255 land ( but 0 include sea and lst with value = 0  )
# pkinfo -hist -i  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST0_mask_daySUM_wgs84_ct.tif  | grep -v " 0" 
# 0 621637171             290757 with lst-no observation 
# 255 311482829

# pkinfo -hist -i  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST0_mask_daySUM_wgs84_ct.tif  | grep -v " 0"
# 0 621637625             291211 with lst-no observation 
# 255 311482375  

~/pktools-2.6.3/bin/pksetmask -ot Int16  -co  COMPRESS=LZW -co ZLEVEL=9  -m /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_mask_wgs84.tif   -msknodata 1  -nodata -1      -i /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST0_mask_daySUM_wgs84_ct.tif  -o /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_LST0_LST_mask_daySUM_wgs84_ct.tif

gdal_edit.py -a_nodata -2  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_LST0_LST_mask_daySUM_wgs84_ct.tif

# ~/pktools-2.6.3/bin/pkinfo -hist  -src_min -3 -src_max +256  -i  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_LST0_LST_mask_daySUM_wgs84_ct.tif  | grep -v  " 0"
# -1 621346414    sea 
# 0 290952        lst with 0 observatio 
# 255 311482634   lst with atleast 1 observation 


~/pktools-2.6.3/bin/pksetmask -ot Int16  -co  COMPRESS=LZW -co ZLEVEL=9   -m /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_mask_wgs84.tif   -msknodata 1 -nodata -1      -i /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST0_mask_daySUM_wgs84_ct.tif  -o /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_LST0_LST_mask_daySUM_wgs84_ct.tif

gdal_edit.py  -a_nodata -2 /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_LST0_LST_mask_daySUM_wgs84_ct.tif

# ~/pktools-2.6.3/bin/pkinfo -hist  -src_min -3 -src_max +256  -i  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_SEA_LST0_LST_mask_daySUM_wgs84_ct.tif  | grep -v " 0"
# -1 621346414
# 0 291407
# 255 311482179





