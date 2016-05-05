module load Tools/CDO/1.6.4  

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING

cd $DIR

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/regression/*/*/*

# make a  select only day 1960 2014 

# observation temporal monthly regression 
cdo regres  -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.pre.dat.nc    $DIR/mean/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.nc   
cdo regres  -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc    $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.nc   

# transform to tif 
gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   $DIR/mean/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.nc     $DIR/mean/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.tif 
gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.nc     $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.tif  

# multiply the montly regression to 12 to get yearly regression   
gdal_calc.py --type=Float32   --outfile=$DIR/mean/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009_year.tif    -A $DIR/mean/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009.tif     --calc="( A.astype(float) * 12 )"   --overwrite
gdal_calc.py --type=Float32   --outfile=$DIR/mean/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009_year.tif    -A $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009.tif     --calc="( A.astype(float) * 12 )"  --overwrite

# spatial change  

# observation temporal mean  

cdo timmean -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.pre.dat.nc     $DIR/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.nc   
cdo timmean -selyear$(for year in $(seq 1960 2009 ) ; do echo -n ,$year ; done)    $DIR/CRU_ts3.23/cru_ts3.23.1901.2014.tmp.dat.nc     $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.nc   

# observation temporal mean   transform to tif

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  $DIR/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.nc     $DIR/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.nc     $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.tif  

echo create random variable for temperature 
R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(259200,max=0.05, min=-0.05),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009_random.tif",options=c("COMPRESS=LZW","ZLEVEL=9"),formats=GTiff,overwrite=TRUE)
EOF

echo create random variable for precipitation 
R --vanilla -q <<EOF
library(raster)
raster=raster(matrix(runif(259200,max=0.1, min=-0.1),360,720) , xmn=-180, xmx=180, ymn=-90, ymx=190 , crs="+proj=longlat +datum=WGS84 +no_defs")
writeRaster(raster,filename="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009_random.tif",options=c("COMPRESS=LZW","ZLEVEL=9"),formats=GTiff,overwrite=TRUE)
EOF

# add the random to temporal mean for precipitation and temperature 

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009r.tif  -A  $DIR/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009.tif -B   $DIR/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009_random.tif   --calc="( A.astype(float) +  B.astype(float) )"  --overwrite

gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009r.tif  -A  $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.tif -B   $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009_random.tif  --calc="( A.astype(float) +  B.astype(float) )"  --overwrite

# slope in percentage so * 10 to get in km 

gdaldem slope -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  -p $DIR/mean/cru_ts3.23.1901.2014.pre.dat_mean_1960-2009r.tif   $DIR/mean/cru_ts3.23.1901.2014.pre.dat_slope_1960-2009.tif
gdaldem slope -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  -p $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009r.tif   $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_slope_1960-2009.tif

# multiply to 10   
gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif  -A  $DIR/mean/cru_ts3.23.1901.2014.pre.dat_slope_1960-2009.tif   --calc="( A.astype(float) * 10 )"  --overwrite
gdal_calc.py --type=Float32  --NoDataValue=-9999  --outfile=$DIR/mean/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif  -A  $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_slope_1960-2009.tif   --calc="( A.astype(float) * 10 )"  --overwrite
# the slope is not = to 0 in any place, due to + random 

# velocity temporal regression / spatial slope 

gdal_calc.py --type=Float32  --NoDataValue=-9999 --outfile=$DIR/mean/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif -A $DIR/mean/cru_ts3.23.1901.2014.pre.dat_reg_1960-2009_year.tif  -B  $DIR/mean/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif   --calc="( A.astype(float) / ( B.astype(float) ))" --overwrite
gdal_calc.py --type=Float32 --NoDataValue=-9999  --outfile=$DIR/mean/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -A $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_reg_1960-2009_year.tif  -B  $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif   --calc="( A.astype(float) / ( B.astype(float) ))"  --overwrite


# mask out the sea final velocity  =  velocity*_msk.tif 

pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m  $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif  -msknodata 100   -p ">"   -nodata -9999   -i $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009.tif -o $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_velocity_1960-2009_msk.tif

pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m  $DIR/mean/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif  -msknodata 100   -p ">"   -nodata -9999   -i $DIR/mean/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009.tif -o $DIR/mean/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif
gdal_edit.py  -a_nodata -9999  $DIR/mean/cru_ts3.23.1901.2014.pre.dat_velocity_1960-2009_msk.tif

# # start to make temporal regression in to the model shenarios 

