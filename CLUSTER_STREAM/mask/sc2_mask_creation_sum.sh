# bash /lustre/home/client/fas/sbsc/ga254/max_min_river/script/sc2_mask_creation_sum.sh

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=10:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/sd566/global_wsheds/global_results_merged/filled_str_ord_maximum_max50x_lakes_manual_correction/
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/global_wsheds/tif_msk

rm -f $OUTDIR/sum.tif

gdalbuildvrt  -separate $OUTDIR/all.vrt     $OUTDIR/*.tif 

string=$(seq 1 230 | xargs -n 1 bash -c $'  echo -n "#"$1" "  ' _ ; seq 1 229 | xargs -n 1 bash -c $'  echo -n +" "  ' _ )

oft-calc -ot Byte   $OUTDIR/all.vrt     $OUTDIR/sum.tif  <<EOF
1
${string}
EOF





