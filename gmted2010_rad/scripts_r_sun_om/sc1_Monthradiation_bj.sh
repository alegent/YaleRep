# cd  /mnt/data2/scratch/GMTED2010/grassdb 
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/?_?.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{1_1,1_2,2_1,2_2,1_0,2_0}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh

# alaska and maine 
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{0_0,3_1}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/2_1.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/2_2.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh


# for tile  in  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/{0_0,3_1,1_1,1_2,2_1,2_2,1_0,2_0}.tif  ; do  qsub -v tile=$tile /home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_r_sun_om/sc1_Monthradiation_bj.sh  ; done 

# for tile  in /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/3_1.tif  ; do  bash   /home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_r_sun_om/sc1_Monthradiation_bj.sh  $tile ; done 


#PBS -S /bin/bash 
#PBS -q fas_long
#PBS -l walltime=72:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

tile=$1

file=`basename $tile`

export file=`basename $tile`
export filename=`basename $file .tif`

export INTIF_mn30=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mn30_grd_tif
export INTIF=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif
export INTIFL=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/
export INDIRG=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/grassdb
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation


echo clip the data 

cd $INDIRG 

# clip the 1km dem, use the be75_grd_tif to ensure larger overlap

# gdal_translate -projwin  $(getCorners4Gtranslate  $INTIF/$file) $INTIF_mn30/mn30_grd.tif $file

gdal_translate -srcwin 9000 4200 50 50  $INTIF_mn30/mn30_grd.tif $file  # to create a file test 


echo create location  loc_$filename 


mkdir -p  $INDIRG/loc_tmp/tmp

echo "LOCATION_NAME: loc_tmp"                                                       > $HOME/.grass7/rc_$filename
echo "GISDBASE: /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/grassdb"    >> $HOME/.grass7/rc_$filename
echo "MAPSET: tmp"                                                                 >> $HOME/.grass7/rc_$filename
echo "GRASS_GUI: text"                                                             >> $HOME/.grass7/rc_$filename


# path to GRASS settings file
export GISRC=$HOME/.grass7/rc_$filename
export GRASS_PYTHON=python
export GRASS_MESSAGE_FORMAT=plain
export GRASS_PAGER=cat
export GRASS_WISH=wish
export GRASS_ADDON_BASE=$HOME/.grass7/addons
export GRASS_VERSION=7.0.0beta1
export GISBASE=/usr/local/cluster/hpc/Apps/GRASS/7.0.0beta1/grass-7.0.0beta1
export GRASS_PROJSHARE=/usr/local/cluster/hpc/Libs/PROJ/4.8.0/share/proj/
export PROJ_DIR=/usr/local/cluster/hpc/Libs/PROJ/4.8.0

export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$GISBASE/lib"
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man
export GIS_LOCK=$$
export GRASS_OVERWRITE=1

rm -rf  $INDIRG/loc_$filename

echo start importing 
r.in.gdal in=$file  out=$filename  location=loc_$filename

g.mapset mapset=PERMANENT  location=loc_$filename

echo import and set the mask 
r.external  -o input=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_1km/land_mask_GSHHS_f_L1.tif output=mask  --overwrite  
r.mask raster=mask

echo calculate r.slope.aspect  
r.slope.aspect elevation=$filename    aspect=aspect_$filename  slope=slope_$filename   # for horizontal surface not usefull

echo calculate horizon

step 1 in r.sun = horizonstep=15   360/24 = 15 

r.horizon  elevin=$filename   horizonstep=15  horizon=horiz   maxdistance=200000

echo  001 017 033 049 065 080 097 113 129 145 161 177 193 209 225 241 257 273 289 305 321 337 353  | xargs -n 1  -P 1  bash  -c $'

