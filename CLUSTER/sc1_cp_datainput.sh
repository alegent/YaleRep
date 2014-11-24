
#  cd    /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif
#  scp   giuseppea@litoria.eeb.yale.edu:/mnt/data2/scratch/Clustering_ga_mt/*.tif .

# scp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/aspect/median/eastness_md_GMTED2010_md.tif . 
# scp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/aspect/median/northness_md_GMTED2010_md.tif . 
# scp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/median_of_md/elevation_md_GMTED2010_md.tif . 

# preparation for solar 
#  ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradCA_month??.tif


#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=0:04:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


# data preparateion 

# for  barren.tif cultivated.tif forest.tif grassland.tif shrub.tif urban.tif water.tif  
# no need to make a mask 

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif
export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask 
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal


echo  bio1.tif  bio4.tif  bio12.tif  bio15.tif  | xargs -n 1 -P 4 bash -c $'  
file=$1 
filename=`basename $file .tif` 

gdal_translate  -projwin -180 84 180 -56  -ot  Int16   -co  COMPRESS=LZW -co ZLEVEL=9  $INDIR/$file    $INDIR/${filename}_crop.tif 

pkgetmask -min  -32700  -max 999999  -data 1 -nodata 0  -co  COMPRESS=LZW -co ZLEVEL=9 -i $INDIR/${filename}_crop.tif   -o  $MSKDIR/${filename}_msk.tif 
' _ 


gdalbuildvrt -separate   -te -180  -56  180 84       $MSKDIR/stack_msk.vrt  $MSKDIR/bio1_msk.tif   $MSKDIR/bio4_msk.tif   $MSKDIR/bio12_msk.tif   $MSKDIR/bio15_msk.tif  -overwrite
gdal_translate  -projwin -180 84 180 -56  -ot  Int16   -co  COMPRESS=LZW -co ZLEVEL=9  $MSKDIR/stack_msk.vrt $MSKDIR/stack_msk.tif

oft-calc  -ot Int16    $MSKDIR/stack_msk.tif    $MSKDIR/mask_tmp.tif   >  /dev/null   <<EOF
1
#1 #1 * #2 * #3 * #4 *
EOF

gdal_translate  -projwin -180 84 180 -56  -ot  Byte   -co  COMPRESS=LZW -co ZLEVEL=9  $MSKDIR/mask_tmp.tif  $MSKDIR/mask.tif

rm $MSKDIR/mask_tmp.tif  $MSKDIR/stack_msk.vrt $MSKDIR/stack_msk.tif


echo  barren.tif cultivated.tif forest.tif grassland.tif shrub.tif urban.tif water.tif  cloud_intra.tif cloud_meanannual.tif eastness_md_GMTED2010_md.tif elevation_md_GMTED2010_md.tif northness_md_GMTED2010_md.tif glob_HradCA_mean.tif glob_HradCA_sd.tif   | xargs -n 1 -P 8  bash -c $'  
file=$1 
filename=`basename $file .tif` 

gdal_translate  -projwin -180 84 180 -56  -ot  Int16   -co  COMPRESS=LZW  -co ZLEVEL=9  $INDIR/$file    $INDIR/${filename}_crop.tif 

' _ 



echo   GDD.tif PET_annual_mean.tif PET_seasonality.tif Prec_seasonality.tif | xargs -n 1 -P 8  bash -c $'  
file=$1 
filename=`basename $file .tif` 

gdal_translate  -projwin -180 84 180 -56  -ot  Int16   -co  COMPRESS=LZW  -co ZLEVEL=9  $INDIR/$file    $INDIR/${filename}_crop.tif 

' _ 


gdal_translate  -projwin -180 84 180 -56    -co  COMPRESS=LZW  -co ZLEVEL=9   $INDIR/aridity_index.tif    $INDIR/aridity_index_crop.tif