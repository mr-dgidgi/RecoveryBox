#!/bin/bash

###############################################################
# Recoverybox Project
# https://github.com/mr-dgidgi/RecoveryBox
# author Ghislain Leblanc aka mr-dgidgi
# contact@dgidgi.ovh
#
#
###############################################################

SRVMSG=' =+= '
MSGGREEN='\033[0;32m'
MSGYELLOW='\033[0;33m'
MSGRED='\033[0;31m'
MSGNC='\033[0m'
SCRIPT_DIR=$(pwd)
RECOVERBOXYDIR="/etc/recoverybox"

WAN=$(grep "recoverybox_interface_wan" "$SCRIPT_DIR/ansible/roles/recoverybox/defaults/main.yml" | awk -F '"' '{print $2}' )
LAN=$(grep "recoverybox_interface_lan" "$SCRIPT_DIR/ansible/roles/recoverybox/defaults/main.yml" | awk -F '"' '{print $2}' )

CUSTOMCONF=false

CUSTOMMESHTASTIC=false
KIWIXENWIKIPEDIA="false"
KIWIXFRWIKIPEDIA="false"
KIWIXENWIKIPEDIAARG="all_nopic"
KIWIXFRWIKIPEDIAARG="all_nopic"
CUSTOMINSTALL=false
DOWNLOADMBTILES="true"
ENABLEHOTSPOT="true"

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

    # set systemd-resolver
    apt-get install -y -qq  systemd-resolved > /dev/null
    systemctl enable systemd-resolved
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    echo "nameserver 8.8.8.8" > /run/systemd/resolve/stub-resolv.conf
    sed -i 's/#DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
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

    if [[ $(systemctl is-enabled systemd-networkd) == "enabled" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Network interfaces configured successfully.${MSGNC}"
        echo -e "$MSGGREEN" "$SRVMSG" "The system MUST reboot to apply interface renaming and network changes.${MSGNC}"

    else
        echo -e "$MSGRED" "$SRVMSG" "failed to configure network interfaces.${MSGNC}"
        exit 1
    fi
}

#######################################################

set_meshtastic_ip() {
    read -rp "Enter the meshtastic node IP address (default : 192.168.200.101) : " MeshtasticIP
    MeshtasticIP=${MeshtasticIP:-192.168.200.101}
    read -rp "Enter the meshtastic node MAC address (default : 00:00:00:00:00:00) : " MeshtasticMAC
    MeshtasticMAC=${MeshtasticMAC:-00:00:00:00:00:00}
    echo -e "$MSGYELLOW" "$SRVMSG" "Meshtastic node IP address set to $MeshtasticIP and MAC address set to $MeshtasticMAC." "$MSGNC"
    CUSTOMMESHTASTIC=true
}

set_worldmap_download() {
    read -rp "Download World map? yes/no (default : yes) : " QuestionDownloadTileserver
    QuestionDownloadTileserver=$(yes_no_check "$QuestionDownloadTileserver")
    if [[ $QuestionDownloadTileserver -eq 0 ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "World map download : disabled." "$MSGNC"
        DOWNLOADMBTILES="false"
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "World map download : enabled." "$MSGNC"
        DOWNLOADMBTILES="true"
    fi
}

#######################################################

set_kiwix_files(){
    read -rp "Download English Wikipedia? yes/no (default : yes) : " QuestionDownloadKiwixEnWikipedia
    QuestionDownloadKiwixEnWikipedia=$(yes_no_check "$QuestionDownloadKiwixEnWikipedia")
    if [[ $QuestionDownloadKiwixEnWikipedia -eq 0 ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "English Wikipedia : disabled." "$MSGNC"
        KIWIXENWIKIPEDIA="false"
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "English Wikipedia : enabled." "$MSGNC"
        KIWIXENWIKIPEDIA="true"
        read -rp "Which size of English Wikipedia do you want to download? (all_mini, all_nopic, all_maxi) (default : all_nopic) : " QuestionDownloadKiwixEnWikipediaSize
        if [[ "$QuestionDownloadKiwixEnWikipediaSize" == "all_mini" ]];then
            KIWIXENWIKIPEDIAARG="all_mini"
        elif [[ "$QuestionDownloadKiwixEnWikipediaSize" == "all_maxi" ]];then
            KIWIXENWIKIPEDIAARG="all_maxi"
        else
            KIWIXENWIKIPEDIAARG="all_nopic"
        fi
    fi

    read -rp "Download French Wikipedia? yes/no (default : yes) : " QuestionDownloadKiwixFrWikipedia
    QuestionDownloadKiwixFrWikipedia=$(yes_no_check "$QuestionDownloadKiwixFrWikipedia")
    if [[ $QuestionDownloadKiwixFrWikipedia -eq 0 ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "French Wikipedia : disabled." "$MSGNC"
        KIWIXFRWIKIPEDIA="false"
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "French Wikipedia : enabled." "$MSGNC"
        KIWIXFRWIKIPEDIA="true"
        read -rp "Which size of French Wikipedia do you want to download? (all_mini, all_nopic, all_maxi) (default : all_nopic) : " QuestionDownloadKiwixFrWikipediaSize
        if [[ "$QuestionDownloadKiwixFrWikipediaSize" == "all_mini" ]];then
            KIWIXFRWIKIPEDIAARG="all_mini"
        elif [[ "$QuestionDownloadKiwixFrWikipediaSize" == "all_maxi" ]];then
            KIWIXFRWIKIPEDIAARG="all_maxi"
        else
            KIWIXFRWIKIPEDIAARG="all_nopic"
        fi
    fi

}

#######################################################

menu_services() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Services configuration menu" "$MSGNC"

    read -rp "Enable Apache web server? yes/no (default : yes) : " QuestionEnableApache
    QuestionEnableApache=$(yes_no_check "$QuestionEnableApache")
    if [[ $QuestionEnableApache -eq 0 ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Apache : disabled." "$MSGNC"
        EnableApache="false"
        EnableLibrary="false"
        EnableBrouter="false"
        EnableTileserver="false"
        EnableMeshtastic="false"
        EnableConsole="false"
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "Apache : enabled." "$MSGNC"
        EnableApache="true"
    fi

    if [[ "$EnableApache" == "true" ]]; then
        read -rp "Enable RecoveryBox Library? yes/no (default : yes) : " QuestionEnableLibrary
        QuestionEnableLibrary=$(yes_no_check "$QuestionEnableLibrary")
        if [[ $QuestionEnableLibrary -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "RecoveryBox Library : disabled." "$MSGNC"
            EnableLibrary="false"
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "RecoveryBox Library : enabled." "$MSGNC"
            EnableLibrary="true"
        fi

        read -rp "Enable brouter? yes/no (default : yes) : " QuestionEnableBrouter
        QuestionEnableBrouter=$(yes_no_check "$QuestionEnableBrouter")
        if [[ $QuestionEnableBrouter -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "brouter : disabled." "$MSGNC"
            EnableBrouter="false"
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "brouter : enabled." "$MSGNC"
            EnableBrouter="true"
            read -rp "Download brouter maps data? yes/no (default : yes) : " QuestionDownloadBrouter
            QuestionDownloadBrouter=$(yes_no_check "$QuestionDownloadBrouter")
            if [[ $QuestionDownloadBrouter -eq 0 ]]; then
                echo -e "$MSGYELLOW" "$SRVMSG" "brouter maps data : disabled." "$MSGNC"
                DownloadBrouterdata="false"
            else
                echo -e "$MSGYELLOW" "$SRVMSG" "brouter maps data : enabled." "$MSGNC"
                DownloadBrouterdata="true"
            fi
        fi

        read -rp "Enable tileserver-gl? yes/no (default : yes) : " QuestionEnableTileserver
        QuestionEnableTileserver=$(yes_no_check "$QuestionEnableTileserver")
        if [[ $QuestionEnableTileserver -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "tileserver-gl : disabled." "$MSGNC"
            EnableTileserver="false"
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "tileserver-gl : enabled." "$MSGNC"
            EnableTileserver="true"
            set_worldmap_download
        fi

        read -rp "Enable Meshtastic services? yes/no (default : yes) : " QuestionEnableMeshtastic
        QuestionEnableMeshtastic=$(yes_no_check "$QuestionEnableMeshtastic")
        if [[ $QuestionEnableMeshtastic -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "Meshtastic services : disabled." "$MSGNC"
            EnableMeshtastic="false"
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "Meshtastic services : enabled." "$MSGNC"
            EnableMeshtastic="true"
        fi

        read -rp "Enable Web Console? yes/no (default : yes) : " QuestionEnableConsole
        QuestionEnableConsole=$(yes_no_check "$QuestionEnableConsole")
        if [[ $QuestionEnableConsole -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "Web Console : disabled." "$MSGNC"
            EnableConsole="false"
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "Web Console : enabled." "$MSGNC"
            EnableConsole="true"
            read -rp "Would you set a meshtastic node IP address? yes/no (default : no) : " QuestionSetMeshtasticIP
            QuestionSetMeshtasticIP=$(yes_no_check "$QuestionSetMeshtasticIP")
            if [[ $QuestionSetMeshtasticIP -eq 1 ]]; then
                set_meshtastic_ip
            fi
        fi
    fi
    read -rp "Enable OpenWebRX plus? yes/no (default : yes) : " QuestionEnableOWRX
    QuestionEnableOWRX=$(yes_no_check "$QuestionEnableOWRX")
    if [[ $QuestionEnableOWRX -eq 0 ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "OpenWebRX plus : disabled." "$MSGNC"
        EnableOWRX="false"
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "OpenWebRX plus : enabled." "$MSGNC"
        EnableOWRX="true"
    fi
    read -rp "Enable Kiwix server? yes/no (default : yes) : " QuestionEnableKiwix
    QuestionEnableKiwix=$(yes_no_check "$QuestionEnableKiwix")
    if [[ $QuestionEnableKiwix -eq 0 ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Kiwix server : disabled." "$MSGNC"
        EnableKiwix="false"
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "Kiwix server : enabled." "$MSGNC"
        EnableKiwix="true"
        set_kiwix_files
    fi

    
    set_ansible_custom_vars
}

set_ansible_custom_vars() {
    cat <<EOL > "$RECOVERBOXYDIR/custom_config.yml"
## Generated by RecoveryBox_install.sh
recoverybox_enable_apache: $EnableApache
recoverybox_enable_library: $EnableLibrary
recoverybox_enable_brouter: $EnableBrouter
recoverybox_download_brouter: $DownloadBrouterdata
recoverybox_enable_tileserver: $EnableTileserver
recoverybox_enable_meshtastic: $EnableMeshtastic
recoverybox_enable_console: $EnableConsole
recoverybox_enable_owrx: $EnableOWRX
recoverybox_enable_kiwix: $EnableKiwix
recoverybox_enable_hotspot: $ENABLEHOTSPOT
recoverybox_download_mbtiles: $DOWNLOADMBTILES
recoverybox_kiwix_files:
  - category: wikipedia
    language: fr
    enable: ${KIWIXFRWIKIPEDIA}
    arg: "$KIWIXFRWIKIPEDIAARG"
  - category: wikipedia
    language: en
    enable: ${KIWIXENWIKIPEDIA}
    arg: "$KIWIXENWIKIPEDIAARG"
EOL

if [[ $CUSTOMMESHTASTIC == true ]]; then
    cat <<EOL >> "$RECOVERBOXYDIR/custom_config.yml"
recoverybox_meshtastic_node:
  mac: ${MeshtasticMAC}
  ip: ${MeshtasticIP}
EOL
fi

}

menu_configuration() {
        echo -e "#########################################################"
        echo -e "$MSGYELLOW" "$SRVMSG" "Services configuration" "$MSGNC"
        read -rp "Do you want the default installation ? yes/no (default : yes) : " ConfigureChoice
        ConfigureChoice=$(yes_no_check "$ConfigureChoice")
        if [[ $ConfigureChoice -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "Custom installation selected." "$MSGNC"
            menu_services
            CUSTOMINSTALL=true
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "Default installation selected." "$MSGNC"
            CUSTOMINSTALL=false
        fi
}

#######################################################
#######################################################
#######################################################
main() {
    mkdir -p $RECOVERBOXYDIR
    if [[ -f $RECOVERBOXYDIR/rb_version ]]; then
        echo -e "-upgrading" >> $RECOVERBOXYDIR/rb_version
    fi
    ## checks / settings
    check_prerequisites
    if [[ ! -f $RECOVERBOXYDIR/rb_version ]]; then
        ## set keyboard layout
        set_keyboard
    fi
    ## Install Ansible prerequisites
    install_ansible

    if [[ -f $RECOVERBOXYDIR/custom_config.yml ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Custom configuration file found at $RECOVERBOXYDIR/custom_config.yml." "$MSGNC"
        read -rp "Do you want to use the existing custom configuration file? yes/no (default : yes) : " UseExistingConfig
        UseExistingConfig=$(yes_no_check "$UseExistingConfig")
        if [[ $UseExistingConfig -eq 0 ]]; then
            echo -e "$MSGYELLOW" "$SRVMSG" "Deleting custom configuration file." "$MSGNC"
            mv $RECOVERBOXYDIR/custom_config.yml $RECOVERBOXYDIR/custom_config.yml.bak
            CUSTOMCONF=false
        else
            echo -e "$MSGYELLOW" "$SRVMSG" "Using existing custom configuration file." "$MSGNC"
            CUSTOMCONF=true
        fi
    fi
    
    if [[ $CUSTOMCONF == false ]]; then
        menu_configuration
    fi

    echo -e "#########################################################"
    echo -e "$MSGYELLOW" "$SRVMSG" "Starting Installation..." "$MSGNC"

    if [[ $CUSTOMINSTALL == true ]] || [[ $CUSTOMCONF == true ]]; then
        if ! ansible-playbook -i localhost, "$SCRIPT_DIR/ansible/Install.yml" --connection=local --extra-vars "@$RECOVERBOXYDIR/custom_config.yml"; then
            echo -e "$MSGRED" "$SRVMSG" "Ansible playbook execution failed.${MSGNC}"
            exit 1
        fi
    else
        if ! ansible-playbook -i localhost, "$SCRIPT_DIR/ansible/Install.yml" --connection=local; then
            echo -e "$MSGRED" "$SRVMSG" "Ansible playbook execution failed.${MSGNC}"
            exit 1
        fi
    fi

    ## avoid skipping the read command in the next step
    stty flush stdin 2>/dev/null || true
    exec 0</dev/tty
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

    cp "$SCRIPT_DIR/VERSION" "$RECOVERBOXYDIR/rb_version"

    ## Final message
    echo -e "$MSGGREEN" "$SRVMSG" "Installation complete! Please REBOOT THE SYSTEM to apply all changes." "$MSGNC"

}

#######################################################

if [[ $1 == "custom" ]]; then
    if [[ -f $RECOVERBOXYDIR/custom_config.yml ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Custom configuration file found at $RECOVERBOXYDIR/custom_config.yml." "$MSGNC"
        CUSTOMCONF=true
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "No custom configuration file found at $RECOVERBOXYDIR/custom_config.yml." "$MSGNC"
        exit 1
    fi
    
fi

if [[ $1 == "config" ]]; then
    mkdir -p $RECOVERBOXYDIR
    menu_configuration
else
    main
fi
