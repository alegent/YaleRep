# download zip from 
# http://sedac.ciesin.columbia.edu/data/set/gpw-v3-population-density-future-estimates/data-download 
cd /mnt/data/jetzlab/Data/environ/global/population/gpw 

ls gl_gpw*_pdens_*_bil_25.zip | xargs -n 1 -P 6 unzip $1 
ls gld*.bil                   | xargs -n 1 -P 6 bash -c ' filename=`basename $1 .bil`  ; gdal_translate -co COMPRESS=LZW    $1 $filename.tif ' _
rm *.bil   *.blw  *.hdr  *.stx


/mnt/data/jetzlab/Data/environ/global/population/grump 
ls gl_grumpv1_pdens_*_bil_30.zip | xargs -n 1 -P 3 unzip $1 
ls gluds*.bil   | xargs -n 1 -P 6  bash -c ' filename=`basename $1 .bil`  ; gdal_translate -co COMPRESS=LZW    $1 $filename.tif ' _
rm *.bil  *.bil.aux.xml  *.bil.xml *.hdr *.prj  *.stx 

rm  GlobalRuralUrbanMappingProjectVersion1GRUMPv1PopulationDensityGrid.html  
rm  GlobalRuralUrbanMappingProjectVersion1GRUMPv1PopulationDensityGrid.xml 

