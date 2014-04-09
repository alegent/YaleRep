# for day  in 00 03 06 09 12 15 18 21 24 27 30 33 ; do qsub -v day=$day /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AEROSOL/sc2_mean_optical_depth.sh ; done 

# bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AEROSOL/sc2_mean_optical_depth.sh 00

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=1gb
#PBS -l walltime=0:10:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Libraries/OSGEO/1.10.0

export day=$day

export INDIR=/lustre0/scratch/ga254/dem_bj/AEROSOL/tif
export OUTDIR=/lustre0/scratch/ga254/dem_bj/AEROSOL


ls    $INDIR/M?D08_M3.A20??${day}?.051.*.tif | xargs -n 1 -P 10 bash -c $' 
file=$1
export filename=`basename $file .tif`
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -b 1 $file   $OUTDIR/tif_stack/${filename}_b1.tif  
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -b 2 $file   $OUTDIR/tif_stack/${filename}_b2.tif  
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -b 3 $file   $OUTDIR/tif_stack/${filename}_b3.tif  
' _ 

echo start calculate  the mean and the median  for  $OUTDIR/tif_mean/day${dayr}_mean.tif $OUTDIR/tif_mean/day${dayr}_median.tif

if [ $day -eq 00 ] ; then export dayr=1 ; fi
if [ $day -eq 03 ] ; then export dayr=32 ; fi
if [ $day -eq 06 ] ; then export dayr=61 ; fi
if [ $day -eq 09 ] ; then export dayr=91 ; fi
if [ $day -eq 12 ] ; then export dayr=122 ; fi
if [ $day -eq 15 ] ; then export dayr=153 ; fi
if [ $day -eq 18 ] ; then export dayr=183 ; fi
if [ $day -eq 21 ] ; then export dayr=214 ; fi
if [ $day -eq 24 ] ; then export dayr=245 ; fi
if [ $day -eq 27 ] ; then export dayr=275 ; fi
if [ $day -eq 30 ] ; then export dayr=306 ; fi
if [ $day -eq 33 ] ; then export dayr=336 ; fi


echo mean median |  xargs -n 1 -P 2 bash -c $'
par=$1
pkmosaic -min -1 -cr $par  $(for tif  in $OUTDIR/tif_stack/M?D08_M3.A20??${day}?.051.*.tif ; do echo -i $tif ; done  ) -o $OUTDIR/tif_$par/day${dayr}_$par.tif  

' _ 
rm -f  $OUTDIR/tif_stack/M?D08_M3.A20??${day}?.051.*_b[1-3].tif


# cp  tif_mean/day001_mean.tif   tif_mean/day365_mean.tif # copiato a mano per il day_estimation

