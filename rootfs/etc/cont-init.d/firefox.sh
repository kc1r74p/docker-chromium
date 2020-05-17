#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Make sure some directories are created.
mkdir -p /config/downloads
mkdir -p /config/log/firefox

# Generate machine id.
if [ ! -f /etc/machine-id ]; then
    log "generating machine-id..."
    cat /proc/sys/kernel/random/uuid | tr -d '-' > /etc/machine-id
fi

# Fix window display size is session stores.
if [ -n "$(ls /config/profile/sessionstore-backups/*.jsonlz4 2>/dev/null)" ]; then
    for FILE in /config/profile/sessionstore-backups/*.jsonlz4; do
        WORKDIR="$(mktemp -d)"

        dejsonlz4 "$FILE" "$WORKDIR"/json
        cp "$WORKDIR"/json "$WORKDIR"/json.orig

        sed -i 's/"width":[0-9]\+/"width":'$DISPLAY_WIDTH'/' "$WORKDIR"/json
        sed -i 's/"height":[0-9]\+/"height":'$DISPLAY_HEIGHT'/' "$WORKDIR"/json
        sed -i 's/"screenX":[0-9]\+/"screenX":0/' "$WORKDIR"/json
        sed -i 's/"screenY":[0-9]\+/"screenY":0/' "$WORKDIR"/json

        if ! diff "$WORKDIR"/json "$WORKDIR"/json.orig >/dev/null; then
            jsonlz4 "$WORKDIR"/json "$WORKDIR"/jsonlz4
            mv "$WORKDIR"/jsonlz4 "$FILE"
            log "fixed display size in $FILE."
        fi

        rm -r "$WORKDIR"
    done
fi


# Take ownership of the config directory content.
find /config -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;

# vim: set ft=sh :
