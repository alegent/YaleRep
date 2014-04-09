# calculate different variables for the dem 
# for dir1  in altitude  ; do for dir2 in stdev ; do echo $dir1/$dir2 ; done ; done  | xargs -n 1 -P 5 bash /mnt/data2/dem_variables/scripts/sc2_dem_merge.sh
# for dir1  in altitude slope tri tpi roughness ; do for dir2 in max mean median min stdev; do echo $dir1/$dir2 ; done ; done  | xargs -n 1 -P 12  bash /mnt/data2/dem_variables/scripts/sc2_dem_merge.sh


OUTDIR=/mnt/data2/dem_variables

DIR=$1
dir1=$(echo ${DIR%/*})   # cancel the part after  /
dir2=$(echo ${DIR#*/})   # cancel the part before /


if [ $dir1 = altitude ]  ; then type=Int16 ; fi 
if [ $dir1 = aspect ]    ; then type=Int16 ; fi 
if [ $dir1 = slope ]     ; then type=Byte ; fi  
if [ $dir1 = tri ]       ; then type=Int16 ; fi 
if [ $dir1 = tpi ]       ; then type=Int16 ; fi   
if [ $dir1 = roughness ] ; then type=Int16 ; fi 

if [ $dir1 != aspect ]; then 

echo processing merging tiles in $dir1   
           
rm -f $OUTDIR/$DIR/$dir1"_"$dir2.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NW".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NE".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SW".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SE".tif

gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_NW".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_N*W*.tif 
gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_NE".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_N*E*.tif 
gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_SW".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_S*W*.tif  
gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_SE".tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_S*E*.tif  

rm -f  $OUTDIR/$DIR/$dir1"_"$dir2.tif

gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/$dir1"_"$dir2"_NW".tif  $OUTDIR/$DIR/$dir1"_"$dir2"_NE".tif  $OUTDIR/$DIR/$dir1"_"$dir2"_SW".tif  $OUTDIR/$DIR/$dir1"_"$dir2"_SE".tif 

rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NW".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NE".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SW".tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SE".tif

else  # just applaied to the aspect variables 

echo processing merging tiles for the different aspect variables in $dir1   

for aspect_var in "_sin_t10k" "_cos_t10k" "_Ew_t10k" "_Nw_t10k" ; do 

rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NW"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NE"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SW"$aspect_var.tif
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SE"$aspect_var.tif

gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_NW"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_N*W*$aspect_var.tif
gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_NE"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_N*E*$aspect_var.tif 
gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_SW"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_S*W*$aspect_var.tif
gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_SE"$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_S*E*$aspect_var.tif

rm -f  $OUTDIR/$DIR/$dir1"_"$dir2$aspect_var.tif

gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2$aspect_var.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/$dir1"_"$dir2"_NW"$aspect_var.tif  $OUTDIR/$DIR/$dir1"_"$dir2"_NE"$aspect_var.tif  $OUTDIR/$DIR/$dir1"_"$dir2"_SW"$aspect_var.tif  $OUTDIR/$DIR/$dir1"_"$dir2"_SE"$aspect_var.tif

rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NW"$aspect_var.tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_NE"$aspect_var.tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SW"$aspect_var.tif  
rm -f $OUTDIR/$DIR/$dir1"_"$dir2"_SE"$aspect_var.tif

done

fi 



