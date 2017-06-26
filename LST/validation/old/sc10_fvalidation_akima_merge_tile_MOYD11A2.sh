

for xn in $(seq 1 100 ) ;  do 

x=$(echo "76.377 + ( 0.00833333 * $xn * 3  )" | bc )


for file in /nobackupp8/gamatull/dataproces/LST/MYD11A2_spline4fill/LST_MYD_QC_day???_wgs84_fillspat.tif ; do 
    gdallocationinfo -geoloc -valonly $file  $x  18.640
done >  /tmp/spline4fill$x.txt

for file in /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/LST_MYD_akima_day???.tif; do 
    gdallocationinfo -geoloc -valonly $file  $x  18.640
done > /tmp/splinefill_merge$x.txt



paste <(paste /nobackupp8/gamatull/dataproces/LST/geo_file/list_day.txt  /tmp/spline4fill$x.txt)  /tmp/splinefill_merge$x.txt  > /tmp/hole$x.txt 


echo 380 > /tmp/test.txt
echo 410 >> /tmp/test.txt
echo 439 >> /tmp/test.txt
echo 470 >> /tmp/test.txt
echo 500 >> /tmp/test.txt
echo 531 >> /tmp/test.txt
echo 561 >> /tmp/test.txt
echo 592 >> /tmp/test.txt
echo 623 >> /tmp/test.txt 
echo 653 >> /tmp/test.txt
echo 684 >> /tmp/test.txt
echo 714 >> /tmp/test.txt
echo 745 >> /tmp/test.txt 

awk '{ print $1-380+15  }'  /tmp/test.txt   > /tmp/month_day.txt 


for file in /nobackupp8/gamatull/dataproces/LST/MYD11A2_spline15/LST_MYD_spline_month?.tif    /nobackupp8/gamatull/dataproces/LST/MYD11A2_spline15/LST_MYD_spline_month??.tif ; do
    gdallocationinfo -geoloc -valonly $file  $x  18.640
done    > /tmp/month_day_lst$x.txt

paste  /tmp/month_day.txt   /tmp/month_day_lst$x.txt > /tmp/month_day_lst_final$x.txt

done 


path=("/tmp/")

files.list.hole = list.files(path , pattern="hole.*")
files.list.month = list.files(path , pattern="month.*")

plot  ( month$V2 ~  month$V1 ,ylim=c(20,60) , col='blue'  , xlab="julian day (46 *  8-day-composite )" , ylab="LST Temperature (Celsius)" )
legend(245,60, c("LST observation","Filled gap using Akima prediction"), lty=c(1,1), lwd=c(1,1), col=c("black","red"))
legend(245,55,c("Akima prediction for the 15th day of each month"),pch=c(1),col=c("blue") )  


a=c(1:10);b=c(100:110)

a=c(1,  2,  3,  4 , 5,  6,  7,  8,  9, 10, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109 ,110)

for(file in files.list.hole[a]  ) {

hole= read.table ( paste ("/tmp/",  file , sep="" )  , na.strings="0")

number=gsub (".txt", "" , (gsub("hole","", file )))

month= read.table (paste ("/tmp/month_day_lst_final" , number , ".txt" ,sep="" ) , na.strings="0" )


hole$V2= (hole$V2  *  0.02 ) - 272.15
hole$V3= (hole$V3  *  0.02 ) - 272.15
month$V2= (month$V2  *  0.02 ) - 272.15


points ( month$V2 ~  month$V1 ,ylim=c(20,60) , col='blue' )
lines (hole$V3 ~ hole$V1  , col='red'  , lwd=c(1,1)) 
lines (hole$V2 ~ hole$V1 ,lwd=c(2,2) ) 

}









