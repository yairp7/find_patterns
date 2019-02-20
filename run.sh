#!/bin/bash

KEYWORDS=$1

if [ -z "$KEYWORDS" ] 
then
	echo "[-] Must provide keywords!"
	echo "[-] Syntax: run <keywords> <apks_folder>"
	exit 1
fi

APKS_FOLDER=$2

if [ -z "$APKS_FOLDER" ] 
then
	echo "[-] Must provide apks folder!"
	echo "[-] Syntax: run ${KEYWORDS} <apks_folder>"
	exit 1
fi

declare -a arrApks
for file in $APKS_FOLDER/*.apk
do
    arrApks+=("$file")
    # echo $file
done

for file in "${arrApks[@]}"
do
	NEW_FILE=$(echo $file | tr ' ' '_')
	mv "${file}" $NEW_FILE
	echo "[+] Starting search on ${NEW_FILE}..."
	./contains_files.sh $file $KEYWORDS
done