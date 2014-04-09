#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=1gb
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Libraries/OSGEO/1.10.0


TIFIN=/lustre0/scratch/ga254/dem_bj/GSHHG/GSHHS_tif_1km


gdalbuildvrt  -overwrite -tr 0.0083333333333 0.0083333333333     $TIFIN/land_perc.vrt   $TIFIN/h??v??_1km.tif
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -ot Byte  $TIFIN/land_perc.vrt  $TIFIN/land_frequency_GSHHS_f_L1.tif

rm /lustre0/scratch/ga254/dem_bj/GSHHG/GSHHS_shp_clip/*  $TIFIN/land_perc.vrt $TIFIN/h??v??_1km.tif /lustre0/scratch/ga254/dem_bj/GSHHG/GSHHS_tif/*.tif

