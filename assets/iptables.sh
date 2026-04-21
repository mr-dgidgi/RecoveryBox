#!/bin/bash
WAN="nic0"
if [[ $1 == "start" ]]; then
    iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE
    echo "IPtables rules applied"
elif [[ $1 == "stop" ]]; then
    iptables -F
    echo "IPtables rules removed"
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi