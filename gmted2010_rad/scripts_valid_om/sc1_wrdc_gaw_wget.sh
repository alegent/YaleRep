# Download the full archive 

# download the archive based on https://github.com/funkycoda/scrappy/tree/master/wrdc

# the html is transformed to txt by html2txt
# ls    html/*/*/*.htm | xargs -n 1 -P  3  bash -c $' file=$1 ; filename=$(basename $file .htm ) ;   html2text  $file > txt/$filename.txt    ' _

# data preparation 

# for file in txt/*.txt ; do filename=$(basename $file .txt )  ;  echo $(awk -v n=$filename  'BEGIN { print (substr (n,0,length(n)-11))  }'  )      $(grep -e Longitude  $file  | awk '{ gsub ("=","" ) ;   gsub ("°"," " ) ;   gsub ("'\''"," " )  ;    print int($2) , $3 , $4  }'  ) $(grep -e Latitude  $file  | awk '{ gsub ("=","" ) ;   gsub ("°"," " ) ;  gsub ("'\''"," " )  ; print int($2) , $3 , $4  }'   ) ; done   | uniq  > geo_file/stations_degree_minute.txt

# awk '{ if ($4=="E") { sig="+" } ; if ($4=="W")  { sig="-" } ;  if ($7=="N")  { nsig="+" } ;  if ($7=="S")  { nsig="-"}  ;    print $1 , sig  $2+($3/60) , nsig  $5+($6/60)  }'    geo_file/stations_degree_minute.txt  >  geo_file/stations_degree_decimal.txt 



# start to import in R 