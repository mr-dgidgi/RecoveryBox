#!/bin/bash

SRVMSG=' =+= '
MSGGREEN='\033[0;32m'
MSGYELLOW='\033[0;33m'
MSGRED='\033[0;31m'
MSGNC='\033[0m'

WAN=wan
LAN=lan
PATHCONFIG="/etc/systemd/network"

## Systemd Networkd files order :
# 10-*.link
# 20-*.netdev
# 30-*.network

yes_no_check () {
	if [ "$1" = "Y" ] || [ "$1" = "y" ] || [ "$1" = "Yes" ] || [ "$1" = "yes" ] || [ "$1" = "Oui" ] || [ "$1" = "OUI" ] || [ "$1" = "oui" ] || [ "$1" = "O" ]; then
		echo 1

	elif [ "$1" = "N" ] || [ "$1" = "n" ] || [ "$1" = "No" ] || [ "$1" = "no" ] || [ "$1" = "Non" ] || [ "$1" = "NON" ] || [ "$1" = "non" ] || [ "$1" = "N" ]; then
		echo 0

	else
		echo 99

	fi
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "$MSGRED" "$SRVMSG" "This script must be run as root. Please run with sudo or as root user." "$MSGNC"
        exit 1
    fi
}

create_bridges() {
    cat <<EOF > "$PATHCONFIG"/30-wan.netdev
[NetDev]
Name=$WAN
Kind=bridge
EOF

    cat <<EOF > "$PATHCONFIG"/30-lan.netdev
[NetDev]
Name=$LAN
Kind=bridge
EOF

}

