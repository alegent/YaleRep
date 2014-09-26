# donwload data from  
wget -mr    ftp://ftp.ncdc.noaa.gov/pub/data/nsrdb-solar/solar-only/  &
scp  /mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/ftp.ncdc.noaa.gov/pub/data/nsrdb-solar/solar-only/*.tar.gz  /mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/tar

cd  /mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/tar/ 

ls /mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/tar/*.tar.gz | xargs -n 1  -P 10 bash  -c   $'
file=$1
tar -xvf $file

' _




# dato di validazione 1991-2005 gia in media mensile 


wget -mr ftp://ftp.ncdc.noaa.gov/pub/data/nsrdb-solar/summary-stats/dailystats/
/mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/ftp.ncdc.noaa.gov/pub/data/nsrdb-solar/summary-stats/dailystats/*.dsf 

for file in `ls /mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/ftp.ncdc.noaa.gov/pub/data/nsrdb-solar/summary-stats/dailystats/*.dsf` ; do 

    filename=$(basename $file .dsf)
    awk '{ if(NR>2 && NR<16) { for(col=1;col<2;col++) { printf("%s " , $col)  } ; printf("%s\n" , $2) }  }'  $file  >   /mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/monthstats_txt/c$filename.txt

done 








