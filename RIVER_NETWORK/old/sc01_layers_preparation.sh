#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


#  GMTED preparation 
# gdalbuildvrt -overwrite   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/be75_grd.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/?_?.tif 
# gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin -180  84  +180 -60 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/be75_grd.vrt    /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/be75_grd.tif  

# MODIS MASK preparation 
# gdalbuildvrt -tr 0.0020833333333 0.0020833333333  -te -180 -60 +180 +84   -overwrite   /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/tiles/modis_water.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/tiles/*.tif  
# gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9   -projwin  -180  84  +180  -60   -ot Byte  /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/tiles/modis_water.vrt    /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/tiles/modis_water.tif 
# gdal_edit.py   -a_ullr  -180 84  -180 -60 /lustre/scratch/client/fas/sbsc/ga254/dataproces/MOD44W/tiles/modis_water.tif 

# GSHHS_tif_250m.tif  = land_mask250m.tif 

#  cost line 
#  create continental feature for and use it as mask 

# gdalbuildvrt -overwrite    /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m/GSHHS_tif_250m.vrt    /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m/h??v??_250m.tif 
# gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m/GSHHS_tif_250m.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m/GSHHS_tif_250m.tif 


# ogr2ogr   -f CSV  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp_continent/out.csv /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/version2.3.5-1/GSHHS_shp/f/GSHHS_f_L1.shp 
 
#  cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp_continent/out.csv | tr "," " "  >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp_continent/out.txt 

# sort -g -k 6,6  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp_continent/out.txt | tail 




 