dayi=$1
day=$(echo $dayi | awk \'{ print int($1) }\'  ) #   to have the integer value 

echo  processing day $dayi "#################################################################"

echo  import albedo 
r.external  -o input=/lustre/scratch/client/fas/sbsc/ga254/dataproces/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0/AlbMap.WS.c004.v2.0.00-04.${dayi}.0.3_5.0.tif   output=albedo${day}_${filename} --overwrite 
r.mapcalc  " albedo${day}_${filename}_coef =  albedo${day}_${filename}  * 0.001" 

echo  import cloud

monthc=$( awk -v day=$day \'{ if ($2==day) {print substr($1,0,2) } }\'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/MERRAero/tif_day/MMDD_JD_0JD.txt  ) 

r.external -o input=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/month/MCD09_mean_${monthc}.tif   output=cloud${day}_${filename}  --overwrite 
r.mapcalc  " cloud${day}_${filename}_coef =  ( cloud${day}_${filename} * 0.001)" 

echo import Aerosol 

r.external -o input=/lustre/scratch/client/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/temp_smoth_1km/AOD_1km_day${day}.tif  output=aeros${day}_${filename}  --overwrite 

# see http://en.wikipedia.org/wiki/Optical_depth 
# 2.718281828^−(5000/1000) = 0.006737947
# 2.718281828^−(−50/1000) = 1.051271096 

r.mapcalc " aeros${day}_${filename}_coef =  1 - (  2.718281828^(- (aeros${day}_${filename} * 0.001))) "

# horizontal clear sky 
# take out aspin=aspect_$filename  slopein=slope_$filename to simulate horizontal behaviur    better specify the slope=0 

# horizontal aerosl and cloud and albedo 

r.sun  --o   elev_in=$filename  slope=0.01 \
lin=1   albedo=albedo${day}_${filename}_coef   coef_bh=cloud${day}_${filename}_coef  coef_dh=aeros${day}_${filename}_coef \
day=$day step=1 horizon=horiz  horizonstep=15   --overwrite  \
glob_rad=glob_HradCA_day$day \
diff_rad=diff_HradCA_day$day \
beam_rad=beam_HradCA_day$day \
refl_rad=refl_HradCA_day$day     # orizontal 0 reflectance 


# r.sun --o  elev_in=$filename  slope=0.01 \
# lin=1   albedo=albedo${day}_${filename}_coef    \
# day=$day step=1 horizon=horiz  horizonstep=15   --overwrite  \
# glob_rad=glob_Hrad_day$day \
# diff_rad=diff_Hrad_day$day \
# beam_rad=beam_Hrad_day$day \
# refl_rad=refl_Hrad_day$day # orizontal 0 reflectance 

# g.remove rast=linke${day}_${filename}_coef,albedo${day}_${filename}_coef,cloud${day}_${filename}_coef,aeros${day}_${filename}_coef

' _



echo starting to calculate average at montly level

echo 1 31 59 90 120 151 181 212 243 273 304 334 | xargs -n 1  -P 12  bash -c  $'  

day=$1

# nalb viene inserito per la computazione 2 (1) giorni al mese sulla base del valore di albedo 

if [ $day -eq 1   ] ; then  month=1  ; dayend=$(expr $day + 29 ) ; n=31 ; nalb=2; fi   # 31 days  
if [ $day -eq 31  ] ; then  month=2  ; dayend=$(expr $day + 26 ) ; n=28 ; nalb=2; fi   # 28 days  
if [ $day -eq 59  ] ; then  month=3  ; dayend=$(expr $day + 29 ) ; n=31 ; nalb=2; fi   # 31 days  
if [ $day -eq 90  ] ; then  month=4  ; dayend=$(expr $day + 28 ) ; n=30 ; nalb=2; fi   # 30 days  
if [ $day -eq 120 ] ; then  month=5  ; dayend=$(expr $day + 29 ) ; n=31 ; nalb=2; fi   # 31 days  
if [ $day -eq 151 ] ; then  month=6  ; dayend=$(expr $day + 28 ) ; n=30 ; nalb=2; fi   # 30 days  
if [ $day -eq 181 ] ; then  month=7  ; dayend=$(expr $day + 29 ) ; n=31 ; nalb=2; fi   # 31 days  
if [ $day -eq 212 ] ; then  month=8  ; dayend=$(expr $day + 29 ) ; n=31 ; nalb=2; fi   # 31 days  
if [ $day -eq 243 ] ; then  month=9  ; dayend=$(expr $day + 28 ) ; n=30 ; nalb=2; fi   # 30 days  
if [ $day -eq 273 ] ; then  month=10 ; dayend=$(expr $day + 29 ) ; n=31 ; nalb=1; fi   # 31 days  
if [ $day -eq 304 ] ; then  month=11 ; dayend=$(expr $day + 28 ) ; n=30 ; nalb=2; fi   # 30 days  
if [ $day -eq 334 ] ; then  month=12 ; dayend=$(expr $day + 29 ) ; n=31 ; nalb=2; fi   # 31 days  

n=$nalb # da togliere in caso di run for the full year 

echo mean compupation aerosol and cloud and albedo 






r.mapcalc  " glob_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  glob_HradCA_day${dayn} +  ; done)  glob_HradCA_day$(expr $day + $n - 1)  ) ) /$n " 
r.mapcalc  " diff_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  diff_HradCA_day${dayn} +  ; done)  diff_HradCA_day$(expr $day + $n - 1)  ) ) /$n "
r.mapcalc  " beam_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  beam_HradCA_day${dayn} +  ; done)  beam_HradCA_day$(expr $day + $n - 1)  ) ) /$n "
r.mapcalc  " refl_HradCA_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  refl_HradCA_day${dayn} +  ; done)  refl_HradCA_day$(expr $day + $n - 1)  ) ) /$n "

r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=glob_HradCA_m$month    output=$OUTDIR/glob_rad/glob_HradCA_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=diff_HradCA_m$month    output=$OUTDIR/diff_rad/diff_HradCA_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=beam_HradCA_m$month    output=$OUTDIR/beam_rad/beam_HradCA_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=refl_HradCA_m$month    output=$OUTDIR/refl_rad/refl_HradCA_month$month"_"$file


if [ ${filename:0:1} -eq 0 ] ; then 
# this was inserted becouse the r.out.gdal of the 0_? was overpassing the -180 border and it was attach the tile to the right border 

# aerosol and cloud

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file  $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file  $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file  $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file  $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file"_tmp"

mv $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file"_tmp" $OUTDIR/glob_rad/glob_HradCA_month$month"_"$file
mv $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file"_tmp" $OUTDIR/diff_rad/diff_HradCA_month$month"_"$file
mv $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file"_tmp" $OUTDIR/beam_rad/beam_HradCA_month$month"_"$file
mv $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file"_tmp" $OUTDIR/refl_rad/refl_HradCA_month$month"_"$file

fi


' _ 

checkjob -v $PBS_JOBID

exit 

# for day in `seq 1 2` ; do r.info  glob_HradC_day11   ; done 





