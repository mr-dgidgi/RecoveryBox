#!/bin/bash

#
#
#
#
#
# monter /data/ avant de lancer le script
#

SRVMSG=' =+= '
MSGGREEN='\033[0;32m'
MSGYELLOW='\033[0;33m'
MSGRED='\033[0;31m'
MSGNC='\033[0m'
LANGUAGE="fr"
INTWAN=""
INTAP=""

#######################################################
# Functions
#######################################################
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
}

#######################################################

define_language() {
    # Language settings
    echo -e "$MSGYELLOW" "$SRVMSG" "choose your Language / choisissez votre Language :" "$MSGNC"
    echo -e "$MSGYELLOW" "$SRVMSG" "1 = English" "$MSGNC"
    echo -e "$MSGYELLOW" "$SRVMSG" "2 = Français" "$MSGNC"
    echo -e "$MSGYELLOW" "$SRVMSG" "3 = Tout/Both" "$MSGNC"
    read -r -p "$SRVMSG Enter your choice / Entrez votre choix : " LanguageChoice
    case $LanguageChoice in
        1) echo -e "$MSGGREEN" "$SRVMSG" "Language set to English" "$MSGNC"
        LANGUAGE="en"
        ;;
        2) echo -e "$MSGGREEN" "$SRVMSG" "Language définie sur Français" "$MSGNC"
        LANGUAGE="fr"
        ;;
        3) echo -e "$MSGGREEN" "$SRVMSG" "Language set to English and Français" "$MSGNC"
        LANGUAGE="all"
        ;;
        *) echo -e "$MSGRED" "$SRVMSG" "Invalid choice, defaulting to French" "$MSGNC"
        LANGUAGE="fr"
        ;;
        esac
}

#######################################################

set_keyboard() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Setting keyboard layout..." "$MSGNC"
    
    local Keymap=""
    local Variant=""
    case "$LANGUAGE" in 
    "en") 
        Keymap="us" 
        ;;
    "fr") 
        Keymap="fr" 
        Variant="latin9"
        ;;
    "all") 
        Keymap="fr"
        Variant="latin9"
        ;;
    *) 
        Keymap="us"
        ;;
    esac    
    # Configure /etc/default/keyboard for persistent configuration
    cat > /etc/default/keyboard <<EOF
XKBMODEL="pc105"
XKBLAYOUT="$Keymap"
XKBVARIANT="$Variant"
XKBOPTIONS=""
BACKSPACE="guess"
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Keyboard layout set to $Keymap.${MSGNC}"
        
        # Apply immediately with setupcon if available
        if command -v setupcon &> /dev/null; then
            setupcon 2>/dev/null
        fi
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to set keyboard layout.${MSGNC}"
        exit 1
    fi
}

#######################################################

install_basic_tools() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Installing basic tools..." "$MSGNC"
    apt-get update -qq
    apt-get install -y -qq curl gpg ca-certificates git wget > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "$MSGGREEN" "$SRVMSG" "basic tools installed successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "basic tools installation failed.${MSGNC}"
        exit 1
    fi
}

#######################################################

set_repositories() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Adding repositories..." "$MSGNC"
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    if [ $? -ne 0 ]; then
        echo -e "$MSGRED" "$SRVMSG" "failed to add Docker repository.${MSGNC}"
        exit 1
    fi

    curl -fsSL https://download.opensuse.org/repositories/home:/tumic:/GPXSee/Debian_13/Release.key -o /etc/apt/keyrings/gpxsee.asc
    chmod a+r /etc/apt/keyrings/gpxsee.asc
    tee /etc/apt/sources.list.d/gpxsee.sources > /dev/null <<EOF
Types: deb
URIs: https://download.opensuse.org/repositories/home:/tumic:/GPXSee/Debian_13/
Suites: /
Components: 
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/gpxsee.asc
EOF

    if [ $? -ne 0 ]; then
        echo -e "$MSGRED" "$SRVMSG" "failed to add GPXSee repository.${MSGNC}"
        exit 1
    fi

    apt-get update -qq
    if [ $? -eq 0 ]; then
        echo -e "$MSGGREEN" "$SRVMSG" "repository added successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to add repository.${MSGNC}"
        exit 1
    fi
}

#######################################################

