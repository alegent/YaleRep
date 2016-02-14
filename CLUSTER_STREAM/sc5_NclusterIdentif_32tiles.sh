# anyway this is better 
# see https://datasciencelab.wordpress.com/2013/12/27/finding-the-k-in-k-means-clustering/ 

# this create a  4_5_6...8   9_10_11....                                                                this allow to wait finish for other jobs 


# for CLUSTERS in $(  seq 4 100 | xargs   -n 8 | awk '{  gsub(" ","_",$0) ; print  }'   ) ; do  qsub -W afterany:jobid:$( qstat -u $USER   | grep sc4_clusteringTi  | awk -F "." '{ printf ("%s:", $1) }' |  sed 's/.$//' )  -v CLUSTERS=$CLUSTERS /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc5_NclusterIdentif.sh  ; done 


# for CLUSTERS in 4  ; do    qsub -W afterany:jobid:$( qstat -u $USER   | grep sc4_clusteringTi  | awk -F "." '{ printf ("%s:", $1) }' |  sed 's/.$//' )  -v CLUSTERS=$CLUSTERS /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc5_NclusterIdentif.sh  ; done 



#PBS -S /bin/bash 
#PBS -l nodes=1:ppn=8
#PBS -q fas_normal
#PBS -l walltime=4:00:00
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal 
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training
export TXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt
export RAM=/dev/shm

export CLUSTERS=$CLUSTER

echo $CLUSTERS 

exit 

echo $CLUSTERS |   awk '{  gsub("_"," ",$0) ; print  }'  | xargs -n 1 -P 8 bash -c $'

CLUSTER=$1

cleanram

echo merging CLUSTER $CLUSTER

gdalbuildvrt -overwrite -tr 0.0083333333333 0.0083333333333 $RAM/cluster_vrt.vrt   $OUTDIR/tiles/cluster_${CLUSTER}_x*_y*.tif
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot UInt16    $RAM/cluster_vrt.vrt   $OUTDIR/cluster${CLUSTER}.tif

# rm $RAM/cluster_vrt.vrt $OUTDIR/tiles/cluster_${CLUSTER}_x*_y*.tif

echo 0 255 255 255  >   /dev/shm/color.txt ; 
for n in $( seq 1 ${CLUSTER}  ) ; do echo -n $n $[ RANDOM % 256 ]" " ; echo -n  $[ RANDOM % 256 ]" "  ; echo -n  $[ RANDOM % 256 ]" " ; echo ""  ;  done  >>   /dev/shm/color.txt

pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct   /dev/shm/color.txt  -i   $OUTDIR/cluster${CLUSTER}.tif -o  $OUTDIR/cluster${CLUSTER}_ct.tif
rm -f  /dev/shm/color.txt 

echo calculate statistic for cluster $CLUSTER

oft-stat  -i   $NORDIR/stack.tif  -o  $TXT/stat/cluster${CLUSTER}_stat.txt   -um   $OUTDIR/cluster${CLUSTER}_ct.tif   &> /dev/null 
                                                       # variance 
awk \'{  for (col=22 ; col<=NF ; col++) {  sum = sum +  (($col)^2 ) * ($2-1)   }     } END  {print sum } \'   $TXT/stat/cluster${CLUSTER}_stat.txt >  $TXT/wss/cluster${CLUSTER}_wss.txt
awk \'{  for (col=22 ; col<=NF ; col++) {  sum = sum +  (($col)^2 ) * ($2-1)   }     } END  {print log(sum) } \'   $TXT/stat/cluster${CLUSTER}_stat.txt >  $TXT/wss/cluster${CLUSTER}_LOGwss.txt

' _ 

cleanram

exit 

# awk '{  for (col=22 ; col<NF ; col++) {  printf ("%s " , (($col)^2 ) * ($2-1)  ) }  printf ("%s\n" , (($NF)^2) * ($2-1) )    }' stat.txt 

# oft-stat is usefull to calculate the wss 
# see http://stackoverflow.com/questions/15376075/cluster-analysis-in-r-determine-the-optimal-number-of-clusters 

# wss =  sum ( ( variance * of each band in each cluster )  * nobs - 1 )   ; where ( variance * of each band in each cluster )  * ( nobs - 1 ) = sum  ( x - xmean )^2

# kmeans(mydata,centers=2)$withinss
# [1] 3658.952 1258.118

# x[65:96]   and y[65:96]  belong to the same cluster 

# var(mydata$x[65:96])* 31 + var(mydata$y[65:96])* 31
# [1] 3658.952


# anyway this is better 
# see https://datasciencelab.wordpress.com/2013/12/27/finding-the-k-in-k-means-clustering/ 





















awk '{  for (col=22 ; col<=NF ; col++) {  sum = sum +  (($col)^2 ) * ($2-1)   } ; obs = obs + $2     } END  { print sum / obs  } '   $OUTDIR/cluster${CLUST}_stat.txt >  $OUTDIR
/cluster${CLUST}_wss.txt
