#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

module load Tools/CDO/1.6.4  

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING

cd $DIR


cdo griddes  $DIR/HadISST/HadISST_sst.nc >  $DIR/HadISST/HadISST_sst_griddes.txt

# time frame  1960 - 2005 and  1960 - 2014 


echo temperature CUR 

# year mean for temperature CRU 0.5 ; then regression
 
# dataset from 1960 to 2014
# seq 1960 2005 | xargs -n 1 -P 8 bash -c $' 
seq 1960 1961 | xargs -n 1 -P 8 bash -c $' 

YYYY=1960.2014
YSTART=$1
YEND=$(expr $YSTART + 9)

# year mean for temperature CRU  ; then regression 


cdo yearmonmean  -setmissval,-9999 -setvrange,-100,50 -selyear$(for year in $(seq $YSTART $YEND) ; do echo -n ,$year ; done) $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc   $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp${YSTART}.${YEND}.dat_0.5deg.nc
cdo regres  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp${YSTART}.${YEND}.dat_0.5deg.nc   $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.nc
pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.nc   -msknodata 100000 -p ">" -nodata -9999 -i $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.nc -o  $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.tif
rm $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp${YSTART}.${YEND}.dat_0.5deg.nc
echo  precipitation CUR 

# year sum for precipitation  CRU  ; then regression 

cdo yearsum -setvrange,0,3000 -selyear$(for year in $(seq $YSTART $YEND); do echo -n ,$year ; done)   $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.pre.dat.nc    $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre${YSTART}.${YEND}.dat_0.5deg.nc
cdo regres $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre${YSTART}.${YEND}.dat_0.5deg.nc   $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.nc
pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.nc -msknodata 100000 -p ">" -nodata -9999 -i $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.nc -o  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.tif
rm $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre${YSTART}.${YEND}.dat_0.5deg.nc

# year mean for precipitation  HadISST_sst  ; then regression 

cdo yearmonmean   -setvals,-1000,-1.8     -setvrange,-50,50 -selyear$(for year in $(seq $YSTART $YEND); do echo -n ,$year; done) -select,param=-2 $DIR/HadISST/HadISST_sst.nc $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp${YSTART}.${YEND}.dat_1.0deg.nc  
cdo regres $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp${YSTART}.${YEND}.dat_1.0deg.nc  $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.nc  
pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.nc   -msknodata 100000 -p ">" -nodata -9999 -i $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.nc -o $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.tif
rm -f $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp${YSTART}.${YEND}.dat_1.0deg.nc

# calculate the weighted median and weighted mean (with real values and absolute values) 
# wighted mean ; sum (area * value ) /  sum area 

# ### run only ones manualy to compute area statistic 
# ### mask the ARA raster with cru and HadISST dataset 
# pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/reg_CRU10/cru_ts3.23.1960.2014.pre.dat_0.5deg.reg1960.1969.nc   -msknodata 100000 -p ">" -nodata -9999 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/area_tif/0.50deg-Area_prj6965.tif -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRU.tif
# pkgetmask -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9 -min 0 -max 100000 -data 1 -nodata 0 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRU.tif -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRUmsk.tif

# pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/reg_HadISST10/HadISST_sst.1960.2014.tmp.dat_1.0deg.reg1960.1969.nc   -msknodata -100000 -p "<" -nodata -9999 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/area_tif/1.00deg-Area_prj6965.tif -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISST.tif
# pkgetmask -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9 -min 0 -max 100000 -data 1 -nodata 0 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISST.tif -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISSTmsk.tif

# # get the sum of the area 
# # oft-stat-sum 

# oft-stat-sum -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRU.tif  -um  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRUmsk.tif -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRUmsk_sum.txt 

# oft-stat-sum -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISST.tif  -um  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISSTmsk.tif  -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISSTmsk_sum.txt
# # head  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/*.txt 
# # 1 67420 146382903.728638 751.131514 

