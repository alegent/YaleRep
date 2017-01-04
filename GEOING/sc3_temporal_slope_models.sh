# bash  /home/fas/sbsc/ga254/scripts/GEOING/sc3_temporal_slope_models.sh 
# qsub  /home/fas/sbsc/ga254/scripts/GEOING/sc3_temporal_slope_models.sh 
# start branching
# modify file

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

module load Tools/CDO/1.6.4  

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING
export RAM=/dev/shm
cd $DIR

#  for dir1 in CCCMA.CanESM2  CSIRO-Mk3L-1-2  HadGEM2-ES  NASA.GISS-E2-R ; do for dir2 in pr tas ; do mkdir -p  $dir1/$dir2 ; done ;done 
#  mv  input/HadGEM2-ES/tas/tas_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210011.nc  input/HadGEM2-ES/tas/tas_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210012.nc
#  mv  input/HadGEM2-ES/tas/tas_oned_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210011.nc   input/HadGEM2-ES/tas/tas_oned_Amon_HadGEM2-ES_rcp45_r1i1p1_200512-210012.nc

# rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/reg_models/*/*/*
# rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/mean_models/*/*/*

# echo "########################################################################################"
# echo "#################MODEL START ###########################################################"
# echo "########################################################################################"

# rm -f $DIR/mean_models/*/*/*

# awk 'NR>1'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/time/nc10YearWindow4modelTASandTOSJan4th.txt     | xargs -n 7 -P 8 bash -c $'
# file=$1
# filename=$(basename $file .nc) 
# dirinput=$(dirname $file)

# dir=$(echo ${dirinput:6:20})

# echo  $2 $3 $4 $5 $6 

# for YEARS in $2 $3; do # temporal mean for the full period 

# if [ $YEARS != "NA" ]  ; then  

# # y = a * X +  
# # change the temperature to  celsius and calculate the year mean 
# if [ ${filename:0:3} = "tas"   ]  || [ ${filename:0:3} = "tos"   ]    ; then 
# cdo   addc,-273.15 -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)     $DIR/$file   $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
# cdo  yearmean    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc       $DIR/mean_models/$dir/${filename}_mean_$YEARS.nc  
# rm -f    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
# fi 

# # change precipitation to mm/year and calculate the sum year 
# if [ ${filename:0:3} = "pr_"   ] ; then 
# cdo   mulc,2592000  -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)   $DIR/$file   $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
# cdo  yearsum    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc       $DIR/mean_models/$dir/${filename}_mean_$YEARS.nc  
# rm -f    $DIR/mean_models/$dir/${filename}_meanTMP_$YEARS.nc  
# fi 
# fi 

# done 

# ' _ 


# # make the ensamble mean for the full period 
# rm -f  $DIR/mean_models/*/*/*ensamble*.nc  
 
# ls     $DIR/mean_models/*/*/*r?i?p1*.nc |  xargs -n 3 -P 8  bash -c $' 

# r1=$(basename $1 .nc )
# r2=$(basename $2 .nc )
# r3=$(basename $3 .nc )

# dir=$(dirname  $1 )
# mod=$( basename $( dirname   $dir) )

# filename=$(echo $r1 | awk \'{ gsub ("r1i1p1" ,  "ensamble" ) ; gsub ("r1i2p1" ,  "ensamble" ) ;  print $0  }\') 

# ensamble=$(basename $filename .nc ) 

# if [ ${ensamble:0:3} = "tas"   ] ||  [ ${ensamble:0:3} = "tos"   ]   ; then par=${ensamble:0:3} ; fi 
# if [ ${ensamble:0:3} = "pr_"   ] ; then par=${ensamble:0:2} ; fi 

# # ensamble model
# rm -f $dir/${ensamble}.nc
# echo cdo ensmean   $dir/$r1.nc $dir/$r2.nc  $dir/$r3.nc $dir/${ensamble}.nc
# cdo ensmean   $dir/$r1.nc $dir/$r2.nc  $dir/$r3.nc $dir/${ensamble}.nc


