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

