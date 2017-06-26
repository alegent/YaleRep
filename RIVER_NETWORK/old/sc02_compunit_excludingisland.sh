
#  bsub -W 24:00  -n 1  -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc02_compunit.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc02_compunit.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc02_compunit.sh

# 1 kg di farena
# 300 lievito madre
# 1 cucchiaino di sale 
# 5 chcchiaio di zucchero 
# 250 olio 
# impastare con il vino 

DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/GSHHG
RAM=/dev/shm/
# # enlarge of 4 pixels the rasterize cost line and use it to mask out the ocean in the dem 

oft-stat -i $DIR/../dem/be75_grd_LandEnlarge.tif  -o  $DIR/GSHHS_land_mask250m_enlarge_clump_hist_GMTED.txt  -um $DIR/GSHHS_land_mask250m_enlarge_clump.tif 

## rmoeve small cell < 64  cell and  flat areas 
awk '{ if( $2 <= 64 ||  $3==0 || $3==-9999 || $4==0 ) {  print $1 , 0 } else { print $1 , $1 }  }'   $DIR/GSHHS_land_mask250m_enlarge_clump_hist_GMTED.txt  >   $DIR/GSHHS_land_mask250m_enlarge_clump_hist_GMTEDreclass.txt

pkreclass  -co COMPRESS=DEFLATE -co ZLEVEL=9  -code  $DIR/GSHHS_land_mask250m_enlarge_clump_hist_GMTEDreclass.txt  -i $DIR/GSHHS_land_mask250m_enlarge_clump.tif -o $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT.tif 

pkstat --hist -i  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT.tif  | grep  -v " 0" > $DIR/GSHHS_land_mask250m_enlarge_clump_UNIThist.txt

awk '{  print $1 , NR-1    }'    $DIR/GSHHS_land_mask250m_enlarge_clump_UNIThist.txt  >  $DIR/GSHHS_land_mask250m_enlarge_clump_UNITreclass2.txt

pkreclass -co COMPRESS=DEFLATE -co ZLEVEL=9 -code $DIR/GSHHS_land_mask250m_enlarge_clump_UNITreclass2.txt  -i $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT.tif -o $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2.tif   

# split the in 2 to create better visualize in qgis 

gdal_translate -projwin -84 +14 -32 -60  -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2.tif  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2w.tif
gdal_translate -projwin -19 +40 +53 -36  -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2.tif  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2e.tif

# 98339 america north and south  
# 91514 africa eurasia 
# max value 

pkstat --hist -i  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump.tif | sort -g -k 2,2 | tail -3 > /tmp/hist.txt 

NSAMERICAUNIT=$( awk '{ if(NR==1) print $1 }' )
AFRICAASIAUNIT=$( awk '{ if(NR==2) print $1 }' )

# africa 
rm  -f $DIR/suez.*
ogr2ogr  -clipsrc 31 27 36 32  $DIR/../shp/suez.shp  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/GSHHG/version2.3.5-1/GSHHS_shp/f/GSHHS_f_L1.shp 
# create the africa.shp in qgis 

gdal_rasterize -ot Byte -te -180 -60 +180 +84 -tr 0.002083333333333333 0.002083333333333333 -co COMPRESS=DEFLATE -co ZLEVEL=9   -burn 1 -l "africa"   $DIR/../shp/africa.shp     $DIR/../shp/africa.tif   
pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte  -min $( echo $AFRICAASIAUNIT - 0.5 | bc )    -max  $( echo $AFRICAASIAUNIT - 0.5 | bc   )    -data 1  -nodata 0  -i  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2.tif -o  $DIR/africaeuroasia.tif 

pkcreatect -min 0 -max 1 > /dev/shm/color.txt 
pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /dev/shm/color.txt -i   $DIR/africaeuroasia.tif -o   $DIR/africaeuroasia_ct.tif

gdalbuildvrt -separate -overwrite  $DIR/outvrt.vrt      $DIR/africaeuroasia.tif  $DIR/../shp/africa.tif

oft-calc  -ot Byte $DIR/outvrt.vrt   $DIR/SUMafricaeuroasia.tif <<EOF
1
#1 #2 +
EOF

pkcreatect -min 0 -max 2 > /dev/shm/color.txt 
pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /dev/shm/color.txt -i $DIR/SUMafricaeuroasia.tif -o $DIR/SUMafricaeuroasia_ct.tif ; 
pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte  -min 2  -max 3   -data 1   -nodata 0    -i  $DIR/SUMafricaeuroasia.tif -o $DIR/africa_clean.tif 
pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /dev/shm/color.txt -i  $DIR/africa_clean.tif -o  $DIR/africa_clean_ct.tif 

rm -f   $DIR/SUMafricaeuroasia.tif   $DIR/SUMafricaeuroasia_ct.tif  $DIR/africa_clean.tif   $DIR/africaeuroasia.tif   $DIR/africaeuroasia_ct.tif $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2e.tif

