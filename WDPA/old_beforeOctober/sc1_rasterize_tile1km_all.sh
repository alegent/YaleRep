
# awk '{ if ( NR > 1 ) print $1 }'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles-te_noOverlap.txt | xargs -n 1  -P 10  bash /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_tile1km_all.sh 

# for tile in  $(awk '{ if ( NR > 1 ) print $1 }'   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles-te_noOverlap.txt )  ; do qsub -v tile=$tile /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_tile1km_all.sh   ; done 



#PBS -S /bin/bash 
#PBS -q fas_normal

#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc//ga254/stderr


# export tile=$1
export tile=$1

export RASTERIZE=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize/all
export SHPIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA_protect_april2014_clean
export SHPCLIP=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_clip


export geo_string=$( grep $tile /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles-te_noOverlap.txt  | awk '{ print $2,$3,$4,$5 }'  ) 

echo  clip the large shp by $geo_string

rm -f   $SHPCLIP/WDPA_protect_april2014_$tile.*

ogr2ogr -skipfailures   -spat   $geo_string  $SHPCLIP/WDPA_protect_april2014_$tile.shp   $SHPIN/WDPA_protect_april2014.shp

rm -f $RASTERIZE/${tile}.tif  
gdal_rasterize -ot UInt32      -a_srs EPSG:4326 -l WDPA_protect_april2014_$tile -tap   -a  wdpaid  -a_nodata 0  -tr   0.008333333333333 0.008333333333333 \
-te  $geo_string  -co COMPRESS=LZW -co ZLEVEL=9  $SHPCLIP/WDPA_protect_april2014_$tile.shp    $RASTERIZE/${tile}.tif 

exit 





