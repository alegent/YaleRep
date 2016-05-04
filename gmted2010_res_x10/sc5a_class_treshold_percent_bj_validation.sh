INDIR=/mnt/data/jetzlab/Data/environ/global/dem_variables/validation
OUTDIR=/mnt/data/jetzlab/Data/environ/global/dem_variables/validation
filename=dem513
echo  calcualte altitude  every 100 meter  using the the Int16 factors for $file 


# gdal_calc.py -A  $INDIR/$filename.tif   --calc="(A / 100)"  --outfile=$OUTDIR/tmp/$filename"_class_tmp1.tif" --type=Int16 --overwrite --co=COMPRESS=LZW 
# gdal_calc.py -A  $OUTDIR/tmp/$filename"_class_tmp1.tif" --calc="(A * 100)" --outfile=$OUTDIR/tmp/$filename"_class_tmp2.tif" --type=Int16 --overwrite --co=COMPRESS=LZW 

rm $OUTDIR/tmp/$filename"_class_tmp1.tif" 

# gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/tmp/$filename"_class_tmp2.tif" $OUTDIR/$filename"_class.tif"
rm $OUTDIR/tmp/$filename"_class_tmp2.tif"


# start to calculate for each treshold percent pixel
 
seq 0 100 4100 | xargs -n 1 -P 10 bash -c $' 
    INDIR=/mnt/data/jetzlab/Data/environ/global/dem_variables/validation/
    OUTDIR=/mnt/data/jetzlab/Data/environ/global/dem_variables/validation/
    filename=dem513
    class=$1
    class_start=$1
    class_end=4100
    class_string=$(for class_unique in $(seq $class_start 100  $class_end  ) ; do echo -n "-class $class_unique "  ; done) 

    echo applaid the filter for the classes  $class_string

    pkfilter -dx 10 -dy 10 $class_string -f density -d 10 -i $OUTDIR/$filename"_class.tif" -o $OUTDIR/class/$filename"_C"$class"Perc.tif" -co COMPRESS=LZW -co ZLEVEL=9 -ot Byte 

' _ 


