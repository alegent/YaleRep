
#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr


module unload Apps/R/3.0.2
module load Apps/R/3.2.2-generic

echo sampling the data
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training


echo "BIO_12 BIO_7 dem_avg lu_10 lu_1 lu_2 lu_3 lu_4 lu_5 lu_6 lu_7 lu_8 lu_9 slope_avg soil_wavg_01 soil_wavg_02 soil_wavg_03 soil_wavg_05 upcells_land"  >   $TRAIN/training_10000_stack_forR.txt
cat $TRAIN/training_x*_y*_stack.txt  |  awk '{if (NR%10000==0)  { for (col = 5 ; col<NF ; col++ ) {  printf ("%s ", $col) } ;     printf ("%s\n", $NF)  }  }'  >>   $TRAIN/training_10000_stack_forR.txt

R --vanilla --no-readline   -q  <<'EOF' 

table=read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training/training_10000_stack_forR.txt" , sep=" " , header = TRUE )

library(cluster)
cluster = clusGap(table, kmeans, 120, B = 100, verbose = interactive())

save.image("/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster.R")

EOF
