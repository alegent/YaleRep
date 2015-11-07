# ancilary layers derived by by final variables 


#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=3:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
INDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/stdev_pulled
RAM=/dev/shm
OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/derived_var

oft-calc -ot Float32   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/mean_of_mn/elevation_mn_GMTED2010_mn.tif  $OUTDIR/elevation_cvtmp_GMTED2010_mnsd_oft.tif   <<EOF  
1
#1 0.000001 +
EOF

gdalbuildvrt -overwrite -separate $RAM/stack.vrt $INDIR_SD/elevation_p16sd_GMTED2010_sd.tif  $OUTDIR/elevation_cvtmp_GMTED2010_mnsd_oft.tif 
oft-calc -ot Float32   $RAM/stack.vrt  $OUTDIR/elevation_cv_GMTED2010_mnsd_oft.tif   <<EOF  
1
#1 #2 /
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/elevation_cv_GMTED2010_mnsd_oft.tif  $OUTDIR/elevation_cv16_GMTED2010_mnsd.tif
rm  $OUTDIR/elevation_cv_GMTED2010_mnsd_oft.tif

# elevation range 


gdalbuildvrt -overwrite -separate $RAM/stack.vrt  $INDIR/altitude/max_of_mx/elevation_mx_GMTED2010_mx.tif $INDIR/altitude/min_of_mi/elevation_mi_GMTED2010_mi.tif 

oft-calc -ot  Float32    $RAM/stack.vrt  $OUTDIR/elevation_range_GMTED2010_mxmi_tmp.tif  <<EOF
1
#1 #2 -
EOF

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9    $OUTDIR/elevation_range_GMTED2010_mxmi_tmp.tif  $OUTDIR/elevation_range_GMTED2010_mxmi.tif

rm -f $OUTDIR/elevation_range_GMTED2010_mxmi_tmp.tif

# slope cv

oft-calc -ot Float32 $INDIR/slope/max/slope_mn_GMTED2010_md.tif $OUTDIR/slope_mn_GMTED2010_md_oft.tif  <<EOF  
1
#1 0.000000001 +
EOF

gdalbuildvrt -overwrite -separate $RAM/stack.vrt  $INDIR/slope/max/slope_sd_GMTED2010_md.tif   $OUTDIR/slope_mn_GMTED2010_md_oft.tif
oft-calc -ot  Float32  $RAM/stack.vrt   $OUTDIR/slope_cv_GMTED2010_mnsd_oft.tif   <<EOF  
1
#1 #2 /
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/slope_cv_GMTED2010_mnsd_oft.tif  $OUTDIR/slope_cv_GMTED2010_mnsd.tif  
rm -f $OUTDIR/slope_mn_GMTED2010_md_oft.tif
# slope range 
gdalbuildvrt -overwrite -separate $RAM/stack.vrt  $INDIR/slope/max/slope_mx_GMTED2010_md.tif $INDIR/slope/min/slope_mi_GMTED2010_md.tif

oft-calc -ot  Float32    $RAM/stack.vrt   $OUTDIR/slope_range_GMTED2010_md_tmp.tif   <<EOF
1
#1 #2 -
EOF

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/slope_range_GMTED2010_md_tmp.tif  $OUTDIR/slope_range_GMTED2010_md.tif
rm -f  $OUTDIR/slope_range_GMTED2010_md_tmp.tif

