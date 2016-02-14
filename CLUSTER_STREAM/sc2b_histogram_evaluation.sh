# qsub    /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc2b_histogram_evaluation.sh

#  priocessa il tutto in 5 min

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr



export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export   RAND=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/random 
export   NORM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal
export   TXTNORM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_normal
export   TXTRAND=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_random
export   RAM=/dev/shm


cleanram
# set P to 2 if not you get saturation of the ram 

filen=$(gdalinfo  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.vrt  | grep tif | wc -l  )

seq 1 $filen | xargs -n 1 -P 8  bash -c $'  

export LYR=$1

file=$(gdalinfo  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.vrt  | grep tif | sed \'s=.*/==\' |   awk -v LYR=$LYR  \'{ if ( NR == LYR ) {  print  }  }\' )

echo min max $file $LYR

minmax_N=$(gdalinfo -mm /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/$file | grep Computed | awk -F = \'{ print $2  }\' )
export Lmin_N=$(echo $minmax_N | awk -F , \'{  print int($1) }\')
export Lmax_N=$(echo $minmax_N | awk -F , \'{  print int($2) }\')

minmax_R=$(gdalinfo -mm /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/random/rand${LYR}_int_msk.tif | grep Computed | awk -F = \'{ print $2  }\' )
export Lmin_R=$(echo $minmax_R | awk -F , \'{  print int($1) }\')
export Lmax_R=$(echo $minmax_R | awk -F , \'{  print int($2) }\')
 
echo hist  $file  $LYR

echo $file $LYR  $Lmin_N $Lmax_N  $Lmin_R $Lmax_R  > $TXTNORM/minmax/$(basename  $file .tif )_R${LYR}.txt  
echo $file $LYR  $Lmin_N $Lmax_N  $Lmin_R $Lmax_R  > $TXTRAND/minmax/$(basename  $file .tif )_R${LYR}.txt  

pkstat -hist --src_min  $Lmin_R  --src_max  $Lmax_R  -i $RAND/rand${LYR}_int_msk.tif >  $TXTRAND/hist/$(basename  $file .tif )_R${LYR}.txt
pkstat -hist --src_min  $Lmin_N  --src_max  $Lmax_N  -i $NORM/$file                  >  $TXTNORM/hist/$(basename  $file .tif )_R${LYR}.txt

' _ 
