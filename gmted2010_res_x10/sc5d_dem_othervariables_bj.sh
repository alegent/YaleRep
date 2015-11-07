# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls *.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 

# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5d_dem_othervariables_bj.sh   
# bash  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5d_dem_othervariables_bj.sh   

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=3:00:00 
#PBS -l mem=34gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export INDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif
export OUTDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/stdev_pulled/tiles
export TMP=/tmp
export RAM=/dev/shm


rm -f $RAM/*

# pulled standard deviation see 
# http://en.wikipedia.org/wiki/Pooled_variance 
# C = 15 * sd^2                  =  D=sd^2
# =SQRT(SUM(C1:C16)/(15*16))    =  SQRT(SUM(D1:D16)/16)


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif/?_?.tif   | xargs -n 1 -P 8 bash -c $' 
file=$1
export filename=`basename $file .tif`
oft-calc -ot Float64  $file  $OUTDIR_SD/$filename.tif  <<EOF
1
#1 #1 *
EOF

pkfilter   -co COMPRESS=LZW    -dx 4 -dy 4   -f sum  -d 4 -i    $OUTDIR_SD/$filename.tif  -o  $RAM/${filename}_sum.tif

rm -f $OUTDIR_SD/$filename.tif  

oft-calc -ot Float32   $RAM/${filename}_sum.tif  $OUTDIR_SD/${filename}_p16sd.tif  <<EOF
1
#1 16 / 0.5 ^
EOF

oft-calc -ot Float32   $RAM/${filename}_sum.tif  $OUTDIR_SD/${filename}_p15sd.tif  <<EOF
1
#1 15 / 0.5 ^
EOF

rm -f $RAM/${filename}_sum.tif


# sd of the sd 

pkfilter  -ot Float32   -co COMPRESS=LZW    -dx 4 -dy 4 -f stdev  -d 4  -i    $file  -o  $OUTDIR_SD/${filename}_sd.tif

'  _ 

# see  http://en.wikipedia.org/wiki/Weighted_arithmetic_mean 

gdalbuildvrt -overwrite   $RAM/psd.vrt     $OUTDIR_SD/?_?_p16sd.tif
gdal_translate   -projwin -180 84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9   $RAM/psd.vrt    $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif

gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds pooled 16 standard deviation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds pooled standard deviation derived from GMTED2010 standard deviation, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4 " \
-a_ullr  -180 +84  +180 -56 \
$OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif

pksetmask  -co COMPRESS=LZW -co ZLEVEL=9    -msknodata  16384  -nodata 0   -i $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif -m $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif -o $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd_tmp.tif
mv $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd_tmp.tif  $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif 

gdalbuildvrt -overwrite   $RAM/psd.vrt     $OUTDIR_SD/?_?_p15sd.tif
gdal_translate   -projwin -180 84  +180 -56   -co COMPRESS=LZW -co ZLEVEL=9    $RAM/psd.vrt    $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd.tif

gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds pooled 15 standard deviation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds pooled standard deviation derived from GMTED2010 standard deviation, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4 " \
-a_ullr  -180 +84  +180 -56 \
$OUTDIR_SD/../elevation_p15sd_GMTED2010_sd.tif

# use the previus mask to mask the same output 


pkgetmask -ot  Byte  -min  16920 -max 16930  -data 1  -nodata 0  -i $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd.tif -o   $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd_4mask.tif

pksetmask  -co COMPRESS=LZW -co ZLEVEL=9    -msknodata  1  -nodata 0   -i $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd.tif -m $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd_4mask.tif  -o $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd_tmp.tif
mv $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd_tmp.tif  $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd.tif 
rm $OUTDIR_SD/../elevation_p15sd_GMTED2010_sd_4mask.tif 


# probabilmente la  $OUTDIR_SD/../elevation_sd_GMTED2010_sd.tif non serve piu quindi abbandonata

gdalbuildvrt -overwrite   $RAM/sd.vrt     $INDIR_SD/?_?.tif
gdal_translate   -projwin -180 84 +180 -56  -co COMPRESS=LZW -co ZLEVEL=9    $RAM/sd.vrt    $OUTDIR_SD/../elevation_sd_GMTED2010_sd.tif

gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds standard deviation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds standard deviation derived from GMTED2010 standard deviation, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4 " \
-a_ullr  -180 +84  +180 -56 \
$OUTDIR_SD/../elevation_sd_GMTED2010_sd.tif

# pksetmask  -co COMPRESS=LZW -co ZLEVEL=9    -msknodata  16384  -nodata 0   -i $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif -m $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif -o $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd_tmp.tif
# mv $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd_tmp.tif  $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif 



rm -f $RAM/*


exit
# da qui in poi 
# spostato il tutto su /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc9_ancillary_var.sh


oft-calc -ot Float32   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/mean_of_mn/altitude_mean_of_mn_md.tif  $OUTDIR_SD/../elevation_cvtmp_GMTED2010_mnsd_oft.tif   <<EOF  
1
#1 0.000000001 +
EOF

gdalbuildvrt -overwrite -separate $RAM/stack.vrt $OUTDIR_SD/../elevation_p16sd_GMTED2010_sd.tif  $OUTDIR_SD/../elevation_cvtmp_GMTED2010_mnsd_oft.tif 
oft-calc -ot Float32     $RAM/stack.vrt   $OUTDIR_SD/../elevation_cv_GMTED2010_mnsd_oft.tif   <<EOF  
1
#1 #2 / 100000 *
EOF
 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR_SD/../elevation_cv_GMTED2010_mnsd_oft.tif  $OUTDIR_SD/../elevation_cv_GMTED2010_mnsd.tif

# elevation range 

DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010

gdalbuildvrt -overwrite -separate $RAM/stack.vrt  $DIR/altitude/max_of_mx/altitude_max_of_mx_md.tif /GMTED2010_bk/elevation_mi_GMTED2010_mi.tif 

oft-calc -ot UInt32     $RAM/stack.vrt  /home/fas/sbsc/ga254/GMTED2010_bk/elevation_range_GMTED2010_mxmi_tmp.tif  <<EOF
1
#1 #2 -
EOF

gdaltranslate -co COMPRESS=LZW -co ZLEVEL=9    /home/fas/sbsc/ga254/GMTED2010_bk/elevation_range_GMTED2010_mxmi_tmp.tif  /home/fas/sbsc/ga254/GMTED2010_bk/elevation_range_GMTED2010_mxmi.tif
rm -f /home/fas/sbsc/ga254/GMTED2010_bk/elevation_range_GMTED2010_mxmi_tmp.tif  

# slope cv

oft-calc -ot Float32 $HOME/GMTED2010_bk/slope_mn_GMTED2010_md.tif $HOME/GMTED2010_bk/slope_mn_GMTED2010_md_oft.tif  <<EOF  
1
#1 0.000000001 +
EOF

gdalbuildvrt -overwrite -separate $RAM/stack.vrt  $HOME/GMTED2010_bk/slope_sd_GMTED2010_md.tif   $HOME/GMTED2010_bk/slope_mn_GMTED2010_md_oft.tif
oft-calc -ot UInt32     $RAM/stack.vrt   $HOME/GMTED2010_bk/slope_cv_GMTED2010_mnsd_oft.tif   <<EOF  
1
#1 #2 / 100000 *
EOF
 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9    $HOME/GMTED2010_bk/slope_cv_GMTED2010_mnsd_oft.tif  $HOME/GMTED2010_bk/slope_cv_GMTED2010_mnsd.tif

# slope range 
gdalbuildvrt -overwrite -separate $RAM/stack.vrt  /home/fas/sbsc/ga254/GMTED2010_bk/slope_mx_GMTED2010_md.tif /home/fas/sbsc/ga254/GMTED2010_bk/slope_mi_GMTED2010_md.tif

oft-calc -ot UInt32     $RAM/stack.vrt   /home/fas/sbsc/ga254/GMTED2010_bk/slope_range_GMTED2010_md_tmp.tif   <<EOF
1
#1 #2 -
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   /home/fas/sbsc/ga254/GMTED2010_bk/slope_range_GMTED2010_md_tmp.tif    /home/fas/sbsc/ga254/GMTED2010_bk/slope_range_GMTED2010_md.tif  
rm -f  /home/fas/sbsc/ga254/GMTED2010_bk/slope_range_GMTED2010_md_tmp.tif