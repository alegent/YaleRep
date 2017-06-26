

# create also for streamOrde = 0 


ogrinfo -where "StreamOrde = 0"   -al NHDFlowline_wgs84.shp | grep LINESTRING  | awk  '{ gsub("[,]" , " ")  ; print $(NF-2) "a" $(NF -1)   }' | sort  > xy_point_end.txt
ogrinfo -where "StreamOrde = 0"   -al NHDFlowline_wgs84.shp | grep LINESTRING  | awk  '{ gsub("[(]" , "" )  ; print $3 "a"  $4   }'           | sort  > xy_point_start.txt 
join -1 1 -2 1 -v 1   xy_point_start.txt xy_point_end.txt | tr "a" " " > xy_point_start0stOrder.txt

pkascii2ogr -i xy_point_start0stOrder.txt  -o  xy_point_start0stOrder.shp


ogrinfo -where "StreamOrde = 1"   -al NHDFlowline_wgs84.shp | grep LINESTRING  | awk  '{ gsub("[,]" , " ")  ; print $(NF-2) "a" $(NF -1)   }' | sort  > xy_point_end.txt
ogrinfo -where "StreamOrde = 1"   -al NHDFlowline_wgs84.shp | grep LINESTRING  | awk  '{ gsub("[(]" , "" )  ; print $3 "a"  $4   }'           | sort  > xy_point_start.txt 
join -1 1 -2 1 -v 1   xy_point_start.txt xy_point_end.txt | tr "a" " " > xy_point_start1stOrder.txt

pkascii2ogr -i xy_point_start1stOrder.txt  -o  xy_point_start1stOrder.shp
