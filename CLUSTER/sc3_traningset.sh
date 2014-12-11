# data preparation 

# in clude the greenland hol in the mask

# pksetmask -i    /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask/mask.tif -m  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal/aridity_index_crop_norm.tif -msknodata -32768 -nodata 0  -o     /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask/mask_greenland.tif -co COMPRESS=LZW -co ZLEVEL=9


# qsub -v density=50  /home/fas/sbsc/ga254/scripts/CLUSTER/sc3_traningset.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr


export RAM=/dev/shm/
export density=$density

# split the stak in 8 tiles Size is 43200, 16800  so 10800  8400 

echo 0        0 10800 8400   > $RAM/tiles_xoff_yoff.txt
echo 10800    0 10800 8400  >> $RAM/tiles_xoff_yoff.txt
echo 21600    0 10800 8400  >> $RAM/tiles_xoff_yoff.txt
echo 32400    0 10800 8400  >> $RAM/tiles_xoff_yoff.txt
echo 0     8400 10800 8400  >> $RAM/tiles_xoff_yoff.txt
echo 10800 8400 10800 8400  >> $RAM/tiles_xoff_yoff.txt
echo 21600 8400 10800 8400  >> $RAM/tiles_xoff_yoff.txt
echo 32400 8400 10800 8400  >> $RAM/tiles_xoff_yoff.txt

# cat $RAM/tiles_xoff_yoff.txt  | xargs -n 4 -P 8 bash -c $' 

# xoff=$1
# yoff=$2
# xsize=$3
# ysize=$4

# gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask/mask_greenland.tif /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask/mask_greenland_${1}_${2}.tif
# gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal/stack.tif   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal/stack_${1}_${2}.tif


# ' _ 



cat $RAM/tiles_xoff_yoff.txt  | xargs -n 4 -P 8 bash -c $' 

INPUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal/stack_${1}_${2}.tif
MASK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask/mask_greenland_${1}_${2}.tif 

cp  $MASK   $RAM
cp  $INPUT  $RAM

INPUT=$RAM/stack_${1}_${2}.tif
MASK=$RAM/mask_greenland_${1}_${2}.tif

xsize=`gdalinfo $MASK | grep "Size is" | awk \'{gsub(","," ")  ; print $3}\'`
ysize=`gdalinfo $MASK | grep "Size is" | awk \'{gsub(","," ")  ; print $4}\'`

ps=`gdalinfo $MASK | grep "Pixel Size" | awk \'{gsub("[(,)]"," "); print $4}\'` 

# compute 10 sample

echo $density

dx=$density
dy=$density

echo "Using " $dx "pixels as X sampling interval"
echo "Using " $dy "pixels as Y sampling interval"

echo  oft-gengrid.bash   $MASK $dx $dy 

oft-gengrid-latlong.bash $MASK $dx $dy /dev/shm/mask_x${1}_y${2}.txt 
       
oft-extr -o /dev/shm/spec_mask_x${1}_y${2}.txt    /dev/shm/mask_x${1}_y${2}.txt    $MASK <<EOF
2
3
EOF

echo cleaning the /dev/shm/mask_x${1}_y${2}.txt 

paste -d " " <(awk \'{ print $2, $3}\' /dev/shm/mask_x${1}_y${2}.txt   )  <(awk \'{ print  $6}\' /dev/shm/spec_mask_x${1}_y${2}.txt ) | awk \'{ if ($3==1) print $1 , $2 }\'  > /dev/shm/training_x${1}_y${2}.txt 

cp /dev/shm/training_x${1}_y${2}.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/cluster/training_x${1}_y${2}_evry$density.txt

echo cleaning the /dev/shm/training_x_y.txt

oft-extr -o /dev/shm/training_x${1}_y${2}_stack.txt /dev/shm/training_x${1}_y${2}.txt     $INPUT <<EOF
1
2
EOF

cp  /dev/shm/training_x${1}_y${2}_stack.txt /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/cluster/training_x${1}_y${2}_stack_evry$density.txt
rm /dev/shm/training_x${1}_y${2}_stack.txt /dev/shm/training_x${1}_y${2}.txt

rm $RAM/stack_${1}_${2}.tif
rm $RAM/mask_greenland_${1}_${2}.tif


' _
 
rm $RAM/tiles_xoff_yoff.txt

exit 
