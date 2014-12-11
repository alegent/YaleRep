
# import nsrdb data 
# module load Applications/R/3.0.1

library(data.table)


path = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/nsrdb/nsrdb_month_average/"
files.list = list.files(path , pattern="c*.txt")

# importing the files with 
obs=c(1:12)
for(file in files.list)
{
  perpos <- which(strsplit(file, "")[[1]]==".")
  a = read.table(paste(path,file,sep=""), sep=" " , header=TRUE) 
  a$CODE = gsub(" ","",substr(file, 2, perpos-1))
  obs = rbind (obs , a   )
}


nsrdb = obs

save.image("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/nsrdb/RData/nsrdb.RData4")