# # Size is 192, 145  remove from now 
# # regression/MOHC.HadGEM2-ES/tas/tas_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-209911.nc Size is 192, 145
# # regression/MOHC.HadGEM2-ES/tas/tas_Amon_HadGEM2-ES_rcp45_r2i1p1_200512-210012.nc Size is 192, 145
# # regression/MOHC.HadGEM2-ES/tas/tas_Amon_HadGEM2-ES_rcp45_r3i1p1_200512-210012.nc Size is 192, 145


tail -60 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/time/nc_time_frame.csv | grep -ve tas_Amon_HadGEM2-ES_rcp45_r2i1p1_200512-210012.nc -ve tas_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-209911.nc  -ve tas_Amon_HadGEM2-ES_rcp45_r3i1p1_200512-210012.nc -ve tas_Amon_HadGEM2-ES_rcp45_r2i1p1_200512-210012.nc  | xargs -n 6 -P 8 bash -c $' 
                                                                                                     

file=$1
filename=$(basename $file .nc) 
dirinput=$(dirname $file)

dir=$(echo ${dirinput:6:20})

echo  $2 $3 $4 $5 $6 

for YEARS in $2 $3 $4 $5 $6 ; do 

if [ $YEARS != "NA" ]  ; then  

# y = a * X +  

# change the temperature to  celsius and calculate the temporal regression 
if [ ${filename:0:3} = "tas"   ] ; then 

cdo addc,-273.15 -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)     $DIR/$file   $DIR/regression/$dir/${filename}_regT_$YEARS.nc  
cdo regres    $DIR/regression/$dir/${filename}_regT_$YEARS.nc   $DIR/regression/$dir/${filename}_reg_$YEARS.nc  
rm $DIR/regression/$dir/${filename}_regT_$YEARS.nc  

fi 

# change precipitation to mm/year and calculate the temporal regression 

if [ ${filename:0:3} = "pr_"   ] ; then 

cdo mulc,2592000  -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)     $DIR/$file   $DIR/regression/$dir/${filename}_regP_$YEARS.nc  
cdo regres    $DIR/regression/$dir/${filename}_regP_$YEARS.nc   $DIR/regression/$dir/${filename}_reg_$YEARS.nc  
rm $DIR/regression/$dir/${filename}_regP_$YEARS.nc  

fi 


# Size is 720, 360 

# invert left to right 

gdal_translate  -srcwin 0 0  360 360 -a_ullr 0 +90 180 -90     -co COMPRESS=LZW -co ZLEVEL=9      $DIR/regression/$dir/${filename}_reg_$YEARS.nc       $DIR/regression/$dir/${filename}_reg_${YEARS}_right.tif
gdal_translate  -srcwin 360 0  360 360 -a_ullr -180 +90 0 -90  -co COMPRESS=LZW -co ZLEVEL=9      $DIR/regression/$dir/${filename}_reg_$YEARS.nc       $DIR/regression/$dir/${filename}_reg_${YEARS}_left.tif

gdalbuildvrt  -a_srs EPSG:4326  -te -180 -90 180 +90  -tr 0.5 0.5  $DIR/regression/$dir/${filename}_reg_${YEARS}.vrt    $DIR/regression/$dir/${filename}_reg_${YEARS}_right.tif      $DIR/regression/$dir/${filename}_reg_${YEARS}_left.tif
gdal_translate  -a_srs EPSG:4326    -co COMPRESS=LZW -co ZLEVEL=9  $DIR/regression/$dir/${filename}_reg_${YEARS}.vrt  $DIR/regression/$dir/${filename}_reg_${YEARS}.tif 

rm -f   $DIR/regression/$dir/${filename}_reg_${YEARS}_right.tif      $DIR/regression/$dir/${filename}_reg_${YEARS}_left.tif $DIR/regression/$dir/${filename}_reg_${YEARS}.vrt 

# moltiply * 12 the regression line to 12 to the get year temporal change 

gdal_calc.py --outfile=$DIR/regression/$dir/${filename}_reg_${YEARS}_year.tif   -A $DIR/regression/$dir/${filename}_reg_${YEARS}.tif   --calc="( A.astype(float)  * 12 )"  --overwrite  --type=Float32   --overwrite

# mask the sea  based the cru sea  
pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.tif -msknodata 100   -p ">"   -nodata -9999   -i  $DIR/regression/$dir/${filename}_reg_${YEARS}_year.tif -o  $DIR/regression/$dir/${filename}_reg_${YEARS}_year_msk.tif 

gdal_edit.py  -a_nodata -9999 $DIR/regression/$dir/${filename}_reg_${YEARS}_year_msk.tif 
fi 

