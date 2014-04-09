cd /lustre0/scratch/ga254/dem_bj/SOLAR/validation/uoregon


for file in MonthCUM/*.txt ; do  filename=`basename $file .txt ` ; echo  $(grep Longitude $file  | awk '{ if (NR==1) print $5  }') $(grep Latitude  $file  | awk '{ if (NR==1) print $2  }' )  ${filename:0:4 }    ; done | uniq  > geo_file/x_y_code.txt 


echo '"X","Y","CODE"' > geo_file/point_uoregon.csv
awk   '{ print -$1","$2","$3 }' geo_file/x_y_code.txt   >>  geo_file/point_uoregon.csv

echo "<OGRVRTDataSource>" > geo_file/point_uoregon.vrt
echo "    <OGRVRTLayer name=\"point_uoregon\">" >>  geo_file/point_uoregon.vrt
echo "        <SrcDataSource>geo_file/point_uoregon.csv</SrcDataSource>"  >> geo_file/point_uoregon.vrt 
echo "	      <GeometryType>wkbPoint</GeometryType>"  >> geo_file/point_uoregon.vrt 
echo "	      <GeometryField encoding=\"PointFromColumns\" x=\"X\" y=\"Y\" z=\"CODE\" /> "  >> geo_file/point_uoregon.vrt 
echo "    </OGRVRTLayer>"  >>  geo_file/point_uoregon.vrt 
echo "</OGRVRTDataSource>"  >> geo_file/point_uoregon.vrt 

rm -f shp/point_uoregon.shp
ogr2ogr shp/point_uoregon.shp geo_file/point_uoregon.vrt 

