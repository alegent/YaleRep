#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:08:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif
export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask 
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal

# ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif/{barren.tif,cultivated.tif,forest.tif,grassland.tif,shrub.tif,urban.tif,water.tif}    | xargs -n 1 -P 8 bash -c $'    
# GDD_crop.tif,PET_annual_mean_crop.tif,PET_seasonality_crop.tif,Prec_seasonality_crop.tif

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif/{GDD_crop.tif,PET_annual_mean_crop.tif,PET_seasonality_crop.tif,Prec_seasonality_crop.tif} | xargs -n 1 -P 8 bash -c $'    

file=$1 
filename=`basename $file .tif` 

pksetmask -ot Int16    -msknodata 0 -nodata  -32768   -m   $MSKDIR/mask.tif    -co  COMPRESS=LZW   -co ZLEVEL=9    -i  $INDIR/$filename.tif  -o   $NORDIR/${filename}_msk.tif 
gdal_edit.py -a_nodata  -32768 $NORDIR/${filename}_msk.tif
 
pkinfo    -stats  -i  $NORDIR/${filename}_msk.tif      >     $NORDIR/${filename}_msk.stat.txt  
mean=$(  awk \'{  print $6 }\'     $NORDIR/${filename}_msk.stat.txt    )
stdev=$( awk \'{  print $8 }\'     $NORDIR/${filename}_msk.stat.txt    )

echo start the normalization 

oft-calc  -ot Int16 -um $MSKDIR/mask.tif     $NORDIR/${filename}_msk.tif   $NORDIR/${filename}_norm_tmp.tif  >  /dev/null   <<EOF
1
#1 $mean - $stdev / 1000 *
EOF


pksetmask  -ot   Int16  -msknodata 0 -nodata -32768      -m   $MSKDIR/mask.tif  -co PREDICTOR=2  -co  COMPRESS=LZW   -co ZLEVEL=9   -i  $NORDIR/${filename}_norm_tmp.tif -o   $NORDIR/${filename}_norm.tif
gdal_edit.py -a_nodata -32769     $NORDIR/${filename}_norm.tif

rm   $NORDIR/${filename}_msk.stat.txt   $NORDIR/${filename}_norm_tmp.tif  $NORDIR/${filename}_msk.tif

' _ 

# for file in *_norm.tif  ; do gdal_edit.py -a_srs EPSG:4326  $file ; done
# gdalbuildvrt -separate   -te -180  -56  180 84     -overwrite stack.vrt      *_norm.tif 

# gdal_translate   -projwin -180 84 180 -56  -ot  Int16 -co  BIGTIFF=YES -co  COMPRESS=LZW -co ZLEVEL=9   stack.vrt      stack.tif 



