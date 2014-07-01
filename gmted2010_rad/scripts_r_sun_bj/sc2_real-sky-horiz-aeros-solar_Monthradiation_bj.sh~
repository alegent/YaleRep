# cd  /mnt/data2/scratch/GMTED2010/grassdb 
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/?_?.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{1_1,1_2,2_1,2_2,1_0,2_0}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# alaska and maine 
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{0_0,3_1}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/2_1.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/2_2.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh


# for tile  in   /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/be75_grd_tif/{0_0,3_1,1_1,1_2,2_1,2_2,1_0,2_0}.tif  ; do  qsub -v tile=$tile  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_rad/scripts_r_sun_bj/sc2_real-sky-horiz-aeros-solar_Monthradiation_bj.sh ; done 

# for tile  in   /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/be75_grd_tif/3_1.tif  ; do  bash   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_rad/scripts_r_sun_bj/sc2_real-sky-horiz-aeros-solar_Monthradiation_bj.sh $tile ; done 



#PBS -S /bin/bash 
#PBS -q fas_long
#PBS -l mem=16gb
#PBS -l walltime=60:00:00  
#PBS -l nodes=1:ppn=2
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2   # exclued to load the pktools from the $HOME/bin
module load Libraries/OSGEO/1.10.0
module load Libraries/GSL
module load Libraries/ARMADILLO
module load Applications/GRASS/6.4.2

# tile=$1

file=`basename $tile`

export file=`basename $tile`
export filename=`basename $file .tif`

export INTIF=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/be75_grd_tif
export INTIFL=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/
export INDIRG=/lustre0/scratch/ga254/dem_bj/SOLAR/grassdb
export OUTDIR=/lustre0/scratch/ga254/dem_bj/SOLAR/radiation

# 
echo clip the data 

cd $INDIRG

# clip the 1km dem, use the be75_grd_tif to ensure larger overlap
# gdal_translate -projwin  $(getCorners4Gtranslate  $INTIF/$file) $INTIFL/mn30_grd_tif/mn30_grd.tif $file

# gdal_translate -srcwin 9000 4200 50 50  $OUTDIR/mn30_grd_tif/mn30_grd.tif $file  # to create a file test 

echo create location 
# rm -rf  $INDIRG/loc_$filename
# /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_rad/scripts_r_sun_bj/create_location_bj.sh $file loc_$filename $INDIRG
# rm -f $file 
echo enter in grass 

echo "LOCATION_NAME: loc_$filename"              >  $HOME/grassrc/.grassrc6$$
echo "MAPSET: PERMANENT"                         >> $HOME/grassrc/.grassrc6$$
echo "DIGITIZER: none"                           >> $HOME/grassrc/.grassrc6$$
echo "GRASS_GUI: text"                           >> $HOME/grassrc/.grassrc6$$
echo "GISDBASE: $INDIRG"                         >> $HOME/grassrc/.grassrc6$$

# path to GRASS binaries and libraries:
               
export GISBASE=/usr/local/cluster/hpc/Software/BDJ/Applications/GRASS/6.4.2/grass-6.4.2
export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cluster/hpc/Software/BDJ/Libraries/PROJ/4.8.0/lib:"$GISBASE/lib"
export GISRC=~/grassrc/.grassrc6$$

g.gisenv

echo calculate r.slope.aspect  
# r.slope.aspect elevation=$file   aspect=aspect_$filename  slope=slope_$filename   # for horizontal surface not usefull

echo calculate horizon

echo import and set the mask 

r.external  -o input=/lustre0/scratch/ga254/dem_bj/GSHHG/GSHHS_tif_1km/land_mask_GSHHS_f_L1.tif output=mask  --overwrite  
r.mask input=mask 

# step 1 in r.sun = horizonstep=15   360/24 = 15 

# r.horizon  elevin=$file  horizonstep=15  horizon=horiz   maxdistance=200000

seq 1 365  | xargs -n 1  -P 12  bash  -c $'
day=$1



