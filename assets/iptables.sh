#!/bin/bash
WAN="nic0"
if [[ $1 == "start" ]]; then
    ################################################
    # All rules should be placed below this line
    ################################################

    ## INPUT rules

    ## OUTPUT rules

    ## FORWARD rules
    # Allow Forwarding trafic to WAN
    iptables -I FORWARD -o $WAN -j ACCEPT
    iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    ## NAT rules
    # "Auto NAT" trafic to WAN
    iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE

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