# bash    /home/fas/sbsc/ga254/scripts/GEOING/sc3_temporal_slope_models_after_review.sh
# qsub    /home/fas/sbsc/ga254/scripts/GEOING/sc3_temporal_slope_models_after_review.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

module unload Tools/CDO/1.6.4
module load Tools/CDO/1.7.2   
module unload Rpkgs/RGDAL/0.8-11
module load Rpkgs/RGDAL/0.9-3

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING
export RAM=/dev/shm
cd $DIR

#  for dir1 in CCCMA.CanESM2  CSIRO-Mk3L-1-2  HadGEM2-ES  NASA.GISS-E2-R ; do for dir2 in pr tas ; do mkdir -p  $dir1/$dir2 ; done ;done 
#  mv  input/HadGEM2-ES/tas/tas_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210011.nc  input/HadGEM2-ES/tas/tas_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210012.nc
#  mv  input/HadGEM2-ES/tas/tas_oned_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210011.nc   input/HadGEM2-ES/tas/tas_oned_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210012.nc

# rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/reg_models/*/*/*
# rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_models/*/*/*

echo remove  files 

find $DIR/mean_models10/ $DIR/reg_models10/  $DIR/velocity_models10/ $DIR/reg_models10txt/ $DIR/velocity_models10txt/ -name "*.*" | xargs -n 1 -P 8 rm

echo "########################################################################################"
echo "#################MODEL START ###########################################################"
echo "########################################################################################"

grep -e  rcp45 -e G4  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/time/nc10YearWindow4modelTASandTOSJan4th.txt | grep oned  | awk '{  print $1  }'   | xargs -n 1 -P 8  bash -c $'
export file=$1
export filename=$(basename $file .nc) 
export dirinput=$(dirname $file)
export dir=$(echo ${dirinput:6:20})
export dirmod=$(basename $(dirname $(dirname $file)))
export par=$(basename $(dirname $file))

# for YSTART in $(seq 2020 2070) ; do  
for YSTART in $(seq 2070 2070) ; do  

export YSTART
export YEND=$(expr $YSTART + 9)
RAM=/dev/shm

# y = a * X +  addc,-273.15 
# change the temperature to  celsius and calculate the year mean 
if [ ${filename:0:3} = "tas"   ]  || [ ${filename:0:3} = "tos"   ]    ; then 
cdo   -setmissval,-9999  -addc,-273.15    -selyear$(for year in $(seq $YSTART $YEND) ; do echo -n ,$year ; done)     $DIR/$file   $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc  
cdo    -yearmean    $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc   $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  
# gdal_translate  $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc    $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif 
rm -r $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc  
fi 

# change precipitation to mm/year and calculate the sum year 
if [ ${filename:0:3} = "pr_"   ] ; then 
cdo -setmissval,-9999   -mulc,2592000  -selyear$(for year in $(seq $YSTART $YEND) ; do echo -n ,$year ; done)   $DIR/$file   $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc  
cdo yearsum $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  
# gdal_translate  $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc    $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif 
rm $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc   
fi 

echo tmporal regression 
cdo regres -setmissval,-9999  -selyear$(for year in $(seq $YSTART $YEND) ; do echo -n ,$year ; done) $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  

# invert left to right 

gdal_translate -srcwin 0 0 180 180  -a_ullr 0 +90 180 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  $RAM/${filename}_mean_${YSTART}.${YEND}_right.tif 
gdal_translate -srcwin 180 0 180 180  -a_ullr -180 +90 0 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc $RAM/${filename}_mean_${YSTART}.${YEND}_left.tif

gdalbuildvrt -overwrite -a_srs EPSG:4326 -te -180 -90 180 +90 -tr 1 1 $RAM/${filename}_reg_${YSTART}.${YEND}.vrt $RAM/${filename}_mean_${YSTART}.${YEND}_right.tif $RAM/${filename}_mean_${YSTART}.${YEND}_left.tif
gdalwarp -overwrite  -dstnodata -9999  -s_srs  EPSG:4326  -t_srs EPSG:4326 -co COMPRESS=DEFLATE  -co ZLEVEL=9  $RAM/${filename}_reg_${YSTART}.${YEND}.vrt   $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif 
rm -f $RAM/${filename}_reg_${YSTART}.${YEND}.vrt  $RAM/${filename}_mean_${YSTART}.${YEND}_right.tif  $RAM/${filename}_mean_${YSTART}.${YEND}_left.tif
res=1.0

if [ $par = "pr"   ]  || [ $par = "tas"   ]  ; then 

