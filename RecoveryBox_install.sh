#!/bin/bash

###############################################################
# Recoverybox Project
# https://github.com/mr-dgidgi/RecoveryBox
# autor Ghislain Leblanc aka mrdgidgi
# contact@dgidgi.ovh
#
#
###############################################################

SRVMSG=' =+= '
MSGGREEN='\033[0;32m'
MSGYELLOW='\033[0;33m'
MSGRED='\033[0;31m'
MSGNC='\033[0m'
LANGUAGE="fr"
WAN="Wan"
LAN="Lan"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


#######################################################
# Functions
#######################################################

yes_no_check () {
	if [ "$1" = "Y" ] || [ "$1" = "y" ] || [ "$1" = "Yes" ] || [ "$1" = "yes" ] || [ "$1" = "Oui" ] || [ "$1" = "OUI" ] || [ "$1" = "oui" ] || [ "$1" = "O" ]; then
		echo 1

	elif [ "$1" = "N" ] || [ "$1" = "n" ] || [ "$1" = "No" ] || [ "$1" = "no" ] || [ "$1" = "Non" ] || [ "$1" = "NON" ] || [ "$1" = "non" ] || [ "$1" = "N" ]; then
		echo 0

	else
		echo 99

	fi
}

check_prerequisites() {
    
    #check if root
    if [[ $(whoami) != root ]]; then 
        echo -e "$MSGRED" "$SRVMSG" "user is not root" "$MSGNC"
        exit 1
    fi
    # check if /data exists
    if [[ ! -d /data ]]; then
        echo -e "$MSGRED" "$SRVMSG" "/data does not exist. Please mount/create /data" "$MSGNC"
        echo -e "$MSGRED" "$SRVMSG" "example: mount /dev/sda1 /data" "$MSGNC"
        exit 1
    fi
    # check if we are on a debian system
    if [[ ! -f /etc/debian_version ]]; then
        echo -e "$MSGRED" "$SRVMSG" "This script is only for Debian based systems" "$MSGNC"
        exit 1
    fi
    # check if we are on amd64 architecture
    if [[ $(dpkg --print-architecture) != "amd64" ]]; then
        echo -e "$MSGRED" "$SRVMSG" "This script is only for amd64 architecture" "$MSGNC"
        exit 1
    fi

    # check if there is a wireless interface for access point setup
    if ! compgen -G "/sys/class/net/*/wireless" > /dev/null; then
        echo -e "$MSGRED" "$SRVMSG" "No wireless interface found. Please connect a wireless interface for the access point or check the drivers." "$MSGNC"
        exit 1
    fi
}

#######################################################

set_keyboard() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Setting keyboard layout..." "$MSGNC"
    while true; do
        read -rp "Would you like to change your keyboard layout? (default QWERTY): " KeyboardLayout
        KeyboardLayout=$(yes_no_check "$KeyboardLayout")
        case "$KeyboardLayout" in
            1)
                dpkg-reconfigure keyboard-configuration
                # Apply immediately with setupcon if available
                if command -v setupcon &> /dev/null; then
                    setupcon 2>/dev/null
                else
                    echo -e "$MSGGREEN" "$SRVMSG" "You should restart your session to apply the new keyboard layout." "$MSGNC"
                fi
                ;;
            0)
                echo -e "$MSGYELLOW" "$SRVMSG" "Keeping default keyboard layout." "$MSGNC"
                return
                ;;
            *)
                echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
                ;;
        esac
    done
}

#######################################################

install_ansible() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Installing Ansible..." "$MSGNC"
    apt-get update -qq
    apt-get install -y -qq ansible python3-docker python3-apt > /dev/null

    if ! command -v ansible >/dev/null 2>&1 || ! command -v ansible-playbook >/dev/null 2>&1 || ! command -v ansible-galaxy >/dev/null 2>&1; then
        echo -e "$MSGRED" "$SRVMSG" "Ansible binaries are not available after installation.${MSGNC}"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/ansible/requirements.yml" ]]; then
        if ! ansible-galaxy collection install -r "$SCRIPT_DIR/ansible/requirements.yml" > /dev/null; then
            echo -e "$MSGRED" "$SRVMSG" "Failed to install Ansible collections from ansible/requirements.yml.${MSGNC}"
            exit 1
        fi
    else
        if ! ansible-galaxy collection install community.docker > /dev/null; then
            echo -e "$MSGRED" "$SRVMSG" "Failed to install the community.docker collection.${MSGNC}"
            exit 1
        fi
    fi

    if ! ansible-galaxy collection list community.docker >/dev/null 2>&1; then
        echo -e "$MSGRED" "$SRVMSG" "community.docker is not available to Ansible.${MSGNC}"
        exit 1
    fi

    echo -e "$MSGGREEN" "$SRVMSG" "Ansible installed successfully.${MSGNC}"
}

#######################################################

