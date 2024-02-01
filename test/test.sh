#!/bin/bash

cp -f test.txt.template test.txt

: ${ADMIN_SECRET:="janusoverlord"}
sed -i 's|${ADMIN_SECRET}|"'"$ADMIN_SECRET"'"|g' ./test.txt

: ${DEBUG_LEVEL:=4}
sed -i 's|${DEBUG_LEVEL}|'"$DEBUG_LEVEL"'|g' ./test.txt

if [[ -n "${RECORDINGS_TMP_EXT}" ]]
then
        RECORD='  recordings_tmp_ext = '${RECORDINGS_TMP_EXT}
        echo $RECORD
        sed -i 's|${RECORDINGS_TMP_EXT_CONFIG}|  recordings_tmp_ext = "'"${RECORDINGS_TMP_EXT}"'"|g' ./test.txt
else
        sed -i 's|${RECORDINGS_TMP_EXT_CONFIG}|''|g' ./test.txt
fi


