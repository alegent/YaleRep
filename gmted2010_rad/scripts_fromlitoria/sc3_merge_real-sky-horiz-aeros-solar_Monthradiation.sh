# mosaic the tile and create a stak layer 
# needs to be impruved with the data type; now keep as floting. 
# reflect in caso di slope=0 reflectance 0 quindi non calcolata 
# for DIR in  beam  diff  glob  ; do bash  /mnt/data2/scratch/GMTED2010/scripts/sc3_merge_real-sky-horiz-aeros-solar_Monthradiation.sh  $DIR ; done 


export DIR=$1
export INDIR=/mnt/data2/scratch/GMTED2010/grassdb/${DIR}_rad/months_gr_horiz1_aeros/
export OUTDIR=/mnt/data2/scratch/GMTED2010/grassdb/${DIR}_rad/months_merge_horiz1_aeros/


seq 1 12 | xargs -n 1  -P  12 bash -c $' 
month=$1
rm -f  $OUTDIR/${DIR}_HradC_month${month}.tif  
gdal_merge.py -ul_lr -172 75  -66  23.5  -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9  -ot Int16    $INDIR/${DIR}_HradC_month${month}_?_?.tif  -o  /tmp/ramdisk/${DIR}_HradC_month${month}.tif
gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9  -ot Int16    /tmp/ramdisk/${DIR}_HradC_month${month}.tif    $OUTDIR/${DIR}_HradCA_month${month}.tif 
rm -f /tmp/ramdisk/${DIR}_HradC_month${month}.tif 
' _ 

rm -f $OUTDIR/${DIR}_HradC_months.tif 
gdal_merge.py  -separate  -co  COMPRESS=LZW -co ZLEVEL=9 -co BIGTIFF=YES -ot Int16  $OUTDIR/${DIR}_HradCA_month[1-9].tif  $OUTDIR/${DIR}_HradCA_month1[0-2].tif   -o  $OUTDIR/${DIR}_HradCA_months.tif

gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_HradCA_months.tif $OUTDIR/${DIR}_HradCA_months2.tif 
mv $OUTDIR/${DIR}_HradCA_months2.tif  $OUTDIR/${DIR}_HradCA_months.tif 