echo  import albedo 
r.external  -o input=/lustre0/scratch/ga254/dem_bj/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_estimation/AlbMap.WS.c004.v2.0.00-04.${day}.0.3_5.0.tif   output=albedo${day}_${filename} --overwrite 
r.mapcalc  albedo${day}_${filename}_coef = " albedo${day}_${filename}  * 0.001" 

# echo  import Linke turbidity
# r.external -o input=/lustre0/scratch/ga254/dem_bj/LINKE/day_estimation/linke$day.tif     output=linke${day}_${filename}  --overwrite 
# r.mapcalc  linke${day}_${filename}_coef = "linke${day}_${filename}  * 0.05 " 

echo  import cloud

r.external -o input=/lustre0/scratch/ga254/dem_bj/CLOUD/day_estimation/cloud${day}.tif   output=cloud${day}_${filename}  --overwrite 
r.mapcalc  cloud${day}_${filename}_coef = " ( cloud${day}_${filename} * 0.001)" 

echo import Aerosol 

r.external -o input=/lustre0/scratch/ga254/dem_bj/AEROSOL/day_estimation/day${day}_res_mean.tif   output=aeros${day}_${filename}  --overwrite 

# see http://en.wikipedia.org/wiki/Optical_depth 
# 2.718281828^−(5000/1000) = 0.006737947
# 2.718281828^−(−50/1000) = 1.051271096 

r.mapcalc  aeros${day}_${filename}_coef = "  2.718281828^(- (aeros${day}_${filename} * 0.001))"
r.mapcalc  aeros${day}_${filename}_coef2 = "1 -  aeros${day}_${filename}_coef  "

# horizontal clear sky 
# take out aspin=aspect_$filename  slopein=slope_$filename to simulate horizontal behaviur    better specify the slope=0 

# horizontal aerosl and cloud 

r.sun -s  elevin=$file slope=0.01 \
lin=1   albedo=albedo${day}_${filename}_coef   coefbh=cloud${day}_${filename}_coef  coefdh=aeros${day}_${filename}_coef \
day=$day step=1 horizon=horiz  horizonstep=15   --overwrite  \
glob_rad=glob_HradCA_day$day \
diff_rad=diff_HradCA_day$day \
beam_rad=beam_HradCA_day$day \
refl_rad=refl_HradCA_day$day # orizontal 0 reflectance 

r.sun -s  elevin=$file slope=0.01 \
lin=1   albedo=albedo${day}_${filename}_coef   coefbh=cloud${day}_${filename}_coef  coefdh=aeros${day}_${filename}_coef2 \
day=$day step=1 horizon=horiz  horizonstep=15   --overwrite  \
glob_rad=glob_HradCA2_day$day \
diff_rad=diff_HradCA2_day$day \
beam_rad=beam_HradCA2_day$day \
refl_rad=refl_HradCA2_day$day # orizontal 0 reflectance 


g.remove rast=linke${day}_${filename}_coef,albedo${day}_${filename}_coef,cloud${day}_${filename}_coef,aeros${day}_${filename}_coef

' _



echo starting to calculate average at montly level

echo 1 31 59 90 120 151 181 212 243 273 304 334 | xargs -n 1  -P 12  bash -c  $'  

day=$1

if [ $day -eq 1   ] ; then  month=1  ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 31  ] ; then  month=2  ; dayend=$(expr $day + 26 ) ; n=28 ; fi   # 28 days  
if [ $day -eq 59  ] ; then  month=3  ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 90  ] ; then  month=4  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 120 ] ; then  month=5  ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 151 ] ; then  month=6  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 181 ] ; then  month=7  ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 212 ] ; then  month=8  ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 243 ] ; then  month=9  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 273 ] ; then  month=10 ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 304 ] ; then  month=11 ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 334 ] ; then  month=12 ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  



aerosol and cloud 

