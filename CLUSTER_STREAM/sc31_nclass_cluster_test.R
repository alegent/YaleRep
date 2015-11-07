module unload Apps/R/3.0.2
module load Apps/R/3.0.2-generic

echo sampling the data
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training


echo "BIO_12 BIO_7 dem_avg lu_10 lu_1 lu_2 lu_3 lu_4 lu_5 lu_6 lu_7 lu_8 lu_9 slope_avg soil_wavg_01 soil_wavg_02 soil_wavg_03 soil_wavg_05 upcells_land"  >   $TRAIN/training_1000_stack_forR.txt
cat $TRAIN/training_x*_y*_stack.txt  |  awk '{if (NR%1000==0)  { for (col = 5 ; col<NF ; col++ ) {  printf ("%s ", $col) } ;     printf ("%s\n", $NF)  }  }'  >>   $TRAIN/training_1000_stack_forR.txt

--vanilla --no-readline   -q  <<'EOF' 

table=read.table("/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training/training_1000_stack_forR.txt" , sep=" " , header = TRUE )

#Classify on environmental features (columns) of spatial units (rows) of data object

#Provides "optimal" clustering solution via gap statistic (cluster::clusGap; see ?clusGap and Tibshirani et al. 2001)

#   and cluster stability information (fpc::clusterboot; consistency of class identities across subsampled replicated clustering)

#Map/visual comparison against (faster) pam/pamk/clara shows hclust/agnes generate qualitatively better map output and are inherently more sensibly nested



if (!require("cluster")) {  install.packages("cluster", dependencies = TRUE);  library(cluster) }

#note fpc may fail on "robustbase" dependency, requiring local install via, e.g., https://urldefense.proofpoint.com/v2/url?u=http-3A__cran.r-2Dproject.org_bin_macosx_mavericks_contrib_3.1_robustbase-5F0.92-2D1.tgz&d=AwIGAg&c=-dg2m7zWuuDZ0MUcV7Sdqw&r=MXazMdKSnmM5Mf9FIedcjvkS-lLqGXZJ4pWDg01pvls&m=22ZP5syqtY4bAusPBiU7ijMIcRxi8oymPkWhoKgGFko&s=y3CwdAhD-KH9OIvU2GcrGXfcaelW4IPO2hzoogFTv9k&e= 

# if (!require("fpc")) {  install.packages("fpc", dependencies = TRUE) ; library(fpc)}

if (!require("fastcluster")) {  install.packages("fastcluster", dependencies = TRUE) ; library(fastcluster)}



streamCluster = function (

  scef,  #(s)tream (c)umulative (e)nvi (f)eatures dataframe (or @data of SpatialDataFrame) object with rows=cells, cols=aggregated/weighted environmental variables

  feat = colnames(scef), # to allow subsets of environmental features if desired

  maxClasses = 5, #default set low

  randSeed = 9797, #should not matter much

  gapBoots = 100 #the underlying function default

) 

{  

  set.seed(randSeed)

  hc = hclust(dist(scef, method="euclidean"), method="ward.D2") #the basic hierarchical solution

  #   clusGap requires that hierarchical methods have a wrapper w/cuttree 

  #   note output is equivalent to cluster::agnes given equivalent settings, i.e., 'ward'=='ward.D2'

  #   but fastcluster masks the hclust name for speedup

  hcl_wrap = function(x, k) list(cluster = cutree(hclust(dist(x, method="euclidean"), method = "ward.D2"), k=k))

  cg = clusGap(x=scef, FUNcluster=hcl_wrap, K.max=maxClasses, B=gapBoots)

  #Using default firstSEmax rule on gap, generate cluster stability

  cb = clusterboot(data=scef, B=100, seed=randSeed, bootmethod="boot", multipleboot=FALSE,

                   clustermethod=hclustCBI, method="ward.D2", 

                   scaling=F, k=maxSE(cg$Tab[,"gap"], cg$Tab[,"SE.sim"]))

  return(list(hc=hc, cg=cg, cb=cb))

} #end function


toy = rbind(iris, iris, iris, iris)

system.time(toy.clus <- streamCluster(scef = toy, feat=c("Sepal.Length", "Sepal.Width"), maxClasses = 10))


system.time( table.clust  <- streamCluster(scef = table, feat=colnames(table), maxClasses = 20))

toy.clus$cb$nccl  # write to a file 


EOF
