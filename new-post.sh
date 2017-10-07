#!/bin/bash

## Creates a new post from the template file inside _posts using the current timestamp and a supplied title.

title=$1

if [[ -z "$title" ]] ; then
    echo "Usage: $0 post_title"
    exit 1
fi

HERE=$(dirname $0)
TEMPLATE_FILE="$HERE/post-template.markdown"

today=$(date +%Y-%m-%d)
now=$(date +%H):00:00

# take the title, replace spaces with dashes, and lowercase it
title_filename=$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
filename="${today}-${title_filename}.markdown"
dest_path="$HERE/_posts/$filename"

if [ -e "$dest_path" ] ; then
    echo "ERROR: Path $dest_path already exists.  Will not clobber."
    exit 1
fi

# Start with the template file, and replace the title and date with the correct values,
# outputting the result into dest_path, the new post file
sed -e 's/^title:  ""/title:  "'"$title"'"/' \
    -e 's/^date:.*$/date:   '"${today} ${now}"'/' \
    < "$TEMPLATE_FILE" \
    > "$dest_path"

echo "Created $dest_path"
