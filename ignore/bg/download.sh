#!/bin/bash
i=0
o=0

./purgeDupes # Purge dupes and prep

sleep 1

while read line; do
	if [[ -z $line ]]; then # Exit if line is empty
		print
	fi
	URL="${line}/download"
	FILEBAD=`echo "${line}" | grep -oE '[^/]+$'`
	FILE="single/Unsplash-${FILEBAD}.jpg"
	((i++))
	if [ ! -f "$FILE" ]; then # Only run if file doesnt exist
		wget $URL -O $FILE
		((o++))
	fi
done < "unsplash.txt"

function print {
	echo ""
	echo "Downloaded $o of $i images --==:==-- $(( 100*$o/$i ))%"
	exit
}
print
