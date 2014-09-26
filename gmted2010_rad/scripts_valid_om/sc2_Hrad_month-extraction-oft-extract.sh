
# extracting data for the nsrdb

export EXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract

# start to extract export beam ( direct )

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_Hrad*_month*.tif    | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/shp/point_nsrdb.txt  $file <<EOF
1
2
EOF

awk \'{  print int($6) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt
' _ 



# start to extract export diffuse 

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/diff_Hrad_month_merge/diff_Hrad*_month*.tif    | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/shp/point_nsrdb.txt  $file <<EOF
1
2
EOF

awk \'{  print int($6) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt

' _ 

echo X Y IDstat  $(for month in $(seq 1 12 ) ; do echo -n  "dCA_m$month "  ; done ) $(for month in $(seq 1 12 ) ; do echo -n  "dT_m$month " ;done  )  $(for month in $(seq 1 12 ) ; do echo -n  "bCA_m$month "  ; done ) $(for month in $(seq 1 12 ) ; do echo -n  "bT_m$month " ;done  )   > $EXT/Hrad_model4nsrdb.txt
paste -d " "   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/shp/point_nsrdb.txt   diff_Hrad*_month??_tmp.txt  beam_Hrad*_month??_tmp.txt  >>  $EXT/Hrad_model4nsrdb.txt


# extracting data for the nsrdb_tmy3


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_Hrad*_month*.tif    | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/shp/TMY3_x_y_station.txt   $file <<EOF
1
2
EOF

awk \'{  print int($6) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt
' _ 



# start to extract export diffuse 

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/diff_Hrad_month_merge/diff_Hrad*_month*.tif    | xargs -n 1 -P 8 bash -c  $'
file=$1
filename=$(basename $file .tif )
oft-extr -nomd  -o $EXT/$filename.txt   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/shp/TMY3_x_y_station.txt    $file <<EOF
1
2
EOF

awk \'{  print int($6) }\'   $EXT/$filename.txt   >   $EXT/${filename}_tmp.txt 
rm  $EXT/$filename.txt

' _ 

echo X Y IDstat  $(for month in $(seq 1 12 ) ; do echo -n  "dCA_m$month "  ; done ) $(for month in $(seq 1 12 ) ; do echo -n  "dT_m$month " ;done  )  $(for month in $(seq 1 12 ) ; do echo -n  "bCA_m$month "  ; done ) $(for month in $(seq 1 12 ) ; do echo -n  "bT_m$month " ;done  )   > $EXT/Hrad_model4tmy3.txt
paste -d " "  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/shp/TMY3_x_y_station.txt    diff_Hrad*_month??_tmp.txt  beam_Hrad*_month??_tmp.txt  >>  $EXT/Hrad_model4tmy3.txt




