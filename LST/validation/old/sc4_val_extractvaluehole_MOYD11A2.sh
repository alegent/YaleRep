
#  qsub -v SENS=MOD  /u/gamatull/scripts/LST/sc4_val_extractvaluehole_MOYD11A2.sh

#PBS -S /bin/bash
#PBS -q devel
#PBS -l select=1:ncpus=4
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo $SENS   /u/gamatull/scripts/LST/sc5_fillspline_MOYD11A2.sh 

export  SENS=$SENS

export  INSENS=/nobackupp8/gamatull/dataproces/LST/MOD11A2_val/${SENS}11A2_splinefill
export RAMDIR=/dev/shm


rm -f /dev/shm/*

# clip the mask holl and create a txt file  

# geo_string=$(  oft-bb /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/MOD_area4holl.tif 1 | grep BB | awk '{ print $6,$7,$8-$6,$9-$7  }') 
# gdal_translate -srcwin $geo_string  -co COMPRESS=LZW -co ZLEVEL=9  /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/MOD_area4holl.tif /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/MOD_area4holl_crop.tif

# gdal_translate  -of XYZ  /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/MOD_area4holl_crop.tif /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/MOD_area4holl_crop.txt 

# awk '{ if ($3==1) print  $1 ,  $2  }'  /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/MOD_area4holl_crop.txt >   /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/holl_xy.txt 

# extract value for the holl 

for HOL in 1 2 3 4 5 6 7 8 9 ; do 

export HOL

export  OUTXT=/nobackupp8/gamatull/dataproces/LST/MOD11A2_val/${SENS}11A2_splinefill_${HOL}hole/txt

echo  h24v08  
echo  h24v06  h26v06  h26v08     | xargs -n 1 -P  3  bash -c $' 
# india tile ul=h24v06  ll=h24v08  ur=h26v06 lr=h26v08 
tile=$1

oft-extr -nomd -o $OUTXT/LST_${SENS}_cspline_${tile}.txt  /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/holl_xy.txt  ${INSENS}_${HOL}hole/LST_${SENS}_cspline_${tile}.tif   <<EOF 
1
2
EOF

oft-extr -nomd -o $OUTXT/LST_${SENS}_akima_${tile}.txt  /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/holl_xy.txt  ${INSENS}_${HOL}hole/LST_${SENS}_akima_${tile}.tif   <<EOF 
1
2
EOF

' _ 

done 


# extract observation value for the holl


export  INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill
export  OUTXT=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill/txt

echo  h24v08  
echo  h24v06  h26v06  h26v08     | xargs -n 1 -P  3  bash -c $' 
# india tile ul=h24v06  ll=h24v08  ur=h26v06 lr=h26v08 
tile=$1

oft-extr -nomd -o $OUTXT/LST_${SENS}_cspline_${tile}.txt  /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/holl_xy.txt  ${INSENS}/LST_${SENS}_cspline_${tile}.tif   <<EOF 
1
2
EOF

oft-extr -nomd -o $OUTXT/LST_${SENS}_akima_${tile}.txt  /nobackupp8/gamatull/dataproces/LST/MOD11A2_val/area_all/holl_xy.txt  ${INSENS}/LST_${SENS}_akima_${tile}.tif   <<EOF 
1
2
EOF

' _ 



