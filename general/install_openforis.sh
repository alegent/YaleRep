cd /home2/ga254/src/OpenForisToolkit-1.25.8

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0


EXE_path=/home2/ga254/bin

libgsl=`gsl-config --libs`
gslflags=`gsl-config --cflags`
libgdal=`gdal-config --libs`
gdalflags=`gdal-config --cflags`


echo "Installing new versions of executables"


for file in c/*.c ; do 

    echo $file
  
    name=`basename $file .c`

    echo gcc -o $EXE_path/$name $file $gdalflags $libgdal $gslflags $libgsl 

    gcc  -o $EXE_path/$name $file $gdalflags $libgdal $gslflags $libgsl  

done 


