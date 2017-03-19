#!/bin/bash

ls -lR $1 > raw.temp

awk '

BEGIN { RS = "" } ;

{
  split($0, x, ":\n");
  if (x[2] !~ /\nd|\.srt\n/) {
    print x[1];
  }
}

' raw.temp > folders.temp

rm raw.temp

CURL_VERSION=$

while read FOLDER; do
  VID_EXT_RE="\.(mpg|MPG|flv|FLV|wmv|WMV|avi|AVI|mkv|MKV|mov|MOV|mp4|MP4)$"
  for FILE in "$FOLDER"/*.*; do
    if [[ "$FILE" =~ $VID_EXT_RE ]]; then
      MD5=$(./md5ex.sh "$FILE")
      echo $FILE " " $MD5
      #curl -A "SubDB/1.0 (curl/7.35.0 https://curl.haxx.se)" "http://api.thesubdb.com/?action=download&hash=$MD5&language=en" -o "$FOLDER/engsub.srt"
    fi
  done
done < folders.temp

rm folders.temp
