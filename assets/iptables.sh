#!/bin/bash
## Managed by network-configurator
WAN=("Wan")
if [[ $1 == "start" ]]; then
    ################################################
    # All rules should be placed below this line
    ################################################

    ## INPUT rules

    ## OUTPUT rules

    ## FORWARD rules
    # Allow Forwarding trafic to WAN
    for interface in "${WAN[@]}"; do
        iptables -I FORWARD -o "$interface" -j ACCEPT
    done
    iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    ## NAT rules
    # "Auto NAT" trafic to WAN
    for interface in "${WAN[@]}"; do
        iptables -t nat -A POSTROUTING -o "$interface" -j MASQUERADE
    done

    ################################################
    # All rules should be placed above this line
    ################################################


    echo "IPtables rules applied"

elif [[ $1 == "stop" ]]; then
    iptables -F
    iptables -t nat -F POSTROUTING
    echo "IPtables rules removed"
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi