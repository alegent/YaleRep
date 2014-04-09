SHP=/lustre0/scratch/ga254/dem_bj/WDPA/shp_input


ogrinfo -al -geom=NO    -sql   "SELECT * FROM WDPA_point_Jan2014   WHERE   ( MARINE = '0')"   $SHP/WDPA_Jan2014.shp/WDPA_point_Jan2014.shp   | grep OGRFeature | wc -l 
# = 22858

ogrinfo -al -geom=NO    -sql   "SELECT * FROM WDPA_point_Jan2014   WHERE ( REP_AREA > 0 ) AND  ( MARINE = '0')"   $SHP/WDPA_Jan2014.shp/WDPA_point_Jan2014.shp   | grep OGRFeature | wc -l 
# = 15847
ogrinfo -al -geom=NO    -sql   "SELECT * FROM WDPA_point_Jan2014   WHERE ( REP_AREA = 0 ) AND  ( MARINE = '0')"   $SHP/WDPA_Jan2014.shp/WDPA_point_Jan2014.shp   | grep OGRFeature | wc -l 
# = 7011

ogrinfo -al -geom=NO    -sql   "SELECT * FROM WDPA_poly_Jan2014   WHERE   ( MARINE = '0')"   $SHP/WDPA_Jan2014.shp/WDPA_poly_Jan2014.shp   | grep OGRFeature | wc -l 
# = 170017 
