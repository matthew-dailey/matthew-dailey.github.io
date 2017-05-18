#!/bin/bash

title=$1

if [[ -z "$title" ]] ; then
    echo "Usage: $0 post_title"
    exit 1
fi

HERE=$(dirname $0)

today=$(date +%Y-%m-%d)
now=$(date +%H):00:00
filename="${today}-${title}.markdown"
dest_path="$HERE/_posts/$filename"

cp "$HERE/post-template.markdown" "$dest_path"
sed -i "" 's/^title:  ""/title:  "'$title'"/' "$dest_path"
sed -i "" 's/^date:.*$/date:   '"${today} ${now}"'/' "$dest_path"
