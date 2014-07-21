# mosaic the tile and create a stak layer 
# needs to be impruved with the data type; now keep as floting. 
# reflect in caso di slope=0 reflectance 0 quindi non calcolata 
# for DIR in  beam   ; do bash  /home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_r_sun_om/sc2_merge_Monthradiation_bj.sh   $DIR ; done 

# for DIR in  beam  diff  glob refl   ; do  qsub -v DIR=$DIR /home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_r_sun_om/sc2_merge_Monthradiation_bj.sh  ; done


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=2:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout  
#PBS -e /scratch/fas/sbsc/ga254/stderr



export DIR=${DIR}
export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_Hrad
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_Hrad_usa


for INPUT in T Al ACA CA C A ; do  

export INPUT=$INPUT

echo  01 02 03 04 05 06 07 08 09 10 11 12 | xargs -n 1  -P  12 bash -c $' 
month=$1

rm -f $OUTDIR/${DIR}_Hrad${INPUT}_month${month}.vrt 

gdalbuildvrt    $OUTDIR/${DIR}_Hrad${INPUT}_month${month}.vrt  $INDIR/${DIR}_Hrad${INPUT}_month${month}_?_?.tif   -overwrite 
gdal_translate -projwin   -172 75  -66  23.5    -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_Hrad${INPUT}_month${month}.vrt  $OUTDIR/${DIR}_Hrad${INPUT}_month${month}.tif


' _ 


rm -f $OUTDIR/${DIR}_Hrad${INPUT}_months.tif 
gdalbuildvrt   -separate  $OUTDIR/${DIR}_Hrad${INPUT}_months.vrt   $OUTDIR/${DIR}_Hrad${INPUT}_month0[1-9].tif  $OUTDIR/${DIR}_Hrad${INPUT}_month1[0-2].tif   -overwrite  
gdal_translate -projwin   -172 75  -66  23.5   -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_Hrad${INPUT}_months.vrt  $OUTDIR/${DIR}_Hrad${INPUT}_months.tif 

done 


export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_rad
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_rad_usa


for INPUT in  ACA ; do

export INPUT=$INPUT

echo  01 02 03 04 05 06 07 08 09 10 11 12 | xargs -n 1  -P  12 bash -c $'                                                                                                             
month=$1                                                                                                                                                                                                                                                                                                                                                                  
rm -f $OUTDIR/${DIR}_rad${INPUT}_month${month}.vrt                                                                                                                                   
                                                                                                                                                                                     
gdalbuildvrt    $OUTDIR/${DIR}_rad${INPUT}_month${month}.vrt  $INDIR/${DIR}_rad${INPUT}_month${month}_?_?.tif   -overwrite                                                          
gdal_translate -projwin   -172 75  -66  23.5    -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_rad${INPUT}_month${month}.vrt  $OUTDIR/${DIR}_rad${INPUT}_month${month}.\
tif
                                                                                                                                                                                     
' _


rm -f $OUTDIR/${DIR}_rad${INPUT}_months.tif
gdalbuildvrt   -separate  $OUTDIR/${DIR}_rad${INPUT}_months.vrt   $OUTDIR/${DIR}_rad${INPUT}_month0[1-9].tif  $OUTDIR/${DIR}_rad${INPUT}_month1[0-2].tif   -overwrite
gdal_translate -projwin   -172 75  -66  23.5   -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/${DIR}_rad${INPUT}_months.vrt  $OUTDIR/${DIR}_rad${INPUT}_months.tif

done


exit 



