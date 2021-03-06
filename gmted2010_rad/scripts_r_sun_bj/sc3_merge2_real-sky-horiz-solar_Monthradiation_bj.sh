# mosaic the tile and create a stak layer 
# needs to be impruved with the data type; now keep as floting. 
# reflect in caso di slope=0 reflectance 0 quindi non calcolata 
# for DIR in  beam   ; do bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_rad/scripts_r_sun_bj/sc3_merge2_real-sky-horiz-solar_Monthradiation_bj.sh  $DIR ; done 

# for DIR in  beam  diff  glob refl   ; do  qsub -v DIR=$DIR /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_rad/scripts_r_sun_bj/sc3_merge2_real-sky-horiz-solar_Monthradiation_bj.sh  ; done

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=16gb
#PBS -l walltime=0:10:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2   # exclued to load the pktools from the $HOME/bin
module load Libraries/OSGEO/1.10.0
module load Libraries/GSL
module load Libraries/ARMADILLO


export DIR=${DIR}
export INDIR=/lustre0/scratch/ga254/dem_bj/SOLAR/radiation/${DIR}_rad
export OUTDIR=/lustre0/scratch/ga254/dem_bj/SOLAR/radiation/${DIR}_rad


seq 1 12 | xargs -n 1  -P  12 bash -c $' 
month=$1

rm -f $OUTDIR/${DIR}_HradCA_month${month}.vrt 

gdalbuildvrt    $OUTDIR/${DIR}_HradCA_month${month}.vrt  $INDIR/${DIR}_HradCA_month${month}_?_?.tif   -overwrite 
gdal_translate -projwin   -172 75  -66  23.5    -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_HradCA_month${month}.vrt  $OUTDIR/${DIR}_HradCA_month${month}.tif

rm -f $OUTDIR/${DIR}_HradCA2_month${month}.vrt 
gdalbuildvrt   $OUTDIR/${DIR}_HradCA2_month${month}.vrt  $INDIR/${DIR}_HradCA2_month${month}_?_?.tif   -overwrite 
gdal_translate -projwin   -172 75  -66  23.5    -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_HradCA2_month${month}.vrt  $OUTDIR/${DIR}_HradCA2_month${month}.tif

' _ 



rm -f $OUTDIR/${DIR}_HradCA_months.tif 
gdalbuildvrt   -separate  $OUTDIR/${DIR}_HradCA_months.vrt   $OUTDIR/${DIR}_HradCA_month[1-9].tif  $OUTDIR/${DIR}_HradCA_month1[0-2].tif   -overwrite  
gdal_translate -projwin   -172 75  -66  23.5   -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_HradCA_months.vrt  $OUTDIR/${DIR}_HradCA_months.tif 


rm -f $OUTDIR/${DIR}_HradCA_months.tif 
gdalbuildvrt   -separate  $OUTDIR/${DIR}_HradCA2_months.vrt   $OUTDIR/${DIR}_HradCA2_month[1-9].tif  $OUTDIR/${DIR}_HradCA2_month1[0-2].tif   -overwrite  
gdal_translate  -projwin   -172 75  -66  23.5   -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_HradCA2_months.vrt  $OUTDIR/${DIR}_HradCA2_months.tif 

exit 

-ul_lr ulx uly lrx lry gdal -172 75  -66  23.5 

-te xmin ymin xmax ymax   vrt 

