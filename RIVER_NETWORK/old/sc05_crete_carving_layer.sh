# bsub -W 24:00 -n 8 -R "span[hosts=1]" -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc05_crete_carving_layer.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc05_crete_carving_layer.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc05_crete_carving_layer.sh

cd         /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb 
export DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK

rm -f   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT/.gislock
source  /gpfs/home/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT 
rm -f   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river/PERMANENT/.gislock

g.list rast 

r.mask   -r  --quiet

export DEM=be75_grd_LandEnlarge
export OCCURANCE=occurrence_250m 
export STDEV=be75_grd_LandEnlarge_std_norm 

echo log transform the water layer 

# # plot ( wa ,  100  * log(wa+1) / ( max(log(0+1)) -  min (log(100+1)))   )  ; log(1)=0   # log(OCCURANCE@PERMANENT + 1) /  4.615121  
                                                             #  gose from 0 to 4  
##  log( $OCCURANCE@PERMANENT + 1) /  4.615121  # log of the occurance /  4.615121  goes from 0 to 1 ; 0 no water at all 1 always water 
# first condition 
# log(occurence ) * altitude (from 10 to 30)

r.mask -r  --quiet
r.mask  raster=be75_grd_LandEnlarge   --o

echo 001
rm -f      /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/${OCCURANCE}_N_DIM.txt 
seq  14 2 24  | xargs -n 1 -P 8 bash -c $'  
DIM=$1


cp  $HOME/.grass7/grass$$     $HOME/.grass7/rc${OCCURANCE}_log001_DIM$DIM
export GISRC=$HOME/.grass7/rc${OCCURANCE}_log001_DIM$DIM

rm -fr  $DIR/grassdb/loc_river/${OCCURANCE}_log001_DIM$DIM
g.mapset  -c  mapset=${OCCURANCE}_log001_DIM$DIM  location=loc_river  dbase=$DIR/grassdb   --quiet --overwrite 

echo create mapset  ${OCCURANCE}_log001_DIM$DIM 
cp $DIR/grassdb/loc_river/PERMANENT/WIND   $DIR/grassdb/loc_river/${OCCURANCE}_log001_DIM$DIM/WIND

rm -f  $DIR/grassdb/loc_river/${OCCURANCE}_log001_DIM$DIM/.gislock

g.gisenv 

g.region   raster=be75_grd_LandEnlarge    --o #   n=35 s=30 e=0 w=-10  #  
r.mask -r  --quiet
r.mask     raster=be75_grd_LandEnlarge   --o

echo 001 $DIM 
r.mapcalc " ${OCCURANCE}_log001_DIM  = if ( $OCCURANCE@PERMANENT < 101 ,  ( log( $OCCURANCE@PERMANENT + 1) /  4.615121 * $DIM   ), 0 )"   --overwrite

' _   >>    /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/${OCCURANCE}_N_DIM.txt  

exit 


# ## log(occurence ) * altitude (from 10 to 200) * power2 of ( 1 - normalized_stde ) ; normalize_stdev goes from 1 mountain area 0 to flat area.   

echo 100
seq 20 10 260 | xargs -n 1 -P 8 bash -c $'  
DIM=$1
echo 100 $DIM 
r.mapcalc " ${OCCURANCE}_log100_DIM$DIM  = if ( $OCCURANCE@PERMANENT < 101 ,  ( log( $OCCURANCE@PERMANENT + 1) /  4.615121 * $DIM * (( 1 - $STDEV )^2)), 0 )"   --overwrite
' _   >>  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/${OCCURANCE}_N_DIM.txt 

# ## log(occurence ) * altitude (from 10 to 200) * ( 1 - normalized_stde ) ; normalize_stdev goes from 1 mountain area 0 to flat area.   

N=200
seq 20 10 260 | xargs -n 1 -P 8 bash -c $'  
DIM=$1
echo 200 $DIM
r.mapcalc " ${OCCURANCE}_log200_DIM$DIM  = if ( $OCCURANCE@PERMANENT < 101 ,  ( log( $OCCURANCE@PERMANENT + 1) /  4.615121 * $DIM * (( 1 -  $STDEV  ))), 0 )"   --overwrite
' _   >>   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/${OCCURANCE}_N_DIM.txt 


# ## log(occurence ) * altitude (from 10 to 200) * power2 of ( normalized_stde ) ; normalize_stdev goes from 1 mountain area 0 to flat area.   

N=300
seq 20 10 260 | xargs -n 1 -P 8 bash -c $'  
DIM=$1
echo 300 $DIM
r.mapcalc " ${OCCURANCE}_log300_DIM$DIM  = if ( $OCCURANCE@PERMANENT < 101 ,  ( log( $OCCURANCE@PERMANENT + 1) /  4.615121 * $DIM * (( $STDEV )^2)), 0 )"   --overwrite
' _  >>  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/${OCCURANCE}_N_DIM.txt 

###  log(occurence ) * altitude (from 10 to 200) * ( normalized_stde ) ; normalize_stdev goes from 1 mountain area 0 to flat area.   

N=400
seq 20 10 260 | xargs -n 1 -P 8 bash -c $'  
DIM=$1
echo 400 $DIM
r.mapcalc " ${OCCURANCE}_log400_DIM$DIM  = if ( $OCCURANCE@PERMANENT < 101 ,  ( log( $OCCURANCE@PERMANENT + 1) /  4.615121 * $DIM * (( $STDEV ))), 0 )"   --overwrite
' _  >>  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/${OCCURANCE}_N_DIM.txt 


pkcreatect -min 0 -max 1 > /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/color0_1.txt

exit 

be75_grd_LandEnlarge_EUROASIA occurrence_250m_EUROASIA be75_grd_LandEnlarge_std_norm_EUROASIA | xargs -n 3  -P 2   bash -c $' 