# # head /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISSTmsk_sum.txt
# # 1 43425 368654892.352112 3524.549964 
# ##########
# ##########

# cru * AREA

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.regAREA${YSTART}.${YEND}.tif  -A $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.tif -B /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRU.tif   --calc="( A.astype(float) +  B.astype(float) )" --overwrite   --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.regAREA${YSTART}.${YEND}.tif  -A $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.tif -B /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRU.tif   --calc="( A.astype(float) +  B.astype(float) )" --overwrite   --co=COMPRESS=DEFLATE --co=ZLEVEL=9

oft-stat-sum -i $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.regAREA${YSTART}.${YEND}.tif  -um /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRUmsk.tif   -o $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.regAREA${YSTART}.${YEND}.txt

oft-stat-sum -i $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.regAREA${YSTART}.${YEND}.tif  -um /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/0.50deg-Area_prj6965_CRUmsk.tif   -o $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.regAREA${YSTART}.${YEND}.txt 

# calculate wighted mean 
paste  $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.regAREA${YSTART}.${YEND}.txt $DIR/GEO_AREA/0.50deg-Area_prj6965_CRUmsk_sum.txt | awk \'{ printf ("%.12f\n", $3 / $7 )  }\' > $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.regAREA${YSTART}.${YEND}wightedmean.txt
rm $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.regAREA${YSTART}.${YEND}.txt

paste  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.regAREA${YSTART}.${YEND}.txt $DIR/GEO_AREA/0.50deg-Area_prj6965_CRUmsk_sum.txt | awk \'{  printf ("%.12f\n", $3 / $7 ) }\' > $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.regAREA${YSTART}.${YEND}wightedmean.txt
rm $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.regAREA${YSTART}.${YEND}.txt

# HadISST * AREA

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.regAREA${YSTART}.${YEND}.tif  -A $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.tif -B /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISST.tif   --calc="( A.astype(float) +  B.astype(float) )" --overwrite   --co=COMPRESS=DEFLATE --co=ZLEVEL=9

oft-stat-sum -i $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.regAREA${YSTART}.${YEND}.tif  -um /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISSTmsk.tif   -o $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.regAREA${YSTART}.${YEND}.txt

# calculate wighted mean 

paste  $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.regAREA${YSTART}.${YEND}.txt $DIR/GEO_AREA/1.00deg-Area_prj6965_HadISSTmsk_sum.txt | awk \'{  printf ("%.12f\n", $3 / $7 ) }\' > $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.regAREA${YSTART}.${YEND}wightedmean.txt
# rm $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.regAREA${YSTART}.${YEND}.txt

' _ 

exit 

##### select the highst regression #######

###### 
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}_tmp.tif -msknodata 10000 -p ">" -nodata -9999 -i


cdo yearmean  -setmissval,-9999 -setvrange,-100,50 -selyear$(for year in $(seq 1960 2014 ) ; do echo -n ,$year ; done) $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc   $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.nc


# year mean 
cdo timmean  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.nc   $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.nc
cdo timmean  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.nc   $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.nc


echo temperature HadISST  # setvals change the value of -1000 to -1.8 



cdo yearmonmean   -setvals,-1000,-1.8     -setvrange,-50,50 -selyear$(for year in $(seq $YSTART $YEND); do echo -n ,$year; done) -select,param=-2 $DIR/HadISST/HadISST_sst.nc $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp${YSTART}.${YEND}.dat_1.0deg.nc  

cdo timmean  $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp${YSTART}.${YEND}.dat_1.0deg.nc           $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean${YSTART}.${YEND}.nc  
cdo regres   $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp${YSTART}.${YEND}.dat_1.0deg.nc           $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.nc  


# transform to tif 

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.nc  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}_tmp.tif
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}_tmp.tif -msknodata 10000 -p ">" -nodata -9999 -i   $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}_tmp.tif -o  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.tif
rm -f  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}_tmp.tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.nc  $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.tif

