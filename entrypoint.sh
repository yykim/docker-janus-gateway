#!/bin/bash

echo "--------------------------"
echo " Janus-Gateway Entrypoint "
echo "--------------------------"

: ${DEBUG_LEVEL:="4"}
sed -i 's|${DEBUG_LEVEL}|'"$DEBUG_LEVEL"'|g' /usr/local/etc/janus/janus.jcfg

: ${ADMIN_SECRET:="janusoverlord"}
sed -i 's|${ADMIN_SECRET}|'\""$ADMIN_SECRET"\"'|g' /usr/local/etc/janus/janus.jcfg

: ${SERVER_NAME:="MyJanusInstance"}
sed -i 's|${SERVER_NAME}|'\""$SERVER_NAME"\"'|g' /usr/local/etc/janus/janus.jcfg

if [[ -n "${RECORDINGS_TMP_EXT}" ]] then
  sed -i 's|${RECORDINGS_TMP_EXT_CONFIG}|'recordings_tmp_ext = "$RECORDINGS_TMP_EXT"'|g' /usr/local/etc/janus/janus.jcfg
else
  sed -i 's|${RECORDINGS_TMP_EXT_CONFIG}|''|g' /usr/local/etc/janus/janus.jcfg
fi

# run application
exec "$@"