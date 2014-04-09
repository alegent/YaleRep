# cd  /mnt/data2/scratch/GMTED2010/grassdb 
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/?_?.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_solar_radiation.sh
# ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{1_1,1_2,2_1,2_2,1_0,2_0}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc2_real-sky-solar_radiation.sh

file=`basename $1 .tif`

time (

export file=`basename $1`
export filename=`basename $file .tif`

export INDIRG=/media/data/grassdb1
export INDIRD=/mnt/data2/scratch/GMTED2010/grassdb

# rm -rf  $INDIRG/loc_$filename
echo clip the data 

cd $INDIRG

# clip the 1km dem, use the be75_grd_tif to ensure larger overlap
# gdal_translate -projwin  $(getCorners4Gtranslate  /mnt/data2/scratch/GMTED2010/tiles/be75_grd_tif/$file) $INDIRD/mn30_grd_tif/mn30_grd.tif $file

# echo create location 

# /mnt/data2/scratch/GMTED2010/scripts/create_location_gr.sh   $file   loc_$filename  $INDIRG
# rm -f $file 
# echo enter in grass 

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


# echo calculate r.slope.aspect  
# r.slope.aspect elevation=$file   aspect=aspect_$filename  slope=slope_$filename  

# produce 12 maps 
# r.horizon elevin=$filename  horizonstep=30 horizon=horangle dist=1 maxdistance=1000

g.mremove -f  rast=*_coef

for day in `seq 1  365` ; do 

# import albedo 

cd $INDIRD 

# gdal_translate  -a_nodata 32767   -projwin  $(getCorners4Gtranslate  /mnt/data2/scratch/GMTED2010/tiles/be75_grd_tif/$file)  /mnt/data2/scratch/GMTED2010/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_estimation/AlbMap.WS.c004.v2.0.00-04.${day}.0.3_5.0.tif    /mnt/data2/scratch/GMTED2010/grassdb/alb_WS/${filename}_albWS_day${day}.tif  
# r.external  -o input=$INDIRD/alb_WS/${filename}_albWS_day${day}.tif    output=${filename}_albWS_day${day}  --overwrite 

r.external  -o input=/mnt/data2/scratch/GMTED2010/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_estimation/AlbMap.WS.c004.v2.0.00-04.${day}.0.3_5.0.tif   output=${filename}_albWS_day${day}  --overwrite 
r.mapcalc  ${filename}_albWS_day${day}_coef = " ${filename}_albWS_day${day}  * 0.001" 

# import Linke turbidity and cloud

if [ $day -ge 1  ] && [ $day -le 31 ]   ; then LT=January  ; MONTH=1 ; fi 
if [ $day -ge 32 ] && [ $day -le 59 ]   ; then LT=February ; MONTH=2 ; fi  
if [ $day -ge 60 ] && [ $day -le 90 ]   ; then LT=March    ; MONTH=3 ;fi 
if [ $day -ge 91 ] && [ $day -le 120 ]  ; then LT=April    ; MONTH=4 ; fi  
if [ $day -ge 121 ] && [ $day -le 151 ] ; then LT=May      ; MONTH=5 ; fi  
if [ $day -ge 152 ] && [ $day -le 181 ] ; then LT=June     ; MONTH=6 ; fi  
if [ $day -ge 182 ] && [ $day -le 212 ] ; then LT=July     ; MONTH=7 ;fi  
if [ $day -ge 213 ] && [ $day -le 243 ] ; then LT=August   ; MONTH=8 ; fi  
if [ $day -ge 244 ] && [ $day -le 273 ] ; then LT=September; MONTH=9 ;fi  
if [ $day -ge 274 ] && [ $day -le 304 ] ; then LT=October  ; MONTH=10  ;fi  
if [ $day -ge 305 ] && [ $day -le 334 ] ; then LT=November ; MONTH=11 ;fi  
if [ $day -ge 335 ] && [ $day -le 365 ] ; then LT=December ; MONTH=12 ;fi 

# gdal_translate   -projwin  $(getCorners4Gtranslate  /mnt/data2/scratch/GMTED2010/tiles/be75_grd_tif/$file) /mnt/data2/scratch/GMTED2010/linke_turbidity/${LT}.tif /mnt/data2/scratch/GMTED2010/grassdb/linke_turbidity_clip/${LT}_${filename}_day${day}.tif  
# r.external -o input=/mnt/data2/scratch/GMTED2010/grassdb/linke_turbidity_clip/${LT}_${filename}_day${day}.tif  output=${LT}_${filename}_day${day}  --overwrite 
# rm -f /mnt/data2/scratch/GMTED2010/grassdb/linke_turbidity_clip/${LT}_${filename}_day${day}.tif 

LTcoef=$(g.mlist type=rast pattern=${LT}_${filename}_coef)
Ccoef=$(g.mlist type=rast pattern=cloud${MONTH}_${filename}_coef)



if [ -z  $LTcoef ] && [ -z $Ccoef  ] ; then 
    #  import Linke
    r.external -o input=/mnt/data2/scratch/GMTED2010/linke_turbidity/${LT}.tif     output=${LT}_${filename}  --overwrite 
    r.mapcalc  ${LT}_${filename}_coef = "${LT}_${filename}  * 0.05 " 
    #  import cloud
    r.external -o input=/mnt/data2/scratch/GMTED2010/cloud/tif/cloud${MONTH}.tif     output=cloud${MONTH}_${filename}  --overwrite 
    r.mapcalc  cloud${MONTH}_${filename}_coef = "cloud${MONTH}_${filename} * 0.001" 
else
    echo the file  ${LT}_${filename}_coef  cloud${MONTH}_${filename}_coef   exist 
fi 


echo run r.sun 

r.sun -s  elevin=$file aspin=aspect_$filename  slopein=slope_$filename   linkein=${LT}_${filename}_coef   albedo=${filename}_albWS_day${day}_coef    coefbh=cloud${MONTH}_${filename}_coef     day=$day step=1 \
glob_rad=glob_radC_day$day"_"$filename \
diff_rad=diff_radC_day$day"_"$filename \
beam_rad=beam_radC_day$day"_"$filename \
refl_rad=refl_radC_day$day"_"$filename

g.remove rast=${filename}_albWS_day${day}_coef

r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=glob_radC_day$day"_"$filename    output=$INDIRD/glob_rad/${day}/glob_radC_day$day"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=diff_radC_day$day"_"$filename    output=$INDIRD/diff_rad/${day}/diff_radC_day$day"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=beam_radC_day$day"_"$filename    output=$INDIRD/beam_rad/${day}/beam_radC_day$day"_"$file
r.out.gdal -c type=Float32  nodata=-1  createopt="COMPRESS=LZW,ZLEVEL=9"  input=refl_radC_day$day"_"$filename    output=$INDIRD/refl_rad/${day}/refl_radC_day$day"_"$file

if [ ${filename:0:1} -eq 0 ] ; then 
# this was inserted becouse the r.out.gdal of the 0_? was overpassing the -180 border and it was attach the tile to the right border 
gdal_translate  -a_ullr   $(getCorners4Gtranslate $file)  $INDIRD/glob_rad/${day}/glob_radC_day$day"_"$file $INDIRD/glob_rad/${day}/glob_radC_day$day"_"$file"_tmp"
gdal_translate  -a_ullr   $(getCorners4Gtranslate $file)  $INDIRD/diff_rad/${day}/diff_radC_day$day"_"$file $INDIRD/diff_rad/${day}/diff_radC_day$day"_"$file"_tmp"
gdal_translate  -a_ullr   $(getCorners4Gtranslate $file)  $INDIRD/beam_rad/${day}/beam_radC_day$day"_"$file $INDIRD/beam_rad/${day}/beam_radC_day$day"_"$file"_tmp"
gdal_translate  -a_ullr   $(getCorners4Gtranslate $file)  $INDIRD/refl_rad/${day}/refl_radC_day$day"_"$file $INDIRD/refl_rad/${day}/refl_radC_day$day"_"$file"_tmp"

mv $INDIRD/glob_rad/${day}/glob_radC_day$day"_"$file"_tmp" $INDIRD/glob_rad/${day}/glob_radC_day$day"_"$file 
mv $INDIRD/diff_rad/${day}/diff_radC_day$day"_"$file"_tmp" $INDIRD/diff_rad/${day}/diff_radC_day$day"_"$file 
mv $INDIRD/beam_rad/${day}/beam_radC_day$day"_"$file"_tmp" $INDIRD/beam_rad/${day}/beam_radC_day$day"_"$file 
mv $INDIRD/refl_rad/${day}/refl_radC_day$day"_"$file"_tmp" $INDIRD/refl_rad/${day}/refl_radC_day$day"_"$file 

fi
done 

g.mremove  type=rast pattern=*_*_*_coef

rm -f $file ~/.grassrc6$$ 

) 2>&1 | tee  /tmp/log_of_$file".txt"

exit 


# To compute the 

# actual surface albedo, MODIS-estimated black sky albedo (reflectance of direct beam radiation at solar noon) 
#                                    and white sky albedo (reflectance of isotropic diffuse radiation)


# coefbh=string
#     Name of real-sky beam radiation coefficient (thick cloud) input raster map [0-1]
# coefdh=string
#     Name of real-sky diffuse radiation coefficient (haze) input raster map [0-1]
#     κL is the extinction coefficient for diffuse radiation 