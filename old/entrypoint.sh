#!/bin/bash

echo "--------------------------"
echo " Janus-Gateway Entrypoint "
echo "--------------------------"

JANUS_CONFIG="/usr/local/etc/janus/janus.jcfg"

[[ -z "${DEBUG_LEVEL}" ]] && DEBUG_LEVEL=4
sed -i 's|${DEBUG_LEVEL}|'"$DEBUG_LEVEL"'|g' "$JANUS_CONFIG"

[[ -z "${ADMIN_SECRET}" ]] && ADMIN_SECRET="janusoverlord"
sed -i 's|${ADMIN_SECRET}|"'"$ADMIN_SECRET"'"|g' "$JANUS_CONFIG"

[[ -z "${SERVER_NAME}" ]] && SERVER_NAME="MyJanusInstance"
sed -i 's|${SERVER_NAME}|"'"$SERVER_NAME"'"|g' "$JANUS_CONFIG"

if [[ -n "${RECORDINGS_TMP_EXT}" ]]
then
  sed -i 's|${RECORDINGS_TMP_EXT_CONFIG}|  recordings_tmp_ext = "'"$RECORDINGS_TMP_EXT"'"|g' "$JANUS_CONFIG"
else
  sed -i 's|${RECORDINGS_TMP_EXT_CONFIG}|''|g' "$JANUS_CONFIG"
fi

if [[ -n "${RTP_PORT_RANGE}" ]]
then
  sed -i 's|${RTP_PORT_RANGE_CONFIG}|  rtp_port_range = "'"$RTP_PORT_RANGE"'"|g' "$JANUS_CONFIG"
else
  sed -i 's|${RTP_PORT_RANGE_CONFIG}|''|g' "$JANUS_CONFIG"
fi

[[ -z "${STUN_SERVER}" ]] && STUN_SERVER="stun.l.google.com"
sed -i 's|${STUN_SERVER}|"'"$STUN_SERVER"'"|g' "$JANUS_CONFIG"

[[ -z "${STUN_PORT}" ]] && STUN_PORT=19302
sed -i 's|${STUN_PORT}|'"$STUN_PORT"'|g' "$JANUS_CONFIG"

# run application
exec "$@"