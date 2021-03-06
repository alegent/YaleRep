cd /mnt/data2/scratch/GMTED2010/solar_radiation/nrel

echo '"X","Y","CODE"' > /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.csv
awk -F ","  '{ if (NR>1) print $5","$4","$1 }' /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv/TMY3_StationsMeta.csv >>  /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.csv

echo "<OGRVRTDataSource>" > /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt
echo "    <OGRVRTLayer name=\"point\">" >>  /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt
echo "        <SrcDataSource>/mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.csv</SrcDataSource>"  >> /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt
echo "	      <GeometryType>wkbPoint</GeometryType>"  >> /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt
echo "	      <GeometryField encoding=\"PointFromColumns\" x=\"X\" y=\"Y\" z=\"CODE\" /> "  >>  /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt
echo "    </OGRVRTLayer>"  >>  /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt
echo "</OGRVRTDataSource>"  >>  /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt

rm -f /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.shp
ogr2ogr /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.shp  /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/shp/point.vrt

