# module load Applications/R/3.0.1
# source ("/home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_valid_om/sc2_wrdc_importR.sh")
# setting up the list of observation file radiation

# data coming from here http://wrdc.mgo.rssi.ru/Protected/DataCGI_HTML/data_list_full/root_index.html 

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


module load Apps/R/3.1.1-generic

R --vanilla  <<'EOF'

library(data.table)

pathd = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/d/"

files.listd = list.files(pathd   , pattern="_????_d.txt")

# importing the files with

tmp2=c()
for(file in files.listd)
{
    perpos <- which(strsplit(file, "")[[1]]==".")
    
    a=readLines(paste(pathd,file,sep="")) 
    skiprow=grep ("DATE", a)

    a = read.table(paste(pathd,file,sep=""), sep="|" , header=TRUE , skip = (skiprow -1  )   ,  nrows = 31 , na.strings=c("-")  )

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
    station=substr(file, 1, perpos-8)
    year=substr(file, perpos-6, perpos-3)
    tmp$station = station
    tmp$year = year
    
    nam <- substr(file, 1, perpos-1)
    assign(nam, tmp)
    print (file)
}


temp <- list()
files.listd = ls(pattern="_d") 

for ( i in 1:length(files.listd))  { 
temp_get <- get(files.listd[i]) 
temp[[i]] <- temp_get  
}

final_list <- rbindlist(temp, fill=T)

nam <- paste("wrdc.dif")
assign(nam,final_list )

rm (list = files.listd) 
rm ( a, file, files.listd, final_list, header , i, item, list, nam, pathd , perpos, skiprow,station,temp ,temp_get , tmp, tmp2,year)

########################################## global ###########################

patht1 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t1/"
patht2 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t2/"
patht3 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t3/"
patht4 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t4/"
patht5 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t5/"
patht6 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t6/"


tmp2=c()
for ( path in  c(patht1,patht2,patht3,patht4,patht5,patht6)) {

if(path== patht1){ files.list = list.files(patht1 , pattern="_????_t1.txt")   } 
if(path== patht2){ files.list = list.files(patht2 , pattern="_????_t2.txt")   } 
if(path== patht3){ files.list = list.files(patht3 , pattern="_????_t3.txt")   } 
if(path== patht4){ files.list = list.files(patht4 , pattern="_????_t4.txt")   } 
if(path== patht5){ files.list = list.files(patht5 , pattern="_????_t5.txt")   } 
if(path== patht6){ files.list = list.files(patht6 , pattern="_????_t6.txt")   } 


for(file in files.list)
{
    perpos <- which(strsplit(file, "")[[1]]==".")

    a=readLines(paste(path,file,sep="")) 
    skiprow=grep ("DATE", a)

    a = read.table(paste(path,file,sep=""), sep="|" , header=TRUE ,  skip = (skiprow -1  ) ,  nrows = 31 , na.strings=c("-")  )

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
    station=substr(file, 1, perpos-9)
    year=substr(file, perpos-7, perpos-4)
    tmp$station = station
    tmp$year = year
    nam <- substr(file, 1, perpos-1)
    assign(nam, tmp)
    print (file)
}
}



temp <- list()
files.listd = ls(pattern="_t*") 

for ( i in 1:length(files.listd))  { 
temp_get <- get(files.listd[i]) 
temp[[i]] <- temp_get  
}

final_list <- rbindlist(temp, fill=T)

nam <- paste("wrdc.glo")
assign(nam,final_list )


rm (list = files.listd)

rm ( a,file,files.list,header,item,list,nam,path,perpos,station,tmp,tmp2,year,skiprow, files.listd, final_list, i, patht1, patht2, patht3, patht4, patht5, patht6, temp,temp_get)
 

save.image("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/Rdata/wrdc.RData")