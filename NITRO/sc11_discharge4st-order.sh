#!/bin/bash
#SBATCH -p scavenge
#SBATCH -J sc10_pred_analysis.sh 
#SBATCH -n 1 -c 3  -N 1  
#SBATCH -t 24:00:00  
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc11_discharge4st-order.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc11_discharge4st-order.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NITRO/sc11_discharge4st-order.sh

export WIDTH=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/width_pred
export ORDER=/project/fas/sbsc/sd566/global_wsheds/global_results_merged/netCDF/stream_order_lakes0.tif
export FLO=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/FLO1K

# w_pete1  <- (0.510 * x ) + 1.86              =   
# w_pete2  <- (0.423 * x ) + 2.56              =
# a-coefficient = 8.5 and b-exponent = 0.47    =
# w_georg  <- (0.47  * x ) + log(8.5)          =


# exp(log (x)^0. + 2.)
# due that 
# exp ( 2.4 * log(4) + 2.3 )  =   (4^2.4) *  exp(2.3 ) 

# w_pete1  <- (0.510 * log (q)  ) + 1.86    to obtain w =  exp ((0.510 * log (q)  ) + 1.86)


gdal_calc.py --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND --NoDataValue=-9999 --type='Float32' -A $FLO/FLO1K.ts.1960.2015.qav_mean_fill_msk.tif \
--calc="(exp( log((A.astype(float) + 0.00001 ) * 0.510 ) + 1.86))"   --outfile=$WIDTH/width_EQpete1.tif  --overwrite

gdal_calc.py --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND --NoDataValue=-9999 --type='Float32' -A $FLO/FLO1K.ts.1960.2015.qav_mean_fill_msk.tif \
--calc="(exp( log((A.astype(float) + 0.00001 ) * 0.423 ) + 2.56))"  --outfile=$WIDTH/width_EQpete2.tif  --overwrite

gdal_calc.py --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND --NoDataValue=-9999 --type='Float32' -A $FLO/FLO1K.ts.1960.2015.qav_mean_fill_msk.tif \
--calc="(exp( log((A.astype(float) + 0.00001 ) * 0.470 ) + 2.14))"  --outfile=$WIDTH/width_EQgeor1.tif  --overwrite

for EQ in pete1 pete2 geor1 ; do 
export EQ
seq 1 9 | xargs  -n 1 -P 3 bash -c $'
ORD=$1

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $ORDER  -msknodata $ORD  -nodata -1 -p "!"  -i $WIDTH/width_EQ${EQ}.tif   -o  $WIDTH/width_EQ${EQ}_order${1}.tif 
gdalinfo -stats  $WIDTH/width_EQ${EQ}_order${1}.tif   | grep MEAN | awk -F "=" \'{ print $2  }\' > $WIDTH/width_EQ${EQ}_mean_order${1}.txt
rm -f  $WIDTH/width_EQ${EQ}_order${1}.tif.aux.xml 
rm -f  $WIDTH/width_EQ${EQ}_order${1}.tif

' _ 

cat $WIDTH/width_EQ${EQ}_mean_order?.txt  > $WIDTH/width_EQ${EQ}_mean.txt
rm -f $WIDTH/width_EQ${EQ}_mean_order?.txt
done 



echo "ORD EQpete1 EQpete2 EQgeor1" > $WIDTH/width_all_mean.txt 
paste <(seq 1 9 ) $WIDTH/width_EQpete1_mean.txt $WIDTH/width_EQpete2_mean.txt  $WIDTH/width_EQgeor1_mean.txt >> $WIDTH/width_all_mean.txt



