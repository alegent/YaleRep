


# identification in the 2 column 
1 GLOBAL   # 2200 stations 
2 DIRECT   # 107 stations 
3 DIFFUS   # 784 stations 

echo "STAT YEAR JEN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DIC MEANY" >  geba_glo.txt
echo "STAT YEAR JEN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DIC MEANY" >  geba_dir.txt
echo "STAT YEAR JEN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DIC MEANY" >  geba_dif.txt

cat    */GEBAdata_2014-10-01_??-??-??.csv | awk '{  if ($2==1) print $1 , $3 , $4  , $5 ,  $6 ,  $7, $8 , $9 , $10 ,$11 , $12, $13 ,  $14 , $15 , $16  }'  >> geba_glo.txt
cat    */GEBAdata_2014-10-01_??-??-??.csv | awk '{  if ($2==2) print $1 , $3 , $4  , $5 ,  $6 ,  $7, $8 , $9 , $10 ,$11 , $12, $13 ,  $14 , $15 , $16  }'  >> geba_dir.txt
cat    */GEBAdata_2014-10-01_??-??-??.csv | awk '{  if ($2==3) print $1 , $3 , $4  , $5 ,  $6 ,  $7, $8 , $9 , $10 ,$11 , $12, $13 ,  $14 , $15 , $16  }'  >> geba_dif.txt



module load Apps/R/3.1.1-generic

R --vanilla  <<'EOF'


library(data.table)

geba.dif = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geba/geba_dif.txt", sep=" " , header=TRUE ,  na.strings=c("99999","-------") )
geba.dir = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geba/geba_dir.txt", sep=" " , header=TRUE ,  na.strings=c("99999","-------") )
geba.glo = read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geba/geba_glo.txt", sep=" " , header=TRUE ,  na.strings=c("99999","-------") )

save.image("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geba/Rdata/geba.RData")

EOF 


