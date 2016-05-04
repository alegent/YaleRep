
INDIR=/mnt/data/jetzlab/Data/environ/global/intersection/input
OUTDIR=/mnt/data/jetzlab/Data/environ/global/intersection/output

echo "ID HBWID" >  $INDIR/../geo_file/ID_geo.txt 
ogrinfo -al -geom=no $INDIR/360x114global/360x114global.shp | grep -e " ID " -e "HBWID " |  awk -v ID=$ID '{  if ($1=="HBWID") { printf("%s\n", $4)}  else {  printf("%s ", $4) }}'  >> $INDIR/../geo_file/ID_geo.txt 


cut -d " "   -f 1  $INDIR/../geo_file/ID_geo.txt | xargs -n 1 -P 40  bash -c $' 
    ID=$1
    INDIR=/mnt/data/jetzlab/Data/environ/global/intersection/input
    OUTDIR=/mnt/data/jetzlab/Data/environ/global/intersection/output
    rm -f $OUTDIR/ID_shp/ID_$ID.* 
    # crete a cell_ID shapefile 
    ogr2ogr  -where "ID=$ID"  $OUTDIR/ID_shp/ID_$ID.shp   $INDIR/360x114global/360x114global.shp 
    ogrinfo -al -so  $OUTDIR/ID_shp/ID_$ID.shp | grep Exten | awk -v ID=$ID \'{ gsub ("[(,)]" ," ")   ;  print ID , $2,$3,$5 ,$6  }\' > $OUTDIR/ID_shp/ID_${ID}_geo.txt
' _ 

echo "ID xmin ymin xmax ymax"  > $INDIR/../geo_file/ID_geo_coor.txt 
cat $OUTDIR/ID_shp/ID_*_geo.tx >> $INDIR/../geo_file/ID_geo_coor.txt 


awk '{ if (NR>1) print }' $INDIR/../geo_file/ID_geo_coor.txt

head $OUTDIR/ID_shp/ID_1136_geo.txt   | xargs -n 5 -P 1  bash -c $' 

    INDIR=/mnt/data/jetzlab/Data/environ/global/intersection/input
    OUTDIR=/mnt/data/jetzlab/Data/environ/global/intersection/output

    ID=$1
    xmin=$2
    ymin=$3
    xmax=$4
    ymax=$5
    rm -f GADM_clip/GADM_clip_ID$ID.*
    echo clip the GADM_islands_join_names.shp  based on the coordinates of the tile 
    rm -f $OUTDIR/GADM_clip/GADM_clip_ID$ID.*
    ogr2ogr -clipsrc $xmin $ymin $xmax $ymax  $OUTDIR/GADM_clip/GADM_clip_ID$ID.shp $INDIR/GADM_islands_Weigelt_etal/GADM_islands_join_names.shp 
    echo  check if the cliped shp  is empty or not 
    geo_string_shp=$(ogrinfo -al -so $OUTDIR/GADM_clip/GADM_clip_ID$ID.shp | grep Exten | awk \'{ gsub ("[(,)]" ," ") ;  print int($2+$3+$5+$6)}\')
    check_geo_string_shp=`echo "$geo_string_shp != 0" | bc`
    if [ $check_geo_string_shp  -eq 1  ] ; then
	addattr-area.py $OUTDIR/GADM_clip/GADM_clip_ID$ID.shp  Area 
	ogrinfo -al -geom=NO $OUTDIR/GADM_clip/GADM_clip_ID$ID.shp | grep  -e "ulm_ID " -e "Area " | awk -v ID=$ID \'{ if ($1=="Area") { printf("%s\\n", $4)}  else {  printf("%s %s ", ID , $4) }}\' > $OUTDIR/GADM_clip/GADM_clip_ID$ID.txt
    else 
    rm $OUTDIR/GADM_clip/GADM_clip_ID$ID.*
    fi 
' _ 









ogr2ogr  -clipsrc GADM_islands_Weigelt_etal/GADM_islands_join_plus.shp GADM_clip/GADM_clip_ID5162.shp  ID_shp/ID_5162.shp


ogr2ogr  -clipsrc GADM_islands_Weigelt_etal/GADM_islands_join_plus.shp 