#!/bin/bash

# Requirements: fd, rg

if [ -z "$1" ] 
then
	echo "[-] Must provide an APK"
	echo "[-] Syntax: contains_files <apk> <filename1,filename2,...>"
	exit 1
fi

if [ -z "$2" ] 
then
	echo "[-] Must provide file names to search"
	echo "[-] Syntax: contains_files <apk> <filename1,filename2,...>"
	exit 1
fi

SEARCH_TYPE="f"
if [ ! -z "$3" ] 
then
	SEARCH_TYPE="$3"
fi

if [[ ! -d "./tmp" ]]; then
	mkdir ./tmp
fi

APK_FILE=$1
TMP_STAMP=$(date +%s)
TMP_APK_NAME=$TMP_STAMP
TMP_APK_DIR="./tmp/${TMP_APK_NAME}"
TMP_APK_NAME="${TMP_APK_NAME}.apk"
IFS=',' read -r -a NAMES_TO_SEARCH <<< "$2"

if [[ ! -d "${TMP_APK_DIR}" ]]; then
	mkdir $TMP_APK_DIR
fi

cp "${APK_FILE}" "${TMP_APK_DIR}/${TMP_APK_NAME}"

function clean_and_exit {
	echo "[+] Cleaning ../../${TMP_STAMP}"
	rm -Rf "../../${TMP_STAMP}"
	exit 1
}

cd $TMP_APK_DIR

echo "[+] Running apktool on ${TMP_APK_NAME}"
apktool --quiet -f d "./${TMP_APK_NAME}"

cd $TMP_STAMP

if [ -f "./AndroidManifest.xml" ]
then
	echo "[+] ${TMP_APK_NAME} decoded successfully."
else
	clean_and_exit "[-] Failed decoding ${TMP_APK_NAME}"
fi

echo "[+] Searching for the following: ${NAMES_TO_SEARCH}"

for keyword in "${NAMES_TO_SEARCH[@]}"
do
	echo "[+] Searching for file: ${keyword}..."
	if [ "$SEARCH_TYPE" = "f" ]; then
	  	RESULT=$(fd --fixed-strings $keyword)
	elif [ "$SEARCH_TYPE" = "d" ]; then
		RESULT=$(rg $keyword)
	fi
	
	if [ -z "${RESULT}" ]; then
		echo "[-] ${keyword} not found!"
	else
		echo "[+] ${keyword} found!"
		echo "[+] Results:"
		echo "${RESULT}"

		OUT="../../results.txt"
		
		echo "${APK_FILE}:${keyword}" >> $OUT
		echo "----------------------" >> $OUT
		echo "${RESULT}" >> $OUT
		echo "######################" >> $OUT
	fi
done

clean_and_exit "[+] ${APK_NAME} matches!"