link_interfaces() {
    Interface=$1
    VInterface=$2
    File="$PATHCONFIG"/30-${Interface}.network
    if [[ -f "$File" ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Backing up existing $File to ${File}.bak" "$MSGNC"
        cp "$File" "${File}.bak"
    fi
    cat <<EOF > "$PATHCONFIG"/30-${Interface}.network
[Match]
Name=${Interface}

[Network]
Bridge=${VInterface}
EOF
    echo -e "$MSGGREEN" "$SRVMSG" "Linked ${Interface} to ${VInterface}" "$MSGNC"
}

unlink_interfaces() {
    Interface=$1
    VInterface=$2
    File="$PATHCONFIG"/30-${Interface}.network
    if [[ -f "$File" ]]; then
        if grep -q "Bridge=${VInterface}" "$File"; then
            rm -f "$File"
            echo -e "$MSGGREEN" "$SRVMSG" "Unlinked ${Interface} from ${VInterface}" "$MSGNC"
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "${Interface} exists but is not linked to ${VInterface}" "$MSGNC"
        fi
    else
        echo -e "$MSGRED" "$SRVMSG" "No link file for ${Interface} found" "$MSGNC"
    fi
}

set_interface_name() {
    MacAddress=$1
    NewName=$2
    File="$PATHCONFIG"/10-${NewName}.link
    if [[ -f "$File" ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Backing up existing $File to ${File}.bak" "$MSGNC"
        cp "$File" "${File}.bak"
    fi
    MacUsed=$(grep "${MacAddress}" "$PATHCONFIG"/10-*.link 2>/dev/null | awk -F":" '{print $1}')
    if [[ -n "$MacUsed" ]]; then
        NameUsed=$(grep -m1 '^Name=' "$MacUsed" | cut -d'=' -f2-)
        echo -e "$MSGYELLOW" "$SRVMSG" "Interface already named ${NameUsed}" "$MSGNC"
        echo -e "$MSGYELLOW" "$SRVMSG" "Backing up existing $MacUsed to ${MacUsed}.bak" "$MSGNC"
        mv "$MacUsed" "${MacUsed}.bak"
    fi
    cat <<EOF > "$File"
[Match]
MACAddress=${MacAddress}

[Link]
Name=${NewName}
EOF
    echo -e "$MSGGREEN" "$SRVMSG" "Interface ${MacAddress} renamed to ${NewName}" "$MSGNC"
}

set_interfaces() {
    local VInterface=$1
    local Dhcp=$2
    local Address=$3
    local Gateway=$4
    local Dns=$5
    local NetworkOptions=$6
    local DHCPv4Options=$7
    local IPv6AcceptRAOption=$8
    # create network conf files for bridges
    cat <<EOF > "$PATHCONFIG"/30-"${VInterface}".network
[Match]
Name=${VInterface}

[Network]
DHCP=${Dhcp}
EOF
if [[ $Dhcp == "no" ]]; then
    cat <<EOF >> "$PATHCONFIG"/30-"${VInterface}".network
Address=${Address}
Gateway=${Gateway}
EOF
fi
if [[ $Dns != "no" ]]; then
    cat <<EOF >> "$PATHCONFIG"/30-"${VInterface}".network
DNS=${Dns}
EOF
fi
if [[ $NetworkOptions != "no" ]]; then
    cat <<EOF >> "$PATHCONFIG"/30-"${VInterface}".network
${NetworkOptions}

EOF
fi
if [[ $DHCPv4Options != "no" ]]; then
    cat <<EOF >> "$PATHCONFIG"/30-"${VInterface}".network
[DHCPv4]
${DHCPv4Options}

EOF
fi
if [[ $IPv6AcceptRAOption != "no" ]]; then
    cat <<EOF >> "$PATHCONFIG"/30-"${VInterface}".network
[IPv6AcceptRA]
${IPv6AcceptRAOption}

EOF
fi
}

get_vinterfaces_config() {
    echo -e "#########################################################"
    echo -e "$MSGYELLOW" "$SRVMSG" "Current network configuration of $1:" "$MSGNC"
    cat "$PATHCONFIG"/30-"$1".network
}

get_physical_interfaces() {
    echo -e "#########################################################"
    echo -e "$MSGYELLOW" "$SRVMSG" "Available physical interfaces :" "$MSGNC"
    for IntPath in /sys/class/net/*; do
        if [ -d "${IntPath}/device" ]; then
            MacAddress=$(cat "${IntPath}/address")
            if grep -q "$MacAddress" "$PATHCONFIG"/10-*.link 2>/dev/null; then
                IntName=$(grep "Name=" "$PATHCONFIG"/10-*.link | awk -F"=" '{print $2}')
            else
                IntName=$(basename "${IntPath}")
            fi
            if ip -c -br link show "$IntName" > /dev/null 2>&1; then
                ip -c -br link show "$IntName"
            else
                echo -e "$IntName\t\t\tWAITING\t\t\t$MacAddress"
            fi
        fi
    done
}

get_bridged_interfaces() {
    echo -e "#########################################################"
    echo -e "$MSGYELLOW" "$SRVMSG" "Bridge virtual interfaces status :" "$MSGNC"
    WanStatus=$(bridge link | grep "$WAN" | grep -c ",UP,")
    LanStatus=$(bridge link | grep "$LAN" | grep -c ",UP,")
    if [[ $WanStatus -gt 0 ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "$WAN bridge is UP" "$MSGNC"
    else
        echo -e "$MSGRED" "$SRVMSG" "$WAN bridge is DOWN" "$MSGNC"
    fi
    if [[ $LanStatus -gt 0 ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "$LAN bridge is UP" "$MSGNC"
    else
        echo -e "$MSGRED" "$SRVMSG" "$LAN bridge is DOWN" "$MSGNC"
    fi

    echo -e "\n"
    echo -e "#########################################################"
    echo -e "$MSGYELLOW" "$SRVMSG" "Interfaces linked to $WAN :" "$MSGNC"
    ip -c -br link show master $WAN 2>/dev/null

    echo -e "\n"
    echo -e "#########################################################"
    echo -e "$MSGYELLOW" "$SRVMSG" "Interfaces linked to $LAN :" "$MSGNC"
    ip -c -br link show master $LAN 2>/dev/null
    echo -e "\n"

}

get_interfaces_status() {
    get_bridged_interfaces
    get_physical_interfaces
}

menu_rename_interfaces() {
    get_physical_interfaces
    while true; do
        read -p "Enter the name of the interface you want to rename : " IfaceToRename
        if ! ip link show "$IfaceToRename" > /dev/null 2>&1; then
            echo -e "$MSGRED" "$SRVMSG" "Interface $IfaceToRename not found." "$MSGNC"
        else
            break
        fi
    done
    while true; do
        read -p "Enter the new name for $IfaceToRename : " NewName
        if [[ -z "$NewName" ]]; then
            echo -e "$MSGRED" "$SRVMSG" "New name cannot be empty." "$MSGNC"
        elif [[ "$NewName" == "$WAN" || "$NewName" == "$LAN" ]]; then
            echo -e "$MSGRED" "$SRVMSG" "New name cannot be $WAN or $LAN." "$MSGNC"
        elif [[ ! "$NewName" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]*$ ]]; then
            echo -e "$MSGRED" "$SRVMSG" "New name contains invalid characters. Allowed: letters, digits, underscore, dot, hyphen, and must not start with a hyphen." "$MSGNC"
        elif ip link show "$NewName" > /dev/null 2>&1; then
            echo -e "$MSGRED" "$SRVMSG" "Interface $NewName already exists." "$MSGNC"
        elif [[ ${#NewName} -gt 15 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "New name cannot be longer than 15 characters." "$MSGNC"
        else
            MacAddress=$(ip link show "$IfaceToRename" | awk '/ether/ {print $2}')
            if [[ -z "$MacAddress" ]]; then
                echo -e "$MSGRED" "$SRVMSG" "Unable to determine MAC address for $IfaceToRename." "$MSGNC"
                return 1
            fi
            set_interface_name "$MacAddress" "$NewName"
            break
        fi
    done
}

menu_link_interfaces() {
    for Viface in $WAN $LAN; do
        echo -e "#########################################################"
        echo -e "$MSGYELLOW" "$SRVMSG" "Manage links for $Viface:" "$MSGNC"
        echo -e "#########################################################"
        echo -e "$MSGYELLOW" "$SRVMSG" "Currently linked interfaces :" "$MSGNC"
        get_physical_interfaces
        ip -c -br link show master $Viface 2>/dev/null
        while true; do
            read -p "Action for $Viface? (a)dd / (r)emove / (n)ext : " Action
            case "$Action" in
                a|A)
                    read -p "Enter interface name to add (or press Enter to cancel): " IfaceChoosed
                    if [[ -z "$IfaceChoosed" ]]; then
                        continue
                    fi
                    if ! grep -q "$IfaceChoosed" $PATHCONFIG/10-*.link && ! ip link show "$IfaceChoosed" > /dev/null 2>&1; then
                        echo -e "$MSGRED" "$SRVMSG" "Interface $IfaceChoosed not found." "$MSGNC"
                        continue
                    fi
                    if [[ -f "$PATHCONFIG"/30-${IfaceChoosed}.network ]] && grep -q "Bridge=${Viface}" "$PATHCONFIG"/30-${IfaceChoosed}.network; then
                        echo -e "$MSGYELLOW" "$SRVMSG" "$IfaceChoosed already linked to $Viface" "$MSGNC"
                    else
                        link_interfaces "$IfaceChoosed" "$Viface"
                    fi
                    ;;
                r|R)
                    read -p "Enter interface name to remove (or press Enter to cancel): " IfaceChoosed
                    if [[ -z "$IfaceChoosed" ]]; then
                        continue
                    fi
                    unlink_interfaces "$IfaceChoosed" "$Viface"
                    ;;
                n|N|"")
                    break
                    ;;
                *)
                    echo -e "$MSGRED" "$SRVMSG" "Invalid action. Choose a, r, or n." "$MSGNC"
                    ;;
            esac
        done
    done

}

menu_set_interfaces() {
    local Dhcp="" 
    local Address=""
    local Gateway="" 
    local Dns="" 
    local NetworkOptions="" 
    local DHCPv4Options="" 
    local IPv6AcceptRAOption=""

    echo -e "$MSGYELLOW" "$SRVMSG" "Configuring $1 interface :" "$MSGNC"
    while true; do
        read -p "Do you want to use DHCP (yes/no) : " DhcpChoice
        DhcpChoice=$(yes_no_check "$DhcpChoice")
        if [[ $DhcpChoice -eq 1 ]]; then
            Dhcp="yes"
            break
        elif [[ $DhcpChoice -eq 0 ]]; then
            Dhcp="no"
            break
        elif [[ $DhcpChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
    if [[ $DhcpChoice -eq 1 ]]; then
        Address=""
        Gateway=""
        while true; do
            read -p "Do you want to set Manual DNS (yes/no) : " DnsChoice
            DnsChoice=$(yes_no_check "$DnsChoice")
            if [[ $DnsChoice -eq 1 ]]; then
                read -p "DNS servers, comma separated. Default : 1.1.1.1 9.9.9.9  (Enter for default): " Dns
                if [[ -z "$Dns" ]]; then
                    Dns="1.1.1.1 9.9.9.9"
                fi
                echo -e "$MSGGREEN" "$SRVMSG" "DNS set to $Dns" "$MSGNC"
                break
            elif [[ $DnsChoice -eq 0 ]]; then
                Dns="no"
                echo -e "$MSGGREEN" "$SRVMSG" "DNS configuration from DHCP" "$MSGNC"
                break
            elif [[ $DnsChoice -eq 99 ]]; then
                echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
            fi
        done
        NetworkOptions=""
        DHCPv4Options=""
        IPv6AcceptRAOption=""
    else
        read -p "Static IP address with mask (e.g., 192.168.1.10/24) : " Address
        read -p "Gateway (or press Enter to skip) : " Gateway
        read -p "DNS servers, comma separated. Default : 1.1.1.1 9.9.9.9  (Enter for default): " Dns
        if [[ -z "$Dns" ]]; then
            Dns="1.1.1.1 9.9.9.9"
        fi
        echo -e "$MSGGREEN" "$SRVMSG" "DNS set to $Dns" "$MSGNC"
    fi
    while true; do
        read -p "Do you want to set Advanced network options (yes/no) : " NetworkOptionsChoice
        NetworkOptionsChoice=$(yes_no_check "$NetworkOptionsChoice")
        if [[ $NetworkOptionsChoice -eq 1 ]]; then
            read -p "Additional Network options (or press Enter to skip) : " NetworkOptions
            if [[ -z "$NetworkOptions" ]]; then
                NetworkOptions="no"
            fi
            read -p "Additional DHCPv4 options (or press Enter to skip) : " DHCPv4Options
            if [[ -z "$DHCPv4Options" ]]; then
                DHCPv4Options="no"
            fi
            read -p "Additional IPv6AcceptRA options (or press Enter to skip) : " IPv6AcceptRAOption
            if [[ -z "$IPv6AcceptRAOption" ]]; then
                IPv6AcceptRAOption="no"
            fi
        elif [[ $NetworkOptionsChoice -eq 0 ]]; then
            NetworkOptions="no"
            DHCPv4Options="no"
            IPv6AcceptRAOption="no"
            break
        elif [[ $NetworkOptionsChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
    set_interfaces "$1" "$Dhcp" "$Address" "$Gateway" "$Dns" "$NetworkOptions" "$DHCPv4Options" "$IPv6AcceptRAOption"

}

menu_interface_configuration() {
    while true; do
        clear
        echo -e "#########################################################"
        echo -e "$MSGYELLOW" "$SRVMSG" "Network configuration menu :" "$MSGNC"
        echo -e "1. Configure network interface"
        echo -e "2. Link physical interfaces to bridges"
        echo -e "3. Rename physical interfaces"
        echo -e "4. Back to main menu"
        read -p "Choose an option : " OptionChoosed
        
        case $OptionChoosed in
            1)
                clear
                while true; do
                    get_physical_interfaces
                    echo -e "#########################################################"
                    read -p "Choose interface to configure - $WAN / $LAN / Other (enter the name of the interface): " InterfaceChoosed
                    if [[ "$InterfaceChoosed" == "$WAN" || "$InterfaceChoosed" == "$LAN" ]]; then
                        break
                    elif ip link show "$InterfaceChoosed" > /dev/null 2>&1; then
                        if [[ -f "$PATHCONFIG"/30-"${InterfaceChoosed}".network ]] && grep -q "Bridge=" "$PATHCONFIG"/30-"${InterfaceChoosed}".network; then
                            echo -e "$MSGYELLOW" "$SRVMSG" "Warning: $InterfaceChoosed is currently linked to a bridge. Changes will affect the bridge configuration." "$MSGNC"
                        else
                            echo -e "$MSGYELLOW" "$SRVMSG" "Configuring physical interface $InterfaceChoosed" "$MSGNC"
                        fi
                        break
                    else
                        echo -e "$MSGRED" "$SRVMSG" "Invalid interface" "$MSGNC"
                    fi
                done
                clear
                menu_set_interfaces "$InterfaceChoosed"
                clear
                get_vinterfaces_config "$InterfaceChoosed"
                apply_changes
                ;;
            2)
                clear
                menu_link_interfaces
                apply_changes
                ;;
            3)
                clear
                menu_rename_interfaces
                apply_changes
                ;;
            4)
                break
                ;;
            *)
                echo -e "$MSGRED" "$SRVMSG" "Invalid option. Please choose 1, 2, 3 or 4." "$MSGNC"
                ;;
        esac
    done
}

apply_changes() {
    while true; do
        read -p "Do you want to apply changes now (yes/no) : " ApplyChoice
        ApplyChoice=$(yes_no_check "$ApplyChoice")
        if [[ $ApplyChoice -eq 1 ]]; then
            systemctl restart systemd-networkd
        elif [[ $ApplyChoice -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "Changes will be applied on next reboot." "$MSGNC"
            break
        elif [[ $ApplyChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
}

continue_enter() {
    read -p "Press Enter to continue"
    clear
}

initial_setup() {
    check_root
    create_bridges
    echo -e "$MSGYELLOW" "$SRVMSG" "The wifi interface for the access point will be renamed to wlanAP." "$MSGNC"
    echo -e "$MSGYELLOW" "$SRVMSG" "which interface should be used for the access point?" "$MSGNC"
    get_physical_interfaces

    while true; do
        read -p "Do you want to rename other physical interfaces before linking (yes/no) : " RenameChoice
        RenameChoice=$(yes_no_check "$RenameChoice")
        if [[ $RenameChoice -eq 1 ]]; then
            menu_rename_interfaces
            break
        elif [[ $RenameChoice -eq 0 ]]; then
            break
        elif [[ $RenameChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
    menu_link_interfaces
    continue_enter
    while true; do
        read -p "Do you want to configure manually $WAN (yes/no) : " ConfigureChoice
        ConfigureChoice=$(yes_no_check "$ConfigureChoice")
        if [[ $ConfigureChoice -eq 1 ]]; then
            menu_set_interfaces "$WAN"
            break
        elif [[ $ConfigureChoice -eq 0 ]]; then
            set_interfaces "$WAN" "yes" "no" "no" "1.1.1.1 9.9.9.9" $'IPv6PrivacyExtensions=yes\nKeepConfiguration=yes' "ClientIdentifier=mac" "Token=static:::1"
            break
        elif [[ $ConfigureChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
    while true; do
        read -p "Do you want to configure manually $LAN (yes/no) : " ConfigureChoice
        ConfigureChoice=$(yes_no_check "$ConfigureChoice")
        if [[ $ConfigureChoice -eq 1 ]]; then
            menu_set_interfaces "$LAN"
            break
        elif [[ $ConfigureChoice -eq 0 ]]; then
            set_interfaces "$LAN" "no" "192.168.200.1/24" "no" "no" $'IPv6AcceptRA=no\nLinkLocalAddressing=no' "no" "no"
            break
        elif [[ $ConfigureChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
    get_vinterfaces_config "$WAN"
    get_vinterfaces_config "$LAN"
    continue_enter
    systemctl disable networking.service
    systemctl mask networking.service 
    systemctl enable systemd-networkd
}

help() {
    echo -e "Usage: $0 [option]"
    echo -e "Options:"
    echo -e "  setup   : Run initial setup to create bridges and configure network"
    echo -e "  status  : Show current status of interfaces and bridges"
    echo -e "  help    : Show this help message"
}

main() {
    while true; do
        echo -e "#########################################################"
        echo -e "############## RecoveryBox Network Configurator #########"
        echo -e "#########################################################"
        echo -e "\n\n"
        echo -e "1. Show Interfaces status"
        echo -e "2. Show current network configuration"
        echo -e "3. Set network configuration"
        echo -e "4. Exit"
        read -p "Choose an option : " OptionChoosed
        case $OptionChoosed in
            1)
                get_interfaces_status
                continue_enter
                ;;
            2)
                get_vinterfaces_config "$WAN"
                get_vinterfaces_config "$LAN"
                continue_enter
                ;;
            3)
                menu_interface_configuration
                clear
                ;;
            4)
                echo -e "$MSGGREEN" "$SRVMSG" "Exiting..." "$MSGNC"
                exit 0
                ;;
            *)
                echo -e "$MSGRED" "$SRVMSG" "Invalid option. Please choose 1, 2, 3 or 4." "$MSGNC"
                ;;
        esac
    done
}


if [[ $1 == "setup" ]]; then
    initial_setup
elif [[ $1 == "status" ]]; then
    get_interfaces_status
elif [[ $1 == "help" ]]; then
    help
else
    check_root
    clear
    main
fi

