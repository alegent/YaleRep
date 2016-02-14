

INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/txt
OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/matrix

for km in 1 5 10 50 100 ; do 
    for  file in $INDIR/*.txt ; do
	filename=$(basename $file  _msk.tif.txt  )
	awk '{ if ($6>=0 ) {sign="+"} else {sign="-"} ; print $1="" , $2 , $4 , $6 , sign sqrt($8) ,  $10 , $12 , sign sqrt($14)    }' $file     > $OUTDIR/$filename.txt
    done 
done 






