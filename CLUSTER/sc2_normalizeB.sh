#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout 
#PBS -e /scratch/fas/sbsc/ga254/stderr

# non funziona con qsub ma si con bash or cp in the terminal
# per arditity index viene mantenuto il Int32 e poi passato a Int16 ...si perdono solo pochi pixel o meglio ci sono solo pochi pixel oltre il 32768

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif
export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask 
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif/aridity_index_crop.tif | xargs -n 1 -P 8 bash -c $'    

file=$1 
filename=`basename $file .tif` 

pksetmask  -ot  Int32  -msknodata 0 -nodata  2147483647  -m   $MSKDIR/mask.tif  -co  COMPRESS=LZW -co ZLEVEL=9  -i  $INDIR/$filename.tif  -o   $NORDIR/${filename}_msk.tif 
gdal_edit.py -a_nodata  2147483647  $NORDIR/${filename}_msk.tif
 
pkinfo    -stats  -i  $NORDIR/${filename}_msk.tif      >     $NORDIR/${filename}_msk.stat.txt  

mean=$(  awk \'{  print $6 }\'     $NORDIR/${filename}_msk.stat.txt    )
stdev=$( awk \'{  print $8 }\'     $NORDIR/${filename}_msk.stat.txt    )

echo start the normalization 

oft-calc -ot Int32  -um $MSKDIR/mask.tif     $NORDIR/${filename}_msk.tif   $NORDIR/${filename}_norm_tmp.tif  >  /dev/null   <<EOF
1
#1 $mean - $stdev / 1000 *
EOF


pksetmask  -ot  Int16   -msknodata 2147483647  -nodata  -32768      -m    $NORDIR/${filename}_msk.tif   -co  COMPRESS=LZW   -co ZLEVEL=9   -i  $NORDIR/${filename}_norm_tmp.tif -o   $NORDIR/${filename}_norm.tif
gdal_edit.py -a_nodata  -32768      $NORDIR/${filename}_norm.tif

rm   $NORDIR/${filename}_msk.stat.txt   $NORDIR/${filename}_norm_tmp.tif  $NORDIR/${filename}_msk.tif

' _ 

