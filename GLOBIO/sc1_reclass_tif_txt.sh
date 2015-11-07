
export INDIR_TIF=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GLOBIO/Yale_paper_1
export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GLOBIO/Yale_paper_1/GLOBIO/Data/GLOBIO_RIO20_BL_RC_6min_NoAreaLoss/

gdal_translate  -a_srs EPSG:4326  -co COMPRESS=LZW -co ZLEVEL=9   $INDIR_TIF/GLOBIO/Data/GLOBIO6minGrid/seq_grd_01  $INDIR_TIF/tif_ID/seq_grd_01.tif 
# globio_intermoutput1970_3 = mdb.get("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GLOBIO/Yale_paper_1/GLOBIO/Data/GLOBIO_RIO20_BL_RC_6min_1970-1990_NoAreaLoss/globio_intermoutput1970_3.mdb")


echo 2000 2010 2020 2030 2040 2050 | xargs -n 1 -P 6 bash -c $' 

year=$1

for col in 12 13 ; do 

if [ $col -eq 12  ] ; then var=agric ; fi  
if [ $col -eq 13  ] ; then var=forers ; fi  

awk -F ,  -v col=$col  \'{ if($col > 0 ) {  printf ("%i %.6f\\n" , $1 , $col)   }}\' $INDIR/globio_intermoutput${year}_3.txt  | sort -k 1,1  >  $INDIR/globio_intermoutput${year}_3_${var}.txt

bash  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_valid/sum.sh     $INDIR/globio_intermoutput${year}_3_${var}.txt  $INDIR/globio_intermoutput${year}_3_${var}SUM.txt <<EOF
n
1
6
EOF


bash  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_valid/sum.sh  <(cat $INDIR/globio_intermoutput${year}_3_${var}SUM.txt  <(awk \'BEGIN  { for(i = 1; i  <= 6480000 ; i++) {  printf ("%i %i\\n" , i , 0 ) }  }\' )  | sort )   $INDIR/globio_intermoutput${year}_3_${var}SUM_w0.txt  <<EOF
n
1
6
EOF

pkreclass -nodata 0  -ot  Float32   -co COMPRESS=LZW -co ZLEVEL=9  -code $INDIR/globio_intermoutput${year}_3_${var}SUM_w0.txt    -i   $INDIR_TIF/tif_ID/seq_grd_01.tif      -o   $INDIR_TIF/tif_ID/globio_intermoutput${year}_3_${var}SUM.tif

done 
' _ 