if [ $par = "tas"   ] ; then parCRU=tmp ; fi
if [ $par = "pr"   ]  ; then parCRU=pre ; fi

echo land  
gdal_calc.py --NoDataValue=-9999 --outfile=$RAM/${filename}_velocity${YSTART}.${YEND}land.tif -A $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif -B $DIR/slope_CRU10/cru_ts3.23.1960.2014.${parCRU}.dat_${res}deg.slope10msk.tif  --calc="(A/B)*logical_and(A>-9998,B>-9998)"  --overwrite --type=Float32
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m $DIR/slope_CRU10/cru_ts3.23.1960.2014.${parCRU}.dat_${res}deg.slope10msk.tif  -msknodata -9999   -p "="   -nodata -9999   -i $RAM/${filename}_velocity${YSTART}.${YEND}land.tif  -o $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}land.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}land.tif
rm  $RAM/${filename}_velocity${YSTART}.${YEND}land.tif 

fi 

if [ $par = "tos"   ] || [ $par = "tas"   ]  ; then 

echo ocean
gdal_calc.py --NoDataValue=-9999 --outfile=$RAM/${filename}_velocity${YSTART}.${YEND}ocea.tif -A $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif -B $DIR/slope_HadISST10/HadISST_sst.1960.2014.tmp.dat_1.0deg.slope10msk.tif  --calc="(A/B)*logical_and(A>-9998,B>-9998)" --overwrite --type=Float32
pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -m $DIR/slope_HadISST10/HadISST_sst.1960.2014.tmp.dat_1.0deg.slope10msk.tif -msknodata -9999 -p "=" -nodata -9999   -i $RAM/${filename}_velocity${YSTART}.${YEND}ocea.tif  -o $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}ocea.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}ocea.tif
rm  $RAM/${filename}_velocity${YSTART}.${YEND}ocea.tif 

fi 

done

' _ 

echo mean and median for regression

find $DIR/reg_models10txt  -name "*.*" | xargs -n 1 -P 8 rm
ls $DIR/reg_models10/*/*/*.tif  | xargs -n 1 -P 8  bash -c $'
export file=$1
export filename=$(basename $file .tif) 
export dirinput=$(dirname $file)
export dirmod=$(basename $(dirname $(dirname $file)))
export par=$(basename $(dirname $file))

#############################################
#### start tas 
############################################


if [ $par = "tas"   ] ; then

pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_CRU.tif -msknodata -9999  -nodata -9999 -i $file -o /dev/shm/${filename}_land.tif 
pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISST.tif -msknodata -9999  -nodata -9999 -i $file -o /dev/shm/${filename}_ocea.tif 

for var in land ocea ; do 
export var 

R --vanilla -q <<EOF

library(raster)
library(bigvis)

