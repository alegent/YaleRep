
# qsub /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc3_traningset.sh
# data preparation 

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr


export MSK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export TRAI=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training
export RAM=/dev/shm
  
# 39000 13920  
# split the stak in 8 tiles Size is 39000 13920   so 9750  6960

echo 0        0 9750 6960   > $RAM/tiles_xoff_yoff.txt
echo 9750     0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 0     6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 9750  6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt

cat $RAM/tiles_xoff_yoff.txt  | xargs -n 4 -P 8 bash -c $' 


xoff=$1
yoff=$2
xsize=$3
ysize=$4

gdal_translate -srcwin  $xoff $yoff $xsize $ysize  -of XYZ   $MSK/mask.tif  $MSK/mask_x${1}_y${2}z.txt 

echo cleaning the  $MSK/mask_x${1}_y${2}.txt 

awk \'{ if ($3==1) print $1, $2 }\'   $MSK/mask_x${1}_y${2}z.txt    >  $RAM/training_x${1}_y${2}.txt 
cp  $RAM/training_x${1}_y${2}.txt   $TRAI/training_x${1}_y${2}.txt 

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack_${1}_${2}.tif

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask/mask.tif     /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask/mask_${1}_${2}.tif

oft-extr -o   $TRAI/training_x${1}_y${2}_stack.txt    $RAM/training_x${1}_y${2}.txt /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack_${1}_${2}.tif   <<EOF
1
2
EOF

' _

rm   $RAM/training_x${1}_y${2}.txt 
exit 
