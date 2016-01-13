#!/bin/sh

# Persist transmission settings for use by transmission-daemon
dockerize -template /etc/transmission/environment-variables.tmpl:/etc/transmission/environment-variables.sh /bin/true

# Source our persisted env variables from container startup
. /etc/transmission/environment-variables.sh

echo "Generating transmission settings.json from env variables"
# Ensure TRANSMISSION_HOME is created
mkdir -p ${TRANSMISSION_HOME}
dockerize -template /etc/transmission/settings.tmpl:${TRANSMISSION_HOME}/settings.json /bin/true

if [ ! -e "/dev/random" ]; then
  # Avoid "Fatal: no entropy gathering module detected" error
  echo "INFO: /dev/random not found - symlink to /dev/urandom"
  ln -s /dev/urandom /dev/random
fi

echo "STARTING TRANSMISSION"
exec /usr/bin/transmission-daemon -g ${TRANSMISSION_HOME} --logfile ${TRANSMISSION_HOME}/transmission.log &

echo "Transmission startup script complete."
