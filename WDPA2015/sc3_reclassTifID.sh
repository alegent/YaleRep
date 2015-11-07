# qsub  /home/fas/sbsc/ga254/scripts/WDPA2015/sc3_reclassTifID.sh

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=10:00:00 
#PBS -l mem=4gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/txt_out

# cat *_tifs.tar.txt  > gridID_polyID.txt

# sort  -k 1 -g  gridID_polyID.txt   > gridID_polyID_s.txt    # ( uniq gridID  55499492  ;  uniq polyID  210137   )

# si annulla lo spazio tra le colonne per effettuare il sorting successivo 
# awk    '$1 != prev{printf "%s%s",ors,$1; ors=ORS; ofs=" "} {printf "%s%s",ofs,$2; ofs=""; prev=$1} END{print ""}'   gridID_polyID_s.txt   >  gridID_polyID_rowgroup.txt   #    ( uniq grid_id   55589932 )

# sort   -k 2 -g  gridID_polyID_rowgroup.txt  > gridID_polyID_rowgroup_s.txt   # viene fatto il sorting dalla 2 colonna in poi 

# awk '"x" $2 != prev { count++; prev = "x" $2 } {print $1, count}'   gridID_polyID_rowgroup_s.txt   >  gridID_molID.txt



# these line create erros see http://stackoverflow.com/questions/26062835/identify-uniq-value-with-awk/26064760?iemail=1&noredirect=1#26064760
# awk -F ,    '$1 != prev{printf "%s%s",ors,$1; ors=ORS; ofs=" "} {printf "%s%s",ofs,$2; ofs=""; prev=$1} END{print ""}' gridID_polyID_rowgroup_s.txt   >  gridID_molID.txt
# awk  '{  if (NR == 1) { old = $2 ; nr=1 ; print $1 , nr } else { if($2 == old){ print $1 , nr } else {  old = $2  ; nr=nr+1 ; print $1 , nr  }}}  ' gridID_polyID_rowgroup_s.txt > gridID_molID.txt  # (this is used for the reclass the tif) 
# awk   '{  if (NR == 1) { old = $2 ; nr=1 ; print $1 , nr , old } else { if($2 == old){ print $1 , nr , old } else {  old = $2  ; nr=nr+1 ; print $1 , nr , old  }}}  ' test1.txt
#                                          21600            10800
# split the stak in 8 tiles Size is 43200, 16800  so 10800  8400



# to do in litoria 
cd  /mnt/data2/scratch/WDPA2014_lv/grid_mol

scp  ga254@omega.hpc.yale.edu:/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/txt_out/gridID_molID.txt   . 

oft-reclass  -oi  grid_mol.tif glob_ID_rast.tif  <<EOF
gridID_molID.txt
1
1
2
0
EOF

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9    grid_mol.tif  grid_mol_tmp.tif
mv grid_mol_tmp.tif  grid_mol2015.tif


exit 







export RAM=/dev/shm

echo 0        0 10800 10800   > $RAM/tiles_xoff_yoff.txt
echo 10800    0 10800 10800  >> $RAM/tiles_xoff_yoff.txt
echo 21600    0 10800 10800  >> $RAM/tiles_xoff_yoff.txt
echo 32400    0 10800 10800  >> $RAM/tiles_xoff_yoff.txt
echo 0     10800 10800 10800  >> $RAM/tiles_xoff_yoff.txt
echo 10800 10800 10800 10800  >> $RAM/tiles_xoff_yoff.txt
echo 21600 10800 10800 10800  >> $RAM/tiles_xoff_yoff.txt
echo 32400 10800 10800 10800  >> $RAM/tiles_xoff_yoff.txt

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/grid_mol

cat $RAM/tiles_xoff_yoff.txt | head -1  | xargs -n 4 -P 1 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4
echo  $xoff $yoff $xsize $ysize  

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID/glob_ID_rast_super_compres.tif $RAM/glob_ID_rast_${1}_${2}.tif 

minmax=$(gdalinfo  -mm    $RAM/glob_ID_rast_${1}_${2}.tif  | grep -e Computed | awk  \'{ gsub ("[=,]", " " )  ; print  int($3) , int($4)  }\' )

min=$(  echo $minmax |  awk  \'{  print $1  }\'  )
max=$(  echo $minmax |  awk  \'{  print $2  }\'  )

echo min $min max $max

awk -v min=$min -v max=$max \'{ if( $1>=min  &&  $1<=max ) print }\' gridID_molID.txt >  $RAM/gridID_molID_${1}_${2}.txt

echo start $RAM/glob_ID_rast_${1}_${2}.tif relass

# pkreclass -nodata 0    -co COMPRESS=LZW  -co ZLEVEL=9   -code  $RAM/gridID_molID_${1}_${2}.txt    -i  $RAM/glob_ID_rast_${1}_${2}.tif  -o $DIR/grid_mol_${1}_${2}_pk.tif

echo oft-reclass  -oi $DIR/grid_mol_${1}_${2}_oft.tif  $RAM/glob_ID_rast_${1}_${2}.tif  <<EOF
$RAM/gridID_molID_${1}_${2}.txt
1
1
2
0
EOF


# rm $RAM/gridID_molID_${1}_${2}.txt $RAM/glob_ID_rast_${1}_${2}.tif 

' _

exit 

gdalbuildvrt -overwrite -tr 0.0083333333333 0.0083333333333 $RAM/grid_mol.vrt     /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/grid_mol/glob_ID_rast_*_*.tif

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot UInt16    $RAM/grid_mol.vrt /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/grid_mol/grid_mol.tif

rm -f $RAM/grid_mol.vrt

########## lockup table 

join -1 1 -2 1  <( awk -F , '{ print $1 , $2  }' gridID_polyID_s.txt)      <( sort -k 1,1 -g  gridID_molID.txt )  >   gridID_polyID_molID.txt
awk '{ print $2 , $3  }' gridID_molID_polyID.txt | sort -k 1 -g  | uniq  > polyID_molID.txt

# stessa operazione precedente ma stamp la nr come id e le altre polyID per lockup table 

# si inserisce  lo spazio tra le colonne
# awk -F ,    '$1 != prev{printf "%s%s",ors,$1; ors=ORS; ofs=" "} {printf "%s%s",ofs,$2; ofs=" "; prev=$1} END{print ""}'   gridID_polyID_s.txt   > gridID_polyID_rowgroup_s_with_space.txt 
# sort  -k 1 -g  gridID_polyID_rowgroup_s_with_space.txt  > gridID_polyID_rowgroup_s_with_space_s.txt   
# sort  -k 1 -g  gridID_molID.txt >   gridID_molID_s.txt
# join -1 1 -2 1     gridID_molID_s.txt  gridID_polyID_rowgroup_s_with_space_s.txt  >  gridID_molID_polyIDs.txt
# awk '{$1="" ; print $0   }' gridID_molID_polyIDs.txt | sort -k 1 -g  | uniq  > molID_polyIDs.txt

exit 


























