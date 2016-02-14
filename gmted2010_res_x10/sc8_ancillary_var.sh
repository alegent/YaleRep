# ancilary layers derived by by final variables 
# bash /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc8_ancillary_var.sh
# qsub /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc8_ancillary_var.sh

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
export INDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/stdev_pulled
export RAM=/dev/shm
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/derived_var

rm -f /dev/shm/*

echo 1 5 10 50 100   | xargs -n 1 -P 8 bash -c $'
km=$1

export res=$( expr $km \\* 4)
export km=$km
export P=$( expr $res \\* $res)  # dividend for the pulled SD

echo  "coefficent of variation with the pulled sd ##################################################"

oft-calc -ot Float32  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/mean_of_mn/altitude_mean_of_mn_km$km.tif  $OUTDIR/altitude_cv_mnp${P}sd_oft_km${km}.tif  <<EOF  
1
#1 0.0001 +
EOF

gdalbuildvrt -overwrite -separate $RAM/stack_km${km}.vrt $INDIR_SD/altitude_p${P}sd_km${km}.tif $OUTDIR/altitude_cv_mnp${P}sd_oft_km${km}.tif 
oft-calc -ot Float32   $RAM/stack_km${km}.vrt  $OUTDIR/altitude_cv_mnp${P}sd_oft_tmp_km${km}.tif  <<EOF  
1
#1 #2 /
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/altitude_cv_mnp${P}sd_oft_tmp_km${km}.tif  $OUTDIR/altitude_cv_mnpsd_km${km}.tif
rm  $OUTDIR/altitude_cv_mnp${P}sd_oft_tmp_km${km}.tif  

echo  "coefficent of variation with the mean sd #######################################################"

gdalbuildvrt -overwrite -separate $RAM/stack_km${km}.vrt $INDIR/altitude/stdev_of_mn/altitude_stdev_of_mn_km${km}.tif    $OUTDIR/altitude_cv_mnp${P}sd_oft_km${km}.tif 
oft-calc -ot Float32   $RAM/stack_km${km}.vrt  $OUTDIR/altitude_cv_mnsd_oft_tmp_km${km}.tif  <<EOF  
1
#1 #2 /
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/altitude_cv_mnsd_oft_tmp_km${km}.tif  $OUTDIR/altitude_cv_mnsd_km${km}.tif
rm -f  $OUTDIR/altitude_cv_mnsd_oft_km${km}.tif $OUTDIR/altitude_cv_mnsd_oft_tmp_km${km}.tif $OUTDIR/altitude_cv_mnp${P}sd_oft_km${km}.tif

echo  "altitude range   #####################################"

gdalbuildvrt -overwrite -separate $RAM/stack_km${km}.vrt   $INDIR/altitude/max_of_mx/altitude_max_of_mx_km${km}.tif  $INDIR/altitude/min_of_mi/altitude_min_of_mi_km${km}.tif

oft-calc -ot  Float32    $RAM/stack_km${km}.vrt  $OUTDIR/altitude_range_mxmi_tmp_km${km}.tif  <<EOF
1
#1 #2 -
EOF

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/altitude_range_mxmi_tmp_km${km}.tif   $OUTDIR/altitude_range_mxmi_km${km}.tif 

rm -f  $OUTDIR/altitude_range_mxmi_tmp_km${km}.tif

echo  "slope cv #############################################"

oft-calc -ot Float32 $INDIR/slope/mean/slope_mean_km${km}.tif  $OUTDIR/slope_mean_km${km}_oft.tif  <<EOF  
1
#1 0.0001 +
EOF

gdalbuildvrt -overwrite -separate $RAM/stack_km${km}.vrt   $INDIR/slope/stdev/slope_stdev_km${km}.tif  $OUTDIR/slope_mean_km${km}_oft.tif
oft-calc -ot  Float32  $RAM/stack_km${km}.vrt   $OUTDIR/slope_cv_mnsd_km${km}_oft.tif   <<EOF  
1
#1 #2 /
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/slope_cv_mnsd_km${km}_oft.tif  $OUTDIR/slope_cv_mnsd_km${km}.tif
rm -f $OUTDIR/slope_cv_mnsd_km${km}_oft.tif  $OUTDIR/slope_mean_km${km}_oft.tif  

echo  "slope range  ##############################################"
gdalbuildvrt -overwrite -separate $RAM/stack_km${km}.vrt   $INDIR/slope/max/slope_max_km${km}.tif  $INDIR/slope/min/slope_min_km${km}.tif

oft-calc -ot  Float32   $RAM/stack_km${km}.vrt   $OUTDIR/slope_range_mxmi_km${km}_oft.tif   <<EOF
1
#1 #2 -
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/slope_range_mxmi_km${km}_oft.tif  $OUTDIR/slope_range_mxmi_km${km}.tif
rm -f  $OUTDIR/slope_range_mxmi_km${km}_oft.tif

' _

rm -f /dev/shm/*