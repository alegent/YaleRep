cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/gz


wget -m -A .gz   ftp://ftp.glcf.umd.edu/modis/WaterMask/Collection_5/2000/
mv  ftp.glcf.umd.edu/modis/WaterMask/Collection_5/2000/*/*.tif.gz  .
rm -r ftp.glcf.umd.edu 

ls *.gz | xargs -n 1 -P 40 bash -c $' 
gunzip $1  
filename=`basename $1 .gz`
mv   /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/gz/$filename  /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/tiles 

' _

# effetture il a mano wget ftp://ftp.glcf.umd.edu/modis/WaterMask/Collection_5/2000/MOD44W_Water_2000_VU2728/MOD44W_Water_2000_VU2728.tif.gz
