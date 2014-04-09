# calculate the linke  days based on linear trend between 2 estimation 
# eventualmente integrare nel lista degli if la parte $mont -lt 7 ... vedere sc2_real-sky-horiz-solar_Monthradiation.sh 
# change the data type in the input file because gdal_calc in case of byte  do not support the operation a-b be negative...
#  for file in months_orig/*.tif ; do filename=`basename $file `  ;  gdal_translate -ot Int16  -co COMPRESS=LZW -co ZLEVEL=9  $file months/$filename ; done 
# seq 0 13   | xargs -n 1 -P 10 bash /mnt/data2/scratch/GMTED2010/scripts/sc1b_dayly_cloud.sh
# for file in `seq 1 365` ;do  ls linke$file.tif  ; done  # for control check 


# cp 
# for day in 1 32 61 91 122 153 183 214 245 275 306 336 ; do qsub -v day=$day  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AEROSOL/sc3_dayly_optical.sh  ; done 

# bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AEROSOL/sc3_dayly_optical.sh 32

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

# export day=$day
export day=$1

export INDIR=/lustre0/scratch/ga254/dem_bj/AEROSOL/tif_mean
export OUTDIR=/lustre0/scratch/ga254/dem_bj/AEROSOL/day_estimation 


if [ $day -eq 1  ] ; then  export dayend=32  ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata  -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi  
if [ $day -eq 32 ] ; then  export dayend=61  ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata  -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 61 ] ; then  export dayend=91  ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata  -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 91 ] ; then  export dayend=122 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata  -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 122 ] ; then  export dayend=153 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 153 ] ; then  export dayend=183 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 183 ] ; then  export dayend=214 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 214 ] ; then  export dayend=245 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 245 ] ; then  export dayend=275 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 275 ] ; then  export dayend=306 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 306 ] ; then  export dayend=336 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   
if [ $day -eq 336 ] ; then  export dayend=365 ; gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -a_nodata -9999 -ot Float32  $INDIR/day${day}_mean.tif  $OUTDIR/day${day}_mean.tif ; fi   


export nseq=$(expr $dayend - $day - 1 )
export fact=$(awk -v nseq=$nseq  'BEGIN { print 1/(nseq + 1) }' )

echo  start to process $1 

for n in `seq 1 $nseq` ; do 
    
    echo processing day $(expr $day + $n)
    rm -f $OUTDIR/tmpday$(expr $day + $n)_mean.tif
    gdal_calc.py --type=Float32   --NoDataValue=-9999   -A $OUTDIR/day${day}_mean.tif  -B $OUTDIR/day${dayend}_mean.tif --calc="( A + ((B-A) * $fact * $n ) )"  --outfile=$OUTDIR/tmpday$(expr $day + $n)_mean.tif --co=COMPRESS=LZW --co=ZLEVEL=9   --type Float32 --overwrite 
    gdal_translate -a_nodata -9999  -co COMPRESS=LZW -co ZLEVEL=9    -ot Float32  $OUTDIR/tmpday$(expr $day + $n)_mean.tif  $OUTDIR/day$(expr $day + $n)_mean.tif
    rm -f $OUTDIR/tmpday$(expr $day + $n)_mean.tif
done 

exit 

# quality controll # funziona tutto 

for day in `seq 1 365` ; do  echo $day `gdallocationinfo  -valonly day${day}_mean.tif 200 100   ` ; done 


