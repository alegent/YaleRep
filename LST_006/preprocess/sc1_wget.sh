

for SENS in MOD MYD ; do 
export INDIR=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.006 

for YEAR in  $( seq 2002 2009) ; do 
export YEAR

cat   /nobackup/gamatull/dataproces/LST_006/geo_file/list_day.txt | xargs -n 1 -P 10  bash -c $'  
DAY=$1
mkdir -p $INDIR/$YEAR/$DAY
cd $INDIR/$YEAR/$DAY
rm -f $INDIR/$YEAR/$DAY/.listing $INDIR/${YEAR}/${DAY}/listhdf$YEAR.txt 
wget  --waitretry=4 --random-wait -q  -c -w 5 --no-remove-listing -A .hdf ftp://ladsweb.nascom.nasa.gov/allData/6/${SENS}11A2/${YEAR}/${DAY}/*.hdf 
awk \'{ if (NR>2)  print $9 }\'  $INDIR/$YEAR/$DAY/.listing >  $INDIR/${YEAR}/${DAY}/listhdf${YEAR}_${DAY}.txt 
rm -f $INDIR/$YEAR/$DAY/.listing 
' _ 

done 
done 

exit 


some command belows can be usefull


echo 2001 2013 2002 2003 2004 2005 2006 2008 2009 2010 2011 2012 | xargs -n 1 -P 20  bash -c  $'
YEAR=$1
wget -r -nH -np  --cut-dirs=3  -A .hdf -P $INDIR  ftp://ladsweb.nascom.nasa.gov/allData/51/MCD12Q1/$YEAR/001/

' _ 

 