install_docker() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Installing Docker..." "$MSGNC"
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Docker installed successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to install Docker.${MSGNC}"
        exit 1
    fi
}
#######################################################

install_kiwix() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Installing kiwix..." "$MSGNC"
    mkdir /data/kiwix
    docker pull ghcr.io/kiwix/kiwix-serve:3.8.2
    if [ $? -eq 0 ]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Kiwix installed successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to install Kiwix.${MSGNC}"
        exit 1
    fi
}

#######################################################

download_wikipedia() {
    if [[ "$LANGUAGE" == "fr" ]] || [[ "$LANGUAGE" == "all" ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Downloading Wikipedia in French. This step may take some time..." "$MSGNC"
        FileName=$(curl -s "https://download.kiwix.org/zim/wikipedia/" | grep -oP 'wikipedia_fr_all_nopic_\d{4}-\d{2}\.zim' | sort -V | tail -1)
        wget -q --show-progress -P /data/kiwix https://download.kiwix.org/zim/wikipedia/${FileName}
        if [[ -e /data/kiwix/$FileName ]]; then
            echo -e "$MSGGREEN" "$SRVMSG" "Wikipedia in French downloaded successfully.${MSGNC}"
        else
            echo -e "$MSGRED" "$SRVMSG" "failed to download Wikipedia in French.${MSGNC}"
            exit 1
        fi
    fi

    if [[ "$LANGUAGE" == "en" ]] || [[ "$LANGUAGE" == "all" ]]; then
        echo -e "$MSGYELLOW" "$SRVMSG" "Downloading Wikipedia in English. This step may take some time..." "$MSGNC"
        FileName=$(curl -s "https://download.kiwix.org/zim/wikipedia/" | grep -oP 'wikipedia_en_all_nopic_\d{4}-\d{2}\.zim' | sort -V | tail -1)
        wget -q --show-progress -P /data/kiwix https://download.kiwix.org/zim/wikipedia/${FileName}
        if [[ -e /data/kiwix/$FileName ]]; then
            echo -e "$MSGGREEN" "$SRVMSG" "Wikipedia in English downloaded successfully.${MSGNC}"
        else
            echo -e "$MSGRED" "$SRVMSG" "failed to download Wikipedia in English.${MSGNC}"
            exit 1
        fi
    fi
}

#######################################################

service_kiwix() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Creating kiwix service..." "$MSGNC"
    cp assets/kiwix.service /etc/systemd/system/kiwix.service
    systemctl enable kiwix
    systemctl start kiwix
    if [[ $(systemctl is-active kiwix) == "active" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Kiwix service started successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to start Kiwix service.${MSGNC}"
        exit 1
    fi
}

#######################################################

choose_interfaces_names() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Renaming network interfaces." "$MSGNC"
    # get current interfaces names
    ip -br link
    read -r -p "$SRVMSG Which interface is the WAN? : " INTWAN
    read -r -p "$SRVMSG Which interface is the Access Point? : " INTAP
}

rename_interfaces() {
    WanMac=$(ip -br l | grep "$INTWAN" | awk -F" " '{print $3}')
    cat > /etc/systemd/network/10-nic0.link <<EOF
[Match]
MACAddress=$WanMac

[Link]
Name=nic0
EOF

    ApMac=$(ip -br l | grep "$INTAP" | awk -F" " '{print $3}')
    cat > /etc/systemd/network/10-wlan0.link <<EOF
[Match]
MACAddress=$ApMac

[Link]
Name=wlan0
EOF
    udevadm control --reload-rules
    udevadm trigger --attr-match=subsystem=net
}

#######################################################

configure_interfaces() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Configuring network interfaces..." "$MSGNC"

    cp assets/20-nic0.network /etc/systemd/network/20-nic0.network
    cp assets/20-wlan0.network /etc/systemd/network/20-wlan0.network

    systemctl stop networking.service
    systemctl disable networking.service
    systemctl mask networking.service 
    systemctl enable systemd-networkd
    systemctl restart systemd-networkd
    sleep 2
    
    if [[ $(systemctl is-active systemd-networkd) == "active" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Network interfaces configured successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to configure network interfaces.${MSGNC}"
        exit 1
    fi
}



#######################################################

#Disable wpa_supplicant on wlan0
disable_wpa_supplicant() {
    echo -e "$SRVMSG" "WiFi Access Point - preparing wlan0 interface..." "$MSGNC"
    systemctl stop wpa_supplicant@wlan0
    systemctl disable wpa_supplicant@wlan0
    if [[ $(systemctl is-active wpa_supplicant@wlan0) == "inactive" ]] && [[ $(systemctl is-enabled wpa_supplicant@wlan0) == "disabled" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "wpa_supplicant disabled on wlan0 successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to disable wpa_supplicant on wlan0.${MSGNC}"
        exit 1
    fi
}

#######################################################

# Install the simple-pi-hotspot container
install_access_point() {
    echo -e "$MSGYELLOW""$SRVMSG" "WiFi Access Point - Installing simple-pi-hotspot container..." "$MSGNC"
    docker pull mrdgidgi/simple-pi-hotspot
    mkdir -p /etc/ap_config/
    cp assets/dnsmasq.conf /etc/ap_config/dnsmasq.conf
    cp assets/hostapd.conf /etc/ap_config/hostapd.conf
    cp assets/ap_start.sh /etc/ap_config/ap_start.sh
    chmod +x /etc/ap_config/ap_start.sh
    cp assets/ap.service /etc/systemd/system/ap.service
    systemctl daemon-reload
    systemctl enable ap.service
    systemctl start ap.service
    if [[ $(systemctl is-active ap.service) == "active" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Access Point service started successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to start Access Point service.${MSGNC}"
        exit 1
    fi
}

#######################################################

enable_ipv4_routing() {
    echo -e "$MSGYELLOW""$SRVMSG" "Enabling IPv4 routing..." "$MSGNC"
    if [[ $(sysctl -n net.ipv4.ip_forward) -eq 1 ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "IPv4 routing already enabled.${MSGNC}"
    else
        echo "net.ipv4.ip_forward=1" >> /usr/lib/sysctl.d/50-default.conf
        sysctl -p > /dev/null

        if [[ $(sysctl -n net.ipv4.ip_forward) -eq 1 ]]; then
            echo -e "$MSGGREEN" "$SRVMSG" "IPv4 routing enabled successfully.${MSGNC}"
        else
            echo -e "$MSGRED" "$SRVMSG" "failed to enable IPv4 routing.${MSGNC}"
            exit 1
        fi
    fi
}

#######################################################

setup_iptables() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Setting up IPtables for NAT and routing..." "$MSGNC"
    mkdir -p /etc/iptables
    cp assets/iptables.sh /etc/iptables/iptables.sh
    chmod +x /etc/iptables/iptables.sh
    cp assets/iptables.service /etc/systemd/system/iptables.service
    systemctl daemon-reload
    systemctl enable iptables.service
    systemctl start iptables.service
    if [[ $(systemctl is-active iptables.service) == "active" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "IPtables service started successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to start IPtables service.${MSGNC}"
        exit 1
    fi
}

#######################################################

download_english_pdfs() {
    echo -e "$MSGYELLOW" "$SRVMSG" "installing English survival PDFs..." "$MSGNC"
    mkdir -p /data/enpdf
    git clone https://github.com/mr-dgidgi/RecoveryENPDF.git /data/enpdf
    if [[ -d /data/enpdf ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "English survival PDFs installed successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to install English survival PDFs.${MSGNC}"
        exit 1
    fi
}

#######################################################

download_french_pdfs() {
    echo -e "$MSGYELLOW" "$SRVMSG" "installing French survival PDFs..." "$MSGNC"
    mkdir -p /data/frpdf
    git clone https://github.com/mr-dgidgi/RecoveryFRPDF.git /data/frpdf
    if [[ -d /data/frpdf ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "French survival PDFs installed successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to install French survival PDFs.${MSGNC}"
        exit 1
    fi
}

#######################################################

install_apache() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Installing and configuring Apache2..." "$MSGNC"
    apt-get install -y -qq apache2 > /dev/null
    if [[ "$LANGUAGE" == "en" ]] || [[ "$LANGUAGE" == "all" ]]; then
        cp assets/enpdf.conf /etc/apache2/sites-available/enpdf.conf
        a2ensite enpdf.conf
        echo -e "$MSGGREEN" "$SRVMSG" "pdf.recovery.box enabled" "$MSGNC"
    fi
    if [[ "$LANGUAGE" == "fr" ]] || [[ "$LANGUAGE" == "all" ]]; then
        cp assets/nopanic.conf /etc/apache2/sites-available/nopanic.conf
        a2ensite nopanic
        echo -e "$MSGGREEN" "$SRVMSG" "nopanic.recovery.box enabled" "$MSGNC"
    fi
    a2dissite 000-default
    if [[ $(grep "listen 8080" /etc/apache2/ports.conf) -eq 1 ]];then
        sed -i 's/Listen 80/ Listen 8080/' /etc/apache2/ports.conf
    fi
    systemctl restart apache2
    if [[ $(systemctl is-active apache2) == "active" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "Apache2 configured successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to configure Apache2.${MSGNC}"
        exit 1
    fi
}

#######################################################

install_openwebrx() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Installing OpenWebRX Plus..." "$MSGNC"
    mkdir -p /etc/owrx/var /etc/owrx/etc /etc/owrx/plugins/{receiver,map}
    docker pull slechev/openwebrxplus-softmbe:latest
    cp assets/openwebrx.service /etc/systemd/system/openwebrx.service
    systemctl daemon-reload
    systemctl enable openwebrx.service
    systemctl start openwebrx.service
    if [[ $(systemctl is-active openwebrx) == "active" ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "OpenWebRX Plus service started successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to start OpenWebRX Plus service.${MSGNC}"
        exit 1
    fi
}

#######################################################

install_rtlsdr_drivers() {
    echo -e "$MSGYELLOW" "$SRVMSG" "Managing rtl-sdr drivers..." "$MSGNC"
    apt-get purge rtl-sdr -y
    apt-get purge -y ^librtlsdr
    rm -rvf /usr/lib/librtlsdr* 
    rm -rvf /usr/include/rtl-sdr* 
    rm -rvf /usr/local/lib/librtlsdr* 
    rm -rvf /usr/local/include/rtl-sdr* 
    rm -rvf /usr/local/include/rtl_* 
    rm -rvf /usr/local/bin/rtl_*
    apt-get install libusb-1.0-0-dev git cmake pkg-config build-essential -y -qq > /dev/null
    (
        git clone https://github.com/rtlsdrblog/rtl-sdr-blog
        cd rtl-sdr-blog/ || exit
        mkdir build
        cd build || exit
        cmake ../ -DINSTALL_UDEV_RULES=ON
        make
        make install
        cp ../rtl-sdr.rules /etc/udev/rules.d/
        ldconfig
    )
}

main() {
    ## checks / settings
    check_prerequisites
    ## define Language (default french)
    define_language
    ## set keyboard layout
    set_keyboard
    ## define interface names
    choose_interfaces_names
    rename_interfaces
    configure_interfaces
    ## Install basic tools
    install_basic_tools
    ## Add needed repositories
    set_repositories
    ## Install Docker
    install_docker
    ## Install Kiwix
    install_kiwix
    read -r -p "$SRVMSG Download Wikipedia ? [y/n] : " WikiDown
    if [[ "$WikiDown" == "y" ]]; then
        download_wikipedia
    else
        echo -e "$MSGYELLOW" "$SRVMSG" "Skipping Wikipedia download." "$MSGNC"
    fi
    service_kiwix
    ## Install Access Point
    disable_wpa_supplicant
    install_access_point
    ## Enable IPv4 routing
    enable_ipv4_routing
    ## Setup IPtables
    setup_iptables
    ## Install PDFs
    if [[ "$LANGUAGE" == "en" ]] || [[ "$LANGUAGE" == "all" ]]; then
        download_english_pdfs
    fi
    if [[ "$LANGUAGE" == "fr" ]] || [[ "$LANGUAGE" == "all" ]]; then
        download_french_pdfs
    fi
    ## Install Apache2 and configure it
    install_apache
    ## Install OpenWebRX Plus
    install_openwebrx
    ## Install the last driver for the rtl-sdr 
    install_rtlsdr_drivers
    echo -e "$MSGRED" "$SRVMSG" "Installation complete! Please reboot the system to apply all changes." "$MSGNC"
}

#######################################################

main