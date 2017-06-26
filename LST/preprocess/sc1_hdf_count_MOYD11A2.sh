


export HDFMOD11A2=/nobackup/gamatull/dataproces/LST/MOD11A2
export HDFMYD11A2=/nobackup/gamatull/datapreces/LST/MYD11A2
export LST=/nobackup/gamatull/dataproces/LST
export INDIR=/nobackupp6/aguzman4/climateLayers/MOD11A2.005/
export RAMDIR=/dev/shm

MOD

ls /nobackupp6/aguzman4/climateLayers/MOD11A2.005/
ls /nobackupp4/datapool/modis/MOD11A2.005

for dir in  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/2???/* ; do echo $( basename  $(dirname $dir ) )     $(basename $dir ) $( ls $dir/*.hdf  | wc -l  ) ; done  > /nobackupp8/gamatull/dataproces/LST/geo_file/count_MYDhdf.txt 
for dir in  /nobackupp6/aguzman4/climateLayers/MOD11A2.005/2???/*  ; do echo $( basename  $(dirname $dir ) )     $(basename $dir ) $( ls $dir/*.hdf  | wc -l  ) ;    done > /nobackupp8/gamatull/dataproces/LST/geo_file/count_MODhdf.txt 


sort -k 3,3 -g /nobackupp8/gamatull/dataproces/LST/geo_file/count_MODhdf.txt |  head 
2001 177 202   no more file in the ftp 
2000 105 317

sort -k 3,3 -g /nobackupp8/gamatull/dataproces/LST/geo_file/count_MODhdf.txt |  tail
2015 289 317
2003 177 318   una in piu non so perche

sort -k 3,3 -g /nobackupp8/gamatull/dataproces/LST/geo_file/count_MYDhdf.txt |  head 
2015 289 0      non ancora calculato da modis 
2002 185 317

check for small file 

find  /nobackupp6/aguzman4/climateLayers/MOD11A2.005/    -name "*.hdf"  | xargs -n 1 -P 10 bash -c $'  ls -l    $1 ' _   | awk '{ print $5  } '   | sort -g | head
find  /nobackupp6/aguzman4/climateLayers/MOD11A2.005/    -name "*.hdf"  | xargs -n 1 -P 10 bash -c $'  ls -l    $1 ' _   | awk '{ print $5  } '   | sort -g | tail

find  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/    -name "*.hdf"  | xargs -n 1 -P 10 bash -c $'  ls -l    $1 ' _   | awk '{ print $5  } '   | sort -g | head
find  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/    -name "*.hdf"  | xargs -n 1 -P 10 bash -c $'  ls -l    $1 ' _   | awk '{ print $5  } '   | sort -g | tail


find  /nobackupp4/datapool/modis/MOD11A2.005/*    -name *.hdf  | xargs -n 1 -P 10 bash -c $'  ls -l    $1 ' _   | awk '{ print $5  } '   | sort -g | head
find  /nobackupp4/datapool/modis/MOD11A2.005/*    -name *.hdf  | xargs -n 1 -P 10 bash -c $'  ls -l    $1 ' _   | awk '{ print $5  } '   | sort -g | tail

empity files 

-rw-rw-r-- 1 armichae s1347 0 Apr  2  2011 /nobackupp4/datapool/modis/MOD11A2.005/2011.01.01/MOD11A2.A2011001.h20v16.005.2011038111323.hdf  fatto il download in /nobackupp6/aguzman4/climateLayers/MOD11A2.005/
-rw-rw-r-- 1 armichae s1347 0 Nov 17  2010 /nobackupp4/datapool/modis/MOD11A2.005/2002.06.26/MOD11A2.A2002177.h18v16.005.2007165001123.hdf fatto il download in /nobackupp6/aguzman4/climateLayers/MOD11A2.005/
-rw-rw-r-- 1 armichae s1347 0 Nov 18  2010 /nobackupp4/datapool/modis/MOD11A2.005/2008.02.10/MOD11A2.A2008041.h27v07.005.2008050205636.hdf fatto il download in /nobackupp6/aguzman4/climateLayers/MOD11A2.005/
-rw-rw-r-- 1 armichae s1347 0 Nov 18  2010 /nobackupp4/datapool/modis/MOD11A2.005/2008.07.03/MOD11A2.A2008185.h09v05.005.2008195044031.hdf gia presenti tutti in /nobackupp6/aguzman4/climateLayers/MOD11A2.005/
-rw-rw-r-- 1 armichae s1347 0 Nov 18  2010 /nobackupp4/datapool/modis/MOD11A2.005/2008.09.05/MOD11A2.A2008249.h18v15.005.2008268054234.hdf fatto il download in /nobackupp6/aguzman4/climateLayers/MOD11A2.005/
-rw-rw-r-- 1 armichae s1347 0 Nov 18  2010 /nobackupp4/datapool/modis/MOD11A2.005/2009.03.06/MOD11A2.A2009065.h08v09.005.2009075042500.hdf fatto il download in /nobackupp6/aguzman4/climateLayers/MOD11A2.005/
# create iper link with the data stored at /nobackupp4/datapool/modis/ 



for file  in   /nobackupp4/datapool/modis/MOD11A2.005/*/*.hdf   ; do     
    if [ -f /nobackupp6/aguzman4/climateLayers/MOD11A2.005/${file:39:4}/${file:63:3}/$(basename $file )  ] ; then 
	echo  the file /nobackupp6/aguzman4/climateLayers/MOD11A2.005/${file:39:4}/${file:63:3}/$(basename $file )  exist  
    else 
        ln -s  $file /nobackupp6/aguzman4/climateLayers/MOD11A2.005/${file:39:4}/${file:63:3}/$(basename $file ) 
    fi 
done 



MYD


for dir in  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/2011/* ; do echo $( basename  $(dirname $dir ) )     $(basename $dir ) $( ls $dir/*.hdf  | wc -l  ) ; done  > /nobackupp8/gamatull/dataproces/LST/geo_fi\
le/count_MYDhdf.txt
for dir in  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/????.??.??  ; do  file=$(ls $dir/*.hdf | head -1 ) ;   echo    ${file:67:4}  ${file:71:3}         $( ls $dir/*.hdf  | wc -l  ) ; done >> /nobackupp8/gamatull/dataproces/LST/geo_file/count_MYDhdf.txt



find  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/   -name *.hdf  | xargs -n 1 -P 10 bash -c $'  ls -l    $1 ' _    | sort -k 5,5 -g  | head



for file  in /nobackupp6/aguzman4/climateLayers/MYD11A2.005/alberto_folder/*/*.hdf   ; do
    if [ -f /nobackupp6/aguzman4/climateLayers/MYD11A2.005/${file:82:4}/${file:86:3}/$(basename $file )  ] ; then
        echo  the file /nobackupp6/aguzman4/climateLayers/MYD11A2.005/${file:82:4}/${file:86:3}/$(basename $file )  exist
    else
        ln -s  $file /nobackupp6/aguzman4/climateLayers/MYD11A2.005/${file:82:4}/${file:86:3}/$(basename $file )
    fi
done













