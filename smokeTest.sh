#!/bin/bash

while read url; do
	STATUS=`curl -sI -o /dev/null -w "%{http_code}" $url`
	if [ $STATUS -ge 400 ]; then
		echo "FAIL: [Error $STATUS] $url"
		exit 1
	fi
	subUrls=`wget -q $url -O - | \
	    tr "\t\r\n'" '   "' | \
	    grep -i -o '<link[^>]\+href[ ]*=[ \t]*"\(ht\|f\)tps\?:[^"]\+"\|<script[^>]\+src[ ]*=[ \t]*"\(ht\|f\)tps\?:[^"]\+"' | \
	    sed -e 's/^.*"\([^"]\+\)".*$/\1/g'`

	for subUrl in $subUrls; do
		STATUS=`curl -sI -o /dev/null -w "%{http_code}" "$subUrl"`
		if [ $STATUS -ge 400 ]; then
		    echo "FAIL: [Error $STATUS] $subUrl"
		    exit 1
		fi
	done
done < $1
echo "OK"
exit 0;