
# using the shape file extract information from the month data radiation and also for the month cloud 


export INTIF=/mnt/data2/scratch/GMTED2010/grassdb/glob_rad/months_merge  
export SHPIN=/mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp
export SHPOUT=/mnt/data2/scratch/GMTED2010/grassdb/shp
export INNC=/mnt/data2/scratch/GMTED2010/cloud/nc

rm  -f $SHPOUT/point_extract_rad.shp  
pkextract -i  $INTIF/glob_rad_months2.tif  -ft Integer  -lt  String -bn OBSRAD  -s   $SHPIN/point.shp  -o $SHPOUT/point_extract_rad.shp  
rm -f $SHPOUT/point_extract_rad_cloud.shp  
pkextract -i  $INNC/cloud_ymonmean.nc  -ft Integer   -lt  String   -bn CLOUD  -s   $SHPOUT/point_extract_rad.shp    -o $SHPOUT/point_extract_rad_cloud.shp  


