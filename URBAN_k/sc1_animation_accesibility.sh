# for DIR in accesibility  pop  rdensity_masked kernel lodes2 roads2   ; do qsub  -v DIR=$DIR  /lustre/home/client/fas/sbsc/ga254/scripts/URBAN_k/sc1_animation_accesibility.sh  ; done 
# bash /lustre/home/client/fas/sbsc/ga254/scripts/URBAN_k/sc1_animation_accesibility.sh accesibility

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

module load Apps/R/3.0.2 

export DIR=$1

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/$DIR/*11700.tif  | head -100  | xargs -n 1 -P 8 bash -c $' 


export file=$1
export filename=$(basename $file .tif)

export min=$(gdalinfo -mm $file   | grep "Comp" | awk \'{ gsub ("[=,]"," ") ; print $3   }\')
export max=$(gdalinfo -mm $file   | grep "Comp" | awk \'{ gsub ("[=,]"," ") ; print $4   }\')



R --vanilla --no-readline   -q  <<'EOF'


# source ("/home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_animationR.sh")
.libPaths( c( .libPaths(), "/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0") )

library(raster)
library(lattice , lib.loc ="/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0")
library(rasterVis)
library(foreach)



file = Sys.getenv(c("file"))
filename = Sys.getenv(c("filename"))
max = as.numeric(Sys.getenv(c("max")))
min = as.numeric(Sys.getenv(c("min")))
DIR = Sys.getenv(c("DIR"))

rmr=function(x){
## function to truly delete raster and temporary files associated with them
if(class(x)=="RasterLayer"&grepl("^/tmp",x@file@name)&fromDisk(x)==T){
file.remove(x@file@name,sub("grd","gri",x@file@name))
rm(x)
}
}


path = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/"

# for parallel
# you can use a foreach to do it in parallel too, if you like

# foreach(file=files.list) %dopar%{

## not sure exactly what this does, but there is basename(file) too...

png(paste("/lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/",DIR,"/",filename,".png",sep=""),width=1000,height=1000)

day001=raster(paste(file,sep=""))

day001

## be careful with this, it will recalculate the whole image into a temporary directory and not automatically delete it..
## I would suggest deleting it at the end of the loop...
 







if ( DIR  == "accesibility") { colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" )) ; des="Accessibility"  } 
if ( DIR  == "pop") { colR=colorRampPalette(c("green","yellow", "brown"))  ; des="Population density" ;  min=0 ;  max=1000 } 
if ( DIR  == "rdensity_masked") { colR=colorRampPalette(c("yellow", "orange" , "red", "brown" )) ; des="Road density" } 
if ( DIR  == "build_up_area") { colR=colorRampPalette(c("white", "grey", "black" )) ; des="Build up area" } 
if ( DIR  == "kernel") { colR=colorRampPalette(c(  "blue","green","yellow", "orange" , "red", "brown", "black"  )) ; des="Cluster class" } 

if ( DIR  == "lodes2") { colR=colorRampPalette(c(  "blue","green","yellow", "orange" , "red"  )) ; des="Jobs density"  ; min=0 ;  max=3000 } 
if ( DIR  == "roads2") { colR=colorRampPalette(c(  "blue", "yellow" , "green"  )) ; des="Roads cost"  ; min=0 ;  max=1.8 } 

n=100
at=seq(min,max,length=n)
cols=colR(n)
res=1e6 # res=1e4 for testing and res=1e6 for the final product
greg=list(ylim=c(-56,84),xlim=c(-180,180))

par(cex.axis=2, cex.lab=2, cex.main=2, cex.sub=2)

day001[day001>max] <- max
day001[day001<min] <- min


print ( levelplot(day001,col.regions=colR(n),  scales=list(cex=2) ,   cuts=99,at=at,colorkey=list(space="right",adj=2 , labels=list( cex=2.5)), panel=panel.levelplot.raster,   margin=T,maxpixels=res,ylab="", xlab=list(paste(des,sep="") , cex=3 , space="left" ) ,useRaster=T)    )

rmr(day001) # really  remove raster files, this will delete the temporary file
dev.off() 

EOF

# eog $DIR/png/$filename.png

' _ 

exit  

join -1 1 -2 1 <( ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/accesibility/*.png  | xargs -n 1 bash -c $'  echo  $(basename $1 )  ' _ ) <( ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/pop/*.png  | xargs -n 1 bash -c $'  var=$(basename $1 ) ; echo ${var:2}   ' _  )  >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/acc_pop.txt

join -1 1 -2 1  /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/acc_pop.txt  <( ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/rdensity_masked/*.png  | xargs -n 1 bash -c $'  var=$(basename $1 ) ; echo ${var:3}   ' _  )    >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/acc_pop_road.txt


convert   -delay 300   -loop 0  $(  cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/acc_pop_road.txt | xargs -n 1 bash -c $'  echo /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/accesibility/$1 ' _   )   /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/accesibility.gif

convert   -delay 300   -loop 0  $(  cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/acc_pop_road.txt | xargs -n 1 bash -c $'  echo /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/pop/p_$1 ' _   )   /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/pop.gif

convert   -delay 300   -loop 0  $(  cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/acc_pop_road.txt | xargs -n 1 bash -c $'  echo /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/rdensity_masked/rd_$1 ' _   )   /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/road.gif


convert   -delay 300   -loop 0  $(ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/kernel/*.png  | head -100 )  /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/kernel.gif 

convert   -delay 50    -loop 0  /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/accesibility/*.png  /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN_k/accesibility/accesibility.gif 


exit 

# sshpass -p "Fiat500_solo" scp ga254@omega.hpc.yale.edu:/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/png/geomorphic_class*    /home/selv/Documents/yale_projects/presentation_nov_2015/JPG_animation/form 

# cd /home/selv/Documents/yale_projects/presentation_nov_2015/JPG_animation/form
# for n in $(seq 1 9) ; do  ; mv geomorphic_class${n}_GMTED2010_md_km10p.png   geomorphic_class0${n}_GMTED2010_md_km10p.png    ; done 
# for file  in g*.png ; do composite -geometry +172+450 \(  class.png -resize 54%  \) $file class_$file ; done 
# ffmpeg -r 0.3   -i class_geomorphic_class%02d_GMTED2010_md_km10p.png  -vcodec libx264  -pix_fmt yuv420p -r 0.5  class_geomorphic_class_GMTED2010_md_km10p.mp4 