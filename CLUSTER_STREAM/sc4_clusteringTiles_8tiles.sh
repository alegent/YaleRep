# run the first time to create a sampled training dataset 

# if (NR%10==0)
# cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_normal/training_x*_y*_stack.txt | awk '{ if (NR%5==0) {for (col=1 ; col<=NF ; col++) { printf ("%i ",$col)} ; printf ("\n",$NF)}}' >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_normal/training_stack.txt
# cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_random/training_x*_y*_stack.txt | awk '{ if (NR%5==0) {for (col=1 ; col<=NF ; col++) { printf ("%i ",$col)} ; printf ("\n",$NF)}}' >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_random/training_stack.txt

#  for CLUST in $(seq 4 100) ; do  qsub -v CLUST=$CLUST,DIR=normal  /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles_8tiles.sh  ; done  
#  for CLUST in $(seq 4 100) ; do  qsub -v CLUST=$CLUST,DIR=random  /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles_8tiles.sh  ; done 

#PBS -S /bin/bash 
#PBS -l nodes=1:ppn=8
#PBS -q fas_normal 
#PBS -l walltime=24:00:00
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export CLUST=$CLUST
export DIR=$DIR

echo  "CLUST $CLUST  /home/fas/sbsc/ga254/scripts/CLUSTER_STREM/sc4_clusteringTiles.sh"    > /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_start.$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_start.$PBS_JOBID.txt 

cleanram

export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export INCLUST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/$DIR
export OUTCLUST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster_$DIR
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_$DIR
export TXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_$DIR

export RAM=/dev/shm


# split the stak in 8 tiles Size is 39000 13920   so 9750  6960

echo 0        0 9750 6960   > $RAM/tiles_xoff_yoff.txt
echo 9750     0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 0     6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 9750  6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt

echo sampling the data

# this is for the full dataset
# cat   $TRAIN/training_x*_y*_stack.txt  >   $RAM/training_stack.txt   

# copy the sampled training 
cp $TRAIN/training_stack.txt     $RAM/training_stack.txt   

cat $RAM/tiles_xoff_yoff.txt  | xargs -n 4 -P 8  bash -c $'
# n 4 even if only use 2 

cp $INCLUST/stack_${1}_${2}.tif   $RAM/stack_${1}_${2}.tif  
cp $MSKDIR/mask_${1}_${2}.tif     $RAM/mask_${1}_${2}.tif

echo start the cluster for training_x${1}_y${2}_cluster${CLUST}.tif 

oft-kmeans -um $RAM/mask_${1}_${2}.tif  -ot Byte  -o $RAM/training_x${1}_y${2}_cluster${CLUST}.tif -i  $RAM/stack_${1}_${2}.tif  &> /dev/null   << EOF
$RAM/training_stack.txt
$CLUST
EOF
echo $(du -hs /dev/shm/)   after x${1}_y${2} clustering 
free -m 


rm -f  $RAM/stack_${1}_${2}.tif      $RAM/mask_${1}_${2}.tif
' _ 
 
echo "############################################################### start the marging ######################################"

gdalbuildvrt -overwrite -tr 0.0083333333333 0.0083333333333 $RAM/cluster_vrt.vrt $RAM/training_x*_y*_cluster${CLUST}.tif

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot Byte   $RAM/cluster_vrt.vrt   $RAM/cluster${CLUST}.tif


echo 0 255 255 255  >   /dev/shm/color.txt ; 
for n in $( seq 1 ${CLUST}  ) ; do echo -n $n $[ RANDOM % 256 ]" " ; echo -n  $[ RANDOM % 256 ]" "  ; echo -n  $[ RANDOM % 256 ]" " ; echo ""  ;  done  >>   /dev/shm/color.txt

pkcreatect  -ot Byte   -co COMPRESS=LZW -co ZLEVEL=9   -ct   /dev/shm/color.txt   -i   $RAM/cluster${CLUST}.tif -o  $OUTCLUST/cluster${CLUST}_ct.tif

oft-stat -i $INCLUST/stack.vrt -mm   -o $TXT/stat/cluster${CLUST}_stat.txt -um $RAM/cluster${CLUST}.tif 

# -nan = standard deviation =0 
awk '{ gsub("-nan","0"  ) ; for (col=NF-19+1  ; col<=NF ; col++) {   sum = sum + ((($col)^2 ) * ($2-1)/100000 ) }} END { printf ("%f\n",sum ) }'      $TXT/stat/cluster${CLUST}_stat.txt  > $TXT/wss/cluster${CLUST}_wss.txt
awk '{ gsub("-nan","0"  ) ; for (col=NF-19+1  ; col<=NF ; col++) {   sum = sum + ((($col)^2 ) * ($2-1)/100000 ) }} END { printf ("%f\n",log(sum )) }' $TXT/stat/cluster${CLUST}_stat.txt  > $TXT/wss/cluster${CLUST}_LOGwss.txt

# hist of the cluster to detect errors by cheking the 0 number values 
# the nodata in the mask are 519560159 so should be the same in all the cluster hist 
pkstat  -hist  -src_min -1   -i $RAM/cluster${CLUST}.tif > $TXT/hist_clust/cluster${CLUST}_hist.txt

cleanram

echo  "CLUST $CLUST /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh"  >  /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_end.$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_end.$PBS_JOBID.txt 

exit 

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


DIR=normal

DIR=random

export TXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/txt_$DIR

for CLUST in $( seq 4  100  ) ; do 

awk '{  gsub("-nan","0"  ) ; for (col=23 ; col<=NF ; col++) { sum = sum + (((($col)^2 ) * ($2-1))/100000000) }} END { printf ("%f\n",sum ) }'        $TXT/stat/cluster${CLUST}_stat.txt  > $TXT/wss/cluster${CLUST}_wss.txt
awk '{  gsub("-nan","0"  ) ; for (col=23 ; col<=NF ; col++) { sum = sum + (((($col)^2 ) * ($2-1))/100000000) }} END { printf ("%f\n",log(sum) ) }'   $TXT/stat/cluster${CLUST}_stat.txt  > $TXT/wss/cluster${CLUST}_LOGwss.txt


done 

