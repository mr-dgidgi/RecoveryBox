#!/bin/bash
rfkill unblock wifi

ip link set Lan up

docker rm -f hotspot 2>/dev/null

docker run --rm \
    --net=host \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    --privileged \
    -e WLAN_INT="Lan" \
    -e WLAN_IP="192.168.200.1" \
    -e WLAN_MASK="24" \
    -v /etc/ap_config/:/etc/conf \
    --name hotspot \
    mrdgidgi/simple-hotspot