#!/bin/bash
## Managed by network-configurator

readarray -t EXTRA_INTERFACES < <(grep -vE '^(#|$)' /etc/iptables/wan_interfaces)
WAN=("Wan" "${EXTRA_INTERFACES[@]}")

if [[ $1 == "start" ]]; then

    # Create custom chains
    iptables -N RB-INPUT
    iptables -N RB-OUTPUT
    iptables -N RB-FORWARD
    iptables -t nat -N RB-POSTROUTING

    iptables -I INPUT -j RB-INPUT
    iptables -I OUTPUT -j RB-OUTPUT
    iptables -I FORWARD -j RB-FORWARD
    iptables -t nat -I POSTROUTING -j RB-POSTROUTING

    ################################################
    # All rules should be placed below this line
    ################################################
    ## INPUT rules
    iptables -A RB-INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A RB-INPUT -i Lan -j ACCEPT
    for interface in "${WAN[@]}"; do
        iptables -A RB-INPUT -i "$interface" -p icmp -j ACCEPT
        iptables -A RB-INPUT -i "$interface" -p tcp --dport 22 -j ACCEPT
        iptables -A RB-INPUT -i "$interface" -j DROP
    done

    ## OUTPUT rules

    ## FORWARD rules
    # Allow Forwarding trafic to WAN
    iptables -A RB-FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    for interface in "${WAN[@]}"; do
        iptables -A RB-FORWARD -o "$interface" -j ACCEPT
    done
    # Allow traffic to container
    iptables -A RB-FORWARD -o docker0 -j ACCEPT

    ## NAT rules
    # "Auto NAT" trafic to WAN
    for interface in "${WAN[@]}"; do
        iptables -t nat -A RB-POSTROUTING -o "$interface" -j MASQUERADE
    done

    ################################################
    # All rules should be placed above this line
    ################################################


    echo "IPtables rules applied"

elif [[ $1 == "stop" ]]; then
    iptables -F RB-INPUT
    iptables -F RB-OUTPUT
    iptables -F RB-FORWARD
    iptables -t nat -F RB-POSTROUTING

    iptables -D INPUT -j RB-INPUT
    iptables -D OUTPUT -j RB-OUTPUT
    iptables -D FORWARD -j RB-FORWARD
    iptables -t nat -D POSTROUTING -j RB-POSTROUTING

    iptables -X RB-INPUT
    iptables -X RB-OUTPUT
    iptables -X RB-FORWARD
    iptables -t nat -X RB-POSTROUTING
    
    echo "IPtables rules removed"
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi