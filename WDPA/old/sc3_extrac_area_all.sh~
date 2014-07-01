
# extract the area for each cell 

rm -f /lustre0/scratch/ga254/dem_bj/WDPA/shp_out/360x114global_areaPrj6974.*
pkextract  -i  /lustre0/scratch/ga254/dem_bj/GEO_AREA/area_tif/30arc-sec-Area_prj6974.tif \
-l  -r sum  -bn AREAp6974  -lt String  -s /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global.shp \
-o /lustre0/scratch/ga254/dem_bj/WDPA/shp_out/360x114global_areaPrj6974.shp


rm -f /lustre0/scratch/ga254/dem_bj/WDPA/shp_out/360x114globalIUCN*.*


# extract the area for each cell  useing as a mask the different IUCN classes 

echo   103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6 | xargs -n 1 -P 8 bash -c $' 

dir=$1
rm -f /lustre0/scratch/ga254/dem_bj/WDPA/shp_out/360x114globalIUCN$dir.*

pkextract  -m  /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/$dir/IUCN*.tif -msknodata  0 -i  /lustre0/scratch/ga254/dem_bj/GEO_AREA/area_tif/30arc-sec-Area_prj6974.tif  -l  -r sum  -bn IUCN$dir  -lt String  -s /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global.shp -o /lustre0/scratch/ga254/dem_bj/WDPA/shp_out/360x114globalIUCN$dir.shp

' _ 


# dir=103 
# pkextract  -m  /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/$dir/IUCN*.tif -msknodata  0 -i  /lustre0/scratch/ga254/dem_bj/GEO_AREA/area_tif/30arc-sec-Area_prj6974.tif  -l  -r sum  -bn IUCN$dir  -lt String  -s /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114globalID.tif  -o /lustre0/scratch/ga254/dem_bj/WDPA/shp_out/test.shp





