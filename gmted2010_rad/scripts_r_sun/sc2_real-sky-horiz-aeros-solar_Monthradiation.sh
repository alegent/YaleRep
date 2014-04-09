# cd  /mnt/data2/scratch/GMTED2010/grassdb 
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/?_?.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{1_1,1_2,2_1,2_2,1_0,2_0}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# alaska and maine 
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{0_0,3_1}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/2_1.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/2_2.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-horiz-solar_Monthradiation.sh

for tile  in   /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{0_0,3_1,1_1,1_2,2_1,2_2,1_0,2_0}.tif  ; do 

file=`basename $tile`

time (

export file=`basename $tile`
export filename=`basename $file .tif`

export INTIF=/mnt/data2/scratch/GMTED2010/tiles/be75_grd_tif
export INDIRG=/media/data/grassdb1
export INDIRD=/mnt/data2/scratch/GMTED2010/grassdb
export OUTDIR=months_gr_horiz1_aeros

# 
echo clip the data 

cd $INDIRG

# clip the 1km dem, use the be75_grd_tif to ensure larger overlap
gdal_translate -projwin  $(getCorners4Gtranslate  /mnt/data2/scratch/GMTED2010/tiles/be75_grd_tif/$file) $INDIRD/mn30_grd_tif/mn30_grd.tif $file
# gdal_translate -srcwin 9000 4200 50 50  $INDIRD/mn30_grd_tif/mn30_grd.tif $file

echo create location 
rm -rf  $INDIRG/loc_$filename
/mnt/data2/scratch/GMTED2010/scripts/create_location_gr.sh   $file   loc_$filename  $INDIRG
# rm -f $file 
echo enter in grass 

echo "LOCATION_NAME: loc_$filename"              >  $HOME/.grassrc6$$
echo "MAPSET: PERMANENT"                         >> $HOME/.grassrc6$$
echo "DIGITIZER: none"                           >> $HOME/.grassrc6$$
echo "GRASS_GUI: text"                           >> $HOME/.grassrc6$$
echo "GISDBASE: $INDIRG"            >> $HOME/.grassrc6$$

# path to GRASS binaries and libraries:

export GISBASE=/usr/lib/grass64
export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH="$GISBASE/lib"
export GISRC=~/.grassrc6$$

g.gisenv

echo calculate r.slope.aspect  
# r.slope.aspect elevation=$file   aspect=aspect_$filename  slope=slope_$filename   # for horizontal surface not usefull

echo calculate horizon
# step 1 in r.sun = horizonstep=15   360/24 = 15 

r.horizon  elevin=$file  horizonstep=15  horizon=horiz   maxdistance=200000

seq 1 365  | xargs -n 1  -P 8  bash  -c $'
day=$1

echo  import albedo 
r.external  -o input=/mnt/data2/scratch/GMTED2010/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_estimation/AlbMap.WS.c004.v2.0.00-04.${day}.0.3_5.0.tif   output=albedo${day}_${filename} --overwrite 
r.mapcalc  albedo${day}_${filename}_coef = " albedo${day}_${filename}  * 0.001" 

echo  import Linke turbidity
r.external -o input=/mnt/data2/scratch/GMTED2010/linke_turbidity/day_estimation/linke$day.tif     output=linke${day}_${filename}  --overwrite 
r.mapcalc  linke${day}_${filename}_coef = "linke${day}_${filename}  * 0.05 " 

echo  import cloud

r.external -o input=/mnt/data2/scratch/GMTED2010/cloud/day_estimation/cloud${day}.tif   output=cloud${day}_${filename}  --overwrite 
r.mapcalc  cloud${day}_${filename}_coef = "1 - (cloud${day}_${filename} * 0.001)" 

echo import Aerosol 

r.external -o input=/mnt/data2/scratch/GMTED2010/MODAEROSOL/day_estimation/day${day}_mean.tif   output=aeros${day}_${filename}  --overwrite 
r.mapcalc  aeros${day}_${filename}_coef = " aeros${day}_${filename} * 0.001 "

echo run r.sun 
# take out aspin=aspect_$filename  slopein=slope_$filename to simulate horizontal behaviur    better specify the slope=0 
# r.sun -s  elevin=$file slope=0  linkein=linke${day}_${filename}_coef    albedo=albedo${day}_${filename}_coef    coefbh=cloud${day}_${filename}_coef  coefdh=aeros${day}_${filename}_coef   day=$day step=1 \
# glob_rad=glob_HradC_day$day \
# diff_rad=diff_HradC_day$day \
# beam_rad=beam_HradC_day$day \
# refl_rad=refl_HradC_day$day  --overwrite

r.sun -s  elevin=$file slope=0  linkein=linke${day}_${filename}_coef    albedo=albedo${day}_${filename}_coef    coefbh=cloud${day}_${filename}_coef    coefdh=aeros${day}_${filename}_coef     day=$day step=1 horizon=horiz  horizonstep=15   --overwrite  \
glob_rad=glob_HradC_day$day \
diff_rad=diff_HradC_day$day \
beam_rad=beam_HradC_day$day 
# refl_rad=refl_HradC_day$day  # orizontal 0 reflectance 


g.remove rast=linke${day}_${filename}_coef,albedo${day}_${filename}_coef,cloud${day}_${filename}_coef 

' _



echo starting to calculate average at montly level

echo 1 31 61 91 121 151 181 211 242 273 304 335 | xargs -n 1  -P 6 bash -c  $'  

day=$1

if [ $day -eq 1   ] ; then  month=1  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 31  ] ; then  month=2  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 61  ] ; then  month=3  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 91  ] ; then  month=4  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 121 ] ; then  month=5  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 151 ] ; then  month=6  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 181 ] ; then  month=7  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 211 ] ; then  month=8  ; dayend=$(expr $day + 28 ) ; n=30 ; fi   # 30 days  
if [ $day -eq 242 ] ; then  month=9  ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 273 ] ; then  month=10 ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 304 ] ; then  month=11 ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  
if [ $day -eq 335 ] ; then  month=12 ; dayend=$(expr $day + 29 ) ; n=31 ; fi   # 31 days  

