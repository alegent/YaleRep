

gdal_translate  -of AAIGrid  IGBP_classAll_binary_30secF.tif  IGBP_classAll_binary_30secFc.asc

awk '{ if (NR>6) {    for (c=1; c<=NF ; c++) {printf ("%s\n", $c) } }}' IGBP_classAll_binary_30secFc.asc  > IGBP_classAll_binary_30secFc_1col.asc

echo calculate unique value 

uniq  IGBP_classAll_binary_30secFc_1col.asc  | sort | uniq > IGBP_classAll_binary_30secFc_uniq.asc

(echo ibase=2; sed 's/ //g' IGBP_classAll_binary_30secFc_uniq.asc) | bc > IGBP_classAll_binary_30secFc_decimal.asc


paste -d " " IGBP_classAll_binary_30secFc_uniq.asc IGBP_classAll_binary_30secFc_decimal.asc > IGBP_classAll_binary_30secFc_bynaryDecimale.asc


# pkreclass  -ot Int32  -o IGBP_classAll_decimal_30secF_17digit.tif -i   IGBP_classAll_binary_30secF.tif -code IGBP_classAll_binary_30secFc_bynaryDecimale.asc  -co COMPRESS=LZW -co ZLEVEL=9