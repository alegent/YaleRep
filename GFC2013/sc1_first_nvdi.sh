#  cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/first
#  awk 'NR%16==1 {x="F"++i;}{ print >  "first_listtif"x".txt" }'  first_listtif.txt ; 

# 

#  for list  in first_listtifF??.txt  first_listtifF?.txt  ; do qsub -v list=$list  /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_first_nvdi.sh   ; done 

# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_first_nvdi.sh  

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=3:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V

#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/first
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/first_ndvi
export RAM=/dev/shm


rm -f $RAM/*

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/first/$list  | xargs -n 1 -P 6  bash -c $' 

file=$1 
filename=$(basename $file .tif )

echo process $file 

# first band 
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9 -b 1  $INDIR/$file $RAM/$filename"_b1.tif" 

oft-calc -um  $RAM/$filename"_b1.tif"   -ot Float32  $INDIR/$file  $OUTDIR/$filename"_b1rfl.tif"   <<EOF
1
#1 1 - 508 /
EOF

gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/$filename"_b1rfl.tif"   $RAM/$filename"_b1rflc.tif" 
rm -f  $RAM/$filename"_b1.tif"  $OUTDIR/$filename"_b1rfl.tif"


# second band 
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9 -b 2   $INDIR/$file  $RAM/$filename"_b2.tif" 

oft-calc    -um  $RAM/$filename"_b2.tif"  -ot Float32  $INDIR/$file  $OUTDIR/$filename"_b2rfl.tif" <<EOF
1
#2 1 - 254 /
EOF
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/$filename"_b2rfl.tif"   $RAM/$filename"_b2rflc.tif" 
rm -f  $RAM/$filename"_b2.tif"   $OUTDIR/$filename"_b2rfl.tif" 

# ndvi 
gdalbuildvrt   -overwrite -separate    $RAM/$filename".vrt"   $RAM/$filename"_b1rflc.tif"  $RAM/$filename"_b2rflc.tif"

oft-calc   -ot Byte  $RAM/$filename".vrt" $OUTDIR/$filename"_ndvi_tmp.tif" <<EOF
1
#2 #1 - #2 #1 + / 100 *
EOF

rm -f $RAM/$filename".vrt"  $RAM/$filename"_b1rflc.tif" $RAM/$filename"_b2rflc.tif"
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/$filename"_ndvi_tmp.tif"  $OUTDIR/$filename"_ndvi.tif"
rm -f $OUTDIR/$filename"_ndvi_tmp.tif"

tile=${filename:21:10}

pksetmask  -msknodata 2  -nodata 255    -msknodata 0   -nodata 255  -co COMPRESS=LZW -co ZLEVEL=9 -ot  Byte    -m  $OUTDIR/../datamask/tif/Hansen_GFC2014_datamask_${filename:21:10}.tif -i  $OUTDIR/$filename"_ndvi.tif" -o  $OUTDIR/$filename"_ndvi_msk.tif" 

pkfilter    -co COMPRESS=LZW -co ZLEVEL=9 -ot  Byte    -dx 33 -dy 33   -f median  -d 30   -i   $OUTDIR/$filename"_ndvi_msk.tif"  -o  $OUTDIR/$filename"_ndvi33.tif"

' _ 

rm -f $RAM/*