# merge the tiles 

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l mem=10gb
#PBS -l walltime=0:01:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc//ga254/stderr


RASTERIZE=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize

# attribute of the shapefile land NO-MARINE

#   IUCN_CAT (String) = Ia               11
#   IUCN_CAT (String) = Ib               12
#   IUCN_CAT (String) = II               2
#   IUCN_CAT (String) = III              3
#   IUCN_CAT (String) = IV               4
#   IUCN_CAT (String) = Not Applicable   20
#   IUCN_CAT (String) = Not Reported     21
#   IUCN_CAT (String) = V                5
#   IUCN_CAT (String) = VI               6


# attribute of the shapefile MARINE

#   IUCN_CAT (String) = Ia               111
#   IUCN_CAT (String) = Ib               112
#   IUCN_CAT (String) = II               102
#   IUCN_CAT (String) = III              103
#   IUCN_CAT (String) = IV               104
#   IUCN_CAT (String) = Not Applicable   120
#   IUCN_CAT (String) = Not Reported     121
#   IUCN_CAT (String) = V                105
#   IUCN_CAT (String) = VI               106


# for n in 11 12 2 3 4 20 21 5 6 ; do 

#     echo rasterize the land category $n

#     if [ $n -eq 11  ] ; then  IUCN_CAT='Ia' ;  fi 
#     if [ $n -eq 12  ] ; then  IUCN_CAT='Ib' ;  fi 
#     if [ $n -eq 2   ] ; then  IUCN_CAT='II' ;  fi 
#     if [ $n -eq 3   ] ; then  IUCN_CAT='III';  fi 
#     if [ $n -eq 4   ] ; then  IUCN_CAT='IV' ;  fi 
#     if [ $n -eq 20  ] ; then  IUCN_CAT='NA' ;  fi 
#     if [ $n -eq 21  ] ; then  IUCN_CAT='NR' ;  fi 
#     if [ $n -eq 5   ] ; then  IUCN_CAT='V'  ;  fi 
#     if [ $n -eq 6   ] ; then  IUCN_CAT='VI' ;  fi 

# gdalbuildvrt  -overwrite  -tr 0.0083333333333 0.0083333333333    $RASTERIZE/tif_class/wdpaid_IUCN${n}_L.vrt   $RASTERIZE/$n/h??v??_IUCN${n}_L.tif
# gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot  UInt32    $RASTERIZE/tif_class/wdpaid_IUCN${n}_L.vrt   $RASTERIZE/tif_class/wdpaid_IUCN_${IUCN_CAT}_L.tif 
# rm  $RASTERIZE/tif_class/wdpaid_IUCN${n}_L.vrt

# done 



for n in 111 112 102 103 104 120 121 105 106 ; do  

    if [ $n -eq 111  ] ; then  IUCN_CAT='Ia' ;   fi 
    if [ $n -eq 112  ] ; then  IUCN_CAT='Ib' ;   fi 
    if [ $n -eq 102  ] ; then  IUCN_CAT='II' ;   fi 
    if [ $n -eq 103  ] ; then  IUCN_CAT='III';   fi 
    if [ $n -eq 104  ] ; then  IUCN_CAT='IV' ;   fi 
    if [ $n -eq 120  ] ; then  IUCN_CAT='NA' ;   fi 
    if [ $n -eq 121  ] ; then  IUCN_CAT='NR' ;   fi 
    if [ $n -eq 105  ] ; then  IUCN_CAT='V'  ;   fi 
    if [ $n -eq 106  ] ; then  IUCN_CAT='VI' ;   fi 

gdalbuildvrt  -overwrite  -tr 0.0083333333333 0.0083333333333    $RASTERIZE/tif_class/wdpaid_IUCN${n}_M.vrt   $RASTERIZE/$n/h??v??_IUCN${n}_M.tif
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot  UInt32    $RASTERIZE/tif_class/wdpaid_IUCN${n}_M.vrt   $RASTERIZE/tif_class/wdpaid_IUCN_${IUCN_CAT}_M.tif 
rm  $RASTERIZE/tif_class/wdpaid_IUCN${n}_M.vrt

done 

checkjob -v $PBS_JOBID