pkfilter -of GTiff -dx 2 -dy 2  -f mean -d 2  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -nodata -9999 -ot Float32  -i  $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg${YSTART}.${YEND}.tif -o $DIR/reg_CRU10/cru_ts3.23.$YYYY.pre.dat_1.0deg.reg${YSTART}.${YEND}.tif 
pkfilter -of GTiff -dx 2 -dy 2  -f mean -d 2  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -nodata -9999 -ot Float32  -i  $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg${YSTART}.${YEND}.tif -o $DIR/reg_CRU10/cru_ts3.23.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.tif

gdal_translate -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 NETCDF:"$DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.nc":sst $DIR/reg_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg${YSTART}.${YEND}.tif

echo observation temporal mean_CRU10   transform to tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean${YSTART}.${YEND}.nc  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean${YSTART}.${YEND}.tif 
gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean${YSTART}.${YEND}.nc  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean${YSTART}.${YEND}_tmp.tif
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean${YSTART}.${YEND}_tmp.tif -msknodata 10000 -p ">" -nodata -9999 -i  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean${YSTART}.${YEND}_tmp.tif -o $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean${YSTART}.${YEND}.tif
rm -f   $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean${YSTART}.${YEND}_tmp.tif

pkfilter -of GTiff -dx 2 -dy 2  -f mean -d 2  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  -ot Float32  -nodata -9999 -i  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean${YSTART}.${YEND}.tif -o $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean${YSTART}.${YEND}.tif
pkfilter -of GTiff -dx 2 -dy 2  -f mean -d 2  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  -ot Float32  -nodata -9999 -i  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean${YSTART}.${YEND}.tif -o $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean${YSTART}.${YEND}.tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  NETCDF:"$DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean${YSTART}.${YEND}.nc":sst    $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean${YSTART}.${YEND}.tif





' _ 

exit


# R --vanilla -q <<EOF
# library(raster)
# raster=raster(matrix(runif(259200,max=0.05, min=-0.05),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
# writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.tmp.dat_mean_random.0.5deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
# EOF
# echo create random variable for temperature 1 deg mean_CRU
# R --vanilla -q <<EOF
# library(raster)
# raster=raster(matrix(runif(64800,max=0.05, min=-0.05),180,360) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
# writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.tmp.dat_mean_random.1.0deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
# EOF

# echo create random variable for precipiation  0.5 deg mean_CRU
# R --vanilla -q <<EOF
# library(raster)
# raster=raster(matrix(runif(259200,max=0.1, min=0.001),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
# writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.pre.dat_mean_random.0.5deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
# EOF

# echo create random variable for precipiatation 1 deg mean_CRU

# R --vanilla -q <<EOF
# library(raster)
# raster=raster(matrix(runif(64800,max=0.1, min=0.001),180,360) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
# writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.pre.dat_mean_random.1.0deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
# EOF

# echo create random variable for temperature 1 deg mean_HadISST

# R --vanilla -q <<EOF
# library(raster)
# raster=raster(matrix(runif(64800,max=0.05, min=-0.05),180,360) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
# writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_HadISST/HadISST_sst.tmp.dat_mean_random.1.0deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
# EOF



echo  1960.200
YYYY=1960.2014
SEQ=$(echo $YYYY  | tr "." " ") 

# add the random to temporal mean for precipitation and temperature 

gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.r.tif -A $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.tmp.dat_mean_random.0.5deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite     --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.r.tif -A $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.pre.dat_mean_random.0.5deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite    --co=COMPRESS=DEFLATE  --co=ZLEVEL=9

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.r.tif -A $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.tmp.dat_mean_random.1.0deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite    --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.r.tif -A $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.pre.dat_mean_random.1.0deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite  --co=COMPRESS=DEFLATE   --co=ZLEVEL=9

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.r.tif -A $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.tif -B $DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_random.1.0deg.tif  --calc="( A.astype(float) +  B.astype(float) )" --overwrite   --co=COMPRESS=DEFLATE --co=ZLEVEL=9


# slope in percentage so * 10 to get in km 

gdaldem slope -p -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.r.tif      $DIR/slope_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope.tif 
gdaldem slope -p -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.r.tif      $DIR/slope_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope.tif 

gdaldem slope -p -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.r.tif      $DIR/slope_CRU10/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope.tif 
gdaldem slope -p -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.r.tif      $DIR/slope_CRU10/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope.tif 

gdaldem slope -p -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.r.tif $DIR/slope_HadISST10/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope.tif 

# multiply to 10   

gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10.tif -A $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope.tif --calc="(A.astype(float) * 10)" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9

# the slope is not = to 0 in any place, due to + random 

# single cell have slope value 0 so mask out, masking out islands that are only one grid cell

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10msk.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10msk.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10msk.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10msk.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10.tif -msknodata -0 -p "=" -nodata -9999 -i $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10.tif -o $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10msk.tif 
gdal_edit.py -a_nodata -9999  $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10msk.tif 

echo velocity temporal regression divided  spatial slope  CRU data 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_translate  -of netCDF $DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.velocity.tif   $DIR/velocity_CRU_nc/cru_ts3.23.$YYYY.tmp.dat_1.00deg.velocity.nc 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_translate  -of netCDF $DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.velocity.tif   $DIR/velocity_CRU_nc/cru_ts3.23.$YYYY.tmp.dat_1.00deg.velocity.nc 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_translate  -of netCDF $DIR/velocity_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.velocity.tif   $DIR/velocity_CRU_nc/cru_ts3.23.$YYYY.pre.dat_0.5deg.velocity.nc 


gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_translate  -of netCDF $DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.velocity.tif   $DIR/velocity_CRU_nc/cru_ts3.23.$YYYY.tmp.dat_0.5deg.velocity.nc 

echo  velocity temporal regression divided  spatial slope  HadISST data 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.velocity.tif  -A  $DIR/reg_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg.tif  -B  $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_translate -of netCDF  $DIR/velocity_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.velocity.tif   $DIR/velocity_HadISST_nc/HadISST_sst.$YYYY.tmp.dat_1.0deg.velocity.nc 

# echo  calculate aspect so direction  based on the mean/sum annual temperature/precipitation 

## aspect CRU tmp 0.5 
gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.r.tif      $DIR/aspect_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.aspect.tif 

cd  $DIR/direction_CRU
rm -fr loc_$YYYY
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh      $DIR/direction_CRU/  loc_$YYYY                  $DIR/aspect_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.aspect.tif  
r.in.gdal in=$DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.velocity.tif   out=cru_ts3.23.$YYYY.tmp.dat_0.5deg.velocity   --overwrite

r.mask raster=cru_ts3.23.$YYYY.tmp.dat_0.5deg.aspect 
# create an invers direction 
r.mapcalc "cru_ts3.23.$YYYY.tmp.dat_0.5deg.directionNEG = if( cru_ts3.23.$YYYY.tmp.dat_0.5deg.aspect  <  180  ,  cru_ts3.23.$YYYY.tmp.dat_0.5deg.aspect + 180    ,   cru_ts3.23.$YYYY.tmp.dat_0.5deg.aspect - 180  ) " 
# create a direction map if velocity > 0 , put aspect , esle put the invert direction
r.mapcalc "cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction = if( cru_ts3.23.$YYYY.tmp.dat_0.5deg.velocity > 0, cru_ts3.23.$YYYY.tmp.dat_0.5deg.aspect, cru_ts3.23.$YYYY.tmp.dat_0.5deg.directionNEG) " 
r.mask -r  # remove the mask 
# set null to 0 
r.mapcalc "cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction0 = if(  isnull(cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction) , 0 ,  cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction       ) " 

echo export direction 
r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=0   input=cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction0     output=$DIR/direction_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction.tif   --overwrite
rm -fr loc_$YYYY
gdal_translate  -of netCDF $DIR/direction_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction.tif   $DIR/direction_CRU_nc/cru_ts3.23.$YYYY.tmp.dat_0.5deg.direction.nc 

## aspect CRU pre  0.5 

gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.r.tif      $DIR/aspect_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.aspect.tif 

cd  $DIR/direction_CRU
rm -fr loc_$YYYY
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh      $DIR/direction_CRU/  loc_$YYYY                  $DIR/aspect_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.aspect.tif  
r.in.gdal in=$DIR/velocity_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.velocity.tif   out=cru_ts3.23.$YYYY.pre.dat_0.5deg.velocity   --overwrite

r.mask raster=cru_ts3.23.$YYYY.pre.dat_0.5deg.aspect 
# create an invers direction 
r.mapcalc "cru_ts3.23.$YYYY.pre.dat_0.5deg.directionNEG = if( cru_ts3.23.$YYYY.pre.dat_0.5deg.aspect  <  180  ,  cru_ts3.23.$YYYY.pre.dat_0.5deg.aspect + 180    ,   cru_ts3.23.$YYYY.pre.dat_0.5deg.aspect - 180  ) " 
# create a direction map if velocity > 0 , put aspect , esle put the invert direction
r.mapcalc "cru_ts3.23.$YYYY.pre.dat_0.5deg.direction    = if( cru_ts3.23.$YYYY.pre.dat_0.5deg.velocity >   0 ,  cru_ts3.23.$YYYY.pre.dat_0.5deg.aspect    ,   cru_ts3.23.$YYYY.pre.dat_0.5deg.directionNEG    ) " 
r.mask -r  # remove the mask 
# set null to 0 
r.mapcalc "cru_ts3.23.$YYYY.pre.dat_0.5deg.direction0 = if(  isnull(cru_ts3.23.$YYYY.pre.dat_0.5deg.direction) , 0 ,  cru_ts3.23.$YYYY.pre.dat_0.5deg.direction       ) " 

echo export direction 
r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=0   input=cru_ts3.23.$YYYY.pre.dat_0.5deg.direction0     output=$DIR/direction_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.direction.tif   --overwrite
rm -fr loc_$YYYY
gdal_translate  -of netCDF $DIR/direction_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.direction.tif   $DIR/direction_CRU_nc/cru_ts3.23.$YYYY.pre.dat_0.5deg.direction.nc 


## aspect CRU tmp 1.0
gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.r.tif      $DIR/aspect_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.aspect.tif 

cd  $DIR/direction_CRU
rm -fr loc_$YYYY
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh      $DIR/direction_CRU/  loc_$YYYY                  $DIR/aspect_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.aspect.tif  
r.in.gdal in=$DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.velocity.tif   out=cru_ts3.23.$YYYY.tmp.dat_1.0deg.velocity   --overwrite

r.mask raster=cru_ts3.23.$YYYY.tmp.dat_1.0deg.aspect 
# create an invers direction 
r.mapcalc "cru_ts3.23.$YYYY.tmp.dat_1.0deg.directionNEG = if( cru_ts3.23.$YYYY.tmp.dat_1.0deg.aspect  <  180  ,  cru_ts3.23.$YYYY.tmp.dat_1.0deg.aspect + 180    ,   cru_ts3.23.$YYYY.tmp.dat_1.0deg.aspect - 180  ) " 
# create a direction map if velocity > 0 , put aspect , esle put the invert direction
r.mapcalc "cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction    = if( cru_ts3.23.$YYYY.tmp.dat_1.0deg.velocity >   0 ,  cru_ts3.23.$YYYY.tmp.dat_1.0deg.aspect    ,   cru_ts3.23.$YYYY.tmp.dat_1.0deg.directionNEG    ) " 
r.mask -r  # remove the mask 
# set null to 0 
r.mapcalc "cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction0 = if(  isnull(cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction) , 0 ,  cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction       ) " 

echo export direction 
r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=0   input=cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction0     output=$DIR/direction_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction.tif   --overwrite
rm -fr loc_$YYYY
gdal_translate  -of netCDF $DIR/direction_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction.tif   $DIR/direction_CRU_nc/cru_ts3.23.$YYYY.tmp.dat_1.0deg.direction.nc 

## aspect CRU pre  1.0 

gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU10/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.r.tif      $DIR/aspect_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.aspect.tif 

cd  $DIR/direction_CRU
rm -fr loc_$YYYY
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh      $DIR/direction_CRU/  loc_$YYYY                  $DIR/aspect_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.aspect.tif  
r.in.gdal in=$DIR/velocity_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.velocity.tif   out=cru_ts3.23.$YYYY.pre.dat_1.0deg.velocity   --overwrite

r.mask raster=cru_ts3.23.$YYYY.pre.dat_1.0deg.aspect 
# create an invers direction 
r.mapcalc "cru_ts3.23.$YYYY.pre.dat_1.0deg.directionNEG = if( cru_ts3.23.$YYYY.pre.dat_1.0deg.aspect  <  180  ,  cru_ts3.23.$YYYY.pre.dat_1.0deg.aspect + 180    ,   cru_ts3.23.$YYYY.pre.dat_1.0deg.aspect - 180  ) " 
# create a direction map if velocity > 0 , put aspect , esle put the invert direction
r.mapcalc "cru_ts3.23.$YYYY.pre.dat_1.0deg.direction    = if( cru_ts3.23.$YYYY.pre.dat_1.0deg.velocity >   0 ,  cru_ts3.23.$YYYY.pre.dat_1.0deg.aspect    ,   cru_ts3.23.$YYYY.pre.dat_1.0deg.directionNEG    ) " 
r.mask -r  # remove the mask 
# set null to 0 
r.mapcalc "cru_ts3.23.$YYYY.pre.dat_1.0deg.direction0 = if(  isnull(cru_ts3.23.$YYYY.pre.dat_1.0deg.direction) , 0 ,  cru_ts3.23.$YYYY.pre.dat_1.0deg.direction       ) " 

echo export direction 
r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=0   input=cru_ts3.23.$YYYY.pre.dat_1.0deg.direction0     output=$DIR/direction_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.direction.tif   --overwrite
rm -fr loc_$YYYY
gdal_translate  -of netCDF $DIR/direction_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.direction.tif   $DIR/direction_CRU_nc/cru_ts3.23.$YYYY.pre.dat_1.0deg.direction.nc 


echo  aspect HadISST  tmp  1.0  aspect HadISST  tmp  1.0  aspect HadISST  tmp  1.0   aspect HadISST  tmp  1.0   aspect HadISST  tmp  1.0  aspect HadISST  tmp  1.0  aspect HadISST  tmp  1.0 aspect HadISST  tmp  1.0 aspect HadISST  tmp  1.0 

gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.r.tif $DIR/aspect_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.aspect.tif 

cd  $DIR/direction_HadISST
rm -fr loc_$YYYY
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh      $DIR/direction_HadISST/  loc_$YYYY                  $DIR/aspect_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.aspect.tif 
r.in.gdal in=$DIR/velocity_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.velocity.tif    out=HadISST_sst.$YYYY.tmp.dat_1.0deg.velocity   --overwrite

r.mask raster=HadISST_sst.$YYYY.tmp.dat_1.0deg.aspect
# create an invers direction 
r.mapcalc "  HadISST_sst.$YYYY.tmp.dat_1.0deg.directionNEG  = if( HadISST_sst.$YYYY.tmp.dat_1.0deg.aspect   <  180  ,  HadISST_sst.$YYYY.tmp.dat_1.0deg.aspect  + 180    ,  HadISST_sst.$YYYY.tmp.dat_1.0deg.aspect  - 180  ) " 

echo  create a direction map if velocity > 0 , put aspect , esle put the invert direction

r.mapcalc "HadISST_sst.$YYYY.tmp.dat_1.0deg.direction    = if( HadISST_sst.$YYYY.tmp.dat_1.0deg.velocity >   0 ,  HadISST_sst.$YYYY.tmp.dat_1.0deg.aspect    ,  HadISST_sst.$YYYY.tmp.dat_1.0deg.directionNEG    ) " 
r.mask -r  # remove the mask 

# set null to 0 
r.mapcalc " HadISST_sst.$YYYY.tmp.dat_1.0deg.direction0  = if(  isnull(HadISST_sst.$YYYY.tmp.dat_1.0deg.direction    ) , 0 ,  HadISST_sst.$YYYY.tmp.dat_1.0deg.direction     ) " 

echo export direction 
r.out.gdal -c     createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=0   input=HadISST_sst.$YYYY.tmp.dat_1.0deg.direction0    output=$DIR/direction_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.direction.tif   --overwrite
rm -fr loc_$YYYY

gdal_translate -of netCDF  $DIR/direction_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.direction.tif   $DIR/direction_HadISST_nc/HadISST_sst.$YYYY.tmp.dat_1.0deg.direction.nc 



exit 


# mask out the sea final velocity  =  velocity*_msk.tif 

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  $DIR/mean_CRU10/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -msknodata 100   -p ">"   -nodata -9999  -m   $DIR/mean_CRU10/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU10/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -o $DIR/mean_CRU10/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU10/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif

pksetmask   -co COMPRESS=DEFLATE  -co ZLEVEL=9  -m  $DIR/mean_CRU10/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif  -msknodata 100   -p ">"   -nodata -9999  -m   $DIR/mean_CRU10/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU10/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif -o $DIR/mean_CRU10/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU10/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif



# calculate velocity direction 

for PAR in tmp pre ; do 

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh $DIR/mean_CRU10 loc_${PAR}_velo $DIR/mean_CRU10/cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk.tif 

# r.terraflow -s elevation=cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk direction=cru_ts3.23.1901.2014.${PAR}.dat_direction_1960-2009_msk filled=cru_ts3.23.1901.2014.${PAR}.dat_filled_1960-2009_msk  swatershed=cru_ts3.23.1901.2014.${PAR}.dat_swater_1960-2009_msk accumulation=cru_ts3.23.1901.2014.${PAR}.dat_accum_1960-2009_msk  tci=cru_ts3.23.1901.2014.${PAR}.dat_tci_1960-2009_msk

r.watershed  -s elevation=cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk drainage=cru_ts3.23.1901.2014.${PAR}.dat_direction_1960-2009_msk --overwrite 

for file in $(g.mlist -r  type=rast   pattern="cru_ts3.23.1901.2014.${PAR}.dat_*" --q | grep -v velocity   )  ; do 
r.out.gdal -c  createopt="COMPRESS=DEFLATE ,ZLEVEL=9" format=GTiff  type=Int32  input=$file    output=$DIR/mean_CRU10/$file.tif  nodata=-9999
done 

done 

#  

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh $DIR/mean_HadISST  loc_HadISST_velo $DIR/mean_HadISST/HadISST_sst.tmp.dat_velocity_1960-2009_msk.tif

r.watershed  -s elevation=HadISST_sst.tmp.dat_velocity_1960-2009_msk   drainage=HadISST_sst.tmp.dat_direction_1960-2009_msk --overwrite 

r.out.gdal -c  createopt="COMPRESS=DEFLATE ,ZLEVEL=9" format=GTiff type=Int32 input=HadISST_sst.tmp.dat_direction_1960-2009_msk   output=$DIR/mean_HadISST/HadISST_sst.tmp.dat_direction_1960-2009_msk.tif nodata=-9999

rm -r  $DIR/mean_*/loc_* 





