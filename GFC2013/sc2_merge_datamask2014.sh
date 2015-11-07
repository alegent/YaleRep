
# bash /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc2_merge_datamask2014.sh



INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask/tif_1km
OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask


rm -f $OUTDIR/water_perc_NE.tif  $OUTDIR/water_perc_SE.tif  $OUTDIR/water_perc_NW.tif $OUTDIR/water_perc_SW.tif 

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_datamask_??N_???E.tif -o $OUTDIR/water_perc_NE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_datamask_??S_???E.tif -o $OUTDIR/water_perc_SE.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_datamask_??N_???W.tif -o $OUTDIR/water_perc_NW.tif
gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9   $INDIR/1km_Hansen_GFC2014_datamask_??S_???W.tif -o $OUTDIR/water_perc_SW.tif

gdal_merge.py -co  COMPRESS=LZW -co ZLEVEL=9 $OUTDIR/water_perc_??.tif -o   $OUTDIR/land_frequency_GFC2014.tif



gdal_edit.py -mo "Author=giuseppe.amatulli@gmail.com using pktools"\
             -mo "Input dataset=Global Forest Change 2000-2013 (Hansen 2014)" \
             -mo "Input layer=Data mask"\
             -mo "Output=Land Frequency(%)"\
             -mo "Offset=0" -mo "Scale=0.01" $OUTDIR/land_frequency_GFC2014.tif
