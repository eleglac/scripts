#!/bin/bash

rm missing-subs

ls -lR > raw.temp

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
LANG=en

while read FOLDER; do
  VID_EXT_RE="\.(mpg|MPG|flv|FLV|wmv|WMV|avi|AVI|mkv|MKV|mov|MOV|mp4|MP4)$"
  for FILE in "$FOLDER"/*.*; do
    if [[ "$FILE" =~ $VID_EXT_RE ]]; then
      MD5=$(./md5ex.sh "$FILE")
    # echo $MD5 " is hash for " $FILE
      SRT_LOCAL_PATH="$FILE.subtitle.$LANG.srt"
      curl -A "SubDB/1.0 (curl/7.35.0 https://curl.haxx.se)" "http://api.thesubdb.com/?action=download&hash=$MD5&language=$LANG" -o "$SRT_LOCAL_PATH" 2> curl-result.log
      if [[ -s "$SRT_LOCAL_PATH" ]] #if the subtitle file created by curl is non-zero, assume it's a real subtitle file 
        then
	  echo "OK: Subtitle found for $FILE"
	else
	  echo "NULL RESULT: No sub found for $FILE!"
	  echo "$FILE" >> missing-subs
	  rm "$SRT_LOCAL_PATH" 
      fi
    fi
  done
done < folders.temp

rm folders.temp

