# for CLUST in $(seq 4 100) ; do  qsub -v CLUST=$CLUST,DIR=normal   /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles_8tiles.sh-delate.sh ; done 


#PBS -S /bin/bash 
#PBS -l nodes=1:ppn=8
#PBS -q fas_normal
#PBS -l walltime=1:00:00
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export CLUST=$CLUST
export DIR=$DIR 

cleanram

export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export INCLUST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/$DIR
export OUTCLUST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster_$DIR
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_$DIR
export TXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_$DIR

export RAM=/dev/shm

cleanram 

oft-stat -i $INCLUST/stack.vrt -mm   -o $TXT/stat/cluster${CLUST}_stat.txt -um $OUTCLUST/cluster${CLUST}_ct.tif  

# -nan = standard deviation =0 
awk '{ gsub("-nan","0"  ) ; for (col=NF-19+1  ; col<=NF ; col++) {   sum = sum + ((($col)^2 ) * ($2-1)/1000000 ) }} END { printf ("%f\n",sum ) }'   $TXT/stat/cluster${CLUST}_stat.txt  > $TXT/wss/cluster${CLUST}_wss.txt
awk '{ gsub("-nan","0"  ) ; for (col=NF-19+1  ; col<=NF ; col++) {   sum = sum + ((($col)^2 ) * ($2-1)/1000000 ) }} END { printf ("%f\n",log(sum )) }'   $TXT/stat/cluster${CLUST}_stat.txt  > $TXT/wss/cluster${CLUST}_LOGwss.txt


cleanram
