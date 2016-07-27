

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MASK
export RAM=/dev/shm
cd 

# gdal_rasterize -co COMPRESS=LZW  -l patagonia -a id -tr 0.008333333333333 0.008333333333333 -te -180 -90 180 90   patagonia.shp patagonia_mask.tif
gdal_edit.py  -a_nodata  0  /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MASK/patagonia_mask.tif

echo start grass 
rm -r /dev/shm/loc_Pat_mask 
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh   /dev/shm loc_Pat_mask /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MASK/patagonia_mask.tif


r.buffer   input=patagonia_mask   output=patagonia_maskB   --overwrite distances=$(seq -s , 1 100)  units=kilometers 

r.report map=patagonia_maskB  units=c
r.out.gdal --overwrite   -c     createopt="COMPRESS=LZW" format=GTiff    input=patagonia_maskB  output=$INDIR/patagonia_maskLarg.tif

 

pkgetmask -co COMPRESS=LZW -co ZLEVEL=9 -min -1 -max 102 -data 1 -nodata 0 -i $INDIR/patagonia_maskLarg.tif -o   $INDIR/patagonia_maskLarg01.tif  

pksetmask  -i  $INDIR/patagonia_maskLarg.tif  -m  $INDIR/patagonia_maskLarg.tif  -msknodata 1 -nodata -100   -m  $INDIR/patagonia_maskLarg.tif  -msknodata 255  -nodata 100   -o $INDIR/patagonia_maskLarg_tmp.tif

oft-calc -ot Float32 $INDIR/patagonia_maskLarg_tmp.tif    $INDIR/patagonia_maskLarg01-1.tif  <<EOF
1
#1 100 - -100 /
EOF


pksetmask  -co COMPRESS=LZW -co ZLEVEL=9  -i  $INDIR/patagonia_maskLarg01-1.tif    -m  $INDIR/patagonia_maskLarg01-1.tif   -msknodata -0 -nodata 0    -o $INDIR/patagonia_maskLargWeight.tif


# portati su nex   $INDIR/patagonia_maskLargWeight.tif  $INDIR/patagonia_maskLarg01.tif  