
# select area for artifact 

for dir in slope altitude tpi tri vrm roughness  ; do 
    gdalbuildvrt -overwrite  out.vrt   -te  -106 29 -104.4 31.1  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/${dir}/tiles/tiles_84000_24000.tif /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/${dir}/tiles/tiles_84000_36000.tif   
    gdal_translate   out.vrt /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/figures/Fig10/${dir}_artifact.tif 
done 

rm out.vrt 


