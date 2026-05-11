#!/bin/bash

WAN=wan
LAN=lan

## Systemd Networkd files order :
# 10-*.link
# 20-*.netdev
# 30-*.network

create_bridges() {
    cat <<EOF > /etc/systemd/network/20-wan.netdev
[NetDev]
Name=$WAN
Kind=bridge
EOF

    cat <<EOF > /etc/systemd/network/20-lan.netdev
[NetDev]
Name=$LAN
Kind=bridge
EOF

}

link_interfaces() {
    Interface=$1
    VInterface=$2
    cat <<EOF > /etc/systemd/network/20-${Interface}.network
[Match]
Name=${Interface}

[Network]
Bridge=${VInterface}
EOF
}

set_interfaces() {
    VInterface=$1
    Dhcp=$2
    Address=$3
    Gateway=$4
    Dns=$5
    NetworkOptions=$6
    DHCPv4Options=$7
    IPv6AcceptRAOption=$8
    # create network conf files for bridges
    cat <<EOF > /etc/systemd/network/20-${VInterface}.network
[Match]
Name=${VInterface}

[Network]
DHCP=${Dhcp}
Address=${Address}
Gateway=${Gateway}
DNS=${Dns}
${NetworkOptions}

[DHCPv4]
${DHCPv4Options}

[IPv6AcceptRA]
${IPv6AcceptRAOption}
EOF
}

