#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

#######################################################################################################################
#
# AUTHOR:    Giuseppe Amatulli ( https://research.computing.yale.edu/about/staff/giuseppe-amatulli ; www.spatial-ecology.net )
#            
#            Potentially dangerous consequences for biodiversity of solar geoengineering implementation and termination     
#            Christopher H. Trisos, Giuseppe Amatulli, Jessica Gurevitch, Alan Robock, Lili Xia, Brian Zambri
#            Nature Ecology & Evolution 
#
# PURPOSE:   Calculate future climate velocity using model scenario CCCMA.CanESM2  CSIRO-Mk3L-1-2  HadGEM2-ES  NASA.GISS-E2-R 
# SOFTWARE:  Combination of several Open Source Software R, CDO, PKTOOLS, GDAL integrate under BASH language 
#
#######################################################################################################################

# bash    /home/fas/sbsc/ga254/scripts/GEOING/sc3_temporal_slope_models_after_review.sh
# qsub    /home/fas/sbsc/ga254/scripts/GEOING/sc3_temporal_slope_models_after_review.sh

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

# remove  files 

# find $DIR/mean_models10/ $DIR/reg_models10/  $DIR/velocity_models10/ $DIR/reg_models10txt/ $DIR/velocity_models10txt/ -name "*.*" | xargs -n 1 -P 8 rm

echo "########################################################################################"
echo "#################MODEL START ###########################################################"
echo "########################################################################################"

####################################
# calculate velocity for all 10-year periods and for long-term periods (see if condition)
####################################

grep -e  rcp45 -e G4  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/time/nc10YearWindow4modelTASandTOSJan4th.txt | grep oned  | awk '{  print $1  }'   | xargs -n 1 -P 8  bash -c $'
file=$1
filename=$(basename $file .nc) 
dirinput=$(dirname $file)
dir=$(echo ${dirinput:6:20})
dirmod=$(basename $(dirname $(dirname $file)))
par=$(basename $(dirname $file))
RAM=/dev/shm


for YSTART in $(echo $(seq 2020 2070) 202000 203000 ) ; do   

# 10-year periods
if [ $YSTART  -lt 3000  ] ; then YEND=$(expr $YSTART + 9)   ; YSTARTIN=$YSTART ;  YENDIN=$(expr $YSTART + 9 )  
if [ $dirmod = "CSIRO-Mk3L-1-2"  ] ; then  YSTARTIN=$(expr $YSTART + 1) ;  YENDIN=$(expr $YSTART + 9 + 1)  ; else   YSTARTIN=$YSTART  ;  YENDIN=$(expr $YSTART + 9) ;  fi
fi 

# long term 2020-2079 # (CSIRO model 2021-2080)
if [ $YSTART -eq 202000  ]; then YSTART=2020 ;  YSTARTIN=$YSTART ;  YENDIN=$(expr $YSTART + 59)  ;  YEND=$(expr $YSTART + 59) 
if [ $dirmod = "CSIRO-Mk3L-1-2"  ] ; then  YSTARTIN=$(expr $YSTART + 1) ;  YENDIN=$(expr $YSTART + 59 + 1)  ; else   YSTARTIN=$YSTART  ;  YENDIN=$(expr $YSTART + 59) ;  YEND=$(expr $YSTART + 59)  ; fi 
fi 

# long term G4 2030-2069 #  (CSIRO model 2031-2070)
if [ $YSTART -eq 203000 ] ; then YSTART=2030 ;  YSTARTIN=$YSTART ;  YENDIN=$(expr $YSTART + 39)  ;  YEND=$(expr $YSTART + 39)  
if [ $dirmod = "CSIRO-Mk3L-1-2"  ] ; then  YSTARTIN=$(expr $YSTART + 1) ;  YENDIN=$(expr $YSTART + 39 + 1)  ; else   YSTARTIN=$YSTART  ;  YENDIN=$(expr $YSTART + 39) ; YEND=$(expr $YSTART + 39)   ; fi 
fi 

# y = a * X +  addc,-273.15 
# change the temperature to  celsius and calculate the year mean 
if [ ${filename:0:3} = "tas"   ]  || [ ${filename:0:3} = "tos"   ]    ; then 
cdo   -setmissval,-9999  -addc,-273.15    -selyear$(for year in $(seq $YSTARTIN $YENDIN) ; do echo -n ,$year ; done)     $DIR/$file   $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc  
cdo    -yearmean    $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc   $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  
gdal_translate  $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc    $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif 
rm -r $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc  
fi 

