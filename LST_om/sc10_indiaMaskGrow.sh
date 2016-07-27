

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MASK
export RAM=/dev/shm
cd 
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh   /dev/shm loc_IndiaMya_mask /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MASK/IndiaMya_mask.tif

g.region n=33 e=98 w=65
r.buffer  input=IndiaMya_mask  output=IndiaMya_maskB  distances=1 --overwrite

r.out.gdal --overwrite  -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Byte     input=IndiaMya_maskB  output=$INDIR/IndiaMya_maskLarg.tif

exit 

pkgetmask -co COMPRESS=LZW -co ZLEVEL=9    -min -1   -max 102  -data 1 -nodata 0   -i $INDIR/IndiaMya_maskLarg.tif -o   $INDIR/IndiaMya_maskLarg01.tif  

pksetmask  -i  $INDIR/IndiaMya_maskLarg.tif  -m  $INDIR/IndiaMya_maskLarg.tif  -msknodata 1 -nodata -100   -m  $INDIR/IndiaMya_maskLarg.tif  -msknodata 255  -nodata 100   -o $INDIR/IndiaMya_maskLarg_tmp.tif

oft-calc -ot Float32 $INDIR/IndiaMya_maskLarg_tmp.tif    $INDIR/IndiaMya_maskLarg01-1.tif  <<EOF
1
#1 100 - -100 /
EOF


pksetmask  -co COMPRESS=LZW -co ZLEVEL=9  -i  $INDIR/IndiaMya_maskLarg01-1.tif    -m  $INDIR/IndiaMya_maskLarg01-1.tif   -msknodata -0 -nodata 0    -o $INDIR/IndiaMya_maskLargWeight.tif


# portati su nex   $INDIR/IndiaMya_maskLargWeight.tif  $INDIR/IndiaMya_maskLarg01.tif  