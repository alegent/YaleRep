
# min max mean sd and median non piu calcolate perche c'e' il mare. 
# ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/*/*_100KM*_*.tif   | xargs -n 1  -P 1 bash -c  $' echo $( basename $1 )  $(gdalinfo -stats  $1 | grep   MIN | awk  -F "="  \' { gsub ("STATISTICS_","" )  ; print $2 }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk  -F "="  \' { gsub ("STATISTICS_","" ) ; print $2  }\' )  $( gdalinfo -stats  $1 | grep  MEAN | awk  -F "="  \' { gsub ("STATISTICS_","" ) ; print $2   }\' )   $( gdalinfo -stats  $1 | grep  MEAN | awk  -F "="  \' { gsub ("STATISTICS_","" ) ; print $2   }\' )    $( gdalinfo -stats  $1 | grep  STDDEV  | awk  -F "="  \' { gsub ("STATISTICS_","" ) ; print $2   }\' ) $(   source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/grasdb  loc_$( basename $file .tif )   $1 > /dev/null  ; r.univar -e  map=$( basename $file .tif )   | grep -e  median  | awk \' { gsub ("even number of cells","" ) ; gsub ("odd number of cells","" ) ;   gsub ("median","" )     ;   gsub ("\\[(=):\\]","" )  ;   print  }\'     )   ' _    2>  /dev/null 

for km in 1 5 10 50 100 ; do 

ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/*/*_${km}KM*_GMTED??.tif   | xargs -n 1  -P 8  bash -c  $' 
echo $( basename $1 )  $(gdalinfo -stats  $1 | grep   MIN | awk  -F "="  \' { gsub ("STATISTICS_","" )  ;  printf ( "%.16f " , $2 )  }\'     )   $(gdalinfo -stats  $1 | grep   MAXIMUM  | awk  -F "="  \' { gsub ("STATISTICS_","" ) ;  printf ( "%.16f" , $2 )   }\' )
rm -f $1.aux.xml
' _    2>  /dev/null  >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/min_max_${km}KM.txt 

done 