configure_interfaces() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Configuring network interfaces..." "$MSGNC"

    if ! command -v network-configurator >/dev/null 2>&1; then
        echo -e "$MSGRED" "$SRVMSG" "network-configurator command not found. Ansible installation may have failed.${MSGNC}"
        exit 1
    fi

    network-configurator CreateBridge "$WAN"
    network-configurator CreateBridge "$LAN"
    echo -e "$MSGYELLOW" "$SRVMSG" "The wifi interface for the access point will be renamed to wlanAP." "$MSGNC"
    network-configurator MenuRenameInterface wlanAP
    ##wlanAP is automaticaly bridged to Lan interface when the container start
    echo -e "$MSGGREEN" "$SRVMSG" "At least one interface should be linked to WAN interface to access internet" "$MSGNC"
    network-configurator LinkInterface

    while true; do
        read -rp "Do you want to configure manually $WAN (yes/no) : " ConfigureChoice
        ConfigureChoice=$(yes_no_check "$ConfigureChoice")
        if [[ $ConfigureChoice -eq 1 ]]; then
            network-configurator MenuSetInterface "$WAN"
            break
        elif [[ $ConfigureChoice -eq 0 ]]; then
            network-configurator SetInterface "$WAN" "yes" "no" "no" "1.1.1.1 9.9.9.9" $'IPv6PrivacyExtensions=yes\nKeepConfiguration=yes' $'ClientIdentifier=mac\nRouteMetric=100' 'Token=static:::1'
            break
        elif [[ $ConfigureChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
    while true; do
        read -rp "Do you want to configure manually $LAN (yes/no) : " ConfigureChoice
        ConfigureChoice=$(yes_no_check "$ConfigureChoice")
        if [[ $ConfigureChoice -eq 1 ]]; then
            network-configurator MenuSetInterface "$LAN"
            break
        elif [[ $ConfigureChoice -eq 0 ]]; then
            network-configurator SetInterface "$LAN" "no" "192.168.200.1/24" "no" "no" $'IPv6AcceptRA=no\nLinkLocalAddressing=no\nConfigureWithoutCarrier=yes' "no" "no"
            break
        elif [[ $ConfigureChoice -eq 99 ]]; then
            echo -e "$MSGRED" "$SRVMSG" "Invalid input. Please enter yes or no." "$MSGNC"
        fi
    done
    network-configurator GetVInterfacesConfig

    read -rp "Press Enter to continue"
    systemctl disable networking.service
    systemctl mask networking.service 
    systemctl enable systemd-networkd

    # set systemd-resolver
    apt-get install -y -qq  systemd-resolved > /dev/null
    systemctl enable systemd-resolved
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    echo "nameserver 8.8.8.8" > /run/systemd/resolve/stub-resolv.conf
    sed -i 's/#DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf

    if [[ $(systemctl is-enabled systemd-networkd) == "enabled" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Network interfaces configured successfully.${MSGNC}"
        echo -e "$MSGGREEN" "$SRVMSG" "The system MUST reboot to apply interface renaming and network changes.${MSGNC}"

    else
        echo -e "$MSGRED" "$SRVMSG" "failed to configure network interfaces.${MSGNC}"
        exit 1
    fi
}

#######################################################
#######################################################
#######################################################
main() {
    mkdir -p /etc/recoverybox
    if [[ -f /etc/recoverybox/rb_version ]]; then
        echo -e "-upgrading" >> /etc/recoverybox/rb_version
    fi
    ## checks / settings
    check_prerequisites
    ## set keyboard layout
    set_keyboard
    ## Install Ansible prerequisites
    install_ansible
    # Set Ansible variables

    if ! ansible-playbook -i localhost, "$SCRIPT_DIR/ansible/Install.yml" --connection=local; then
        echo -e "$MSGRED" "$SRVMSG" "Ansible playbook execution failed.${MSGNC}"
        exit 1
    fi

    ## Download more map
    read -r -p "$SRVMSG Do you want to download a continent/country map ? [y/n] : " CustomMapGen
    if [[ "$CustomMapGen" == "y" || "$CustomMapGen" == "Y" ]]; then
        if command -v generate-map >/dev/null 2>&1; then
            /usr/local/bin/generate-map
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "generate-map command not found, skipping custom map generation." "$MSGNC"
        fi
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "Skipping custom map generation." "$MSGNC"
    fi

    # Set interfaces if systemd-networkd is not the only network manager
    if [[ $(systemctl is-enabled networking) == "enabled" ]] || [[ $(systemctl is-enabled NetworkManager) == "enabled" ]] || [[ $(systemctl is-enabled systemd-resolved) != "enabled" ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Network configuration needed." "$MSGNC"
        configure_interfaces
    fi

    cp "$SCRIPT_DIR/VERSION" /etc/recoverybox/rb_version

    ## Final message
    echo -e "$MSGGREEN" "$SRVMSG" "Installation complete! Please REBOOT THE SYSTEM to apply all changes." "$MSGNC"

}

#######################################################

main

