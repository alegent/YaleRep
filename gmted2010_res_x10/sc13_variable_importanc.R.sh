
module unload Apps/R/3.0.2
module load  Applications/R/3.2.0-generic 

library("randomForest")
outfile  =  read.delim ( "/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/point_sp/x_y_km1.txt" ,  header = TRUE  ,  sep = " " ) 

random = randomForest(  SR ~ aspect.cosine_md + aspect.sine_md + dx_md + dxx_md + dy_md + dyy_md + eastness_md +  elevation_cv +  elevation_cv.1 +  elevation_md + elevation_range + geomorphic_ent + geomorphic_shannon + geomorphic_uni +  northness_md + pcurv_md +  roughness_md + slope_cv + slope_md + slope_range +  tcurv_md +  tpi_md + tri_md + vrm_md + geomorphic_class10 +  geomorphic_class1 + geomorphic_class2 +  geomorphic_class3 + geomorphic_class4  + geomorphic_class5  + geomorphic_class6 + geomorphic_class7 + geomorphic_class8 +  geomorphic_class9 +  geomorphic_count + geomorphic_majority , outfile , ntree=200,importance=TRUE )
