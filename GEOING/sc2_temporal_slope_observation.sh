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

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/regression/*/*/*

# make a  select only day 1960 2014 

# observation temporal monthly regression 
cdo regres  -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.pre.dat.nc    $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.nc   
cdo regres  -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc    $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.nc   

cdo regres  -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/HadISST/HadISST_sst.nc   $DIR/mean_HadISST/HadISST_sst.tmp.dat_reg_1960-2009.nc  

# transform to tif 
gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.nc     $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.tif 
gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.nc     $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.tif  

gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9  NETCDF:"$DIR/mean_HadISST/HadISST_sst.tmp.dat_reg_1960-2009.nc":sst    $DIR/mean_HadISST/HadISST_sst.tmp.dat_reg_1960-2009.tif  

# multiply the montly regression to 12 to get yearly regression   
gdal_calc.py --type=Float32   --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009_year.tif   -A $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.tif     --calc="( A.astype(float) * 12 )"   --overwrite
gdal_calc.py --type=Float32   --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009_year.tif   -A $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.tif     --calc="( A.astype(float) * 12 )"  --overwrite

gdal_calc.py --type=Float32   --outfile=$DIR/mean_HadISST/HadISST_sst.tmp.dat_reg_1960-2009_year.tif   -A $DIR/mean_HadISST/HadISST_sst.tmp.dat_reg_1960-2009.tif   --calc="( A.astype(float) * 12 )"  --overwrite

# spatial change  

# observation temporal mean_CRU  

cdo timmean -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.pre.dat.nc     $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.nc   
cdo timmean -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc     $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.nc   

cdo timmean  -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/HadISST/HadISST_sst.nc $DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009.nc  

# observation temporal mean_CRU   transform to tif

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.nc     $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.nc     $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.tif  

gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9  NETCDF:"$DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009.nc":sst    $DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009.tif  

echo create random variable for temperature 
R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(259200,max=0.05, min=-0.05),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009_random.tif",options=c("COMPRESS=LZW","ZLEVEL=9"),formats=GTiff,overwrite=TRUE)
EOF

R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(259200,max=0.05, min=-0.05),180,360) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009_random.tif",options=c("COMPRESS=LZW","ZLEVEL=9"),formats=GTiff,overwrite=TRUE)
EOF

echo create random variable for precipitation 
R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(259200,max=0.1, min=-0.1),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009_random.tif",options=c("COMPRESS=LZW","ZLEVEL=9"),formats=GTiff,overwrite=TRUE)
EOF

# add the random to temporal mean for precipitation and temperature 

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009r.tif  -A  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.tif -B   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009_random.tif   --calc="( A.astype(float) +  B.astype(float) )"  --overwrite

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009r.tif  -A  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.tif -B   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009_random.tif  --calc="( A.astype(float) +  B.astype(float) )"  --overwrite

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009r.tif  -A  $DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009.tif -B   $DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009_random.tif  --calc="( A.astype(float) +  B.astype(float) )"  --overwrite

# slope in percentage so * 10 to get in km 

gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  -p $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009r.tif   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope_1960-2009.tif
gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  -p $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009r.tif   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope_1960-2009.tif

gdaldem slope -compute_edges -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  -p $DIR/mean_HadISST/HadISST_sst.tmp.dat_mean_1960-2009r.tif   $DIR/mean_HadISST/HadISST_sst.tmp.dat_slope_1960-2009.tif

# multiply to 10   
gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif  -A  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope_1960-2009.tif   --calc="( A.astype(float) * 10 )"  --overwrite
gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif  -A  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope_1960-2009.tif   --calc="( A.astype(float) * 10 )"  --overwrite

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean_HadISST/HadISST_sst.tmp.dat_slope10_1960-2009.tif  -A  $DIR/mean_HadISST/HadISST_sst.tmp.dat_slope_1960-2009.tif   --calc="( A.astype(float) * 10 )"  --overwrite

# the slope is not = to 0 in any place, due to + random 

# single cell have slope value 0 o 
pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif  -o $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009_msk.tif 
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009_msk.tif 

pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif  -o $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009_msk.tif 
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009_msk.tif 

pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m   $DIR/mean_HadISST/HadISST_sst.tmp.dat_slope10_1960-2009.tif      -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_HadISST/HadISST_sst.tmp.dat_slope10_1960-2009.tif  -o $DIR/mean_HadISST/HadISST_sst.tmp.dat_slope10_1960-2009_msk.tif 
gdal_edit.py  -a_nodata -9999  $DIR/mean_HadISST/HadISST_sst.tmp.dat_slope10_1960-2009_msk.tif


# velocity temporal regression / spatial slope 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif -A $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009_year.tif  -B  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009_msk.tif   --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite
gdal_calc.py --type=Float32 --NoDataValue=-9999  --outfile=$DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -A $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009_year.tif  -B  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009_msk.tif   --calc="( A.astype(float) / ( B.astype(float) ))"  --overwrite

gdal_calc.py --type=Float32 --NoDataValue=-9999  --outfile=$DIR/mean_HadISST/HadISST_sst.tmp.dat_velocity_1960-2009_msk.tif  -A $DIR/mean_HadISST/HadISST_sst.tmp.dat_reg_1960-2009_year.tif -B $DIR/mean_HadISST/HadISST_sst.tmp.dat_slope10_1960-2009_msk.tif --calc="( A.astype(float) / ( B.astype(float) ))"  --overwrite

# mask out the sea final velocity  =  velocity*_msk.tif 

pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif  -msknodata 100   -p ">"   -nodata -9999  -m   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -o $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif

pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif  -msknodata 100   -p ">"   -nodata -9999  -m   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif   -msknodata 0 -p "=" -nodata -9999  -i $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif -o $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif

### calculate aspect 

gdaldem aspect  -compute_edges -zero_for_flat   -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif   $DIR/mean_CRU/cru_ts3.23.1901.2014.pre.dat_aspect_1960-2009_msk.tif 

gdaldem aspect  -compute_edges -zero_for_flat   -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif   $DIR/mean_CRU/cru_ts3.23.1901.2014.tmp.dat_aspect_1960-2009_msk.tif 

gdaldem aspect  -compute_edges -zero_for_flat   -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/mean_HadISST/HadISST_sst.tmp.dat_velocity_1960-2009_msk.tif $DIR/mean_HadISST/HadISST_sst.tmp.dat_aspect_1960-2009_msk.tif


# calculate velocity direction 

for PAR in tmp pre ; do 

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh $DIR/mean_CRU loc_${PAR}_velo $DIR/mean_CRU/cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk.tif 

# r.terraflow -s elevation=cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk direction=cru_ts3.23.1901.2014.${PAR}.dat_direction_1960-2009_msk filled=cru_ts3.23.1901.2014.${PAR}.dat_filled_1960-2009_msk  swatershed=cru_ts3.23.1901.2014.${PAR}.dat_swater_1960-2009_msk accumulation=cru_ts3.23.1901.2014.${PAR}.dat_accum_1960-2009_msk  tci=cru_ts3.23.1901.2014.${PAR}.dat_tci_1960-2009_msk

r.watershed  -s elevation=cru_ts3.23.1901.2014.${PAR}.dat_velocity_1960-2009_msk drainage=cru_ts3.23.1901.2014.${PAR}.dat_direction_1960-2009_msk --overwrite 

for file in $(g.mlist -r  type=rast   pattern="cru_ts3.23.1901.2014.${PAR}.dat_*" --q | grep -v velocity   )  ; do 
r.out.gdal -c  createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Int32  input=$file    output=$DIR/mean_CRU/$file.tif  nodata=-9999
done 

done 

#  

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh $DIR/mean_HadISST  loc_HadISST_velo $DIR/mean_HadISST/HadISST_sst.tmp.dat_velocity_1960-2009_msk.tif

r.watershed  -s elevation=HadISST_sst.tmp.dat_velocity_1960-2009_msk   drainage=HadISST_sst.tmp.dat_direction_1960-2009_msk --overwrite 

r.out.gdal -c  createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff type=Int32 input=HadISST_sst.tmp.dat_direction_1960-2009_msk   output=$DIR/mean_HadISST/HadISST_sst.tmp.dat_direction_1960-2009_msk.tif nodata=-9999

rm -r  $DIR/mean_*/loc_* 






