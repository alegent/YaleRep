

# for dir in `seq -600 100 8700` ; do echo $dir ; done |  xargs -n 1 -P 36 bash /mnt/data/jetzlab/Data/environ/global/dem_class/sc2_dem_treshold_density_merge.sh

DIR=$1

INDIR=/mnt/data/jetzlab/Data/environ/global/dem_class/class$DIR
OUTDIR=/mnt/data/jetzlab/Data/environ/global/dem_class/percent

rm  $INDIR/file_processed_sc1.txt  # the file has ben processed by the script sc1_dem_treshold_percent.sh

for tile in `cat $OUTDIR/../geo_file/list_tiles.txt  ` ; do 

# for tile in `grep -e N45E09*  -e  N50E09* -e N55E09*   $OUTDIR/../list_tiles.txt`  ; do 

    if [ -f $INDIR/$tile"_C"$DIR"Perc.tif" ] ; then 

	echo the file  $INDIR/$tile"_C"$DIR"Perc.tif"   exist and will be merged as it is
	echo $tile"_C"$DIR"Perc.tif" >>  $INDIR/file_processed_sc1.txt # usefull to list file processed by script sc1, in case of delatio use this.

    else

max=$( awk '{print $2 * 100  }'  /mnt/data/jetzlab/Data/environ/global/dem_class/txt/$tile"_min_max.txt")
min=$( awk '{print $1 * 100  }'  /mnt/data/jetzlab/Data/environ/global/dem_class/txt/$tile"_min_max.txt")

echo $min and $max compare to $DIR

if [ $max -lt $DIR ]  ;  then 
      echo building the $INDIR/$tile"_C"$DIR"Perc.tif"  with 0 value
      pkgetmask -min 100 -max 101  -t 0 -ot Byte -i $INDIR/../class/$tile"_class.tif" -co COMPRESS=LZW  -o $INDIR/$tile"_C"$DIR"Perc.tif" 
      gdalwarp -tr 0.00833333333333 -0.00833333333333 -co COMPRESS=LZW   -ot Byte $INDIR/$tile"_C"$DIR"Perc_tmp.tif" $INDIR/$tile"_C"$DIR"Perc.tif" 
      rm $INDIR/$tile"_C"$DIR"Perc_tmp.tif" 
fi 

if [ $min -gt $DIR ] ; then 
      echo building the $INDIR/$tile"_C"$DIR"Perc.tif"  with 100 value 
      pkgetmask -min 100 -max 101  -t 0 -f 100  -ot Byte  -co COMPRESS=LZW  -i $INDIR/../class/$tile"_class.tif"  -o $INDIR/$tile"_C"$DIR"Perc.tif" 
      gdalwarp -tr 0.00833333333333 -0.00833333333333 -co COMPRESS=LZW   -ot Byte $INDIR/$tile"_C"$DIR"Perc_tmp.tif" $INDIR/$tile"_C"$DIR"Perc.tif" 
      rm $INDIR/$tile"_C"$DIR"Perc_tmp.tif" 
fi 

fi  

done

# pkcrop -ulx -180  -uly  83  -lrx  180  -lry -60    -ot Byte  -co COMPRESS=LZW  -o $OUTDIR/perc_$DIR.tif  $(for file in $INDIR/Smoothed_N*E*_C$DIR"Perc.tif" ; do echo -n "-i $file " ; done)

gdal_merge.py -ul_lr  -180  83  180  -60  -ps -0.008333333333330  -0.008333333333330   -ot Byte  -o $OUTDIR/perc_NE_$DIR.tif  $INDIR/Smoothed_N*E*_C$DIR"Perc.tif" 
gdal_merge.py -ul_lr  -180  83  180  -60  -ps -0.008333333333330  -0.008333333333330   -ot Byte  -o $OUTDIR/perc_NW_$DIR.tif  $INDIR/Smoothed_N*W*_C$DIR"Perc.tif" 
gdal_merge.py -ul_lr  -180  83  180  -60  -ps -0.008333333333330  -0.008333333333330   -ot Byte  -o $OUTDIR/perc_SE_$DIR.tif  $INDIR/Smoothed_S*E*_C$DIR"Perc.tif" 
gdal_merge.py -ul_lr  -180  83  180  -60  -ps -0.008333333333330  -0.008333333333330   -ot Byte  -o $OUTDIR/perc_SW_$DIR.tif  $INDIR/Smoothed_S*W*_C$DIR"Perc.tif" 

gdal_merge.py -ul_lr  -180  83  180 -60   -co COMPRESS=LZW   -ps -0.008333333333330  -0.008333333333330 -ot Byte -o $OUTDIR/perc_$DIR.tif  $INDIR/Smoothed_N*E*_C$DIR"Perc.tif" $INDIR/Smoothed_N*W*_C$DIR"Perc.tif" $INDIR/Smoothed_S*E*_C$DIR"Perc.tif" $INDIR/Smoothed_S*W*_C$DIR"Perc.tif" 

