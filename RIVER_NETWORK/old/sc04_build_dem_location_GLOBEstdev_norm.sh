# for RADIUS in 11 21 31 41 51 61 71 81 91 101 111 121 131 141 151 161  ; do  sleep 60 ; bsub  -q shared    -W 10:00  -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc04_build_dem_location_GLOBEstdev_norm.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc04_build_dem_location_GLOBEstdev_norm.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc04_build_dem_location_GLOBEstdev_norm.sh $RADIUS ; done 
# rifarlo per la 81 and 151 
cd /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb 
export DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK

rm -f   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_fill_GLOBE/PERMANENT/.gislock
source  /gpfs/home/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_fill_GLOBE/PERMANENT 
rm -f   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_fill_GLOBE/PERMANENT/.gislock

# # compute standard deviation 


# r.mask -r  --quiet
# g.region raster=UNIT3753,UNIT4000
# r.patch  output=UNIT3753_4000  input=UNIT3753,UNIT4000   --o
# g.region raster=UNIT3753_4000
# r.mask  raster=UNIT3753_4000 --o # inserito a mano per tutte le computazioni 

RADIUS=$1

echo normalize the standard deviation  

r.mapcalc " be75_grd_LandEnlarge_std${RADIUS}_norm_GLOBE = be75_grd_LandEnlarge_std${RADIUS}_GLOBE / $( r.info be75_grd_LandEnlarge_std${RADIUS}_GLOBE  | grep max | awk '{  print $10  }' )   "    --overwrite

