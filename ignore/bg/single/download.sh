while read line; do
	# wget "${line}/download" -O ""
	if [${line} == ""]; then
		exit
	fi
	URL="${line}/download"
	FILEBAD=`echo "${line}" | grep -oE '[^/]+$'`
	FILE="Unsplash-${FILEBAD}.jpg"
	wget $URL -O $FILE
done < "unsplash.txt"

