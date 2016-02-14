# anyway this is better 
# see https://datasciencelab.wordpress.com/2013/12/27/finding-the-k-in-k-means-clustering/ 

export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export INCLUST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/$DIR
export OUTCLUST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster_$DIR

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/

export RAM=/dev/shm


rm -f $INDIR/gap/gap.txt   $INDIR/gap/gap_LOG.txt 

for CLUST in $( seq 4  100  ) ; do 

echo $CLUST  $(cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_normal/wss/cluster${CLUST}_wss.txt ) $(cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_random/wss/cluster${CLUST}_wss.txt  )  | awk '{ printf ("%i %i %i %i\n" , $1 , $2 , $3, $3-$2 ) }'       >>  $INDIR/gap/gap.txt 

echo $CLUST  $(cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_normal/wss/cluster${CLUST}_LOGwss.txt ) $(cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_random/wss/cluster${CLUST}_LOGwss.txt  )  | awk '{ printf ("%i %f %f %f\n" , $1 , $2 , $3, $3-$2 ) }' >>  $INDIR/gap/gap_LOG.txt 


done 







