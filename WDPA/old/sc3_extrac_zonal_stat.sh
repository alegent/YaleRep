
# abbadonato per ora perche il .py non funzionava nel hpc

# calculate area for each cell 

TIF_GRID=/lustre0/scratch/ga254/dem_bj/WDPA/tif_grid
OUTDIR=/lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat



# calcuate area for ecah cell in a specific IUCN class 

echo 102  103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6 | xargs -n 1 -P 18 bash -c $' 

TIF_GRID=/lustre0/scratch/ga254/dem_bj/WDPA/tif_grid
OUTDIR=/lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat
IUCN=$1
ulx=-180
uly=$(getCorners4Gtranslate /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/$IUCN/IUCN$IUCN.tif | awk \'{print $2}\')
lrx=+180
lry=$(getCorners4Gtranslate /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/$IUCN/IUCN$IUCN.tif | awk \'{print $4}\')

# gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   -projwin  $ulx $uly $lrx $lry  $TIF_GRID/360x114globalID.tif  $TIF_GRID/360x114globalIDclip$IUCN.tif
# gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   -projwin  $ulx $uly $lrx $lry  /lustre0/scratch/ga254/dem_bj/GEO_AREA/area_tif/30arc-sec-Area_prj6974.tif    $TIF_GRID/30arc-sec-Area_prj6974clip$IUCN.tif


# pksetmask  -co COMPRESS=LZW -co ZLEVEL=9   -i $TIF_GRID/360x114globalIDclip$IUCN.tif -m /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/$IUCN/IUCN$IUCN.tif -msknodata 0 -nodata 0 -o $TIF_GRID/360x114globalID$IUCN.tif

echo ost4sem_zonal_stats.py  -category_no_data 0 -raster_no_data 0 -sum $TIF_GRID/360x114globalID$IUCN.tif  $TIF_GRID/30arc-sec-Area_prj6974clip$IUCN.tif  $OUTDIR/${IUCN}_stat-py.txt

' _ 


# calculate the area for each class 

echo 102  103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6 | xargs -n 1 -P 18 bash -c $' 

INDIR=/lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat
IUCN=$1
awk \'{ print $1 , int ($2*$3 )  }\' $INDIR/${IUCN}_stat.txt  >  $INDIR/${IUCN}_stat_sum.txt 

' _


# calculate the area for each cell 
INDIR=/lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat
oft-stat  -nostd  -i /lustre0/scratch/ga254/dem_bj/WDPA/tif_grid/30arc-sec-Area_prj6974clip20.tif    -o $OUTDIR/ID_area_stat.txt   -um $TIF_GRID/360x114globalID.tif 
awk '{ print $1 , int ($2*$3 )  }' $INDIR/ID_area_stat.txt >   $INDIR/ID_area_sum.txt 



# join and calculate the percentage 

echo 102  103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6 | xargs -n 1 -P 18 bash -c $' 

INDIR=/lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat
IUCN=$1

echo join 
join -1 1 -2 1 -a 1   <(sort -k 1,1  $INDIR/ID_area_sum.txt)   <(sort -k 1,1 $INDIR/${IUCN}_stat_sum.txt) >  $INDIR/${IUCN}_stat_sum_j.txt
echo perc
awk \'{  if (NF==3) {print $1 , (100/$2)*$3 } else { print $1 , "0" }   }\'  $INDIR/${IUCN}_stat_sum_j.txt >  $INDIR/${IUCN}_stat_perc.txt

' _ 


INDIR=/lustre0/scratch/ga254/dem_bj/WDPA
rm -f /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global_join.*
ogr2ogr  $INDIR/shp_grid/360x114global/360x114global_join.shp  $INDIR/shp_grid/360x114global/360x114global.shp

INDIR=/lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat
for  IUCN in  102  103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6 ; do 
    oft-addattr-new.py /lustre0/scratch/ga254/dem_bj/WDPA/shp_grid/360x114global/360x114global_join.shp ID IUCN${IUCN} Int $INDIR/${IUCN}_stat_perc.txt 0 
done 


# create tif file 



echo 102  103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6 | xargs -n 1 -P 18 bash  -c  $' 
IUCN=$1
pkreclass  -co COMPRESS=LZW -co ZLEVEL=9 -ot Byte  -msknodata 0 -nodata 0 -code /lustre0/scratch/ga254/dem_bj/WDPA/txt_oft-stat/${IUCN}_stat_perc.txt   -i    /lustre0/scratch/ga254/dem_bj/WDPA/tif_grid/360x114globalID${IUCN}.tif  -o  /lustre0/scratch/ga254/dem_bj/WDPA/tif_grid/perc$IUCN.tif

' _








