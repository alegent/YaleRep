# valid for one aridity_index_crop.tif  whihc is label 


export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif
export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask 
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif/aridity_index_crop.tif | xargs -n 1 -P 8 bash -c $'    

file=$1 
filename=`basename $file .tif` 

# pksetmask  -ot  Int32  -msknodata 0 -nodata  2147483647    -m   $MSKDIR/mask.tif    -co  COMPRESS=LZW   -co ZLEVEL=9    -i  $INDIR/$filename.tif  -o   $NORDIR/${filename}_msk.tif 
# gdal_edit.py -a_nodata  2147483647  $NORDIR/${filename}_msk.tif
 
pkinfo    -stats  -i  $NORDIR/${filename}_msk.tif      >     $NORDIR/${filename}_msk.stat.txt  
mean=$(  awk \'{  print $6 }\'     $NORDIR/${filename}_msk.stat.txt    )
stdev=$( awk \'{  print $8 }\'     $NORDIR/${filename}_msk.stat.txt    )

echo start the normalization 

oft-calc -ot Int16  -um $MSKDIR/mask.tif     $NORDIR/${filename}_msk.tif   $NORDIR/${filename}_norm_tmp.tif  >  /dev/null   <<EOF
1
#1 $mean - $stdev / 100 *
EOF

# rospetto agli altri e' stato usato lo stesso _msk come mask. per maskcare anche il nodata della groenlandia.

pksetmask  -ot  Int16   -msknodata 2147483647  -nodata  -32768      -m    $NORDIR/${filename}_msk.tif   -co  COMPRESS=LZW   -co ZLEVEL=9   -i  $NORDIR/${filename}_norm_tmp.tif -o   $NORDIR/${filename}_norm.tif
gdal_edit.py -a_nodata  -32768      $NORDIR/${filename}_norm.tif

# rm   $NORDIR/${filename}_msk.stat.txt   $NORDIR/${filename}_norm_tmp.tif  $NORDIR/${filename}_msk.tif

' _ 

