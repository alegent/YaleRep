# calculate different variables for the dem 
# for dir1  in altitude  ; do for dir2 in stdev ; do echo $dir1/$dir2 ; done ; done  | xargs -n 1 -P 5 bash /mnt/data2/dem_variables/scripts/sc2_dem_merge.sh
# for dir1  in altitude slope tri tpi roughness ; do for dir2 in max mean median min stdev; do echo $dir1/$dir2 ; done ; done  | xargs -n 1 -P 12  bash /mnt/data2/dem_variables/scripts/sc2_dem_merge.sh


OUTDIR=/mnt/data2/dem_variables/resol_x5

DIR=$1
dir1=$(echo ${DIR%/*})   # cancel the part after  /
dir2=$(echo ${DIR#*/})   # cancel the part before /


rm  $OUTDIR/$DIR/$dir1"_"$dir2.tif

echo processing merging tiles in $dir1   

if [ $dir1=altitude ]  ; then type=Int16 ; fi 
if [ $dir1=slope ]     ; then type=Byte ; fi  
if [ $dir1=tri ]       ; then type=Int16 ; fi 
if [ $dir1=tpi ]       ; then type=Int16 ; fi 
if [ $dir1=roughness ] ; then type=Int16 ; fi 
           
rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_NW*.tif 
rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_NE*.tif 
rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_SW*.tif  
rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_SE*.tif  

for tile in 0 1 2 3 4 5 6 7 8 ; do 
    gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_NW"${tile}.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_N${tile}*W*.tif 
    gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_NE"${tile}.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_N${tile}*E*.tif 

    gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_SW"${tile}.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_S${tile}*W*.tif 
    gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2"_SE"${tile}.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/tiles/Smoothed_S${tile}*E*.tif 
done 

rm -f  $OUTDIR/$DIR/$dir1"_"$dir2.tif

gdal_merge.py -o $OUTDIR/$DIR/$dir1"_"$dir2.tif -ot $type -co COMPRESS=LZW  $OUTDIR/$DIR/$dir1"_"${dir2}_NW*.tif $OUTDIR/$DIR/$dir1"_"${dir2}_NE*.tif $OUTDIR/$DIR/$dir1"_"${dir2}_SW*.tif  $OUTDIR/$DIR/$dir1"_"${dir2}_SE*.tif  


rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_NW*.tif 
rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_NE*.tif 
rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_SW*.tif  
rm -f $OUTDIR/$DIR/$dir1"_"${dir2}_SE*.tif  





