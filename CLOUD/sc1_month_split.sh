# cut the tif in northen par

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/month
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD

# this is usefull to take out the colored table in the image....the color table produce an error in buldvrt 

echo  01  02 03 04 05 06 07 08 09 10 11 12 | xargs -n 1 -P 12 bash -c $' 
month=$1
gdalbuildvrt -overwrite   $INDIR/MCD09_mean_${month}.vrt    $INDIR/MCD09_mean_${month}.tif  
head  -6  $INDIR/MCD09_mean_${month}.vrt     >  $INDIR/MCD09_mean_${month}a.vrt 
echo  "<ColorInterp>Grey</ColorInterp>"     >>  $INDIR/MCD09_mean_${month}a.vrt
tail -10  $INDIR/MCD09_mean_${month}.vrt    >>  $INDIR/MCD09_mean_${month}a.vrt 
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9    $INDIR/MCD09_mean_${month}a.vrt $INDIR/MCD09_mean_${month}_noct.tif 

rm -f  $INDIR/MCD09_mean_${month}a.vrt  $INDIR/MCD09_mean_${month}.vrt   $INDIR/MCD09_mean_${month}_noct.tif.aux.xml 

' _ 


# area with no data y dimension 

echo 02 720  >  y.txt
echo 11 1560 >> y.txt
echo 01 1980 >> y.txt
echo 12 2520 >> y.txt


# for dicember cut all the month 

yoff=$(grep ^01 y.txt | awk '{  print $2 }'  )
ylow=$(grep ^12 y.txt | awk '{  print $2 }'  )
ysize=$(( $ylow -   $yoff ))

for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do 
    gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin 0 $yoff 43200 $ysize    $INDIR/MCD09_mean_$month.tif  $OUTDIR/month12_cut/MCD09_mean_$month.tif
done 
rm  $OUTDIR/month12_cut/MCD09_mean_12.tif # this will be predicted 

gdalbuildvrt   -separate   -overwrite   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean_??.tif  $OUTDIR/month12_cut/MCD09_mean_??.tif   $OUTDIR/month12_cut/MCD09_mean_??.tif 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean.tif
rm  $OUTDIR/month12_cut/MCD09_mean.vrt

# predict the dicember stripe with the other months

pkfilter  $(seq 1 11 | xargs -n 1 echo -win)  $(seq 13 23 | xargs -n 1 echo -win)  $(seq 25 35 | xargs -n 1 echo -win)  -wout 24  -fwhm 3 -i  $OUTDIR/month12_cut/MCD09_mean.tif -o  $OUTDIR/month12_cut/MCD09_mean_12a.tif
rm -f $OUTDIR/month12_cut/MCD09_mean.tif

# for dicember and january cut all the months                                  2 month prediction 


yoff=$(grep ^11 y.txt | awk '{  print $2 }'  )
ylow=$(grep ^01 y.txt | awk '{  print $2 }'  )
ysize=$(( $ylow -   $yoff ))

for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do 
    gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin 0 $yoff 43200 $ysize    $INDIR/MCD09_mean_$month.tif  $OUTDIR/month12_cut/MCD09_mean_$month.tif
done 
rm  $OUTDIR/month12_cut/MCD09_mean_12.tif  $OUTDIR/month12_cut/MCD09_mean_01.tif # this will be predicted 

gdalbuildvrt   -separate   -overwrite   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean_??.tif  $OUTDIR/month12_cut/MCD09_mean_??.tif   $OUTDIR/month12_cut/MCD09_mean_??.tif 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean.tif
rm  $OUTDIR/month12_cut/MCD09_mean.vrt

# predict the dicember stripe with the other months

pkfilter  $(seq 2 11 | xargs -n 1 echo -win)  $(seq 14 23 | xargs -n 1 echo -win)  $(seq 26 35 | xargs -n 1 echo -win)  -wout 24  -fwhm 3  -wout 25    -fwhm 3 -i  $OUTDIR/month12_cut/MCD09_mean.tif -o  $OUTDIR/month12_cut/MCD09_mean_stak.tif


gdal_translate  -b 1  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_12b.tif
gdal_translate  -b 2  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_01b.tif



# for dicember and january november  cut all the months                         3 month 

