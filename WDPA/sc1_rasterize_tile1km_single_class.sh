
# awk '{ if ( NR > 1 ) print $1 }'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles-te_noOverlap.txt | xargs -n 1  -P 10  bash /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_tile1km_single_class.sh 

# for tile in  $(awk '{ if ( NR > 1 ) print $1 }'   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles-te_noOverlap.txt )  ; do qsub -v tile=$tile /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_tile1km_all.sh   ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=10gb
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc//ga254/stderr

export tile=$1
# export tile=$tile


export RASTERIZE=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize/
export SHPIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA_protect_april2014_clean
export SHPCLIP=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_clip

# attribute of the shapefile land NO-MARINE

#   IUCN_CAT (String) = Ia               11
#   IUCN_CAT (String) = Ib               12
#   IUCN_CAT (String) = II               2
#   IUCN_CAT (String) = III              3
#   IUCN_CAT (String) = IV               4
#   IUCN_CAT (String) = Not Applicable   20
#   IUCN_CAT (String) = Not Reported     21
#   IUCN_CAT (String) = V                5
#   IUCN_CAT (String) = VI               6


# attribute of the shapefile MARINE

#   IUCN_CAT (String) = Ia               111
#   IUCN_CAT (String) = Ib               112
#   IUCN_CAT (String) = II               102
#   IUCN_CAT (String) = III              103
#   IUCN_CAT (String) = IV               104
#   IUCN_CAT (String) = Not Applicable   120
#   IUCN_CAT (String) = Not Reported     121
#   IUCN_CAT (String) = V                105
#   IUCN_CAT (String) = VI               106


export geo_string=$( grep $tile /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles-te_noOverlap.txt  | awk '{ print $2,$3,$4,$5 }'  ) 

echo  clip the large shp

rm -f   $SHPCLIP/WDPA_protect_april2014_$tile.*

ogr2ogr -skipfailures   -spat   $geo_string  $SHPCLIP/WDPA_protect_april2014_$tile.shp   $SHPIN/WDPA_protect_april2014.shp 

echo  start the resterize 

for n in 1 2 3 4 5 6 7 8 9 ; do  

    echo rasterize the land 

    if [ $n -eq 1  ] ; then  IUCN_CAT='"Ia"' ;              BURN=11 ; fi 
    if [ $n -eq 2  ] ; then  IUCN_CAT='"Ib"' ;              BURN=12 ; fi 
    if [ $n -eq 3  ] ; then  IUCN_CAT='"II"' ;              BURN=2  ; fi 
    if [ $n -eq 4  ] ; then  IUCN_CAT='"III"';              BURN=3  ; fi 
    if [ $n -eq 5  ] ; then  IUCN_CAT='"IV"' ;              BURN=4  ; fi 
    if [ $n -eq 6  ] ; then  IUCN_CAT='"Not Applicable"' ;  BURN=20 ; fi 
    if [ $n -eq 7  ] ; then  IUCN_CAT='"Not Reported"' ;    BURN=21 ; fi 
    if [ $n -eq 8  ] ; then  IUCN_CAT='"V"'  ;              BURN=5  ; fi 
    if [ $n -eq 9  ] ; then  IUCN_CAT='"VI"' ;              BURN=6  ; fi 


    rm -f $SHPCLIP/WDPA_protect_april2014_${tile}L${BURN}.*

    ogr2ogr   -sql   "SELECT * FROM  WDPA_protect_april2014_${tile}  WHERE  ( IUCN_CAT = ${IUCN_CAT} )  AND (  MARINE = '0')   "   $SHPCLIP/WDPA_protect_april2014_${tile}L${BURN}.shp   $SHPCLIP/WDPA_protect_april2014_${tile}.shp 

    rm -f $RASTERIZE/${tile}_IUCN${BURN}_L.tif 
    gdal_rasterize -ot  UInt32 -a_srs EPSG:4326 -l  WDPA_protect_april2014_${tile}L${BURN}  -a wdpaid  \
	-a_nodata 0  -tap  -tr   0.008333333333333 0.008333333333333  -te  $geo_string  -co COMPRESS=LZW \
	-co ZLEVEL=9 $SHPCLIP/WDPA_protect_april2014_${tile}L${BURN}.shp $RASTERIZE/${BURN}/${tile}_IUCN${BURN}_L.tif 

# 
    rm -f  $SHPCLIP/WDPA_protect_april2014_${tile}L${BURN}.*


    echo rasterize the marine 

    if [ $n -eq 1  ] ; then  IUCN_CAT='"Ia"' ;              BURN=111 ; fi 
    if [ $n -eq 2  ] ; then  IUCN_CAT='"Ib"' ;              BURN=112 ; fi 
    if [ $n -eq 3  ] ; then  IUCN_CAT='"II"' ;              BURN=102  ; fi 
    if [ $n -eq 4  ] ; then  IUCN_CAT='"III"';              BURN=103  ; fi 
    if [ $n -eq 5  ] ; then  IUCN_CAT='"IV"' ;              BURN=104  ; fi 
    if [ $n -eq 6  ] ; then  IUCN_CAT='"Not Applicable"' ;  BURN=120 ; fi 
    if [ $n -eq 7  ] ; then  IUCN_CAT='"Not Reported"' ;    BURN=121 ; fi 
    if [ $n -eq 8  ] ; then  IUCN_CAT='"V"'  ;              BURN=105  ; fi 
    if [ $n -eq 9  ] ; then  IUCN_CAT='"VI"' ;              BURN=106  ; fi 
    
    rm -f  $SHPCLIP/WDPA_protect_april2014_${tile}M${BURN}.shp
    ogr2ogr     -sql   "SELECT * FROM  WDPA_protect_april2014_${tile}  WHERE  ( IUCN_CAT = ${IUCN_CAT} )  AND (  MARINE = '1')   "   $SHPCLIP/WDPA_protect_april2014_${tile}M${BURN}.shp    $SHPCLIP/WDPA_protect_april2014_${tile}.shp 
    
    rm -f $RASTERIZE/${tile}_IUCN${BURN}_M.tif 
    
    gdal_rasterize -ot  UInt32  -a_srs EPSG:4326 -l  WDPA_protect_april2014_${tile}M${BURN}  -a wdpaid  \
	-a_nodata 0 -tap   -tr   0.008333333333333 0.008333333333333  -te  $geo_string  -co COMPRESS=LZW   \
	-co ZLEVEL=9 $SHPCLIP/WDPA_protect_april2014_${tile}M${BURN}.shp $RASTERIZE/${BURN}/${tile}_IUCN${BURN}_M.tif 

rm -f $SHPCLIP/WDPA_protect_april2014_${tile}M${BURN}.*

done 

rm -f  $SHPCLIP/WDPA_protect_april2014_$tile.* 

exit 





gdalbuildvrt  -overwrite -tr 0.0083333333333 0.0083333333333  IUCN11_L.vrt    ?_?_IUCN11_L.tif 
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  ot  UInt32 -tr   0.008333333333333 0.008333333333333  IUCN11_L.vrt   IUCN11_L.tif 