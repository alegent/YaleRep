# calculate the linke  days based on linear trend between 2 estimation 

# change the data type in the input file because gdal_calc in case of byte  do not support the operation a-b be negative...
#  for file in months_orig/*.tif ; do filename=`basename $file `  ;  gdal_translate -ot Int16  -co COMPRESS=LZW -co ZLEVEL=9  $file months/$filename ; done 

# seq 0 13   | xargs -n 1 -P 10 bash /mnt/data2/scratch/GMTED2010/scripts/sc1b_dayly_linke.sh
# for file in `seq 1 365` ;do  ls linke$file.tif  ; done  # for control check 

INDIR=/mnt/data2/scratch/GMTED2010/linke_turbidity/months
OUTDIR=/mnt/data2/scratch/GMTED2010/linke_turbidity/day_estimation/

month=$1

if [ $month -eq 0 ] ; then  daystart=-15  ; fi   # 30 days  
if [ $month -eq 1 ] ; then  daystart=15  ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi   # 30 days  
if [ $month -eq 2 ] ; then  daystart=45  ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 30 days  
if [ $month -eq 3 ] ; then  daystart=75  ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 30 days  
if [ $month -eq 4 ] ; then  daystart=105 ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 30 days  
if [ $month -eq 5 ] ; then  daystart=135 ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 30 days  
if [ $month -eq 6 ] ; then  daystart=165 ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 30 days  
if [ $month -eq 7 ] ; then  daystart=195 ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 30 days  
if [ $month -eq 8 ] ; then  daystart=226 ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 30 days  
if [ $month -eq 9 ] ; then  daystart=257 ; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 31 days  
if [ $month -eq 10 ] ; then  daystart=288; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 31 days  
if [ $month -eq 11 ] ; then  daystart=319; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 31 days  
if [ $month -eq 12 ] ; then  daystart=350; cp  $INDIR/linke$month.tif $OUTDIR/linke$daystart.tif ; fi    # 31 days  
if [ $month -eq 13 ] ; then  daystart=381; fi    # 31 days  


# to use the january  for the 366 day 
if [ $month -lt  7  ]  ; then 
    filend=$(expr $month + 30)
    nseq=29
    fact=0.033333333  # 1/30
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
    echo processing day $fileout
    gdal_calc.py -A $INDIR/linke$month.tif -B $INDIR/linke$monthend.tif --calc="( A + ((B-A) * $fact * $n) )"  --outfile=$OUTDIR/linke$fileout.tif --co=COMPRESS=LZW --co=ZLEVEL=9   --type Float32  --overwrite 
done 


exit 
# quality controll # funziona tutto 
rm linke-*.tif rm linke0.tif

for day in `seq 1 365` ; do  

echo $day `gdallocationinfo  -valonly  linke$day.tif 2100 1000`

done  > text2100-800.txt 