yoff=$(grep ^02 y.txt | awk '{  print $2 }'  )
ylow=$(grep ^11 y.txt | awk '{  print $2 }'  )
ysize=$(( $ylow -   $yoff ))

for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do 
    gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin 0 $yoff 43200 $ysize    $INDIR/MCD09_mean_$month.tif  $OUTDIR/month12_cut/MCD09_mean_$month.tif
done 
rm  $OUTDIR/month12_cut/MCD09_mean_11.tif   $OUTDIR/month12_cut/MCD09_mean_12.tif $OUTDIR/month12_cut/MCD09_mean_01.tif # this will be predicted 

gdalbuildvrt   -separate   -overwrite   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean_??.tif  $OUTDIR/month12_cut/MCD09_mean_??.tif   $OUTDIR/month12_cut/MCD09_mean_??.tif 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean.tif
rm  $OUTDIR/month12_cut/MCD09_mean.vrt

# predict the dicember stripe with the other months

pkfilter  $(seq 2 10 | xargs -n 1 echo -win)  $(seq 14 22 | xargs -n 1 echo -win)  $(seq 26 34 | xargs -n 1 echo -win)  -wout 23 -fwhm 3 -wout 24 -fwhm 3 -wout 25 -fwhm 3 -i  $OUTDIR/month12_cut/MCD09_mean.tif -o  $OUTDIR/month12_cut/MCD09_mean_stak.tif

gdal_translate  -b 1  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_11c.tif
gdal_translate  -b 2  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_12c.tif
gdal_translate  -b 3  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_01c.tif

# for dicember and january november and february  cut all the months            4 month prediction 

yoff=0
ysize=720

for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do 
    gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin 0 $yoff 43200 $ysize    $INDIR/MCD09_mean_$month.tif  $OUTDIR/month12_cut/MCD09_mean_$month.tif
done 
rm  $OUTDIR/month12_cut/MCD09_mean_12.tif  $OUTDIR/month12_cut/MCD09_mean_01.tif $OUTDIR/month12_cut/MCD09_mean_11.tif $OUTDIR/month12_cut/MCD09_mean_02.tif  # this will be predicted 

gdalbuildvrt   -separate   -overwrite   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean_??.tif  $OUTDIR/month12_cut/MCD09_mean_??.tif   $OUTDIR/month12_cut/MCD09_mean_??.tif 
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/month12_cut/MCD09_mean.vrt   $OUTDIR/month12_cut/MCD09_mean.tif


rm  $OUTDIR/month12_cut/MCD09_mean.vrt

# predict the november dicember jenuary and february stripe with the other months

pkfilter  $(seq 3 10 | xargs -n 1 echo -win)  $(seq 15 22 | xargs -n 1 echo -win)  $(seq 27 34 | xargs -n 1 echo -win) -wout 23 -fwhm 3 -wout 24 -fwhm 3  -wout 25  -fwhm 3 -wout 26  -fwhm 3  -i  $OUTDIR/month12_cut/MCD09_mean.tif -o  $OUTDIR/month12_cut/MCD09_mean_stak.tif

gdal_translate   -b 1  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_11d.tif
gdal_translate   -b 2  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_12d.tif
gdal_translate   -b 3  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_01d.tif
gdal_translate   -b 4  -co  COMPRESS=LZW -co ZLEVEL=9     $OUTDIR/month12_cut/MCD09_mean_stak.tif  $OUTDIR/month12_cut/MCD09_mean_02d.tif

# merge the results 

echo  11 12 01 02    | xargs -n 1 -P 4  bash -c $' 
month=$1
TIF=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/month_inter
gdalbuildvrt -srcnodata  65535  -vrtnodata 65535   -hidenodata -overwrite    $TIF/MCD09_mean_${month}_interp.vrt  $INDIR/MCD09_mean_${month}_noct.tif $OUTDIR/month12_cut/MCD09_mean_${month}?.tif
gdal_translate  -co PREDICTOR=2  -co  COMPRESS=LZW -co ZLEVEL=9   $TIF/MCD09_mean_${month}_interp.vrt  $TIF/MCD09_mean_${month}_interp.tif
rm -f   $TIF/MCD09_mean_${month}_interp.vrt
' _ 


