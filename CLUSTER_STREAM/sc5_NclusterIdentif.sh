# anyway this is better 
# see https://datasciencelab.wordpress.com/2013/12/27/finding-the-k-in-k-means-clustering/ 

export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal 
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training
export RAM=/dev/shm





awk '{  for (col=22 ; col<=NF ; col++) {  sum = sum +  (($col)^2 ) * ($2-1)   } ; obs = obs + $2     } END  { print sum / obs  } '   $OUTDIR/cluster${CLUST}_stat.txt >  $OUTDIR
/cluster${CLUST}_wss.txt
