#!/bin/bash
rfkill unblock wifi
ip link set wlan0 up

docker rm -f hotspot 2>/dev/null

docker run --rm \
    --net=host \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    --privileged \
    -v /etc/ap_config/:/etc/conf \
    --name hotspot \
    mrdgidgi/simple-hotspot