DIR = Sys.getenv(c(\'DIR\'))
dirmod = Sys.getenv(c(\'dirmod\'))
par = Sys.getenv(c(\'par\'))
filename = Sys.getenv(c(\'filename\'))
var = Sys.getenv(c(\'var\'))
# regression 

if ( var  == "land" ) { 
value = "/dev/shm/${filename}_land.tif"
weightraster = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_CRU.tif" 
}

if ( var  == "ocea" ) { 
value = "/dev/shm/${filename}_ocea.tif"
weightraster = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/GEO_AREA/1.00deg-Area_prj6965_HadISST.tif" 
}

value=na.omit(as.vector (raster(value       )), mode = "numeric") 
weight=na.omit(as.vector(raster(weightraster)), mode = "numeric")

median=bigvis::weighted.median(value,weight)
write.table(median, paste0(DIR,"/reg_models10txt/",dirmod,"/",par,"/",filename,"_reg_",var,"_weightedmedian.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

mean=stats::weighted.mean(value,weight)
write.table(mean, paste0(DIR,"/reg_models10txt/",dirmod,"/",par,"/",filename,"_reg_",var,"_weightedmean.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

EOF
done 
# rm -f /dev/shm/${filename}_land.tif  /dev/shm/${filename}_ocea.tif 
fi 

#############################################
#### start mean median for tos and pr 
############################################

if [ $par = "tos"   ] || [ $par = "pr"   ]   ; then
if [ $par = "tos"   ]   ; then export var=ocea ; fi 
if [ $par = "pr"    ]   ; then export var=land ; fi 

pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $file -msknodata -9999 -nodata -9999 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/area_tif/1.00deg-Area_prj6965.tif -o /dev/shm/${filename}_maskAREA.tif 

R --vanilla -q <<EOF

library(raster)
library(bigvis)

DIR = Sys.getenv(c(\'DIR\'))
dirmod = Sys.getenv(c(\'dirmod\'))
par = Sys.getenv(c(\'par\'))
filename = Sys.getenv(c(\'filename\'))
var = Sys.getenv(c(\'var\'))
file = Sys.getenv(c(\'file\'))
# regression 

value=na.omit(as.vector (raster( file  )), mode = "numeric")
weight=na.omit(as.vector(raster(paste0("/dev/shm/",filename,"_maskAREA.tif"))), mode = "numeric")

median=bigvis::weighted.median(value,weight)
write.table(median, paste0(DIR,"/reg_models10txt/",dirmod,"/",par,"/",filename,"_reg_",var,"_weightedmedian.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

mean=stats::weighted.mean(value,weight)
write.table(mean, paste0(DIR,"/reg_models10txt/",dirmod,"/",par,"/",filename,"_reg_",var,"_weightedmean.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

EOF
# rm  -f /dev/shm/${filename}_maskAREA.tif

fi 

' _ 



# merge the results 

find $DIR/reg_models10txt/*_stat   -name "*.*" | xargs -n 1 -P 8 rm
seq 2070 2070 | xargs -n 1 -P 8 bash -c $'
#  tas 

YSTART=$1 
YEND=$(expr $YSTART + 9)

for landocean in land ocea ; do 
for stat in median mean ; do
cat $DIR/reg_models10txt/*/tas/tas_oned_Amon_*_mean_${YSTART}.${YEND}_reg_${landocean}_weighted$stat.txt | sort -g > $DIR/reg_models10txt/tas_stat/tas_oned_Amon_mean_${YSTART}.${YEND}_reg_${landocean}_weighted$stat.txt 
done 
done 
# tos 
for stat in median mean ; do
cat $DIR/reg_models10txt/*/tos/tos_oned_Amon_*_mean_${YSTART}.${YEND}_reg_ocea_weighted$stat.txt | sort -g > $DIR/reg_models10txt/tos_stat/tos_oned_Amon_mean_${YSTART}.${YEND}_reg_ocea_weighted$stat.txt 
done 
# pr
for stat in median mean ; do
cat $DIR/reg_models10txt/*/pr/pr_oned_Amon_*_mean_${YSTART}.${YEND}_reg_land_weighted$stat.txt | sort -g > $DIR/reg_models10txt/pr_stat/pr_oned_Amon_mean_${YSTART}.${YEND}_reg_land_weighted$stat.txt 
done 

' _ 


find $DIR/velocity_models10txt   -name "*.txt" | xargs -n 1 -P 8 rm
ls $DIR/velocity_models10/*/*/*.tif | xargs -n 1 -P 8  bash -c $'
export file=$1
export filename=$(basename $file .tif) 
export dirinput=$(dirname $file)
export dirmod=$(basename $(dirname $(dirname $file)))
export par=$(basename $(dirname $file))

pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $file  -msknodata -9999 -nodata -9999 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/area_tif/1.00deg-Area_prj6965.tif -o /dev/shm/${filename}_maskAREA.tif 
# velocity 

R --vanilla -q <<EOF

library(raster)
library(bigvis)

DIR = Sys.getenv(c(\'DIR\'))
dirmod = Sys.getenv(c(\'dirmod\'))
par = Sys.getenv(c(\'par\'))
filename = Sys.getenv(c(\'filename\'))
var = Sys.getenv(c(\'var\'))
file = Sys.getenv(c(\'file\'))

value=na.omit(as.vector (raster( file  )), mode = "numeric")
weight=na.omit(as.vector(raster(paste0("/dev/shm/",filename,"_maskAREA.tif"))), mode = "numeric")

median=bigvis::weighted.median(value,weight)
write.table(median, paste0(DIR,"/velocity_models10txt/",dirmod,"/",par,"/",filename,"_weightedmedian.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

mean=stats::weighted.mean(value,weight)
write.table(mean, paste0(DIR,"/velocity_models10txt/",dirmod,"/",par,"/",filename,"_weightedmean.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

EOF

' _ 


# merge the txt file 
find $DIR/velocity_models10txt/*_stat/   -name "*.txt" | xargs -n 1 -P 8 rm
seq 2070 2070 | xargs -n 1 -P 8 bash -c $'
#  tas 

YSTART=$1 
YEND=$(expr $YSTART + 9)

for landocean in land ocea ; do 
for stat in median mean ; do
# echo $DIR/velocity_models10txt/*/tas/tas_oned_Amon_*_velocity${YSTART}.${YEND}${landocean}_weighted$stat.txt 
cat $DIR/velocity_models10txt/*/tas/tas_oned_Amon_*_velocity${YSTART}.${YEND}${landocean}_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/tas_stat/tas_oned_Amon_velocity_${YSTART}.${YEND}_${landocean}_weighted$stat.txt 
done
done 
# tos 
for stat in median mean ; do
cat $DIR/velocity_models10txt/*/tos/tos_oned_Amon_*_velocity${YSTART}.${YEND}ocea_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/tos_stat/tos_oned_Amon_velocity_${YSTART}.${YEND}_ocea_weighted$stat.txt 
                                    
done 
# pr
for stat in median mean ; do
cat $DIR/velocity_models10txt/*/pr/pr_oned_Amon_*_velocity${YSTART}.${YEND}land_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/pr_stat/pr_oned_Amon_velocity_${YSTART}.${YEND}_land_weighted$stat.txt 
done 

' _ 


exit 
exit

# old script 






awk 'NR>1'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/time/nc10YearWindow4modelTASandTOSJan4th.txt   | xargs -n 7 -P 8 bash -c $'
file=$1
filename=$(basename $file .nc) 
dirinput=$(dirname $file)

dir=$(echo ${dirinput:6:20})

echo  $2 $3 $4 $5 $6 $7

for YEARS in $2 $3 $4 $5 $6 $7  ; do # temporal mean for the full period 

if [ $YEARS != "NA" ]  ; then  

# y = a * X +  addc,-273.15 
# change the temperature to  celsius and calculate the year mean 
if [ ${filename:0:3} = "tas"   ]  || [ ${filename:0:3} = "tos"   ]    ; then 
cdo   -setmissval,-9999  -addc,-273.15    -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)     $DIR/$file   $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
cdo    -yearmean    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc       $DIR/mean_models/$dir/${filename}_mean_$YEARS.nc  
rm -f    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
fi 

# change precipitation to mm/year and calculate the sum year 
if [ ${filename:0:3} = "pr_"   ] ; then 
cdo    -setmissval,-9999   -mulc,2592000  -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)   $DIR/$file   $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
cdo   yearsum    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc       $DIR/mean_models/$dir/${filename}_mean_$YEARS.nc  
rm -f    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
fi 
fi 


done 

' _ 

# make the ensamble mean for the full period 
# rm -f  $DIR/mean_models/*/*/*ensamble*.nc          

for YYYY in 2020-2029 2021-2030 2020-2089 2021-2090 2030-2069 2031-2070 2070-2079 2071-2080 2080-2089 2081-2090 2020-2079 2021-2080  ; do 
 
ls     $DIR/mean_models/*/*/*r?i?p1*$YYYY.nc |  xargs -n 3 -P 8  bash -c $' 

r1=$(basename $1 .nc )
r2=$(basename $2 .nc )
r3=$(basename $3 .nc )

dir=$(dirname  $1 )
mod=$( basename $( dirname   $dir) )

filename=$(echo $r1 | awk \'{ gsub ("r1i1p1" ,  "ensamble" ) ; gsub ("r1i2p1" ,  "ensamble" ) ;  print $0  }\') 

ensamble=$(basename $filename .nc ) 

if [ ${ensamble:0:3} = "tas"   ] ||  [ ${ensamble:0:3} = "tos"   ]   ; then par=${ensamble:0:3} ; fi 
if [ ${ensamble:0:3} = "pr_"   ] ; then par=${ensamble:0:2} ; fi 

# ensamble model
rm -f $dir/${ensamble}.nc
echo cdo ensmean   $dir/$r1.nc $dir/$r2.nc  $dir/$r3.nc $dir/${ensamble}.nc
cdo   ensmean   $dir/$r1.nc $dir/$r2.nc  $dir/$r3.nc $dir/${ensamble}.nc

' _ 

done 


# calculate teporal regression using the ensamble model. One regression line for each period, for each model,  

rm -f $DIR/reg_models/*/*/*

ls   mean_models/*/*/*ensamble*.nc    |  xargs -n 1 -P 8  bash -c $'

file=$1
filename=$(basename $file .nc) 
dirinput=$(dirname $file)

dirmod=$(basename $(dirname $(dirname $file)))
par=$(basename $(dirname $file))

YEARS=$(echo ${filename: -9})

echo input   ${file}  output  $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc   
cdo  regres  -setmissval,-9999  -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)  $file   $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc   

dimension=$(echo $filename | grep oned)

if [ -n  $dimension ] ; then dimXY=180 ; res=1.0 ; fi   # dimension for 1 degree     # Size is 360, 180 
if [ -z  $dimension ] ; then dimXY=360 ; res=0.5 ; fi   # dimension for 0.5 degree   # Size is 720, 360  
# invert left to right 

gdal_translate -srcwin 0 0 $dimXY $dimXY -a_ullr 0 +90 180 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc $RAM/${filename}_reg_${YEARS}_right.tif
gdal_translate -srcwin $dimXY 0 $dimXY $dimXY -a_ullr -180 +90 0 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc $RAM/${filename}_reg_${YEARS}_left.tif

gdalbuildvrt  -overwrite   -a_srs EPSG:4326 -te -180 -90 180 +90 -tr $res $res   $RAM/${filename}_reg_${YEARS}.vrt  $RAM/${filename}_reg_${YEARS}_right.tif $RAM/${filename}_reg_${YEARS}_left.tif 
gdalwarp -overwrite  -dstnodata -9999  -s_srs  EPSG:4326  -t_srs EPSG:4326 -co COMPRESS=DEFLATE  -co ZLEVEL=9  $RAM/${filename}_reg_${YEARS}.vrt   $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.tif   
rm -f   $RAM/${filename}_reg_${YEARS}.vrt  $RAM/${filename}_reg_${YEARS}_right.tif $RAM/${filename}_reg_${YEARS}_left.tif 

' _


# echo "########################################################################################"
# echo "################# Calculate velocity ###################################################"
# echo "########################################################################################"

# calculate velocity for the precipitation model using temporal regression mean and  spatial slope from observation    

cleanram
rm -f  $DIR/velocity_models/*/*/*.tif
ls  reg_models/*/*/*.tif   | xargs -n 1  -P 8 bash -c  $' 

file=$1
filename=$(basename $file .tif) 
dirinput=$(dirname $file)

dirmod=$(basename $(dirname $(dirname $file)))
par=$(basename $(dirname $file))

dimension=$(echo $filename | grep oned)

if [ -n  $dimension ] ; then res=1.0 ; fi   # dimension for 1 degree     # Size is 360, 180 
if [ -z  $dimension ] ; then res=0.5 ; fi   # dimension for 0.5 degree   # Size is 720, 360  

if [ $par = "pr"   ]  ; then parCRU=pre ; fi   
if [ $par = "tas"   ] ||  [ $par = "tos"   ]  ; then parCRU=tmp ; fi   

historical=$(echo $filename | grep historical )

if [ -z  $historical  ] ; then 

for YYYY in 1960.2009 1960.2014 ; do 

# land 
gdal_calc.py --NoDataValue=-9999   --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif --calc="(A/B)*logical_and(A>-9998,B>-9998)"  --overwrite --type=Float32
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif -msknodata -9999   -p "="   -nodata -9999   -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
rm  $RAM/${filename}_velocity.tif  

# ocean

if [ $res = "1.0"   ] ; then 
gdal_calc.py  --NoDataValue=-9999  --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif  --calc="(A/B)*logical_and(A>-9998,B>-9998)"   --overwrite  --type=Float32
pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif -msknodata -9999 -p "=" -nodata -9999   -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
rm  $RAM/${filename}_velocity.tif  
fi 
done 
fi 

# valid only for the historical file using slope 1960.2005

if [ -n  $historical  ] ; then 

for YYYY in 1960.2005 ; do 

# land 
gdal_calc.py  --NoDataValue=-9999   --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif  --calc="(A/B)*logical_and(A>-9998,B>-9998)"   --overwrite --type=Float32
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif -msknodata -9999   -p "="   -nodata -9999   -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
rm  $RAM/${filename}_velocity.tif  

# ocean

if [ $res = "1.0"   ] ; then 
gdal_calc.py  --NoDataValue=-9999    --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif --calc="(A/B)*logical_and(A>-9998,B>-9998)"   --overwrite  --type=Float32
pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif -msknodata -9999 -p "=" -nodata -9999 -m  $file  -msknodata -9999 -p "=" -nodata -9999  -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
rm  $RAM/${filename}_velocity.tif  
fi 
done 

fi 

' _ 



# all the different time period but not the historical
# 2 paramenters 
# 2020-2029 valid for CCCMA.CanESM2  HadGEM2-ES NASA.GISS-E2-R 
# 2021-2030 CSIRO-Mk3L-1-2 

rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/{velocity_models,direction_models}/ensamble/*/*

# the multicore do not work
echo 2020-2029 2021-2030 2020-2089 2021-2090 2030-2069 2031-2070 2070-2079 2071-2080 2080-2089 2081-2090 2020-2079 2021-2080  | xargs -n 2 -P 1  bash -c $'

year1=${1} 
year2=${2} 

for MOD in G4 rcp45 ; do 
for PAR in tos tas pr ; do 
for RES in _oned_ _ ; do 
for BASE in 1960.2005 1960.2009 1960.2014 ; do 
for RULES in mean stdev ; do 
for LS in ocea land ; do 

output=$(basename   $(ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif 2> /dev/null  | head -1  )  2> /dev/null  )

if [[ -n  $output ]] ; then  

if [[ $PAR = "tos" && $LS = "land"  ]] ; then  
echo no computation
elif [[ $PAR = "pr" && $LS = "ocea"  ]] ; then  
echo no computation
else 

ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif  $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year2}_velocityBased${BASE}${LS}.tif   >   $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}.txt 

~/bin/pkcomposite    -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9 -file 1   -cr ${RULES}   $( ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif  $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year2}_velocityBased${BASE}${LS}.tif  | xargs -n 1  echo  -i  ) -o  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} 
gdal_edit.py -a_nodata -9999  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} 

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -b 1  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}   $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}_tmp   

gdal_translate  -ot Byte -co COMPRESS=LZW -co ZLEVEL=9 -b 2  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}   $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_TMP_${output: -40}

pkcreatect  -co COMPRESS=LZW -co ZLEVEL=9 -min 1 -max 4 -i  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_TMP_${output: -40} -o  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_OBS_${output: -40}

rm -f   $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_TMP_${output: -40}

mv   $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}_tmp  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} 

if [ $RULES = mean ]  ; then 

echo "calculate direction" using CRU data 

cd  $DIR/direction_models/ensamble/
rm -fr loc_${BASE}_${year1}

## aspect CRU tmp 0.5 

if [ $RES = _oned_  ] ; then RESOBS=1.0 ; fi 
if [ $RES = _  ]      ; then RESOBS=0.5 ; fi 

if [ $LS = land ] ; then ASPECT=aspect_CRU/cru_ts3.23.$BASE.tmp.dat_${RESOBS}deg.aspect.tif      ; fi 
if [ $LS = ocea ] ; then ASPECT=aspect_HadISST/HadISST_sst.$BASE.tmp.dat_${RESOBS}deg.aspect.tif ; fi 

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh   $DIR/direction_models/ensamble   loc_${BASE}_${year1}     $DIR/$ASPECT 

ASPECT=$( basename $ASPECT .tif )

r.in.gdal -o  in=$DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}  out=${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}

r.mask raster=$ASPECT 

echo  create an invers direction   "###################################################" 

r.mapcalc " directionNEG = if( $ASPECT  <  180  ,  $ASPECT  + 180    ,   $ASPECT  - 180  ) " 

echo " create a direction map if velocity > 0 , put aspect , esle put the invert direction  ############################"  

g.list rast 

r.mapcalc "direction = if( \'${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40}\'  > 0, $ASPECT  , directionNEG )" 
r.mask -r  # remove the mask 
# set null to 0 
r.mapcalc "direction0 = if(  isnull(direction) , 0 ,  direction       ) " 

echo export direction 
r.out.gdal -c  createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff  type=Float32 nodata=0   input=direction0  output=$DIR/direction_models/ensamble/$PAR/$( echo ${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} | sed  's/velocity/direction/' )  --overwrite
rm -fr $DIR/direction_models/ensamble/loc_${BASE}_${year1}

fi 
fi 
fi 

done 
done
done 
done 
done 
done 

' _ 


exit 

# 1960-2005 historical 

echo 1960-2005   | xargs -n 1 -P 8  bash -c $' 
year1=$1 

for MOD in historical  ; do 
for PAR in tas pr ; do 
for RES in _oned_ _ ; do 
for BASE in  1960.2005  ; do 
for RULES in mean stdev ; do 
for LS in land ocea ; do 

output=$(basename  $(ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif | head -1 ))

ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif 
echo ""
echo output $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} 
echo""
pkcomposite -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9  -cr ${RULES}   $( ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif   | xargs -n 1  echo  -i  ) -o      $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} 

echo "" 
done 
done
done 
done 
done 
done 

' _ 










exit 



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
