
# 1 8-day mean no considered QC
# check http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_8dcmg.html#qa
# and QC at http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_1dcmg.html#Table_17

# for DAY  in $(cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/geo_file/list_day.txt ) ; do qsub -v DAY=$DAY /home/fas/sbsc/ga254/scripts/LST/sc1_wget_MYOD11C2.sh ; done 

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr


export DAY=$1

export DAY=$DAY

export HDFMOD11A2=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MOD11A2
export HDFMYD11A2=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MYD11A2
export LST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST
export RAMDIR=/dev/shm

seq 2003 2003  | xargs -n 1 -P 8 bash -c $' 

YEAR=$1

# wget -N   -P   $RAMDIR   ftp://ladsweb.nascom.nasa.gov/allData/5/MOD11A2/${YEAR}/$DAY/*.hdf
# wget -N   -P   $RAMDIR   ftp://ladsweb.nascom.nasa.gov/allData/5/MYD11A2/${YEAR}/$DAY/*.hdf

for SENS in MOD  MYD ; do

# for file in   $RAMDIR/${SENS}11A2.A????${DAY}.??????.???.*.hdf   ; do  

# filename=$(basename $file .hdf)

# gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9    HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:LST_Day_1km   $RAMDIR/$filename.tif 
# gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9    HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:QC_Day        $RAMDIR/${filename}_QC.tif 

# done 

gdalbuildvrt   -overwrite    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.vrt    HDF4_EOS:EOS_GRID:" $RAMDIR/${SENS}11A2.A????${DAY}.??????.???.*.hdf":MODIS_Grid_8Day_1km_LST:LST_Day_1km   

# gdal_translate     $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.vrt     -co COMPRESS=LZW -co ZLEVEL=9            $HDF${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}.tif

# gdalbuildvrt   -overwrite    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.??????.???.?????????????_QC.tif 
# gdal_translate     $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC.vrt     -co COMPRESS=LZW -co ZLEVEL=9            $HDF${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_QC.tif 

done


' _ 


exit 





echo start the pkcomposite /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MOYD11C2/LST_Day_CMG_day$DAY.tif 

pkcomposite $(ls $LST/*/*/M?D11C2.A20??${DAY}.005.*[0-9].tif | xargs -n 1 echo -i ) -file observations -ot Float32   -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0 -srcnodata 0 -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MOYD11C2/LST_Day_CMG_day$DAY.tif 