# change precipitation to mm/year and calculate the sum year 
if [ ${filename:0:3} = "pr_"   ] ; then 
cdo -setmissval,-9999   -mulc,2592000  -selyear$(for year in $(seq $YSTARTIN $YENDIN) ; do echo -n ,$year ; done)   $DIR/$file   $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc  
cdo yearsum $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  
gdal_translate  $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc    $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif 
rm $RAM/${filename}_meanTMP_${YSTART}.${YEND}.nc   
fi 

# calculate temporal regression 
cdo regres -setmissval,-9999  -selyear$(for year in $(seq $YSTART $YEND) ; do echo -n ,$year ; done) $DIR/mean_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  

# invert raster west to east 

gdal_translate -srcwin 0 0 180 180  -a_ullr 0 +90 180 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc  $RAM/${filename}_mean_${YSTART}.${YEND}_right.tif 
gdal_translate -srcwin 180 0 180 180  -a_ullr -180 +90 0 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.nc $RAM/${filename}_mean_${YSTART}.${YEND}_left.tif

gdalbuildvrt -overwrite -a_srs EPSG:4326 -te -180 -90 180 +90 -tr 1 1 $RAM/${filename}_reg_${YSTART}.${YEND}.vrt $RAM/${filename}_mean_${YSTART}.${YEND}_right.tif $RAM/${filename}_mean_${YSTART}.${YEND}_left.tif
gdalwarp -overwrite  -dstnodata -9999  -s_srs  EPSG:4326  -t_srs EPSG:4326 -co COMPRESS=DEFLATE  -co ZLEVEL=9  $RAM/${filename}_reg_${YSTART}.${YEND}.vrt   $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif 
rm -f $RAM/${filename}_reg_${YSTART}.${YEND}.vrt  $RAM/${filename}_mean_${YSTART}.${YEND}_right.tif  $RAM/${filename}_mean_${YSTART}.${YEND}_left.tif
res=1.0

if [ $par = "pr"   ]  || [ $par = "tas"   ]  ; then 

if [ $par = "tas"   ] ; then parCRU=tmp ; fi
if [ $par = "pr"   ]  ; then parCRU=pre ; fi

# calculate land climate velocity  
gdal_calc.py --NoDataValue=-9999 --outfile=$RAM/${filename}_velocity${YSTART}.${YEND}land.tif -A $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif -B $DIR/slope_CRU10/cru_ts3.23.1960.2014.${parCRU}.dat_${res}deg.slope10msk.tif  --calc="(A/B)*logical_and(A>-9998,B>-9998)"  --overwrite --type=Float32
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m $DIR/slope_CRU10/cru_ts3.23.1960.2014.${parCRU}.dat_${res}deg.slope10msk.tif  -msknodata -9999   -p "="   -nodata -9999   -i $RAM/${filename}_velocity${YSTART}.${YEND}land.tif  -o $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}land.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}land.tif
rm  $RAM/${filename}_velocity${YSTART}.${YEND}land.tif 

fi 

if [ $par = "tos"   ] || [ $par = "tas"   ]  ; then 

# calculate ocean climate velocity
gdal_calc.py --NoDataValue=-9999 --outfile=$RAM/${filename}_velocity${YSTART}.${YEND}ocea.tif -A $DIR/reg_models10/$dir/${filename}_mean_${YSTART}.${YEND}.tif -B $DIR/slope_HadISST10/HadISST_sst.1960.2014.tmp.dat_1.0deg.slope10msk.tif  --calc="(A/B)*logical_and(A>-9998,B>-9998)" --overwrite --type=Float32
pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -m $DIR/slope_HadISST10/HadISST_sst.1960.2014.tmp.dat_1.0deg.slope10msk.tif -msknodata -9999 -p "=" -nodata -9999   -i $RAM/${filename}_velocity${YSTART}.${YEND}ocea.tif  -o $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}ocea.tif
gdal_edit.py  -a_nodata -9999 $DIR/velocity_models10/$dirmod/$par/${filename}_velocity${YSTART}.${YEND}ocea.tif
rm  $RAM/${filename}_velocity${YSTART}.${YEND}ocea.tif 

fi 

done

' _ 


############################################
# calculate global area-weighted mean and median for temporal regression
############################################

find $DIR/reg_models10txt  -name "*.*" | xargs -n 1 -P 8 rm
ls $DIR/reg_models10/*/*/*.tif  | xargs -n 1 -P 8  bash -c $'
export file=$1
export filename=$(basename $file .tif) 
export dirinput=$(dirname $file)
export dirmod=$(basename $(dirname $(dirname $file)))
export par=$(basename $(dirname $file))


