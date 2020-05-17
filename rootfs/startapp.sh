#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config
exec /usr/bin/chromium-browser $url --start-maximized --profile-directory=Default --use-gl=swiftshader --disable-software-rasterizer --disable-dev-shm-usage
