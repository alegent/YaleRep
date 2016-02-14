# qsub /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc9_renameTif.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final

echo 1 5 10 50 100   | xargs -n 1 -P 8 bash -c $'

km=$1

echo "altitude  ###############################################################################"

for dir in max_of_mx mean_of_mn median_of_md min_of_mi ; do  

dir2=$(echo ${dir: -2})

if [ $dir2 = mi ] ; then var="Minimum" ; fi   
if [ $dir2 = mx ] ; then var="Maximum" ; fi   
if [ $dir2 = mean ] ; then var="Mean" ; fi   
if [ $dir2 = median ] ; then var="Median" ; fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/altitude/$dir/altitude_${dir}_km${km}.tif     $OUTDIR/$dir/elevation_${dir2}_GMTED2010_${dir2}_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds ${var} elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds ${var} elevation derived from GMTED2010 ${var} Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/$dir/elevation_${dir2}_GMTED2010_${dir2}_km${km}.tif

done 

echo "altitude stdev   ###############################################################################"

for dir in stdev_of_mn stdev_of_md  ; do  

dir2=$(echo ${dir: -2})

if [ $dir2 = mean ] ; then var="Mean" ; fi   
if [ $dir2 = median ] ; then var="Median" ; fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/altitude/$dir/altitude_${dir}_km${km}.tif     $OUTDIR/$dir/elevation_sd_GMTED2010_${dir2}_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation elevation derived from GMTED2010 ${var} Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/$dir/elevation_sd_GMTED2010_${dir2}_km${km}.tif

done 


echo "altitude stdev pulled #############################################################################"

for dir in stdev_pulled  ; do  

var=$(expr $km \* $km \* 16 )   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/altitude/$dir/altitude_p${var}sd_km${km}.tif  $OUTDIR/$dir/elevation_psd_GMTED2010_sd_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Pulled Standard Deviation elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Pulled Standard Deviation elevation derived from GMTED2010 Standard Deviation Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/$dir/elevation_psd_GMTED2010_sd_km${km}.tif

done


 
echo "altitude stdev of the stdev  #############################################################################"

for dir in stdev_pulled  ; do  

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/altitude/$dir/altitude_sd_km${km}.tif  $OUTDIR/$dir/elevation_sd_GMTED2010_sd_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation elevation derived from GMTED2010 Standard Deviation Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/$dir/elevation_sd_GMTED2010_sd_km${km}.tif

done 



echo "aspect  ###################################################"

for dir1 in max mean  median min stdev ; do

if [ $dir1 = min ]     ; then var="Minimum" ;  var1="mi" ; fi   
if [ $dir1 = max ]     ; then var="Maximum" ;  var1="mx" ; fi   
if [ $dir1 = mean ]   ; then var="Mean"    ;  var1="mn" ; fi   
if [ $dir1 = median ] ; then var="Median"  ;  var1="md" ;  fi   
if [ $dir1 = stdev ] ;  then var="Standard Deviation"  ;  var1="sd" ;  fi   

for dir2 in cos sin Ew Nw ; do

if [ $dir2 = cos ] ; then var2="aspect-cosine" ; fi   
if [ $dir2 = sin ] ; then var2="aspect-sine" ; fi   
if [ $dir2 = Ew  ] ; then var2="eastness" ; fi   
if [ $dir2 = Nw  ] ; then var2="northness" ; fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/aspect/$dir1/aspect_${dir1}_${dir2}_km${km}.tif   $OUTDIR/aspect/${var2}_${var1}_GMTED2010_md_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds ${var} ${var2}" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds ${var} ${var2} derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/aspect/${var2}_${var1}_GMTED2010_md_km${km}.tif

done 
done 

echo "topoindex  ###############################################################################"

for dir1 in tpi tri vrm roughness slope  ; do

for dir2 in max mean  median min stdev ; do

if [ $dir2 = min ]     ; then var="Minimum" ;  var1="mi" ; fi   
if [ $dir2 = max ]     ; then var="Maximum" ;  var1="mx" ; fi   
if [ $dir2 = mean ]   ; then var="Mean"     ;  var1="mn" ; fi   
if [ $dir2 = median ] ; then var="Median"   ;  var1="md" ;  fi   
if [ $dir2 = stdev ] ;  then var="Standard Deviation"  ;  var1="sd" ;  fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/$dir1/$dir2/${dir1}_${dir2}_km${km}.tif   $OUTDIR/$dir1/${dir1}_${var1}_GMTED2010_md_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds ${var} ${dir1}" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds ${var} ${dir1} derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/$dir1/${dir1}_${var1}_GMTED2010_md_km${km}.tif

