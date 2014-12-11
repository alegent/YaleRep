
cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/pangea/download 

awk -F "\t"  '{ if (NR>2) { gsub("ø","" ) ;  print $1 , $2 , $3 , $4 , $5 , $6 }}' ../download/radiation_month_average_pangea_date.txt   | sort -k 2,2 -k 3,3 > ../txt/radiation_month_average_pangea_date.txt



awk -F "\t"  '{ if (NR>2) { gsub("ø","" ) ;  print $1 , $2 , $3 , $4 , $5 , $6 }}' ../download/BSRN.tab   | sort -k 2,2 -k 3,3 > ../txt/BSRN.txt
awk '{ print $2, $3, $1, $4 , $5 , $6 }'  ../txt/BSRN.txt > ../txt/BSRN_date_glo_dir_dif.txt
