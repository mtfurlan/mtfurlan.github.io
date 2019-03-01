#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ $# -eq 0 ]; then
    #no arguments
    echo "pass a title"
    exit 1
fi

date=$(date +%Y-%m-%d)
file="$date-$1.markdown"


echo "creating '$file'"
if [ -f $file ]; then
    echo "file already exists"
    exit 1
fi

cat << EOF > $file
---
layout: post
title:  "$1"
categories:
---


<!--excerpt-->
EOF