# euroasia 
rm -f  $DIR/../shp/panama.shp 
ogr2ogr -clipsrc   -82 +5  -73 13    $DIR/../shp/panama.shp   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/GSHHG/version2.3.5-1/GSHHS_shp/f/GSHHS_f_L1.shp 
# create the africa.shp in qgis 

gdal_rasterize -ot Byte -te -180 -60 +180 +84 -tr 0.002083333333333333 0.002083333333333333 -co COMPRESS=DEFLATE -co ZLEVEL=9   -burn 1 -l "southamerica"   $DIR/../shp/southamerica.shp     $DIR/../shp/southamerica.tif   

pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte  -min  $( echo $AFRICAASIAUNIT - 0.5 | bc )    -max  $( echo $AFRICAASIAUNIT + 0.5 | bc )   -data 1 -nodata 0 -i  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2.tif -o  $DIR/northsoutamerica.tif 
pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /dev/shm/color.txt -i $DIR/northsoutamerica.tif  -o $DIR/northsoutamerica_ct.tif   

gdalbuildvrt -separate -overwrite  $DIR/outvrt.vrt    $DIR/northsoutamerica.tif   $DIR/../shp/southamerica.tif   

oft-calc  -ot Byte $DIR/outvrt.vrt   $DIR/SUMnorthsoutamerica.tif <<EOF
1
#1 #2 +
EOF

pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /dev/shm/color.txt -i  $DIR/SUMnorthsoutamerica.tif  -o  $DIR/SUMnorthsoutamerica_ct.tif 
pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte  -min 2  -max 3   -data 1   -nodata 0    -i   $DIR/SUMnorthsoutamerica_ct.tif   -o  $DIR/southamerica_clean.tif  
pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /dev/shm/color.txt -i   $DIR/southamerica_clean.tif   -o   $DIR/southamerica_clean_ct.tif  

rm -f $DIR/SUMnorthsoutamerica.tif  $DIR/SUMnorthsoutamerica_ct.tif   $DIR/southamerica_clean.tif   $DIR/southamerica.tif  $DIR/northsoutamerica.tif  $DIR/northsoutamerica_ct.tif   $DIR/outvrt.vrt $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT2w.tif

pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9 \
           -m  $DIR/southamerica_clean_ct.tif  -msknodata 1  -nodata 11000 \
           -m  $DIR/africa_clean_ct.tif        -msknodata 1  -nodata 11001 \
           -i  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT.tif  -o  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif

pkstat --hist -i  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif   | grep  -v " 0" >   $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.txt 

sort -k 2,2 -g /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3.txt  >   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3_s.txt

create island dataset 

head -10449  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_s.txt  | awk '{  print $1 , $1 }'     >  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_island_tmp.txt
tail -13     $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_s.txt  | awk '{  print $1 , 0 }'      >> $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_island_tmp.txt
awk '{ if($1==19899) { print $1 , 0  }  else {  print $1 , $2 } }'     $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_island_tmp.txt >    $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_island.txt  # camptacha 
rm     $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_island_tmp.txt    

pkreclass -co COMPRESS=DEFLATE -co ZLEVEL=9 -code $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3_island.txt  -i   $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif -o  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3island.tif
# set all the island  ugula to 1
pkgetmask   -co COMPRESS=DEFLATE -co ZLEVEL=9   -ot Byte   -min 0.5   -max  999999999  -data 255   -i $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3island.tif  -o $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3island0-1.tif 

# # create the island_areas in qgis 
export DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK
gdal_rasterize -ot Byte -te -180 -60 +180 +84 -tr 0.002083333333333333 0.002083333333333333 -co COMPRESS=DEFLATE -co ZLEVEL=9 -a id -l island_areas $DIR/shp/island_areas.shp $DIR/shp/island_areas.tif 

pkcreatect -min 1 -max 12 >  /dev/shm/color.txt 
pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct   /dev/shm/color.txt   -i $DIR/shp/island_areas.tif  -o  $DIR/shp/island_areas_ct.tif  ;

echo 1 2 3 4 5 6 7 8 9 10 11 12 13 14  | xargs -n 1 -P 14  bash -c  $' 

geo_string=$(oft-bb  $DIR/shp/island_areas_ct.tif $1 | grep BB | awk \'{ print $6,$7,$8-$6,$9-$7 }\') 
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -srcwin $geo_string  $DIR/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3island0-1.tif /dev/shm/GSHHS_land_mask250m_enlarge_clump_UNIT$1.tif  
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -srcwin $geo_string  $DIR/shp/island_areas_ct.tif  /dev/shm/island_areas_ct$1.tif

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot Byte -m /dev/shm/island_areas_ct$1.tif  -msknodata $1  -nodata 0 -p "!" -i /dev/shm/GSHHS_land_mask250m_enlarge_clump_UNIT$1.tif   -o     $DIR/unit/UNIT${1}msk.tif  

' _ 

cleanram

