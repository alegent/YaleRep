# growing the lst of 1 pixel
# qsub  -v SENS=MYD /u/gamatull/scripts/LST/spline/sc3_sc4_allobservation_noenlarge4spline_medianIndiaMOYD11A2.sh

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=23
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo   /u/gamatull/scripts/LST/spline/sc3_sc4_allobservation_noenlarge4spline_MOYD11A2.sh   
export SENS=${SENS}
export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export MSK=/nobackup/gamatull/dataproces/LST/${SENS}11A2_mean_msk
export RAMDIR=/dev/shm

rm -f /dev/shm/*

# cluster class to mask out 

module load R/3.1.1_rgal_nex


# per questo R ci voglio 16 ore 
# echo 137 145 153 161 169 177 185 193 201 209 217 225 233 241 249    | xargs -n 1 -P 23   bash -c $'

# export DAY=$1 

# gdal_translate -projwin 65 35 95 5  -co COMPRESS=LZW -co ZLEVEL=9 ${INSENS}/LST_${SENS}_QC_day${DAY}_wgs84.tif ${INSENS}/indiaLST_${SENS}_day${DAY}_wgs84.tif
# # gdal_translate -projwin 75 30 90 20  -co COMPRESS=LZW -co ZLEVEL=9 ${INSENS}/LST_${SENS}_QC_day${DAY}_wgs84.tif ${INSENS}/indiaLST_${SENS}_day${DAY}_wgs84.tif
# # w=50
# # f=median
# # abbandonato 
# # pkfilter -nodata 0  -circ -dx $w -dy $w  -f $f  -co COMPRESS=LZW -co ZLEVEL=9    -i ${INSENS}/indiaLST_${SENS}_day${DAY}_wgs84.tif -o ${INSENS}/indiaLST_${SENS}_day${DAY}_wgs84_medianf.tif


# R --vanilla -q <<EOF

# library(raster)

# DAY = Sys.getenv(\'DAY\')
# SENS = Sys.getenv(\'SENS\')

# rast = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_mean/indiaLST_",SENS,"_day", DAY , "_wgs84.tif",sep="")  , band=1)
# NAvalue(rast)=0

# # see  https://scrogster.wordpress.com/2012/10/05/applying-a-circular-moving-window-filter-to-raster-data-in-r/ 

# make_circ_filter<-function(radius, res){
#   circ_filter<-matrix(NA, nrow=1+(2*radius/res), ncol=1+(2*radius/res))
#   dimnames(circ_filter)[[1]]<-seq(-radius, radius, by=res)
#   dimnames(circ_filter)[[2]]<-seq(-radius, radius, by=res)
#   sweeper<-function(mat){
#     for(row in 1:nrow(mat)){
#       for(col in 1:ncol(mat)){
#         dist<-sqrt((as.numeric(dimnames(mat)[[1]])[row])^2 +
#           (as.numeric(dimnames(mat)[[1]])[col])^2)
#         if(dist<=radius) {mat[row, col]<-1}
#       }
#     }
#     return(mat)
#   }
# out<-sweeper(circ_filter)
# return(out)
# }

# cf<-make_circ_filter(100, 1)


# mean.default <- 
# function (x, trim = 0, na.rm = FALSE, ..., side="both") 
# {
#     if (!is.numeric(x) && !is.complex(x) && !is.logical(x)) {
#         warning("argument is not numeric or logical: returning NA")
#         return(NA_real_)
#     }
#     if (na.rm) 
#         x <- x[!is.na(x)]
#     if (!is.numeric(trim) || length(trim) != 1L) 
#         stop("'trim' must be numeric of length one")
#     n <- length(x)
#     if (trim > 0 && n) {
#         if (is.complex(x)) 
#             stop("trimmed means are not defined for complex data")
#         if (any(is.na(x))) 
#             return(NA_real_)
#         if (trim >= 0.5) 
#             return(stats::median(x, na.rm = FALSE))
#         lo <- if( side=="both" || side=="right" ){ floor(n * trim) + 1 }else{1}
#         hi <- if( side=="both" || side=="left" ){ n + 1 - (floor(n * trim) + 1 ) }else{ n}
#         x <- sort.int(x, partial = unique(c(lo, hi)))[lo:hi]
#       # cat(c(length(x), lo , hi) ) # this is usefull to see the tail 
#     }
#     .Internal(mean(x))
# }

# r_filt = focal(rast , w=cf, file=paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_mean/indiaLST_",SENS,"_day", DAY , "_wgs84_quantile.tif",sep="") ,     options=c("COMPRESS=LZW")    ,  fun= function  (x) {    mean(x, trim = 0.50, na.rm = T , side="right" ) }  , overwrite=TRUE , NAflag=0 )

# # r_filt = focal(rast , w=cf, file=paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_mean/indiaLST_",SENS,"_day", DAY , "_wgs84_quantile.tif",sep="") ,     options=c("COMPRESS=LZW")    ,  fun= function  (x) { quantile( x , probs=c(0.90) , na.rm=T )}  , overwrite=TRUE , NAflag=0 )

# EOF

# ' _


echo 137 145 153 161 169 177 185 193 201 209 217 225 233 241 249    | xargs -n 1 -P 23   bash -c $'  
DAY=$1
pksetmask -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9  -m  /nobackupp8/gamatull/dataproces/LST/MASK/india${SENS}43obs.tif  -msknodata 0  -nodata 0 -i $INSENS/indiaLST_${SENS}_day${DAY}_wgs84_quantile.tif  -o $INSENS/indiaLST_${SENS}_day${DAY}_wgs84_quantileMSK.tif

pkcomposite  -srcnodata  0 -dstnodata 0  -co COMPRESS=LZW -co ZLEVEL=9  -i $INSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif -i $INSENS/indiaLST_${SENS}_day${DAY}_wgs84_quantileMSK.tif  -o  $INSENS/LST_${SENS}_QC_day${DAY}_wgs84_TrimmskPK.tif
' _ 


cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  | xargs -n 1 -P  23   bash -c $'
DAY=$1

if [ $DAY -ge  169 ] &&  [ $DAY -le 233 ] ; then CL="_TrimmskPK" ; fi 

echo oft-calc -ot Byte  $INSENS/LST_${SENS}_QC_day${DAY}_wgs84${CL}.tif  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_allobsBolean.tif <<EOF
EOF
1
#1 1 > 0 1 ?
EOF

' _                                                                                                                               

rm -f   $RAMDIR/LST_${SENS}.vrt  
gdalbuildvrt -overwrite -separate  $RAMDIR/LST_${SENS}.vrt  $OUTSENS/LST_${SENS}_QC_day???_wgs84_allobsBolean.tif 

oft-calc -ot Byte  $RAMDIR/LST_${SENS}.vrt  $RAMDIR/${SENS}_LST3k_count.tif   <<EOF
1
#1 #2 #3 #4 #5 #6 #7 #8 #9 #10 #11 #12 #13 #14 #15 #16 #17 #18 #19 #20 #21 #22 #23 #24 #25 #26 #27 #28 #29 #30 #31 #32 #33 #34 #35 #36 #37 #38 #39 #40 #41 #42 #43 #44 #45 #46 + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
EOF

pkcreatect   -min 0 -max 46   > /tmp/color.txt
pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct  /tmp/color.txt   -i     $RAMDIR/${SENS}_LST3k_count.tif  -o  $MSK/${SENS}_LST3k_mask_daySUM_wgs84_allobs.tif

# the max value is considered as 1 ; max <= 5  ; this is used in combination of the sea mask to select only pixel with more than 5 obs.                         
pkgetmask -min -1 -max 5 -data 1 -nodata 0 -co COMPRESS=LZW -co ZLEVEL=9   -i  $MSK/${SENS}_LST3k_mask_daySUM_wgs84_allobs.tif -o $MSK/${SENS}_LST3k_mask_daySUM_wgs84_allobs_mask5noobs.tif
# mask all pixel with les than 5 obs in the year

cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  | xargs -n 1 -P 23    bash -c $'
DAY=$1
echo masking $DAY  $SENS
# 0 for the cloud and -1 for the sea  and -1 also for the pixel with less than 5 observation
# 0 lst with 0 value
# OBS_${SENS}_QC_day${DAY}_wgs84.tif  exclude pixel with less then one observation over 12 years

if [ $DAY -ge  169 ] &&  [ $DAY -le 233 ] ; then CL="_TrimmskPK" ; fi 

pksetmask -co COMPRESS=LZW -co ZLEVEL=9  \
-m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif      -msknodata 255   -nodata -1   \
-m  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_count_yessea_ct.tif      -msknodata 0     -nodata -1   \
-m  $MSK/${SENS}_LST3k_mask_daySUM_wgs84_allobs_mask5noobs.tif                                      -msknodata 1     -nodata -1   \
-i  $INSENS/LST_${SENS}_QC_day${DAY}_wgs84${CL}.tif  -o  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_allobs_mask5noobs.tif

' _

rm  -f /dev/shm/*

qsub -v SENS=$SENS   /u/gamatull/scripts/LST/spline/sc5_fillsplineAkima_MOYD11A2_allobs.sh
