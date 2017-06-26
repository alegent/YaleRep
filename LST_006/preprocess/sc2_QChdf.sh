
# conta gli hdf nel list file e nela directory 

for SENS in MOD MYD ; do 
    export INDIR=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.006 
    export SENS=$SENS
    for YEAR in  $( seq 2002 2009) ; do 
	export YEAR
	ls  $INDIR/$YEAR/ | xargs -n 1 -P 4 bash -c $' echo $SENS $YEAR $1   $(ls  $INDIR/$YEAR/$1/*.hdf   2> /dev/null  | wc -l  ) $( wc -l $INDIR/$YEAR/$1/listhdf${YEAR}_$1.txt)   ' _ 
    done 
done   | sort -k 4,4 -g 

# file that was missing fatto il download manuale 
# MYD 2003 233 316 317 /nobackupp6/aguzman4/climateLayers/MYD11A2.006/2003/233/listhdf2003_233.txt
# wget ftp://ladsweb.nascom.nasa.gov/allData/6/MYD11A2/2003/233/MYD11A2.A2003233.h08v04.006.2015202194633.hdf


# che the hdf quality 
for SENS in MOD MYD ; do
export INDIR=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.006
export SENS=$SENS
for YEAR in  $( seq 2002 2009) ; do
export YEAR=$YEAR
ls  $INDIR/$YEAR/*/*.hdf  | xargs -n 1 -P 20  bash -c $' echo  $1   $( gdalinfo $1  | wc -l ) ' _  | sort -k 2,2 -g  | head -2
done
done     








 

