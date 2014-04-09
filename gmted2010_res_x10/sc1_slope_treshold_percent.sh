# calculate slope or area percent above a specific treshold   eg 0-4.9 put 0 ; 5-9.9 put 5
# for this case the treshold is set every 5 degrees  
# geting the integer of the altitued / 100

# ls /mnt/data/jetzlab/Data/environ/global/dem_variables/slope/tiles/Smoothed_N*E*.tif  | xargs -n 1 -P 36  bash /mnt/data/jetzlab/Data/environ/global/dem_variables/scripts/sc1_slope_treshold_percent.sh
# too check 
# ny=45 ; for n in `seq 1 9` ;do echo ` gdallocationinfo -valonly tiles/Smoothed_N00E005.tif 2$n $ny` `gdallocationinfo  -valonly  class/class/Smoothed_N00E005_class.tif 2$n $ny` ; done 

export file=$1
export filename=`basename $file .tif`
(
INDIR=/mnt/data/jetzlab/Data/environ/global/dem_variables/slope/tiles
OUTDIR=/mnt/data/jetzlab/Data/environ/global/dem_variables/slope/class/class

# calcualte slope every 5 degree using the the Int16 factors

oft-calc  -ot Byte $INDIR/$filename.tif $OUTDIR/$filename"_class_tmp1.tif"    <<EOF
1
#1 2.5 - 5 /
EOF

oft-calc  -inv -ot Byte  $OUTDIR/$filename"_class_tmp1.tif"  $OUTDIR/$filename"_class_tmp2.tif"     <<EOF
1
#1 5 *
EOF

oft-calc  -inv -ot Byte  $OUTDIR/$filename"_class_tmp2.tif"  $OUTDIR/$filename"_class_tmp3.tif"    <<EOF
1
#1 0 < 0 #1 ?
EOF

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 $OUTDIR/$filename"_class_tmp3.tif" $OUTDIR/$filename"_class.tif"
rm $OUTDIR/$filename"_class_tmp1.tif"  $OUTDIR/$filename"_class_tmp2.tif" $OUTDIR/$filename"_class_tmp3.tif"

gdalinfo -mm $OUTDIR/$filename"_class.tif"  | grep Computed | awk '{ gsub ("[=,]"," "); print int($(NF-1)), int($(NF))}' > $OUTDIR/txt/$filename"_min_max.txt"

for class in $(seq `awk '{ print $1}'  $OUTDIR/txt/${filename}_min_max.txt` 5  `awk '{ print $2}' $OUTDIR/txt/${filename}_min_max.txt`) ; do 

    class_start=$class
    class_end=$(awk '{ print $2}' $OUTDIR/txt/$filename"_min_max.txt")
    class_string=$(for class_unique in $(seq $class_start 5  $class_end  ) ; do echo -n "-class $class_unique "  ; done) 

    echo applaid the filter for the classes  $class_string

    pkfilter -dx 10 -dy 10  $class_string -f density -d 10 -i $OUTDIR/$filename"_class.tif" -o $OUTDIR/../class$class/$filename"_C"$class"Perc.tif" -co COMPRESS=LZW -co ZLEVEL=9   -ot Byte 

done 


) 2>&1 | tee  /mnt/data/jetzlab/Data/environ/global/tif_tmp/log_of_$filename".txt"
