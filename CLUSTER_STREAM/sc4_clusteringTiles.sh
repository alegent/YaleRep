
# some of them fail in the wall time ...select the one that do not apper in the fas_long

#  for CLUST in $(seq 4 100) ; do  qsub -q fas_normal -l walltime=4:00:00 -v CLUST=$CLUST /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles.sh ; done 

#PBS -S /bin/bash 
#PBS -l nodes=1:ppn=8
#PBS -l mem=34gb
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export CLUST=$CLUST

echo  "CLUST $CLUST  /home/fas/sbsc/ga254/scripts/CLUSTER_STREM/sc4_clusteringTiles.sh"    > /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_start.$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_start.$PBS_JOBID.txt 


export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal 
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training
export RAM=/dev/shm

rm  -fr /dev/shm/*


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

cat $TRAIN/training_x*_y*_stack.txt  |  awk '{if (NR%10==0) print $0}'  >  $TRAIN/training_100_stack.txt
cp  $TRAIN/training_100_stack.txt $RAM

cat $RAM/tiles_xoff_yoff.txt  | xargs -n 2 -P 8  bash -c $'

cp $NORDIR/stack_${1}_${2}.tif   $RAM/stack_${1}_${2}.tif
cp $MSKDIR/mask_${1}_${2}.tif    $RAM/mask_${1}_${2}.tif

echo start the cluster 

oft-kmeans -um $RAM/mask_${1}_${2}.tif  -ot UInt16  -o $RAM/training_x${1}_y${2}_cluster${CLUST}.tif -i  $RAM/stack_${1}_${2}.tif  << EOF
$RAM/training_100_stack.txt
$CLUST
EOF

# rm $RAM/stack_${1}_${2}.tif      $RAM/mask_${1}_${2}.tif

' _ 

 
echo "############################################################### start the marging ######################################"

gdalbuildvrt -overwrite -tr 0.0083333333333 0.0083333333333 $RAM/cluster_vrt.vrt     $RAM/training_x*_y*_cluster${CLUST}.tif

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot UInt16 $RAM/cluster_vrt.vrt   $OUTDIR/cluster${CLUST}.tif

# pkcreatect  -min 1 -max  ${CLUST}  > /dev/shm/color.txt 

echo 0 255 255 255  >   /dev/shm/color.txt ; 
for n in $( seq 1 ${CLUST}  ) ; do echo -n $n $[ RANDOM % 256 ]" " ; echo -n  $[ RANDOM % 256 ]" "  ; echo -n  $[ RANDOM % 256 ]" " ; echo ""  ;  done  >>   /dev/shm/color.txt

pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct   /dev/shm/color.txt   -i   $OUTDIR/cluster${CLUST}.tif -o  $OUTDIR/cluster${CLUST}_ct.tif
rm -f  $RAM/training_x*_y*_cluster*.tif  $RAM/mask_*_*.tif   $RAM/stack_*_*.tif    $RAM/cluster_vrt.vrt  $RAM/tiles_xoff_yoff.txt  $RAM/training_stack_evry$DENSITY.txt   /dev/shm/color.txt 

oft-stat  -i   $NORDIR/stack.tif  -o  $OUTDIR/cluster${CLUST}_stat.txt   -um   $OUTDIR/cluster${CLUST}_ct.tif  

# awk '{  for (col=22 ; col<NF ; col++) {  printf ("%s " , (($col)^2 ) * ($2-1)  ) }  printf ("%s\n" , (($NF)^2) * ($2-1) )    }' stat.txt 

awk '{  for (col=22 ; col<=NF ; col++) {  sum = sum +  (($col)^2 ) * ($2-1)   }     } END  {print sum } '   $OUTDIR/cluster${CLUST}_stat.txt >  $OUTDIR/cluster${CLUST}_wss.txt

echo  "CLUST $CLUST /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh"    >  /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_end.$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_end.$PBS_JOBID.txt 

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
