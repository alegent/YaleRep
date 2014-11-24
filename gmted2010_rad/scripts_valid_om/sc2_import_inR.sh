
# module load Applications/R/3.0.1  
# source ("/home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_valid_om/sc3_importing_inR2.R")

pathd  = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/d/"
patht1 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t1/"
patht2 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t2/"
patht3 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t3/"
patht4 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t4/"
patht5 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t5/"
patht6 = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/wrdc/txt/t6/"

files.listd = list.files(pathd , pattern="*_????_*.txt")
files.listt1 = list.files(patht1 , pattern="*_????_*.txt")
files.listt2 = list.files(patht2 , pattern="*_????_*.txt")
files.listt3 = list.files(patht3 , pattern="*_????_*.txt")
files.listt4 = list.files(patht4 , pattern="*_????_*.txt")
files.listt5 = list.files(patht5 , pattern="*_????_*.txt")
files.listt6 = list.files(patht6 , pattern="*_????_*.txt")

# importing the files with 

for(file in files.listd[1])
{
  # perpos <- which(strsplit(file, "")[[1]]==".")
  a = read.table(paste(pathd,file,sep=""), sep=" " , header=TRUE) 
  
}

a$CODE = gsub(" ","",substr(file, 2, perpos-1))
  obs = rbind (obs , a   )

