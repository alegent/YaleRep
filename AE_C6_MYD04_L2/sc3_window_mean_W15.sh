# qsub -v DAYc=010,WIND=15 /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc3_window_mean_W15.sh   

# for DAYc  in `cat /scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/day_list_year_round.txt`  ; do qsub -v DAYc=$DAYc,WIND=15 /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc3_window_mean_W15.sh    ; done 

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export DAYc=$DAYc
export WIND=$WIND

# export DAYc=002
# export WIND=15

export INDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2
export OUTDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/mean_${WIND}_C6/tif

echo multiply the AOD for the quality flag

echo create the file list  for $DAYc



# fa la somma dey valori moltiplicati 
rm -f  $OUTDIR/file4vrt_day${DAYc}.txt
for YEAR in  $(seq 2002 2014) ; do 
    for DAY in $(awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc + 16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }'  /scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/day_list_year_round.txt ) ; do  
	# redirect the sterr to dev/null if the file is missing # to a file if the file is there 
	ls  $INDIR/$YEAR/tif_merge/Combined_year${YEAR}_day${DAY}.tif  2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
    done 
done

echo pkcomposite for $OUTDIR/AOD_550_mean_day${DAYc}.tif

pkcomposite  $(cat $OUTDIR/file4vrt_day${DAYc}.txt |  xargs -n 1 echo -i $1 ) -min -101 -max 5001  -cr mean  -dstnodata -9999  -srcnodata -9999  -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9    -o $OUTDIR/AOD_550_mean_day${DAYc}.tif

exit 