done 
done 

echo "curvature  ###############################################################################"

for dir1 in dx dxx dy dyy pcurv tcurv  ; do

if [ $dir1 = dx ]      ; then des="first order partial derivative (E-W slope)" ;  fi   
if [ $dir1 = dxx ]     ; then des="second order partial derivative (E-W slope)" ;  fi   
if [ $dir1 = dy ]      ; then des="first order partial derivative (N-S slope)" ;  fi   
if [ $dir1 = dyy ]     ; then des="second order partial derivative (N-S slope)" ;  fi   
if [ $dir1 = pcurv ]   ;  then des="profile curvature" ;  fi   
if [ $dir1 = tcurv ]   ;  then des="tangential curvature" ;  fi   

for dir2 in max mean  median min stdev ; do

if [ $dir2 = min ]     ; then var="Minimum" ;  var1="mi" ; fi   
if [ $dir2 = max ]     ; then var="Maximum" ;  var1="mx" ; fi   
if [ $dir2 = mean ]   ; then var="Mean"     ;  var1="mn" ; fi   
if [ $dir2 = median ] ; then var="Median"   ;  var1="md" ;  fi   
if [ $dir2 = stdev ] ;  then var="Standard Deviation"  ;  var1="sd" ;  fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/geomorphon/tiles/$dir1/$dir2/${dir1}_${dir2}_km${km}.tif   $OUTDIR/$dir1/${dir1}_${var1}_GMTED2010_md_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds ${var} ${dir1}" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds ${var} ${des} derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
-a_nodata -32768 \
 $OUTDIR/$dir1/${dir1}_${var1}_GMTED2010_md_km${km}.tif

done 
done 

echo "morphon  ###############################################################################"

for dir2 in count majority  shannon asm ent ; do

if [ $dir2 = count ]    ; then var="count"    ;   fi   
if [ $dir2 = majority ] ; then var="majority" ;   fi   
if [ $dir2 = shannon  ] ; then var="shannon"  ;   fi   
if [ $dir2 = asm  ]     ; then var="uni"      ;   fi   
if [ $dir2 = ent  ]     ; then var="ent"      ;   fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/geomorphon/$dir2/geomorphon_${dir2}_km${km}.tif   $OUTDIR/$var/geomorphic_${var}_GMTED2010_md_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Geomorphic ${var} " \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Geomorphic class ${var} derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/$var/geomorphic_${var}_GMTED2010_md_km${km}.tif

done 

echo "percent  ###############################################################################"

for class in  1 2 3 4 5 6 7 8 9 10  ; do

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/geomorphon/percent/geomorphon_class${class}_km${km}.tif   $OUTDIR/percent/geomorphic_class${class}_GMTED2010_md_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Geomorphic class ${class} " \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Geomorphic class ${class} percent derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
-a_nodata -32768 \
$OUTDIR/percent/geomorphic_class${class}_GMTED2010_md_km${km}.tif

done 

echo "cv   ###############################################################################"

for dir  in  altitude slope  ; do
for dir2 in cv range ; do

if [ $dir2 = cv ]     ; then var="mnsd" ;   fi   
if [ $dir2 = range ]  ; then var="mxmi" ;   fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/derived_var/${dir}_${dir2}_${var}_km${km}.tif  $OUTDIR/derived_var/${dir}_${dir2}_GMTED2010_${var}_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds ${dir} ${dir2}  " \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds  ${dir} ${dir2} derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
-a_nodata -32768 \
 $OUTDIR/derived_var/${dir}_${dir2}_GMTED2010_${var}_km${km}.tif

done 
done 

for dir  in  altitude ; do
for dir2 in cv ; do

if [ $dir2 = cv ]     ; then var="mnpsd" ;   fi   

gdal_translate   -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR/derived_var/${dir}_${dir2}_${var}_km${km}.tif  $OUTDIR/derived_var/${dir}_${dir2}_GMTED2010_${var}_km${km}.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2016" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds ${dir} ${dir2}  " \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds  ${dir} ${dir2} derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 2.0.1 & pktools 2.6.4 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
-a_nodata -32768 \
 $OUTDIR/derived_var/${dir}_${dir2}_GMTED2010_${var}_km${km}.tif

done 
done

' _

exit 



