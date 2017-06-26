tar xzvf  ...... 

export GSL_LIBS="-L/gpfs/apps/hpc/Libs/GSL/gsl-1.16/lib -lgsl -lgslcblas"
export CPPFLAGS="-I/gpfs/apps/hpc/Libs/ARMADILLO/3.900.6/include -I/home/apps/fas/Libs/GSL/gsl-1.15/include"
export GDAL_LDFLAGS="-L/gpfs/apps/hpc/Libs/GDAL/1.11.2/lib -lgdal"



cmake  -D  ARMADILLO_INCLUDE_DIR=/gpfs/apps/hpc/Libs/ARMADILLO/3.900.6/include/  -D  ARMADILLO_LIBRARY=/gpfs/apps/hpc/Libs/ARMADILLO/3.900.6/lib/libarmadillo.so  ..







./configure --with-gdal=/gpfs/apps/hpc/Libs/GDAL/1.11.2/bin/gdal-config --prefix=$HOME

