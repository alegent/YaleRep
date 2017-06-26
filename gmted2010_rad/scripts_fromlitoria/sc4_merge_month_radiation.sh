# mosaic the tile and create a stak layer 
# needs to be impruved with the data type; now keep as floting. 

export INDIR=/mnt/data2/scratch/GMTED2010/grassdb/glob_rad/months
export OUTDIR=/mnt/data2/scratch/GMTED2010/grassdb/glob_rad/months_merge 


seq 1 12 | xargs -n 1  -P  12 bash -c $' 
month=$1
rm -f  $OUTDIR/glob_rad_month${month}.tif 
gdal_merge.py  -co  COMPRESS=LZW -co ZLEVEL=9  -ot Int16    $INDIR/glob_rad_month${month}_?_?.tif -o  /tmp/glob_rad_month${month}.tif
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9  -ot Int16   /tmp/glob_rad_month${month}.tif  $OUTDIR/glob_rad_month${month}.tif 
rm /tmp/glob_rad_month${month}.tif 

' _ 


rm $OUTDIR/glob_rad_months.tif 
gdal_merge.py  -separate  -co  COMPRESS=LZW -co ZLEVEL=9 -co BIGTIFF=YES -ot Int16  $OUTDIR/glob_rad_month[1-9].tif  $OUTDIR/glob_rad_month1[0-2].tif   -o  $OUTDIR/glob_rad_months.tif

gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/glob_rad_months.tif $OUTDIR/glob_rad_months2.tif 
mv $OUTDIR/glob_rad_months2.tif  $OUTDIR/glob_rad_months.tif 