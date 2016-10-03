cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/

for file1 in $(ls reg_models/*/tas/tas_oned_Amon_*_historical_ensamble_*-*_reg_1960-2005.tif reg_CRU/cru_ts3.23.1960.2005.tmp.dat_1.0deg.reg.tif)  ; do 
    for file2 in $(ls reg_models/*/tas/tas_oned_Amon_*_historical_ensamble_*-*_reg_1960-2005.tif reg_CRU/cru_ts3.23.1960.2005.tmp.dat_1.0deg.reg.tif)  ; do
      
   pksetmask -msknodata -9999  -nodata -9999 -m reg_CRU/cru_ts3.23.1960.2005.tmp.dat_1.0deg.reg.tif  -i $file1 -o /dev/shm/msk1.tif 
   pksetmask -msknodata -9999  -nodata -9999 -m reg_CRU/cru_ts3.23.1960.2005.tmp.dat_1.0deg.reg.tif  -i $file2 -o /dev/shm/msk2.tif
   echo $(basename $file1 ) $(basename $file2 ) $(pkstat  -nodata -9999  -reg -i /dev/shm/msk1.tif  -i /dev/shm/msk2.tif   | awk '{if (NR==1) { print sqrt($6)} }'   ) 
    done 
done   | grep -v done  > correlation_regression.txt 
