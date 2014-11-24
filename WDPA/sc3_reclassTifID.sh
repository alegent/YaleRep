cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/csv_out

cat *_tifs.tar.csv  > gridID_polyID.csv

sort -t , -k 1 -g  gridID_polyID.csv   > gridID_polyID_s.csv    # ( uniq gridID  55499492  ;  uniq polyID  210137   )

# si annulla lo spazio tra le colonne per effettuare il sorting successivo 
awk -F ,    '$1 != prev{printf "%s%s",ors,$1; ors=ORS; ofs=" "} {printf "%s%s",ofs,$2; ofs=""; prev=$1} END{print ""}'   gridID_polyID_s.csv   >  gridID_polyID_rowgroup.txt   #    ( uniq grid_id   55589932 )

sort   -k 2 -g  gridID_polyID_rowgroup.txt  > gridID_polyID_rowgroup_s.txt   # viene fatto il sorting dalla 2 colonna in poi 

awk '"x" $2 != prev { count++; prev = "x" $2 } {print $1, count}'   gridID_polyID_rowgroup_s.txt   >  gridID_molID.txt



# these line create erros see http://stackoverflow.com/questions/26062835/identify-uniq-value-with-awk/26064760?iemail=1&noredirect=1#26064760
# awk -F ,    '$1 != prev{printf "%s%s",ors,$1; ors=ORS; ofs=" "} {printf "%s%s",ofs,$2; ofs=""; prev=$1} END{print ""}' gridID_polyID_rowgroup_s.txt   >  gridID_molID.txt
# awk  '{  if (NR == 1) { old = $2 ; nr=1 ; print $1 , nr } else { if($2 == old){ print $1 , nr } else {  old = $2  ; nr=nr+1 ; print $1 , nr  }}}  ' gridID_polyID_rowgroup_s.txt > gridID_molID.txt  # (this is used for the reclass the tif) 
# awk   '{  if (NR == 1) { old = $2 ; nr=1 ; print $1 , nr , old } else { if($2 == old){ print $1 , nr , old } else {  old = $2  ; nr=nr+1 ; print $1 , nr , old  }}}  ' test1.txt


# to do in litoria 
cd  /mnt/data2/scratch/WDPA_new/grid_mol/

scp  ga254@omega.hpc.yale.edu:/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/csv_out/gridID_molID.txt   . 

oft-reclass  -oi  grid_mol.tif glob_ID_rast.tif  <<EOF
gridID_molID.txt
1
1
2
0
EOF

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9    grid_mol.tif  grid_mol_tmp.tif
mv grid_mol_tmp.tif  grid_mol.tif



########## lockup table 

join -1 1 -2 1  <( awk -F , '{ print $1 , $2  }' gridID_polyID_s.csv)      <( sort -k 1,1 -g  gridID_molID.txt )  >   gridID_polyID_molID.txt


# stessa operazione precedente ma stamp la nr come id e le altre polyID per lockup table 

# si inserisce  lo spazio tra le colonne
# awk -F ,    '$1 != prev{printf "%s%s",ors,$1; ors=ORS; ofs=" "} {printf "%s%s",ofs,$2; ofs=" "; prev=$1} END{print ""}'   gridID_polyID_s.csv   > gridID_polyID_rowgroup_s_with_space.txt 
# sort  -k 1 -g  gridID_polyID_rowgroup_s_with_space.txt  > gridID_polyID_rowgroup_s_with_space_s.txt   
# sort  -k 1 -g  gridID_molID.txt >   gridID_molID_s.txt
# join -1 1 -2 1     gridID_molID_s.txt  gridID_polyID_rowgroup_s_with_space_s.txt  >  gridID_molID_polyIDs.txt
# awk '{$1="" ; print $0   }' gridID_molID_polyIDs.txt | sort -k 1 -g  | uniq  > molID_polyIDs.txt

















