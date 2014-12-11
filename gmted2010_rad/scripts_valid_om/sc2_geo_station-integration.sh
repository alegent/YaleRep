

cd      /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/

# create a geodata station withe the station code 


cat  <(awk ' { if (NR>1) print $1 , $2 , $3 , "bsrn"   }'   bsrn/geo_file/bsrn_x_y_code.txt) <(awk ' { print $2 , $3 , $1 , "wrdc"  }'  wrdc/geo_file/stations_degree_decimal.txt) <(awk ' { print $2 , $3 ,  $1 , "wrdc.gaw"  }'  wrdc_gaw/geo_file/stations_degree_decimal.txt) <(awk ' { print $2 , $3 , $1 , "geba"  }'  geba/geo_file/geba_code_x_y_x180.txt)   <(awk ' { print $1 , $2 , $3 , "nsrdb"  }'     nsrdb/geo_file/point_nsrdb.txt )  <( awk ' { print $1 , $2 , $3 , "nsrdbtmy3"  }'   nsrdb/geo_file/TMY3_x_y_station.txt   )   > geo_file/alldb_stations.txt



awk ' { print $1 , $2  }'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geo_file/alldb_stations.txt  >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geo_file/alldb_stations_x_y.txt


# uniq   station 
# not uniq  station  


export EXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract
cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract
# start to extract export beam ( direct )


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_Hrad*_month*.tif  | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geo_file/alldb_stations_x_y.txt  $file <<EOF
1
2
EOF

awk \'{  print int($5) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt
' _ 

# start to extract export diffuse 

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/diff_Hrad_month_merge/diff_Hrad*_month*.tif   | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geo_file/alldb_stations_x_y.txt  $file <<EOF
1
2
EOF

awk \'{  print int($5) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt

' _ 

# export the cloud  at point location 

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLOUD/month/MCD09_mean_??.tif  | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geo_file/alldb_stations_x_y.txt  $file <<EOF
1
2
EOF

awk \'{  print int($5) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt

' _ 

#


# export the aeroslo at point location 


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/temp_smoth_1km_month_mean/AODmeanMM??.tif  | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geo_file/alldb_stations_x_y.txt  $file <<EOF
1
2
EOF

awk \'{  print int($5) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt

' _ 



echo X Y IDstat db  $(for month in $(seq 1 12 ) ; do echo -n  "dCA_m$month "  ; done ) $(for month in $(seq 1 12 ) ; do echo -n  "dT_m$month " ;done  )  $(for month in $(seq 1 12 ) ; do echo -n  "bCA_m$month "  ; done ) $(for month in $(seq 1 12 ) ; do echo -n  "bT_m$month " ;done  )  $(for month in $(seq 1 12 ) ; do echo -n  "CL_m$month " ;done  ) $(for month in $(seq 1 12 ) ; do echo -n  "AE_m$month " ;done  )  > $EXT/Hrad_model.txt

paste -d " "  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geo_file/alldb_stations.txt    $EXT/diff_Hrad*_month??_tmp.txt $EXT/beam_Hrad*_month??_tmp.txt   $EXT/MCD09_mean_??_tmp.txt $EXT/AODmeanMM??_tmp.txt    >> $EXT/Hrad_model.txt

