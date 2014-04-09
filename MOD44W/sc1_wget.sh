cd /lustre0/scratch/ga254/dem_bj/MOD44W/gz


wget -m -A .gz   ftp://ftp.glcf.umd.edu/modis/WaterMask/Collection_5/2000/
mv  ftp.glcf.umd.edu/modis/WaterMask/Collection_5/2000/*/*.tif.gz  .
rm -r ftp.glcf.umd.edu 

ls *.gz | xargs -n 1 -P 40 bash -c $' 
gunzip $1  
filename=`basename $1 .gz`
mv /lustre0/scratch/ga254/dem_bj/MOD44W/gz/$filename /lustre0/scratch/ga254/dem_bj/MOD44W/tiles 
' _

