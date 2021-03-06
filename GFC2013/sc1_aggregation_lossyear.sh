
# downlaod data from http://earthenginepartners.appspot.com/science-2013-global-forest/download.html
# cd /lustre0/scratch/ga254/dem_bj/GFC2013/datamask/tif
# wget -i ../datamask.txt
# create vrt 
# gdalbuildvrt  datamask.vrt    *.tif
# create new tiles becouse the original one have 30001 pixel and can not be done an agregate opereation 30.
# x 1296036 pixel west to east . togliendo 1 pixel per ogni tile 1296000 che e' divisibile per 30 
# y 
# 10 tiles east  to west      ; each tile 129600 30m che 1 km diventano 4320 ; partenza da -180 a + 180 
# 10 tiles east  nord to south; each tile  46800 30m che 1 km diventano 1560 ; partenza + 80 - 50 
# pixel size 0.000277777777778  30m 
# pixel size 0.002083333333333  1km 

# all fine si e' deciso di cancellare un pixel alla fine di ogni tile...forse da cambiare con un gdalwarp , warp non va bene, il pixel finale e' in overlap with il seguente tile



# for file in /lustre0/scratch/ga254/dem_bj/GFC2013/datamask/tif/Hansen_GFC2013_lossyear_*.tif ; do  bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc1_aggregation_lossyear.sh  ; done 


# for file in /lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tif/Hansen_GFC2013_lossyear_*.tif ; do  qsub -v file=$file /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/GFC2013/sc1_aggregation_lossyear.sh  ; done 


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=1gb
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

# file=$1

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Libraries/OSGEO/1.10.0

export filename=$(basename $file .tif)

export INDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tif
export OUTDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/lossyear/tif_1km

geo_string=$(getCorners4Gtranslate  $file)
ulx=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $1 )}')  # round the number to rounded cordinates
uly=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $2 )}')
lrx=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $3 )}')
lry=$(echo $geo_string  | awk '{ print  sprintf("%.0f", $4 )}')


# soutest tile smaler
if [ ${filename:24:3} = '50S' ] ; then  ysize=25200 ; else ysize=36000 ; fi

gdal_translate -srcwin 0 0 36000 $ysize  -a_ullr  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9 $INDIR/$filename.tif  $OUTDIR/tmp_$filename.tif 

seq 1 12 | xargs -n 1 -P 12 bash -c $' 
    class=$1
    pkfilter    -co COMPRESS=LZW -ot  Float32   -class $class  -dx 30 -dy 30   -f density -d 30  -i  $OUTDIR/tmp_$filename.tif  -o  /tmp/1km_y${class}_tmp_$filename.tif 
    gdal_calc.py  -A /tmp/1km_y${class}_tmp_$filename.tif     --calc="(A * 100)" --co=COMPRESS=LZW  --co=ZLEVEL=9    --overwrite  --outfile  /tmp/1km_y${class}_tmp2_$filename.tif
    rm -f /tmp/1km_y${class}_tmp_$filename.tif 
    gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9 /tmp/1km_y${class}_tmp2_$filename.tif   $OUTDIR/1km_y${class}_$filename.tif  
    rm -f /tmp/1km_y${class}_tmp2_$filename.tif
' _

rm -f $OUTDIR/tmp_$filename.tif


checkjob -v $PBS_JOBID 
