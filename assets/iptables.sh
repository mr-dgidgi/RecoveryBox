#!/bin/bash
## Managed by network-configurator
WAN=("Wan")
if [[ $1 == "start" ]]; then
    ################################################
    # All rules should be placed below this line
    ################################################

    ## INPUT rules
    iptables -A INPUT -i Lan -j ACCEPT
    for interface in "${WAN[@]}"; do
        iptables -A INPUT -i "$interface" -p tcp --dport 22 -j ACCEPT
        iptables -A INPUT -i "$interface" -j DROP
    done

    ## OUTPUT rules

    ## FORWARD rules
    # Allow Forwarding trafic to WAN
    iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    for interface in "${WAN[@]}"; do
        iptables -A FORWARD -o "$interface" -j ACCEPT
    done

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