
# cd /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif
# wget -i /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/treecover2000.txt


# for file in /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_*.tif ; do  qsub -v file=$file  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc1_aggregation_treecover_lossyear.sh    ; sleep 60 ; done 

# for file in /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_*.tif ; do  bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc1_aggregation_treecover_lossyear.sh  $file  ; done 
# Hansen_GFC2013_lossyear_10N_010E.tif

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=2gb
#PBS -l walltime=2:00:00 
#PBS -l nodes=2:ppn=2
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

time ( 

# file=$1

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Libraries/OSGEO/1.10.0

filename=$(basename $file .tif)
tile=${filename:29:8}
INDIRT=/lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif
INDIRL=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tif
OUTDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tif_1km

geo_string=$(getCorners4Gtranslate  $file)
ulx=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $1 )}')  # round the number to rounded cordinates
uly=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $2 )}')
lrx=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $3 )}')
lry=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $4 )}')


# soutest tile smoler
if [ ${filename:29:3} = '50S' ] ; then  ysize=25200 ; else ysize=36000 ; fi

echo cropping the images 

gdal_translate -srcwin 0 0 36000 $ysize  -a_ullr  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9 $INDIRT/$filename.tif  $INDIRT/tmp_$filename.tif 
gdal_translate -srcwin 0 0 36000 $ysize  -a_ullr  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9 $INDIRL/Hansen_GFC2013_lossyear_$tile.tif  $INDIRL/tmp_Hansen_GFC2013_lossyear_$tile.tif 

echo setting the mask 2001  
pksetmask  --mask  $INDIRL/tmp_Hansen_GFC2013_lossyear_$tile.tif    -msknodata 1 -nodata 0    -i   $INDIRT/tmp_$filename.tif   -o $INDIRL/${filename}_loss2001.tif 
echo aggregation 2001
pkfilter    -co COMPRESS=LZW -ot  Float32    -dx 30 -dy 30   -f mean  -d 30  -i  $INDIRL/${filename}_loss2001.tif   -o  $OUTDIR/1km_tmp_${filename}_loss2001.tif
gdal_calc.py  -A $OUTDIR/1km_tmp_${filename}_loss2001.tif    --calc="(A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9    --overwrite  --outfile  $OUTDIR/1km_tmp2_${filename}_loss2001.tif 
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9 $OUTDIR/1km_tmp2_${filename}_loss2001.tif   $OUTDIR/1km_mn_${filename}_loss2001.tif  

rm -f  $INDIRT/tmp_$filename.tif   $OUTDIR/1km_tmp2_${filename}_loss2001.tif  

echo start xargs computation 



for YEAR in $(seq 2002 2012) ; do   

YEAR_PREC=$( expr $YEAR - 1 )
YEAR_CLASS=$( expr $YEAR - 2000 )

echo setting the mask for the $YEAR

pksetmask  --mask  $INDIRL/tmp_Hansen_GFC2013_lossyear_$tile.tif    -msknodata $YEAR_CLASS  -nodata 0    -i  $INDIRL/${filename}_loss$YEAR_PREC.tif     -o $INDIRL/${filename}_loss$YEAR.tif 

echo aggregation $YEAR
pkfilter    -co COMPRESS=LZW -ot  Float32    -dx 30 -dy 30   -f mean  -d 30  -i  $INDIRL/${filename}_loss$YEAR.tif   -o  $OUTDIR/1km_tmp_${filename}_loss$YEAR.tif
gdal_calc.py  -A $OUTDIR/1km_tmp_${filename}_loss$YEAR.tif    --calc="(A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9    --overwrite  --outfile  $OUTDIR/1km_tmp2_${filename}_loss$YEAR.tif
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9 $OUTDIR/1km_tmp2_${filename}_loss$YEAR.tif   $OUTDIR/1km_mn_${filename}_loss$YEAR.tif
rm -f $OUTDIR/1km_tmp2_${filename}_loss$YEAR.tif   $OUTDIR/1km_tmp1_${filename}_loss$YEAR.tif   

done

rm -f  $INDIRL/tmp_Hansen_GFC2013_lossyear_$tile.tif  $OUTDIR/1km_tmp2_${filename}_loss2001.tif   $OUTDIR/1km_tmp_${filename}_loss2001.tif  

)



checkjob -v $PBS_JOBID 
