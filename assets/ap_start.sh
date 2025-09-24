#!/bin/bash
rfkill unblock wifi
docker run --rm --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW --privileged -v /etc/ap_config/:/etc/conf --name hotspot mrdgidgi/simple-pi-hotspot