for year in 2015 ; do 
export year
echo  065 081  097  113  129  145  161  177  193  209  225  241  257  273  289  305  321  337  353 073  089  105  121  137  153  169  185  201  217  233  249  265  281  297  313  329  345  361 | xargs -n 1 -P 20 bash -c $' 
dir=$1
cd  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/${year}/${dir} 
pwd
wget -c -N    -w 2 --waitretry=2 --random-wait   --no-remove-listing  ftp://ladsweb.nascom.nasa.gov/allData/5/MYD11A2/$year/$dir/*.hdf -o  download.005.log    
cd  /nobackupp6/aguzman4/climateLayers/MYD11A2.005/${year}/${dir} 
' _ 
done 
