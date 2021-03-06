# calculate the linke  days based on linear trend between 2 estimation 

# eventualmente integrare nel lista degli if la parte $mont -lt 7 ... vedere sc2_real-sky-horiz-solar_Monthradiation.sh 

# seq 0 13   | xargs -n 1 -P 14 bash  /home/fas/sbsc/ga254/scripts/CLOUD/sc1b_daily_linear_interp_cloud.sh 

# for month in $( seq 0 13)  ; do  qsub -v month=$month /home/fas/sbsc/ga254/scripts/CLOUD/sc1b_daily_linear_interp_cloud.sh    ; done 
# bash  /home/fas/sbsc/ga254/scripts/CLOUD/sc1b_daily_linear_interp_cloud.sh  1

# un tile ha impiegato 6 ore

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=3:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR_ORIG=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/month
export INDIR_INTERP=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/month_inter
export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/day_estimation_input
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/day_estimation_linear

# cp the file  do before the computtation ....aggiungre -ot Float 
# seq 0 13   | xargs -n 1  -P 14 bash -c $' 
# month=$1
# if [ $month -eq 0 ] ; then  daystart=-15 ;  gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_INTERP/MCD09_mean_12_interp.tif  $INDIR/cloud$month.tif ;  fi   # 30 days  
# if [ $month -eq 1 ] ; then  daystart=15  ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_INTERP/MCD09_mean_01_interp.tif  $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days  
# if [ $month -eq 2 ] ; then  daystart=45  ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_INTERP/MCD09_mean_02_interp.tif  $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days    
# if [ $month -eq 3 ] ; then  daystart=75  ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_03_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days     
# if [ $month -eq 4 ] ; then  daystart=105 ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_04_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days     
# if [ $month -eq 5 ] ; then  daystart=135 ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_05_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days     
# if [ $month -eq 6 ] ; then  daystart=165 ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_06_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days  
# if [ $month -eq 7 ] ; then  daystart=195 ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_07_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days  
# if [ $month -eq 8 ] ; then  daystart=226 ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_08_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 30 days  
# if [ $month -eq 9 ] ; then  daystart=257 ; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_09_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 31 days  
# if [ $month -eq 10 ] ; then  daystart=288; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_ORIG/MCD09_mean_10_noct.tif      $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 31 days  
# if [ $month -eq 11 ] ; then  daystart=319; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_INTERP/MCD09_mean_11_interp.tif  $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 31 days  
# if [ $month -eq 12 ] ; then  daystart=350; gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_INTERP/MCD09_mean_12_interp.tif  $OUTDIR/cloud$daystart.tif ; cp  $OUTDIR/cloud$daystart.tif $INDIR/cloud$month.tif ; fi   # 31 days  
# if [ $month -eq 13 ] ; then  daystart=381;  gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    -co PREDICTOR=2 $INDIR_INTERP/MCD09_mean_01_interp.tif $INDIR/cloud$month.tif ;    fi    # 31 days  

# ' _ 

# month=$1

if [ $month -eq 0 ] ; then  daystart=-15 ;   fi   # 30 days  
if [ $month -eq 1 ] ; then  daystart=15  ;   fi   # 30 days  
if [ $month -eq 2 ] ; then  daystart=45  ;   fi   # 30 days    
if [ $month -eq 3 ] ; then  daystart=75  ;   fi   # 30 days     
if [ $month -eq 4 ] ; then  daystart=105 ;   fi   # 30 days     
if [ $month -eq 5 ] ; then  daystart=135 ;   fi   # 30 days     
if [ $month -eq 6 ] ; then  daystart=165 ;   fi   # 30 days  
if [ $month -eq 7 ] ; then  daystart=195 ;   fi   # 30 days  
if [ $month -eq 8 ] ; then  daystart=226 ;   fi   # 30 days  
if [ $month -eq 9 ] ; then  daystart=257 ;   fi   # 31 days  
if [ $month -eq 10 ] ; then  daystart=288;   fi   # 31 days  
if [ $month -eq 11 ] ; then  daystart=319;   fi   # 31 days  
if [ $month -eq 12 ] ; then  daystart=350;   fi   # 31 days  
if [ $month -eq 13 ] ; then  daystart=381;   fi   # 31 days   


# to use the january  for the 366 day 
if [ $month -lt  7  ]  ; then 
    filend=$(expr $month + 30)
    nseq=29
    fact=0.033333333  # 1/30   dayly increment 
 else 
    filend=$(expr $month  + 31)
    nseq=30 
    fact=0.032258065  # 1/31
fi

echo  start to process $1 

for n in `seq 1 $nseq` ; do 
    # decide to take out the 0 before the daynumber 
    monthend=$(expr $month  + 1)
    fileout=$(expr $daystart  + $n)
    if [ $fileout -gt 0  ] && [ $fileout -lt 366  ]  ; then 
    echo processing day $fileout
    date 
    gdal_calc.py   -A $INDIR/flot_cloud$month.tif -B $INDIR/flot_cloud$monthend.tif --calc="( A + ((B-A) * $fact * $n) )"  --outfile=$OUTDIR/tmpcloud$fileout.tif --co=COMPRESS=LZW --co=ZLEVEL=9   --type Float32  --overwrite 
    gdal_translate  -ot UInt32    -co COMPRESS=LZW -co ZLEVEL=9  -co PREDICTOR=2     $OUTDIR/tmpcloud$fileout.tif $OUTDIR/cloud$fileout.tif
    rm -f $OUTDIR/tmpcloud$fileout.tif
    fi
done 


exit 
# quality controll # funziona tutto 
rm cloud-*.tif rm cloud0.tif

for day in `seq 1 365` ; do   echo $day `gdallocationinfo  -valonly  cloud$day.tif 2100 1000`  ; done  > /tmp/text2100-800.txt 