# ' _ 

# # calculate teporal regression using the ensamble model. One regression line for each period, for each model,  

# rm -f $DIR/reg_models/*/*/*

# awk '{ if(NR>1) {gsub("r1i1p1","ensamble"); gsub("r2i1p1","ensamble"); gsub("r3i1p1","ensamble"); gsub("r1i2p1","ensamble"); gsub("r2i2p1","ensamble"); gsub("r3i2p1","ensamble"); gsub("input","mean_models"); print}}' /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/time/nc10YearWindow4modelTASandTOSJan4th.txt  | uniq | xargs -n 7 -P 8  bash -c $'

# file=$1
# filename=$(basename $file .nc) 
# dirinput=$(dirname $file)

# dirmod=$(basename $(dirname $(dirname $file)))
# par=$(basename $(dirname $file))
# echo  $2 $3 $4 $5 $6 $7

# if [ $2 != "NA" ]  ; then  filensamble=${filename}_mean_${2} ; fi 
# if [ $3 != "NA" ]  ; then  filensamble=${filename}_mean_${3} ; fi

# for YEARS in $2 $3 $4 $5 $6 $7 ; do # temporal mean for the full period 

# if [ $YEARS != "NA" ]  ; then  
# echo input   $DIR/$dirinput/${filensamble}.nc  output  $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc   
# cdo regres  -selyear$(for year in $(seq $(  echo "$YEARS" | tr -  " "  )  ) ; do echo -n ,$year ; done)  $DIR/$dirinput/${filensamble}.nc   $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc   

# dimension=$(echo $filename | grep oned)

# if [ -n  $dimension ] ; then dimXY=180 ; res=1.0 ; fi   # dimension for 1 degree     # Size is 360, 180 
# if [ -z  $dimension ] ; then dimXY=360 ; res=0.5 ; fi   # dimension for 0.5 degree   # Size is 720, 360  
# # invert left to right 

# gdal_translate -srcwin 0 0 $dimXY $dimXY -a_ullr 0 +90 180 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc $RAM/${filename}_reg_${YEARS}_right.tif
# gdal_translate -srcwin $dimXY 0 $dimXY $dimXY -a_ullr -180 +90 0 -90 -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.nc $RAM/${filename}_reg_${YEARS}_left.tif

# gdalbuildvrt -a_srs EPSG:4326 -te -180 -90 180 +90 -tr $res $res   $RAM/${filename}_reg_${YEARS}.vrt  $RAM/${filename}_reg_${YEARS}_right.tif $RAM/${filename}_reg_${YEARS}_left.tif 
# gdal_translate -a_srs EPSG:4326 -co COMPRESS=DEFLATE  -co ZLEVEL=9  $RAM/${filename}_reg_${YEARS}.vrt   $DIR/reg_models/$dirmod/$par/${filename}_reg_$YEARS.tif   
# rm -f   $RAM/${filename}_reg_${YEARS}.vrt  $RAM/${filename}_reg_${YEARS}_right.tif $RAM/${filename}_reg_${YEARS}_left.tif 

# fi 
# done 

# ' _



# echo "########################################################################################"
# echo "################# Calculate velocity ###################################################"
# echo "########################################################################################"

# # calculate velocity for the precipitation model using temporal regression mean and  spatial slope from observation    

# cleanram
# rm -f  $DIR/velocity_models/*/*/*.tif
# ls  reg_models/*/*/*.tif   | xargs -n 1  -P 8 bash -c  $' 

# file=$1
# filename=$(basename $file .tif) 
# dirinput=$(dirname $file)

# dirmod=$(basename $(dirname $(dirname $file)))
# par=$(basename $(dirname $file))

# dimension=$(echo $filename | grep oned)

# if [ -n  $dimension ] ; then res=1.0 ; fi   # dimension for 1 degree     # Size is 360, 180 
# if [ -z  $dimension ] ; then res=0.5 ; fi   # dimension for 0.5 degree   # Size is 720, 360  