#### mean and median for tas 

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
rm -f /dev/shm/${filename}_land.tif  /dev/shm/${filename}_ocea.tif 
fi 


#### mean and median for tos and pr 

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

value=na.omit(as.vector (raster( file  )), mode = "numeric")
weight=na.omit(as.vector(raster(paste0("/dev/shm/",filename,"_maskAREA.tif"))), mode = "numeric")

median=bigvis::weighted.median(value,weight)
write.table(median, paste0(DIR,"/reg_models10txt/",dirmod,"/",par,"/",filename,"_reg_",var,"_weightedmedian.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

mean=stats::weighted.mean(value,weight)
write.table(mean, paste0(DIR,"/reg_models10txt/",dirmod,"/",par,"/",filename,"_reg_",var,"_weightedmean.txt"), col.names = FALSE , quote = FALSE , row.names=FALSE  )

EOF
rm  -f /dev/shm/${filename}_maskAREA.tif

fi 

' _ 

# merge the results and make txt file

find $DIR/reg_models10txt/*_stat   -name "*.*" | xargs -n 1 -P 8 rm

for MOD in G4 rcp45 ; do 
export MOD
seq 2070 2070 | xargs -n 1 -P 8 bash -c $'
#  tas 

YSTART=$1 
YEND=$(expr $YSTART + 9)

for landocean in land ocea ; do 
for stat in median mean ; do
cat $DIR/reg_models10txt/*/tas/tas_oned_Amon_*_${MOD}_*_mean_${YSTART}.${YEND}_reg_${landocean}_weighted$stat.txt | sort -g > $DIR/reg_models10txt/tas_stat/tas_oned_Amon_${MOD}_mean_${YSTART}.${YEND}_reg_${landocean}_weighted$stat.txt 
done 
done 
# tos 
for stat in median mean ; do
cat $DIR/reg_models10txt/*/tos/tos_oned_Amon_*_${MOD}_*_mean_${YSTART}.${YEND}_reg_ocea_weighted$stat.txt | sort -g > $DIR/reg_models10txt/tos_stat/tos_oned_Amon_${MOD}_mean_${YSTART}.${YEND}_reg_ocea_weighted$stat.txt 
done 
# pr
for stat in median mean ; do
cat $DIR/reg_models10txt/*/pr/pr_oned_Amon_*_${MOD}_*_mean_${YSTART}.${YEND}_reg_land_weighted$stat.txt | sort -g > $DIR/reg_models10txt/pr_stat/pr_oned_Amon_${MOD}_mean_${YSTART}.${YEND}_reg_land_weighted$stat.txt 
done 

' _ 

# make txt files for long-term periods

for YSTART in 2020 2030 ; do 

if [ $YSTART = 2030 ] ; then YEND=$(expr $YSTART + 39) ; fi 
if [ $YSTART = 2020 ] ; then YEND=$(expr $YSTART + 59) ; fi 

for landocean in land ocea ; do 
for stat in median mean ; do
cat $DIR/reg_models10txt/*/tas/tas_oned_Amon_*_${MOD}_*_mean_${YSTART}.${YEND}_reg_${landocean}_weighted$stat.txt | sort -g > $DIR/reg_models10txt/tas_stat/tas_oned_Amon_${MOD}_mean_${YSTART}.${YEND}_reg_${landocean}_weighted$stat.txt 
done 
done 
# tos 
for stat in median mean ; do
cat $DIR/reg_models10txt/*/tos/tos_oned_Amon_*_${MOD}_*_mean_${YSTART}.${YEND}_reg_ocea_weighted$stat.txt | sort -g > $DIR/reg_models10txt/tos_stat/tos_oned_Amon_${MOD}_mean_${YSTART}.${YEND}_reg_ocea_weighted$stat.txt 
done 
# pr
for stat in median mean ; do
cat $DIR/reg_models10txt/*/pr/pr_oned_Amon_*_${MOD}_*_mean_${YSTART}.${YEND}_reg_land_weighted$stat.txt | sort -g > $DIR/reg_models10txt/pr_stat/pr_oned_Amon_${MOD}_mean_${YSTART}.${YEND}_reg_land_weighted$stat.txt 
done 

done 
done 


#########################################
####  calculate area-weigthed global mean and median of velocity 
#########################################

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


# make the txt file 
find $DIR/velocity_models10txt/*_stat/   -name "*.txt" | xargs -n 1 -P 8 rm

for MOD in G4 rcp45 ; do 
export MOD 
seq 2070 2070 | xargs -n 1 -P 8 bash -c $'
#  tas 

YSTART=$1 
YEND=$(expr $YSTART + 9)

for landocean in land ocea ; do 
for stat in median mean ; do
# echo $DIR/velocity_models10txt/*/tas/tas_oned_Amon_*_velocity${YSTART}.${YEND}${landocean}_weighted$stat.txt 
cat $DIR/velocity_models10txt/*/tas/tas_oned_Amon_*_${MOD}_*_velocity${YSTART}.${YEND}${landocean}_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/tas_stat/tas_oned_Amon_${MOD}_velocity_${YSTART}.${YEND}_${landocean}_weighted$stat.txt 
done
done 
# tos 
for stat in median mean ; do
cat $DIR/velocity_models10txt/*/tos/tos_oned_Amon_*_${MOD}_*_velocity${YSTART}.${YEND}ocea_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/tos_stat/tos_oned_Amon_${MOD}_velocity_${YSTART}.${YEND}_ocea_weighted$stat.txt 
                                    
done 
# pr
for stat in median mean ; do
cat $DIR/velocity_models10txt/*/pr/pr_oned_Amon_*_${MOD}_*_velocity${YSTART}.${YEND}land_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/pr_stat/pr_oned_Amon_${MOD}_velocity_${YSTART}.${YEND}_land_weighted$stat.txt 
done 

' _ 


for YSTART in 2020 2030 ; do 

if [ $YSTART = 2030 ] ; then YEND=$(expr $YSTART + 39) ; fi 
if [ $YSTART = 2020 ] ; then YEND=$(expr $YSTART + 59) ; fi 

#  tas 

for landocean in land ocea ; do 
for stat in median mean ; do
# echo $DIR/velocity_models10txt/*/tas/tas_oned_Amon_*_${MOD}_*_velocity${YSTART}.${YEND}${landocean}_weighted$stat.txt 
cat $DIR/velocity_models10txt/*/tas/tas_oned_Amon_*_${MOD}_*_velocity${YSTART}.${YEND}${landocean}_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/tas_stat/tas_oned_Amon_${MOD}_velocity_${YSTART}.${YEND}_${landocean}_weighted$stat.txt 
done
done 
# tos 
for stat in median mean ; do
cat $DIR/velocity_models10txt/*/tos/tos_oned_Amon_*_${MOD}_*_velocity${YSTART}.${YEND}ocea_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/tos_stat/tos_oned_Amon_${MOD}_velocity_${YSTART}.${YEND}_ocea_weighted$stat.txt 
done 
# pr
for stat in median mean ; do
cat $DIR/velocity_models10txt/*/pr/pr_oned_Amon_*_${MOD}_*_velocity${YSTART}.${YEND}land_weighted$stat.txt | sort -g > $DIR/velocity_models10txt/pr_stat/pr_oned_Amon_${MOD}_velocity_${YSTART}.${YEND}_land_weighted$stat.txt 
done 
done 
done 




#  start to aggregate the tif 

# G4 mean tif of the 12 tif files for G4 velocity 2020-2029 and 2070-2079 2030-2069 

echo 2020 2029  2030 2069 2070 2079 | xargs -n 2 -P 1 bash -c $' 
YSTART=$1
YEND=$2

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING
for landocean in land ocea ; do 
rm -f $DIR/velocity_models10/tas_stat/tas_oned_Amon_G4_velocity${YSTART}.${YEND}${landocean}.*
~/bin/pkcomposite  -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9  -cr mean   $( ls $DIR/velocity_models10/*/tas/tas_oned_Amon_*_G4_*_velocity${YSTART}.${YEND}${landocean}.tif  | xargs -n 1  echo  -i  ) -o $DIR/velocity_models10/tas_stat/tas_oned_Amon_G4_velocity${YSTART}.${YEND}${landocean}.tif 

pkextract -polygon -r mean -f  "ESRI Shapefile" -srcnodata -9999 -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/velocity_models10/tas_stat/tas_oned_Amon_G4_velocity${YSTART}.${YEND}${landocean}.tif  -o $DIR/velocity_models10/tas_stat/tas_oned_Amon_G4_velocity${YSTART}.${YEND}${landocean}.shp
done 

rm $DIR/velocity_models10/tos_stat/tos_oned_Amon_G4_velocity${YSTART}.${YEND}ocea.*
~/bin/pkcomposite  -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9 -cr mean $( ls $DIR/velocity_models10/*/tos/tos_oned_Amon_*_G4_*_velocity${YSTART}.${YEND}ocea.tif  | xargs -n 1 echo -i ) -o $DIR/velocity_models10/tos_stat/tos_oned_Amon_G4_velocity${YSTART}.${YEND}ocea.tif

pkextract -polygon -r mean -f  "ESRI Shapefile" -srcnodata -9999 -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/velocity_models10/tos_stat/tos_oned_Amon_G4_velocity${YSTART}.${YEND}ocea.tif -o $DIR/velocity_models10/tos_stat/tos_oned_Amon_G4_velocity${YSTART}.${YEND}ocea.shp

rm $DIR/velocity_models10/pr_stat/pr_oned_Amon_G4_velocity${YSTART}.${YEND}land.*
~/bin/pkcomposite  -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9 -cr mean  $( ls $DIR/velocity_models10/*/pr/pr_oned_Amon_*_G4_*_velocity${YSTART}.${YEND}land.tif | xargs -n 1 echo -i ) -o $DIR/velocity_models10/pr_stat/pr_oned_Amon_G4_velocity${YSTART}.${YEND}land.tif 

pkextract -polygon -r mean -f  "ESRI Shapefile" -srcnodata -9999 -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/velocity_models10/pr_stat/pr_oned_Amon_G4_velocity${YSTART}.${YEND}land.tif -o $DIR/velocity_models10/pr_stat/pr_oned_Amon_G4_velocity${YSTART}.${YEND}land.shp

' _

# RCP45 mean tif of the 12 tif files for rcp45 for the period 2020-2079

echo 2020 2079 | xargs -n 2 -P 1 bash -c $' 
YSTART=$1
YEND=$2

DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING
for landocean in land ocea ; do 
rm -f $DIR/velocity_models10/tas_stat/tas_oned_Amon_rcp45_velocity${YSTART}.${YEND}${landocean}.*
~/bin/pkcomposite  -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9  -cr mean   $( ls $DIR/velocity_models10/*/tas/tas_oned_Amon_*_rcp45_*_velocity${YSTART}.${YEND}${landocean}.tif  | xargs -n 1  echo  -i  ) -o $DIR/velocity_models10/tas_stat/tas_oned_Amon_rcp45_velocity${YSTART}.${YEND}${landocean}.tif 

pkextract -polygon -r mean -f  "ESRI Shapefile" -srcnodata -9999 -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/velocity_models10/tas_stat/tas_oned_Amon_rcp45_velocity${YSTART}.${YEND}${landocean}.tif  -o $DIR/velocity_models10/tas_stat/tas_oned_Amon_rcp45_velocity${YSTART}.${YEND}${landocean}.shp
done 
rm $DIR/velocity_models10/tos_stat/tos_oned_Amon_rcp45_velocity${YSTART}.${YEND}ocea.*
~/bin/pkcomposite  -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9 -cr mean $( ls $DIR/velocity_models10/*/tos/tos_oned_Amon_*_rcp45_*_velocity${YSTART}.${YEND}ocea.tif  | xargs -n 1 echo -i ) -o $DIR/velocity_models10/tos_stat/tos_oned_Amon_rcp45_velocity${YSTART}.${YEND}ocea.tif

pkextract -polygon -r mean -f  "ESRI Shapefile" -srcnodata -9999 -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/velocity_models10/tos_stat/tos_oned_Amon_rcp45_velocity${YSTART}.${YEND}ocea.tif -o $DIR/velocity_models10/tos_stat/tos_oned_Amon_rcp45_velocity${YSTART}.${YEND}ocea.shp

rm $DIR/velocity_models10/pr_stat/pr_oned_Amon_rcp45_velocity${YSTART}.${YEND}landx.*
~/bin/pkcomposite  -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9 -cr mean  $( ls $DIR/velocity_models10/*/pr/pr_oned_Amon_*_rcp45_*_velocity${YSTART}.${YEND}land.tif | xargs -n 1 echo -i ) -o $DIR/velocity_models10/pr_stat/pr_oned_Amon_rcp45_velocity${YSTART}.${YEND}land.tif 

pkextract -polygon -r mean -f  "ESRI Shapefile" -srcnodata -9999 -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/velocity_models10/pr_stat/pr_oned_Amon_rcp45_velocity${YSTART}.${YEND}land.tif -o $DIR/velocity_models10/pr_stat/pr_oned_Amon_rcp45_velocity${YSTART}.${YEND}land.shp

' _

exit 
