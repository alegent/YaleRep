# module load Applications/R/3.0.1
# qsub /home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_valid_om/sc2_wrdc_gaw_importR.sh
# source ("/home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_valid_om/sc2_wrdc_gaw_importR.sh")
# setting up the list of observation file radiation
# data from http://wrdc.mgo.rssi.ru/wrdccgi/protect.exe?wrdc/data_gaw.htm 

# Global rad. 	glo_d.txt
# Diffuse rad. 	dif_d.txt
# Direct rad. 	dir_d.txt
# Spectral rad. spe_d.txt
# Downward rad. dwl_d.txt


#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

module load Applications/R/3.0.1



R --vanilla  <<'EOF'

library(data.table)

path = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc_gaw/txt/"


tmp2=c()

for ( rad in  c("glo", "dif", "dir" ) ) { 

# for ( rad in  c("glo") ) { 

tmp2=c()
if(rad=="glo"){ files.list = list.files(path , pattern="_glo_d.txt")   } 
if(rad=="dif"){ files.list = list.files(path , pattern="_dif_d.txt")   } 
if(rad=="dir"){ files.list = list.files(path , pattern="_dir_d.txt")   } 

for(file in files.list)
{
    perpos <- which(strsplit(file, "")[[1]]==".")
    a = read.table(paste(path,file,sep=""), sep="|" )  # provare a=readLines(paste(pathd,file,sep="")) 
    skiprow=grep ("DATE", a)
    a = read.table(paste(path,file,sep=""), sep="|" , header=TRUE , skip = (skiprow + 1 )   ,  nrows = 31 , na.strings=c("-")  )
    a$X<- NULL
    a$X.1<- NULL
    tmp <- gsub("[_ ]", "", as.matrix(a, perl=TRUE))
    tmp[tmp=="-"] <- NA
    tmp = apply(tmp, 2, as.numeric) 
    tmp = as.data.frame(tmp)
    header = gsub("[_X]", "", names(tmp) )
    colnames(tmp) <- header 
    header = colnames(tmp)
    list=header[1]
    for(item in   seq(2 , length(header) , by=2)) {
    list=c(list, header[item])
    list=c(list, paste ("F.",header[item],sep=""))
    }
    colnames(tmp) <- list

    perpos <- which(strsplit(file, "")[[1]]==".")
    station=substr(file, 1, perpos-12)
    year=substr(file, perpos-10, perpos-7)
    tmp$station = station
    tmp$year = year

    nam <- substr(file, 1, perpos-1)
    assign(nam, tmp)
    print (file)
    }
}

# this file create problem kishinev_2003_dif_d.txt... the "DATA" is not get in automatic.

rm ( a,file,files.list,header,item,list,nam,path,perpos,rad,station,tmp,tmp2,year,skiprow)



for ( rad in  c("glo", "dif", "dir" ) ) { 

if(rad=="glo"){ files.list = ls(pattern="_glo_d")   } 
if(rad=="dif"){ files.list = ls(pattern="_dif_d")   } 
if(rad=="dir"){ files.list = ls(pattern="_dir_d")   } 

temp <- list()

for ( i in 1:length(files.list))  { 

temp_get <- get(files.list[i]) 

temp[[i]] <- temp_get  

}

final_list <- rbindlist(temp, fill=T)

nam <- paste("wrdc.gaw.", rad, sep = "")
assign(nam,final_list )

}

rm (temp_get, temp,i)

# rm the file 

for ( rad in  c("glo", "dif", "dir" ) ) { 

if(rad=="glo"){ files.list = ls(pattern="_glo_d")   } 
if(rad=="dif"){ files.list = ls(pattern="_dif_d")   } 
if(rad=="dir"){ files.list = ls(pattern="_dir_d")   } 

rm (list = files.list) 

}
rm (final_list)

save.image("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc_gaw/Rdata/wrdc.gaw.RData")