# final file to calculate the velocity is $DIR/regression/$dir/${filename}_reg_${YEARS}_year_msk.tif 

done 

' _ 


echo  calculate the mean and standard deviation  of the different temporal regression for the differen model run 

rm -f $DIR/regression/*/*/*_{stdev,mean}_*.tif  
ls  $DIR/regression/*/*/*r?i1p1*_year_msk.tif   | awk '{ gsub ("r1i", " ") ; gsub ("r2i", " ") ; gsub ("r3i", " ") ; gsub ("r4i", " ")  ; gsub ("r5i", " ")  ;   print  }' | sort | uniq  | xargs -n 2 -P 8  bash -c $' 

pkcomposite  -co COMPRESS=LZW -co ZLEVEL=9  -cr stdev  $( ls ${1}r?i$2 | xargs -n 1  echo  -i  ) -o   ${1}stdev${2:3} ; gdal_edit.py  -a_nodata -9999  ${1}stdev${2:3}
pkcomposite  -co COMPRESS=LZW -co ZLEVEL=9  -cr mean   $( ls ${1}r?i$2 | xargs -n 1  echo  -i  ) -o   ${1}mean${2:3}  ; gdal_edit.py  -a_nodata -9999  ${1}mean${2:3}

' _  

# 
# echo temporal regress includeing the sea  # removed for the actual calculation  
# ls    $DIR/regression/*/*/*r?i1p1*_year.tif   | awk '{ gsub ("r1i", " ") ; gsub ("r2i", " ") ; gsub ("r3i", " ") ; gsub ("r4i", " ")  ; gsub ("r5i", " ")  ;   print  }' | sort | uniq  | xargs -n 2 -P 8  bash -c $' 
# echo $1   $2 
# pkcomposite  -co COMPRESS=LZW -co ZLEVEL=9  -cr stdev  $( ls ${1}r?i$2 | xargs -n 1  echo  -i  ) -o   ${1}stdev_SEA${2:3} ; gdal_edit.py  -a_nodata -9999  ${1}stdev_SEA${2:3}
 #pkcomposite  -co COMPRESS=LZW -co ZLEVEL=9  -cr mean   $( ls ${1}r?i$2 | xargs -n 1  echo  -i  ) -o   ${1}mean_SEA${2:3}  ; gdal_edit.py  -a_nodata # -9999  ${1}mean$_SEA{2:3}
# 
# ' _  


# calculate velocity for the precipitation model using temporal regression mean and cru spatial slope   

rm -f  $DIR/regression/*/*/pr*velocity*
ls  $DIR/regression/*/*/pr*_mean_*_year_msk.tif     | xargs -n 1  -P 8 bash -c  $' 
file=$1
filename=$(basename $file _year_msk.tif) 
dir=$(dirname $file)

gdal_calc.py --outfile=$dir/${filename}_velocity.tif -A $file -B $DIR/mean/cru_ts3.23.1901.2014.pre.dat_slope10_1960-2009.tif --calc="( A.astype(float) /  B.astype(float) )"  --overwrite   --type=Float32
pksetmask  -co COMPRESS=LZW -co ZLEVEL=9  -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.tif -msknodata 100   -p ">"   -nodata -9999  -i $dir/${filename}_velocity.tif  -o $dir/${filename}_velocity_msk.tif 
gdal_edit.py  -a_nodata -9999 $dir/${filename}_velocity_msk.tif 
' _ 

# calculate velocity for the temperature  model using temporal regression mean and cru spatial slope   

rm -f  $DIR/regression/*/*/tas*velocity*
ls  $DIR/regression/*/*/tas*_mean_*_year_msk.tif    | xargs -n 1  -P 8 bash -c  $' 

file=$1
filename=$(basename $file _year_msk.tif) 
dir=$(dirname $file)

gdal_calc.py --outfile=$dir/${filename}_velocity.tif -A $file -B  $DIR/mean/cru_ts3.23.1901.2014.tmp.dat_slope10_1960-2009.tif  --calc="(  A.astype(float)  / B.astype(float) )"  --overwrite   --type=Float32
pksetmask  -co COMPRESS=LZW -co ZLEVEL=9  -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean/cru_ts3.23.1901.2014.tmp.dat_mean_1960-2009.tif -msknodata 100   -p ">"   -nodata -9999  -i $dir/${filename}_velocity.tif  -o $dir/${filename}_velocity_msk.tif 
gdal_edit.py  -a_nodata -9999 $dir/${filename}_velocity_msk.tif 