r.mapcalc  " glob_HradC_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  glob_HradC_day${dayn} +  ; done)  glob_HradC_day$(expr $day + $n - 1)  ) ) /$n " 
r.mapcalc  " diff_HradC_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  diff_HradC_day${dayn} +  ; done)  diff_HradC_day$(expr $day + $n - 1)  ) ) /$n "
r.mapcalc  " beam_HradC_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  beam_HradC_day${dayn} +  ; done)  beam_HradC_day$(expr $day + $n - 1)  ) ) /$n "
# r.mapcalc  " refl_HradC_m$month = (  $(  echo $(for dayn in `seq $day $dayend` ;   do  echo  refl_HradC_day${dayn} +  ; done)  refl_HradC_day$(expr $day + $n - 1)  ) ) /$n "

r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=glob_HradC_m$month    output=$INDIRD/glob_rad/$OUTDIR/glob_HradC_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=diff_HradC_m$month    output=$INDIRD/diff_rad/$OUTDIR/diff_HradC_month$month"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=beam_HradC_m$month    output=$INDIRD/beam_rad/$OUTDIR/beam_HradC_month$month"_"$file
# r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=refl_HradC_m$month    output=$INDIRD/refl_rad/$OUTDIR/refl_HradC_month$month"_"$file


if [ ${filename:0:1} -eq 0 ] ; then 
# this was inserted becouse the r.out.gdal of the 0_? was overpassing the -180 border and it was attach the tile to the right border 
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $INDIRD/glob_rad/$OUTDIR/glob_HradC_month$month"_"$file  $INDIRD/glob_rad/$OUTDIR/glob_HradC_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $INDIRD/diff_rad/$OUTDIR/diff_HradC_month$month"_"$file  $INDIRD/diff_rad/$OUTDIR/diff_HradC_month$month"_"$file"_tmp"
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr   $(getCorners4Gtranslate $INTIF/$file)  $INDIRD/beam_rad/$OUTDIR/beam_HradC_month$month"_"$file  $INDIRD/beam_rad/$OUTDIR/beam_HradC_month$month"_"$file"_tmp"
# gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_ullr $(getCorners4Gtranslate $INTIF/$file)  $INDIRD/refl_rad/$OUTDIR/refl_HradC_month$month"_"$file  $INDIRD/refl_rad/$OUTDIR/refl_HradC_month$month"_"$file"_tmp"

mv $INDIRD/glob_rad/$OUTDIR/glob_HradC_month$month"_"$file"_tmp" $INDIRD/glob_rad/$OUTDIR/glob_HradC_month$month"_"$file
mv $INDIRD/diff_rad/$OUTDIR/diff_HradC_month$month"_"$file"_tmp" $INDIRD/diff_rad/$OUTDIR/diff_HradC_month$month"_"$file
mv $INDIRD/beam_rad/$OUTDIR/beam_HradC_month$month"_"$file"_tmp" $INDIRD/beam_rad/$OUTDIR/beam_HradC_month$month"_"$file
# mv $INDIRD/refl_rad/$OUTDIR/refl_HradC_month$month"_"$file"_tmp" $INDIRD/refl_rad/$OUTDIR/refl_HradC_month$month"_"$file

fi


' _ 

) 2>&1 | tee  /tmp/log_of_$file".txt"

done 
exit 

# for day in `seq 1 2` ; do r.info  glob_HradC_day11   ; done 





