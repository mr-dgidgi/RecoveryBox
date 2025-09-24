#!/bin/bash

if [[ $1 == "start" ]]; then
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    echo "IPtables rules applied"
elif [[ $1 == "stop" ]]; then
    iptables -F
    echo "IPtables rules removed"
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi