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


time frame  1960 - 2005 and  1960 - 2014 

echo 1960.2005  1960.2014 | xargs -n 1 -P 2 bash -c $' 

YYYY=$1
SEQ=$(echo $YYYY  | tr "." " ") 

echo temperature CUR 

# resampling from 0.5 to 1

cdo -P 2  remapcon2,$DIR/HadISST/HadISST_sst_griddes.txt -setmissval,-9999 -setvrange,-100,50 -selyear$(for year in $(seq $SEQ ) ; do echo -n ,$year ; done)  $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc   $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_1.0deg_tmp.nc

# year mean for 0.5 and 1 

cdo yearmean    $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_1.0deg_tmp.nc   $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_1.0deg.nc
rm   $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_1.0deg_tmp.nc

cdo yearmean  -setmissval,-9999 -setvrange,-100,50 -selyear$(for year in $(seq $SEQ ) ; do echo -n ,$year ; done)  $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc   $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_0.5deg.nc

echo  precipitation CUR 

# resampling to from 0.5 to 1 deg 

cdo -P 2 remapcon2,$DIR/HadISST/HadISST_sst_griddes.txt -selyear$(for year in $(seq $SEQ) ; do echo -n ,$year ; done)  $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.pre.dat.nc   $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_1.0deg_tmp.nc

# year mean 

cdo yearsum    $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_1.0deg_tmp.nc    $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_1.0deg.nc
rm $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_1.0deg_tmp.nc

cdo yearsum   -selyear$(for year in $(seq $SEQ); do echo -n ,$year ; done)   $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.pre.dat.nc   $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_0.5deg.nc

echo temperature HadISST

cdo yearmean  -setmissval,-9999 -setvrange,-100,50 -selyear$(for year in $(seq $SEQ); do echo -n ,$year; done) -select,param=-2 $DIR/HadISST/HadISST_sst.nc $DIR/HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.nc  

echo  observation temporal monthly regression 

cdo regres  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_0.5deg.nc   $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg.nc
cdo regres  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_0.5deg.nc   $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg.nc

cdo regres  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_1.0deg.nc   $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.reg.nc
cdo regres  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_1.0deg.nc   $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.reg.nc

cdo regres  $DIR/HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.nc     $DIR/reg_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg.nc  

# transform to tif 


gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg.nc  $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg.tif 
gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg.nc  $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg.tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.reg.nc  $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.reg.tif
gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.reg.nc  $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.reg.tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  -co ZLEVEL=9 NETCDF:"$DIR/reg_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg.nc":sst    $DIR/reg_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg.tif


echo  observation temporal mean_CRU  mean_HadISST

cdo timmean  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_0.5deg.nc   $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.nc
cdo timmean  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_0.5deg.nc   $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.nc

cdo timmean  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.pre.dat_1.0deg.nc   $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.nc
cdo timmean  $DIR/CRU_ts3.23/cru_ts3.23.$YYYY.tmp.dat_1.0deg.nc   $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.nc

cdo timmean  $DIR/HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.nc     $DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.nc  

observation temporal mean_CRU   transform to tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.nc  $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.tif 
gdal_translate -ot Float32  -co COMPRESS=DEFLATE  $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.nc  $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.nc $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.tif
gdal_translate -ot Float32  -co COMPRESS=DEFLATE  $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.nc $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.tif

gdal_translate -ot Float32  -co COMPRESS=DEFLATE  NETCDF:"$DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.nc":sst    $DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.tif

' _ 

echo create random variable for temperature 0.5 deg mean_CRU
R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(259200,max=0.05, min=-0.05),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.tmp.dat_mean_random.0.5deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
EOF
echo create random variable for temperature 1 deg mean_CRU
R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(64800,max=0.05, min=-0.05),180,360) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.tmp.dat_mean_random.1.0deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
EOF

echo create random variable for precipiation  0.5 deg mean_CRU
R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(259200,max=0.1, min=-0.1),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.pre.dat_mean_random.0.5deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
EOF

echo create random variable for precipiatation 1 deg mean_CRU

R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(64800,max=0.1, min=-0.1),180,360) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.pre.dat_mean_random.1.0deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
EOF

echo create random variable for temperature 1 deg mean_HadISST

R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(64800,max=0.05, min=-0.05),180,360) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_HadISST/HadISST_sst.tmp.dat_mean_random.1.0deg.tif",options=c("COMPRESS=DEFLATE "),formats=GTiff,overwrite=TRUE)
EOF



echo  1960.2005  1960.2014 | xargs -n 1 -P 2 bash -c $' 

YYYY=$1
SEQ=$(echo $YYYY  | tr "." " ") 

# add the random to temporal mean for precipitation and temperature 

gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.r.tif -A $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.tmp.dat_mean_random.0.5deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite     --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.r.tif -A $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.pre.dat_mean_random.0.5deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite    --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.r.tif -A $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.tmp.dat_mean_random.1.0deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite    --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.r.tif -A $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.tif -B $DIR/mean_CRU/cru_ts3.23.pre.dat_mean_random.1.0deg.tif --calc="( A.astype(float) +  B.astype(float) )"  --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.r.tif -A $DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.tif -B $DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_random.1.0deg.tif  --calc="( A.astype(float) +  B.astype(float) )" --overwrite   --co=COMPRESS=DEFLATE --co=ZLEVEL=9


# slope in percentage so * 10 to get in km 

gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope.tif 
gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope.tif 

gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope.tif 
gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope.tif 

gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.r.tif $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope.tif 

# multiply to 10   
gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10.tif -A $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope.tif --calc="( A.astype(float) * 10 )" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32 --NoDataValue=-9999 --outfile=$DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10.tif -A $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope.tif --calc="(A.astype(float) * 10)" --overwrite --co=COMPRESS=DEFLATE --co=ZLEVEL=9

# the slope is not = to 0 in any place, due to + random 

# single cell have slope value 0 o 

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10msk.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10msk.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10msk.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10.tif  -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10.tif -o $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10msk.tif 
gdal_edit.py  -a_nodata -9999   $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10msk.tif


pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10.tif -msknodata 0 -p "=" -nodata -9999 -i $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10.tif -o $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10msk.tif 
gdal_edit.py -a_nodata -9999  $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10msk.tif 


echo velocity temporal regression divided  spatial slope  CRU data 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9
gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.velocity.tif -A $DIR/reg_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.reg.tif -B $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9

echo  velocity temporal regression divided  spatial slope  HadISST data 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/velocity_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.velocity.tif  -A  $DIR/reg_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.reg.tif  -B  $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite  --co=COMPRESS=DEFLATE --co=ZLEVEL=9

echo  calculate aspect 

gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_0.5deg.slope.tif 
gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_0.5deg.slope.tif 

gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.tmp.dat_1.0deg.slope.tif 
gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.mean.r.tif      $DIR/slope_CRU/cru_ts3.23.$YYYY.pre.dat_1.0deg.slope.tif 

gdaldem aspect -zero_for_flat -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.mean.r.tif $DIR/slope_HadISST/HadISST_sst.$YYYY.tmp.dat_1.0deg.slope.tif 


' _ 

exit 





gdaldem aspect  -compute_edges -zero_for_flat   -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_aspect_1960-2009_msk.tif 

gdaldem aspect  -compute_edges -zero_for_flat   -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_aspect_1960-2009_msk.tif 

gdaldem aspect  -compute_edges -zero_for_flat   -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_HadISST/HadISST_sst.tmp.dat_velocity_1960-2009_msk.tif $DIR/mean_HadISST/HadISST_sst.tmp.dat_aspect_1960-2009_msk.tif

# mask out the sea final velocity  =  velocity*_msk.tif 

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -msknodata 100   -p ">"   -nodata -9999  -m   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -o $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif

pksetmask   -co COMPRESS=DEFLATE  -co ZLEVEL=9  -m  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif  -msknodata 100   -p ">"   -nodata -9999  -m   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif -o $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif



# calculate velocity direction 

for PAR in tmp pre ; do 

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh $DIR/mean_CRU loc_${PAR}_velo $DIR/mean_CRU/cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk.tif 

# r.terraflow -s elevation=cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk direction=cru_ts3.23.1901.2014.${PAR}.dat_direction_1960-2009_msk filled=cru_ts3.23.1901.2014.${PAR}.dat_filled_1960-2009_msk  swatershed=cru_ts3.23.1901.2014.${PAR}.dat_swater_1960-2009_msk accumulation=cru_ts3.23.1901.2014.${PAR}.dat_accum_1960-2009_msk  tci=cru_ts3.23.1901.2014.${PAR}.dat_tci_1960-2009_msk

r.watershed  -s elevation=cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk drainage=cru_ts3.23.1901.2014.${PAR}.dat_direction_1960-2009_msk --overwrite 

for file in $(g.mlist -r  type=rast   pattern="cru_ts3.23.1901.2014.${PAR}.dat_*" --q | grep -v velocity   )  ; do 
r.out.gdal -c  createopt="COMPRESS=DEFLATE ,ZLEVEL=9" format=GTiff  type=Int32  input=$file    output=$DIR/mean_CRU/$file.tif  nodata=-9999
done 

done 

#  

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh $DIR/mean_HadISST  loc_HadISST_velo $DIR/mean_HadISST/HadISST_sst.tmp.dat_velocity_1960-2009_msk.tif

r.watershed  -s elevation=HadISST_sst.tmp.dat_velocity_1960-2009_msk   drainage=HadISST_sst.tmp.dat_direction_1960-2009_msk --overwrite 

r.out.gdal -c  createopt="COMPRESS=DEFLATE ,ZLEVEL=9" format=GTiff type=Int32 input=HadISST_sst.tmp.dat_direction_1960-2009_msk   output=$DIR/mean_HadISST/HadISST_sst.tmp.dat_direction_1960-2009_msk.tif nodata=-9999

rm -r  $DIR/mean_*/loc_* 






