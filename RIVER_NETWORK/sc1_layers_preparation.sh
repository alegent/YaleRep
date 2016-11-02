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


# spostato su GSHH script
rm -f   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp_continent/continent*.shp  
for ID in  0-W 0-E 1 2 3 4 5 6 7 8 9 10 ; do 

#  1 = africa 
# 

echo start ogr ID$ID
ogr2ogr    -where  " id = '$ID' "  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp_continent/continent$ID.shp        /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/version2.3.5-1/GSHHS_shp/f/GSHHS_f_L1.shp
done 




# enlarge of 4 pixels the rasterize cost line and use it to mask out the ocean in the dem 

# source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb loc_Cost /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m_merge/land_mask250m.tif
# r.grow  input=land_mask250m   output=land_mask250m_enlarge  radius=4.01
# r.out.gdal  --overwrite -f  -c  createopt="COMPRESS=LZW,BIGTIFF=YES" format=GTiff type=Byte  input=land_mask250m_enlarge  output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/land_mask250m_enlarge.tif 

# xmin,ymin,xmax,ymax  is 0 3055 172799 76283 /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/land_mask250m_enlarge.tif 
# crop sulla base dei valor precedenti e tolto l'artico 
# gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin -180 +84 +180 -60  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/land_mask250m_enlarge.tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/land_mask250m_enlarge_cropto1.tif

pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9 -nodata -9999   -msknodata 0  -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/land_mask250m_enlarge_cropto1.tif  -nodata -9999   -msknodata -32768  -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/be75_grd.tif   -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/be75_grd.tif -o  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/be75_grd_Land.tif  


 