rm $dir/${filename}_velocity.tif 
' _ 


echo This is for printing the results 

rm -fr /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb/loc_*    $DIR/regression/*/*/*.aux.xml
echo precipitation velocity model  > $DIR/velocity_results.txt
ls   $DIR/regression/*/*/pr*velocity_msk.tif   | xargs -n 1  -P 1 bash -c  $' echo $( basename $1 )  $(gdalinfo -stats  $1 | grep   MIN | awk \' { gsub ("STATISTICS_","" ) ; print  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )    $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep median  | awk \' { gsub ("even number of cells","=" ) ; gsub ("odd number of cells","=" )   ;    print  }\'     )   ' _   2>  /dev/null   >>  $DIR/velocity_results.txt  ; rm -f    $DIR/regression/*/*/*.aux.xml

echo ""
echo temperature  velocity model  >> $DIR/velocity_results.txt
ls   $DIR/regression/*/*/tas*velocity_msk.tif   | xargs -n 1  -P 1 bash -c  $' echo $( basename $1)  $(gdalinfo -stats  $1 | grep   MIN | awk \' { gsub ("STATISTICS_","" ) ; print  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )    $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep  median  | awk \' { gsub ("even number of cells","=" ) ; gsub ("odd number of cells","=" )   ; print  }\'     )   ' _         2>  /dev/null    >>  $DIR/velocity_results.txt

echo ""
echo precipitation mean regression model  >> $DIR/velocity_results.txt
ls   $DIR/regression/*/*/pr*_mean_*_year_msk.tif  | xargs -n 1  -P 1 bash -c  $' echo $( basename $1)  $(gdalinfo -stats  $1 | grep   MIN | awk \' { gsub ("STATISTICS_","" ) ; print  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )    $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep  median | awk \' { gsub ("even number of cells","=" ) ; gsub ("odd number of cells","=" )  ;  print  }\'     )   ' _       2>  /dev/null    >>  $DIR/velocity_results.txt

echo ""
echo temperature mean regression model    >>  $DIR/velocity_results.txt
ls   $DIR/regression/*/*/tas*_mean_*_year_msk.tif  | xargs -n 1  -P 1 bash -c  $' echo $( basename $1)  $(gdalinfo -stats  $1 | grep   MIN | awk \' { gsub ("STATISTICS_","" ) ; print  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )    $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep -e median   | awk \' { gsub ("even number of cells","=" ) ;  gsub ("odd number of cells","=" ) ;  print  }\'     )   ' _   2>  /dev/null    >>  $DIR/velocity_results.txt

# echo ""
# echo precipitation mean regression SEA model  >> $DIR/velocity_results.txt
# ls   $DIR/regression/*/*/pr*_mean_SEA_*_year_msk.tif  | xargs -n 1  -P 1 bash -c  $' echo $( basename $1)  $(gdalinfo -stats  $1 | grep   MIN | awk \' { gsub ("STATISTICS_","" ) ; print  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )    $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep  median | awk \' { gsub ("even number of cells","=" ) ; gsub ("odd number of cells","=" )  ;  print  }\'     )   ' _       2>  /dev/null    >>  $DIR/velocity_results.txt

# echo ""
# echo temperature mean regression SEA model    >>  $DIR/velocity_results.txt
# ls   $DIR/regression/*/*/tas*_mean_SEA_*_year_msk.tif  | xargs -n 1  -P 1 bash -c  $' echo $( basename $1)  $(gdalinfo -stats  $1 | grep   MIN | awk \' { gsub ("STATISTICS_","" ) ; print  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )    $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep -e median   | awk \' { gsub ("even number of cells","=" ) ;  gsub ("odd number of cells","=" ) ;  print  }\'     )   ' _   2>  /dev/null    >>  $DIR/velocity_results.txt

echo ""
rm -f $DIR/mean/*.aux.xml
echo temperature and precipitation  velocity observation  >> $DIR/velocity_results.txt
ls   $DIR/mean/*velo*msk*    | xargs -n 1  -P 1 bash -c  $' echo $( basename $1)  $(gdalinfo -stats  $1 | grep   MIN | awk \' { gsub ("STATISTICS_","" ) ; print  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk \' { gsub ("STATISTICS_","" ) ; print  }\' )    $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep -e  median  | awk \' { gsub ("even number of cells","=" ) ; gsub ("odd number of cells","=" ) ; print  }\'     )   ' _   2>  /dev/null   >>  $DIR/velocity_results.txt

rm   $DIR/regression/*/*/*aux*  $DIR/mean/*aux* 
