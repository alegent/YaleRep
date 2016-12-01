for file in $(./bin/google-cloud-sdk/bin/gsutil ls   gs://data.earthenv.org/topography/aspect-sine*) ; do  ./bin/google-cloud-sdk/bin/gsutil mv $file $(echo $file |  awk '{ gsub("-","") ; print }' ) ; done



for file in $(~/bin/google-cloud-sdk/bin/gsutil ls   gs://data.earthenv.org/topography/*mx*) ; do ~/bin/google-cloud-sdk/bin/gsutil  mv $file $(echo $file |  awk '{ gsub("mx","ma") ; print }' ) ; done