r.mapcalc  " glob_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  glob_HradCA_day${dayn} +  ; done)  glob_HradCA_day$(expr $day + $n - 1)  ) ) /$n " 
r.mapcalc  " diff_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  diff_HradCA_day${dayn} +  ; done)  diff_HradCA_day$(expr $day + $n - 1)  ) ) /$n "
r.mapcalc  " beam_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  beam_HradCA_day${dayn} +  ; done)  beam_HradCA_day$(expr $day + $n - 1)  ) ) /$n "
r.mapcalc  " refl_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  refl_HradCA_day${dayn} +  ; done)  refl_HradCA_day$(expr $day + $n - 1)  ) ) /$n "

r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=glob_HradCA_m$month    output=$OUTDIR/glob_rad/glob_HradCA_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=diff_HradCA_m$month    output=$OUTDIR/diff_rad/diff_HradCA_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=beam_HradCA_m$month    output=$OUTDIR/beam_rad/beam_HradCA_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=refl_HradCA_m$month    output=$OUTDIR/refl_rad/refl_HradCA_month$month"_"$file


aerosol2 and cloud 

r.mapcalc  " glob_HradCA2_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  glob_HradCA2_day${dayn} +  ; done)  glob_HradCA2_day$(expr $day + $n - 1)  ) ) /$n " 
r.mapcalc  " diff_HradCA2_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  diff_HradCA2_day${dayn} +  ; done)  diff_HradCA2_day$(expr $day + $n - 1)  ) ) /$n "
r.mapcalc  " beam_HradCA2_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  beam_HradCA2_day${dayn} +  ; done)  beam_HradCA2_day$(expr $day + $n - 1)  ) ) /$n "
r.mapcalc  " refl_HradCA2_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  refl_HradCA2_day${dayn} +  ; done)  refl_HradCA2_day$(expr $day + $n - 1)  ) ) /$n "

r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=glob_HradCA2_m$month    output=$OUTDIR/glob_rad/glob_HradCA2_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=diff_HradCA2_m$month    output=$OUTDIR/diff_rad/diff_HradCA2_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=beam_HradCA2_m$month    output=$OUTDIR/beam_rad/beam_HradCA2_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=refl_HradCA2_m$month    output=$OUTDIR/refl_rad/refl_HradCA2_month$month"_"$file


if [ ${filename:0:1} -eq 0 ] ; then 
# this was inserted becouse the r.out.gdal of the 0_? was overpassing the -180 border and it was attach the tile to the right border 

aerosol and cloud

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file  $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file  $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file  $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file  $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file"_tmp"

mv $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file"_tmp" $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file
mv $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file"_tmp" $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file
mv $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file"_tmp" $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file
mv $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file"_tmp" $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file

aerosol2 and cloud

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/glob_rad/glob_HradCA2_month$month"_"$file  $OUTDIR/glob_rad/glob_HradCA2_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/diff_rad/diff_HradCA2_month$month"_"$file  $OUTDIR/diff_rad/diff_HradCA2_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/beam_rad/beam_HradCA2_month$month"_"$file  $OUTDIR/beam_rad/beam_HradCA2_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/refl_rad/refl_HradCA2_month$month"_"$file  $OUTDIR/refl_rad/refl_HradCA2_month$month"_"$file"_tmp"

mv $OUTDIR/glob_rad/glob_HradCA2_month$month"_"$file"_tmp" $OUTDIR/glob_rad/glob_HradCA2_month$month"_"$file
mv $OUTDIR/diff_rad/diff_HradCA2_month$month"_"$file"_tmp" $OUTDIR/diff_rad/diff_HradCA2_month$month"_"$file
mv $OUTDIR/beam_rad/beam_HradCA2_month$month"_"$file"_tmp" $OUTDIR/beam_rad/beam_HradCA2_month$month"_"$file
mv $OUTDIR/refl_rad/refl_HradCA2_month$month"_"$file"_tmp" $OUTDIR/refl_rad/refl_HradCA2_month$month"_"$file


fi


' _ 

checkjob -v $PBS_JOBID

exit 

# for day in `seq 1 2` ; do r.info  glob_HradC_day11   ; done 





