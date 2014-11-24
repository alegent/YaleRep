cd  /home/selv/geo_area 
# create a tif whith one column 

# una colonna di numeri 
echo "ncols        1"                   > GMTED2010_30arc-sec-IDcol.asc
echo "nrows        16800"              >> GMTED2010_30arc-sec-IDcol.asc
echo "xllcorner    -180"  >> GMTED2010_30arc-sec-IDcol.asc
echo "yllcorner    -56"   >> GMTED2010_30arc-sec-IDcol.asc
echo "cellsize     0.008333333333"     >> GMTED2010_30arc-sec-IDcol.asc

awk ' BEGIN {  
for (row=1 ; row<=16800 ; row++)  { 
     for (col=1 ; col<=1 ; col++) { 
         printf ("%i " ,  col+(row-1)*1  ) } ; printf ("\n")  }}' >> GMTED2010_30arc-sec-IDcol.asc

gdal_translate -ot UInt16   GMTED2010_30arc-sec-IDcol.asc    GMTED2010_30arc-sec-IDcol.tif 

gdalwarp -overwrite -t_srs GMTED2010_30arc-sec.prj GMTED2010_30arc-sec-IDcol.tif GMTED2010_30arc-sec-IDcol-proj.tif


rm classID_area.txt

for n in `seq 1 2` ; do 

pkgetmask  -ot  Byte -min $n  -max $n -t 1   -f  0     -i  GMTED2010_30arc-sec-IDcol-proj.tif  -o  GMTED2010_30arc-sec-IDcol-proj_$n.tif

rm  -f GMTED2010_30arc-sec-IDcol-proj_$n.{shp,dbf,prj,shx}

gdal_polygonize.py   -f  "ESRI Shapefile"  GMTED2010_30arc-sec-IDcol-proj_$n.tif  GMTED2010_30arc-sec-IDcol-proj_$n.shp

rm -f poly_$n.*

ogr2ogr  -where "DN = 1"  poly_$n.shp   GMTED2010_30arc-sec-IDcol-proj_$n.shp  

rm -f GMTED2010_30arc-sec-IDcol-proj_$n.shp



export n=$n

R --vanilla -q <<EOF

library (geosphere)
library (rgdal)
n=Sys.getenv('n')


print (n)

library(geosphere)

poly =  readOGR(paste("poly_",n,".shp",sep="") , paste("poly_",n,sep="")  )
areaPolygon(poly)
write.table (areaPolygon(poly)[1] ,paste("area_",n,".txt",sep="" ) ,row.names = F , col.names = F)

EOF

n_file=`expr $n + 5` 

echo  $(awk  -v n_file=$n_file '{ if (NR==n_file)  print }' GMTED2010_30arc-sec-IDcol.asc) $(cat area_$n.txt) >> classID_area.txt

echo  area_$n.txt rm poly_$n.*  

done 

