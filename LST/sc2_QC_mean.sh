# 1 8-day mean considering the QC

# check http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_8dcmg.html#qa
# and QC at http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_1dcmg.html#Table_17
# data preparation of the QC list value 
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST
# echo echo 0 > geo_file/uniq_QC.txt  # inserted manualy because labeled as 0 in the image.
# for file in MOD11C2/*/*QC.tif  MYD11C2/*/*QC.tif  ; do pkinfo -hist -i $file | awk '{ if($2==0) print $1  }'   ; done   |  sort -g  | uniq >> geo_file/uniq_QC.txt
# transformation of the decimal to bynary
# (echo obase=2; sed 's/ //g'  geo_file/uniq_QC.txt ) | bc >  geo_file/uniq_QC_bynary.txt
# paste -d " " geo_file/uniq_QC.txt  geo_file/uniq_QC_bynary.txt  > geo_file/uniq_QC_decimal_bynary.txt

# based on the http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_1dcmg.html#Table_17
# https://lpdaac.usgs.gov/products/modis_products_table/mod11c2

# bits 	        Long Name 	   Key
# 1 & 0 	Mandatory QA flags 00=LST produced, good quality, not necessary to examine more detailed QA
#                                  01=LST produced, other quality quality, recommend examination of more detailed QA
#                                  10=LST not produced due to cloud effects
#                                  11=LST not produced primarily due to reasons other than    cloud

# 3 & 2 	Data quality flag  00=good data quality
#                                  01=other data quality pixel
#                                  10=LST affected by nearby clouds and/or sub-grid   clouds and/or ocean
#                                  11=LST screened off

# 5 & 4 	Emis Error flag    00=average emissivity error <= 0.01
#                                  01=average emissivity error <= 0.02
#                                  10=average emissivity error <= 0.04
#                                  11=average emissivity error > 0.04

# 7 & 6 	LST Error flag 	   00=average LST error <= 1K
#                                  01=average LST error <= 2K
#                                  10=average LST error <= 3K
#                                  11=average LST error > 3K


# for DAY  in $(cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/geo_file/list_day.txt ) ; do qsub -v DAY=$DAY /home/fas/sbsc/ga254/scripts/LST/sc1_wget_MYOD11C2.sh ; done 


#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr


# export DAY=$1

export DAY=$DAY

export HDFMOD11C2=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MOD11C2
export HDFMYD11C2=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MYD11C2
export LST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST
export RAMDIR=/dev/shm


echo start the pkcomposite /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MOYD11C2/LST_Day_CMG_day$DAY.tif 


gdal_translate  -ot   UInt16    -co COMPRESS=LZW -co ZLEVEL=9   MOD11C2.A2002353.005.2007261204533_QC.tif  MOD11C2.A2002353.005.2007261204533_QC_UInt16.tif

gdalbuildvrt -separate  -overwrite    MOD11C2.A2002361.005.2007265181117.vrt   MOD11C2.A2002361.005.2007265181117.tif MOD11C2.A2002361.005.2007265181117_QC_UInt16.tif 

gdal_translate  -ot   UInt16    -co COMPRESS=LZW -co ZLEVEL=9   MOD11C2.A2002361.005.2007265181117.vrt  MOD11C2.A2002361.005.2007265181117_withQC.tif

pkcomposite  -i MOD11C2.A2002361.005.2007265181117_withQC.tif  -bndnodata 1  -min 10 -max 50  -min 100 -max 250      -i MOD11C2.A2002353.005.2007261204533_withQC.tif -bndnodata 1     -file observations -ot Float32   -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0 -srcnodata 0  -o  test.tif



# pkcomposite $(ls $LST/*/*/M?D11C2.A20??${DAY}.005.*[0-9].tif | xargs -n 1 echo -i ) -file observations -ot Float32   -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0 -srcnodata 0 -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MOYD11C2/LST_Day_CMG_day$DAY.tif 

