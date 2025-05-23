#!/bin/sh

cat >&2 <<EOF
*
* This script will be removed in the future to replace it with OpenRC user-services.
*
EOF

# Exit if the service is already running through user services
rc-service --user pipewire status 1>/dev/null 2>&1 && exit 0

# We need to kill any existing pipewire instance to restore sound
pkill -u "${USER}" -fx /usr/bin/pipewire-pulse 1>/dev/null 2>&1
pkill -u "${USER}" -fx /usr/bin/pipewire-media-session 1>/dev/null 2>&1
pkill -u "${USER}" -fx /usr/bin/wireplumber 1>/dev/null 2>&1
pkill -u "${USER}" -fx /usr/bin/pipewire 1>/dev/null 2>&1

exec /usr/bin/pipewire &

# wait for pipewire to start before attempting to start related daemons
while [ "$(pgrep -f /usr/bin/pipewire)" = "" ]; do
	sleep 1
done

if [ -x /usr/bin/wireplumber ]; then
	exec /usr/bin/wireplumber &
elif [ -x /usr/bin/pipewire-media-session ]; then
	exec /usr/bin/pipewire-media-session &
fi

[ -f "/usr/share/pipewire/pipewire-pulse.conf" ] && exec /usr/bin/pipewire-pulse &