# if [ $par = "pr"   ]  ; then parCRU=pre ; fi   
# if [ $par = "tas"   ] ||  [ $par = "tos"   ]  ; then parCRU=tmp ; fi   

# historical=$(echo $filename | grep historical )

# if [ -z  $historical  ] ; then 

# for YYYY in 1960.2009 1960.2014 ; do 

# # land 
# gdal_calc.py --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif --calc="( A.astype(float) /  B.astype(float) )"  --overwrite --type=Float32
# pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif -msknodata -9999   -p "="   -nodata -9999   -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
# gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
# rm  $RAM/${filename}_velocity.tif  

# # ocean

# if [ $res = "1.0"   ] ; then 
# gdal_calc.py --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) /  B.astype(float) )"  --overwrite  --type=Float32
# pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif -msknodata -9999 -p "=" -nodata -9999   -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
# gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
# rm  $RAM/${filename}_velocity.tif  
# fi 
# done 
# fi 

# # valid only for the historical file using slope 1960.2005

# if [ -n  $historical  ] ; then 

# for YYYY in 1960.2005 ; do 

# # land 
# gdal_calc.py --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif --calc="( A.astype(float) /  B.astype(float) )"  --overwrite --type=Float32
# pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/slope_CRU/cru_ts3.23.${YYYY}.${parCRU}.dat_${res}deg.slope10msk.tif -msknodata -9999   -p "="   -nodata -9999   -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
# gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}land.tif
# rm  $RAM/${filename}_velocity.tif  

# # ocean

# if [ $res = "1.0"   ] ; then 
# gdal_calc.py --outfile=$RAM/${filename}_velocity.tif -A $file -B $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif  --calc="( A.astype(float) /  B.astype(float) )"  --overwrite  --type=Float32
# pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/slope_HadISST/HadISST_sst.${YYYY}.tmp.dat_1.0deg.slope10msk.tif -msknodata -9999 -p "=" -nodata -9999   -i $RAM/${filename}_velocity.tif  -o $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
# gdal_edit.py  -a_nodata -9999 $DIR/velocity_models/$dirmod/$par/${filename}_velocityBased${YYYY}ocea.tif
# rm  $RAM/${filename}_velocity.tif  
# fi 
# done 

# fi 

# ' _ 



# all the different time period but not the historical
# 2 paramenters 
# 2020-2029 valid for CCCMA.CanESM2  HadGEM2-ES NASA.GISS-E2-R 
# 2021-2030 CSIRO-Mk3L-1-2 
# rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/velocity_models/ensamble/*/*

# echo   2020-2029  | xargs -n 2 -P 8  bash -c $' 

echo 2020-2079 2020-2029 2021-2030 2020-2089 2021-2090 2030-2069 2031-2070 2070-2079 2071-2080 2080-2089 2081-2090 | xargs -n 2 -P 8  bash -c $' 

year1=$1 
year2=$2 

for MOD in G4  rcp45 ; do 
for PAR in tos tas pr ; do 
for RES in _oned_ _ ; do 
for BASE in  1960.2005  1960.2009 1960.2014 ; do 
for RULES in mean stdev ; do 
for LS in land ocea ; do 


output=$(basename   $(ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif | head -1  ))

ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif  $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year2}_velocityBased${BASE}${LS}.tif

echo ""
echo output $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} 

sleep 3 

echo""
pkcomposite -srcnodata -9999 -dstnodata -9999  -co COMPRESS=LZW -co ZLEVEL=9  -cr ${RULES}   $( ls $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year1}_velocityBased${BASE}${LS}.tif  $DIR/velocity_models/*/*/${PAR}${RES}Amon_*_${MOD}_ensamble_*-*_reg_${year2}_velocityBased${BASE}${LS}.tif  | xargs -n 1  echo  -i  ) -o  $DIR/velocity_models/ensamble/$PAR/${PAR}${RES}Amon_${MOD}_${RULES}_${output: -40} 

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
