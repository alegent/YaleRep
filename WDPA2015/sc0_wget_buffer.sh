get the shp
data preparation 1 buffer in qgis fast and easy 

cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/shp_input/

wget  http://d1gam3xoknrgr2.cloudfront.net/current/WDPA_Sept2015-shapefile.zip 

unzip WDPA_Sept2015-shapefile.zip

cd WDPA_Sept2015-shapefile

rm    WDPASept2015ShapefilePoints.*

ogr2ogr   -t_srs  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/prj/6974.prj   WDPASept2015ShapefilePoints_prj6974.shp   WDPA_Sept2015-shapefile-points.shp

ogrinfo -al  -geom=no  WDPASept2015ShapefilePoints_prj6974.shp  | grep WDPAID  | awk '{ print $4   }'  | sort  > point_WDPAID.txt

ogrinfo -al  -geom=no   WDPASept2015ShapefilePoints_prj6974.shp  | grep -e   WDPAID -e REP_AREA   |  awk '{  if($1=="REP_AREA") { printf("%s\n", $4) }  else {  printf("%s ", $4) }}'  >   point_WDPAID_REP_AREA.txt
awk '{  if ($2==0) { print $1 ,  544 } else {print $1 , sqrt($2/3.14)*1000 } }'  point_WDPAID_REP_AREA.txt  > point_WDPAID_BUFm.txt

oft-addattr-new.py   WDPASept2015ShapefilePoints_prj6974.shp   WDPAID  distance Float  point_WDPAID_BUFm.txt 

# send to WDPASept2015ShapefilePoints_prj6974.shp  and to the buffer with qgis obtaining   WDPASept2015ShapefilePoints_prj6974_buf.shp
# scp  ga254@omega.hpc.yale.edu:/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/shp_input/WDPASept2015ShapefilePoints_prj6974.* .

# rasterize poly and  buf 

ogr2ogr  -t_srs EPSG:4326  -sql "SELECT WDPAID  FROM WDPASept2015ShapefilePoints_prj6974_buf"  buff.shp  WDPASept2015ShapefilePoints_prj6974_buf.shp
ogr2ogr poly_tmp.shp  WDPA_Sept2015-shapefile-polygons.shp  # i trattini davano errore quind copiato il file 

ogr2ogr -sql "SELECT WDPAID  FROM poly_tmp  "   poly.shp  poly_tmp.shp 
rm -f poly_tmp.*

ogr2ogr -update -append  poly.shp  buff.shp 

rm -f buff.*

ogrinfo -al  -geom=no  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/shp_input/poly.shp   | grep "WDPAID " | awk ' { print $4}' > /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tables/WDPAID.txt

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tables

awk  ' {  print int(NR/10000), $1 } ' WDPAID.txt  > Blkid_WDPAID.txt
awk  ' {  print  $2  >  "Blkid"$1"_WDPAID.txt"   }'  Blkid_WDPAID.txt
rm Blkid_WDPAID.txt

total 217839 WDPAID.txt 

