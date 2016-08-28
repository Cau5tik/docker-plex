#!/bin/bash
# If debug mode, then enable xtrace
set -x

# Set the defaults
RUN_AS_ROOT=${RUN_AS_ROOT:-true}
MEDIA_ROOT=/mnt/media

GROUP=plextmp

mkdir -p /config/logs/supervisor

touch /supervisord.log
touch /supervisord.pid
chown plex: /supervisord.log /supervisord.pid

# Preferences
[ -f /etc/default/plexmediaserver ] && . /etc/default/plexmediaserver
PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR:-${HOME}/Library/Application Support}"
PLEX_PREFERENCES="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Preferences.xml"
PLEX_PID="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/plexmediaserver.pid"

getPreference(){
  local preference_key="$1"
  xmlstarlet sel -T -t -m "/Preferences" -v "@$preference_key" -n "${PLEX_PREFERENCES}"
}

setPreference(){
  local preference_key="$1"
  local preference_val="$2"
  if [ -z "$(getPreference "$preference_key")" ]; then
    xmlstarlet ed --inplace --insert "Preferences" --type attr -n "$preference_key" -v "$preference_val" "${PLEX_PREFERENCES}"
  else
    xmlstarlet ed --inplace --update "/Preferences[@$preference_key]" -v "$preference_val" "${PLEX_PREFERENCES}"
  fi
}

if [ ! -f "${PLEX_PREFERENCES}" ]; then
  mkdir -p "$(dirname "${PLEX_PREFERENCES}")"
  ls -la "$(dirname "${PLEX_PREFERENCES}")"
  PLEX_PREFERENCES_DIR=$(dirname "${PLEX_PREFERENCES}")
  cp /Preferences.xml "${PLEX_PREFERENCES}"
fi
 
ls -la "$(dirname "${PLEX_PREFERENCES}")"

# Set the PlexOnlineToken to PLEX_TOKEN if defined,
# otherwise get plex token if PLEX_USERNAME and PLEX_PASSWORD are defined,
# otherwise account must be manually linked via Plex Media Server in Settings > Server
echo "PLEX_TOKEN :"${PLEX_TOKEN}
echo "PLEX_USERNAME :"${PLEX_USERNAME}
echo "PLEX_PASSWORD :"${PLEX_PASSWORD}
if [ -n "${PLEX_TOKEN}" ]; then
  setPreference PlexOnlineToken ${PLEX_TOKEN}
elif [ -n "${PLEX_USERNAME}" ] && [ -n "${PLEX_PASSWORD}" ] && [ -z "$(getPreference "PlexOnlineToken")" ]; then
  # Ask Plex.tv a token key
  PLEX_TOKEN=$(curl -u "${PLEX_USERNAME}":"${PLEX_PASSWORD}" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 0.9' \
    -H 'X-Plex-Platform-Version: 0.9' \
    -H 'X-Plex-Platform: xcid' \
    -H 'X-Plex-Product: Plex Media Server'\
    -H 'X-Plex-Device: Linux'\
    -H 'X-Plex-Client-Identifier: XXXX' --compressed | sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p')
fi

echo "AFTER PLEX_TOKEN :"${PLEX_TOKEN}
echo "PLEX_USERNAME :"${PLEX_USERNAME}
echo "PLEX_PASSWORD :"${PLEX_PASSWORD}

if [ "${PLEX_TOKEN}" ]; then
  setPreference PlexOnlineToken "${PLEX_TOKEN}"
fi

# Tells Plex the external port is not "32400" but something else.
# Useful if you run multiple Plex instances on the same IP
[ -n "${PLEX_EXTERNALPORT}" ] && setPreference ManualPortMappingPort "${PLEX_EXTERNALPORT}"

# Allow disabling the remote security (hidding the Server tab in Settings)
[ -n "${PLEX_DISABLE_SECURITY}" ] && setPreference disableRemoteSecurity "${PLEX_DISABLE_SECURITY}"

# Detect networks and add them to the allowed list of networks
PLEX_ALLOWED_NETWORKS=${PLEX_ALLOWED_NETWORKS:-$(ip route | grep '/' | awk '{print $1}' | paste -sd "," -)}
[ -n "${PLEX_ALLOWED_NETWORKS}" ] && setPreference allowedNetworks "${PLEX_ALLOWED_NETWORKS}"


# Remove previous pid if it exists
rm "${PLEX_PID}"

# Current defaults to run as root while testing.
if [ "${RUN_AS_ROOT,,}" = "true" ]; then
  /usr/sbin/start_pms
else
  sudo -u plex -E sh -c "/usr/sbin/start_pms"
fi
