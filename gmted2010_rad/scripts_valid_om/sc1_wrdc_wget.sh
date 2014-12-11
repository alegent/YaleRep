# Download the full archive 

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc

wget --cookies=on --keep-session-cookies --save-cookies=cookie.txt http://wrdc.mgo.rssi.ru/wrdccgi/protect.exe?wrdc/wrdc.htm
wget -t 7 -w 5 --waitretry=14 --random-wait -m -k -K -e robots=off http://wrdc.mgo.rssi.ru/Protected/DataCGI_HTML/data_list_full/root_index.html -o ./myLog.log

# migrate the full dir to litoria to use the html2txt 

cd /mnt/data2/scratch/SOLAR/wrdc 

for dir in d t1 t2 t3 t4 t5 t6 t7 ; do 

export dir=$dir 

find   full_wrdc.mgo.rssi.ru/Protected/DataCGI_HTML/data_list_full/$dir/ -name *$dir.html   | xargs -n 1 -P 24  bash -c $' 
file=$1 
filename=$(basename $file .html) ;  html2text  $file  >   $dir/$filename.txt     
' _

done 



# mv the file to omega /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt  

#                                                                                                   station 

# folder D > Diffuse radiation. Daily sums, monthly sums and means.                                   d 365
# folder t1 > Global radiation. Daily sums, monthly sums and means (Africa).                          t1 235
# folder t2 > Global radiation. Daily sums, monthly sums and means (Asia).                            t2 123
# folder t3 > Global radiation. Daily sums, monthly sums and means (S. America).                      t3 135
# folder t4 > Global radiation. Daily sums, monthly sums and means (N. America).                      t4 165
# folder t5 > Global radiation. Daily sums, monthly sums and means (Australia and Oceania).           t5 84
# folder t6 > Global radiation. Daily sums, monthly sums and means (Europe).                          t6 414
# folder t7 > Global radiation. Daily sums, monthly sums and means (Antarctica).


# scp -r d      ga254@omega.hpc.yale.edu:/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt 
# scp -r t*      ga254@omega.hpc.yale.edu:/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt 

# for file in d/*_????_*.txt ; do   filename=$(basename $file .txt ) ;  echo ${filename:0:${#filename}-7}    $(grep -e Longitude  $file  | awk '{ gsub ("=","" ) ;   gsub ("°"," " ) ;   gsub ("'\''"," " )  ;    print $2 , $3 , $4  }'  ) $(grep -e Latitude  $file  | awk '{ gsub ("=","" ) ;   gsub ("°"," " ) ;  gsub ("'\''"," " )  ; print $2 , $3 , $4  }'   ) ; done | uniq | sort  -k 1 | uniq  > ../geo_file/stations_degree_minute.txt

# for file in t*/*_????_*.txt ; do   filename=$(basename $file .txt ) ;  echo ${filename:0:${#filename}-8}    $(grep -e Longitude  $file  | awk '{ gsub ("=","" ) ;   gsub ("°"," " ) ;   gsub ("'\''"," " )  ;    print $2 , $3 , $4  }'  ) $(grep -e Latitude  $file  | awk '{ gsub ("=","" ) ;   gsub ("°"," " ) ;  gsub ("'\''"," " )  ; print $2 , $3 , $4  }'   ) ; done | uniq | sort  -k 1 | uniq  >> ../geo_file/stations_degree_minute.txt

#  sort -k 1 ../geo_file/stations_degree_minute.txt  | uniq >  ../geo_file/stations_degree_minute_1.txt
#  mv ../geo_file/stations_degree_minute_1.txt ../geo_file/stations_degree_minute.txt

# awk '{ if ($4=="E") { sig="+" } ; if ($4=="W")  { sig="-" } ;  if ($7=="N")  { nsig="+" } ;  if ($7=="S")  { nsig="-"}  ;    print $1 , sig  $2+($3/60) , nsig  $5+($6/60)  }'    ../geo_file/stations_degree_minute.txt  >  ../geo_file/stations_degree_decimal.txt 



# start to import in R 