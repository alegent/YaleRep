
# attribute of the shapefile land NO-MARINE

#   IUCN_CAT (String) = Ia               11
#   IUCN_CAT (String) = Ib               12
#   IUCN_CAT (String) = II               2
#   IUCN_CAT (String) = III              3
#   IUCN_CAT (String) = IV               4
#   IUCN_CAT (String) = Not Applicable   20
#   IUCN_CAT (String) = Not Reported     21
#   IUCN_CAT (String) = V                5
#   IUCN_CAT (String) = VI               6

geo_string=$( getCorners4Gwarp  /lustre0/scratch/ga254/dem_bj/GFC2013/treecover2000/tif/Hansen_GFC2013_treecover2000_50N_010E.tif  )

cd /lustre0/scratch/ga254/dem_bj/WDPA/shp_input/WDPA_protect_april2014 

# for Integer use marine = '0' 
for  class in Ia  Ib II III IV V VI ; do 
    rm -f WDPA_protect_april2014_IUCN_$class.*

  ogr2ogr    -spat   $geo_string     -sql ' SELECT * FROM  "selvaje-search-1396640206107"  WHERE  (  iucn_cat = "'${class}'"  )  AND (  marine = '0') '    WDPA_protect_april2014_IUCN_$class.shp   selvaje-search-1396640206107.shp 

done 


cd /lustre0/scratch/ga254/dem_bj/WDPA/shp_input/WDPA_Apr2014


# for string use MARINE  = "0" 

for  class in Ia  Ib II III IV V VI ; do 
    rm -f WDPA_Apr2014_IUCN_$class.*

    ogr2ogr    -spat   $geo_string     -sql ' SELECT * FROM  "WDPA_Apr2014"  WHERE  (  IUCN_CAT  = "'${class}'"  )  AND (  MARINE  = "0") '  WDPA_Apr2014_IUCN_$class.shp  WDPA_Apr2014.shp  

done 



