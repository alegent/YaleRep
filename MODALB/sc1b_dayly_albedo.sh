# calculate the albdedo days based on linear trend between 2 estimation 
# echo 001 017 033 049 065 081 097 113 129 145 161 177 193 209 225 241 257 273 289 305 321 337 353  | xargs -n 1 -P 10 bash /mnt/data2/scratch/GMTED2010/scripts/sc1b_dayly_albedo.sh

INDIR=/mnt/data2/scratch/GMTED2010/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0
OUTDIR=/mnt/data2/scratch/GMTED2010/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_estimation

file=AlbMap.WS.c004.v2.0.00-04.$1.0.3_5.0.tif

cp $INDIR/$file  $OUTDIR/AlbMap.WS.c004.v2.0.00-04.$(expr $1 + 0 ).0.3_5.0.tif

# to use the 001 for the 366 day 
if [ $1 = '353' ]  ; then 
    filend=$(expr $1 + 13)
    cp  $INDIR/AlbMap.WS.c004.v2.0.00-04.001.0.3_5.0.tif   $OUTDIR/AlbMap.WS.c004.v2.0.00-04.366.0.3_5.0.tif
    nseq=12 
else 
    filend=$(expr $1 + 16)
    if [ $filend -lt 99  ] ; then 
	fileB=0$filend 
    else
	fileB=$filend 
    fi 
    cp  $INDIR/AlbMap.WS.c004.v2.0.00-04.$fileB.0.3_5.0.tif   $OUTDIR/AlbMap.WS.c004.v2.0.00-04.$filend.0.3_5.0.tif
    nseq=15 
fi

echo  start to process $1 

for n in `seq 1 $nseq` ; do 
    # decide to take out the 0 before the daynumber 
    fileout=$(expr $1 + $n)
    echo processing day $fileout
    gdal_calc.py --co=COMPRESS=LZW --co=ZLEVEL=9 -A $INDIR/$file -B $OUTDIR/AlbMap.WS.c004.v2.0.00-04.$filend.0.3_5.0.tif  --calc="( A + ((B-A) * 0.0625 * $n) )" --type Int16  --outfile=$OUTDIR/AlbMap.WS.c004.v2.0.00-04.$fileout.0.3_5.0.tif  --overwrite
done 


