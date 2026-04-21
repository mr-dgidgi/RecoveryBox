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

#######################################################
# checks / settings
#######################################################

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

# language settings
echo -e "$MSGYELLOW" "$SRVMSG" "choose your language / choisissez votre langue :" "$MSGNC"
echo -e "$MSGYELLOW" "$SRVMSG" "1 = English" "$MSGNC"
echo -e "$MSGYELLOW" "$SRVMSG" "2 = Français" "$MSGNC"
echo -e "$MSGYELLOW" "$SRVMSG" "3 = Tout/Both" "$MSGNC"
read -r -p "$SRVMSG Enter your choice / Entrez votre choix : " lang_choice
case $lang_choice in
    1) echo -e "$MSGGREEN" "$SRVMSG" "Language set to English" "$MSGNC"
    Lang="en"
    ;;
    2) echo -e "$MSGGREEN" "$SRVMSG" "Langue définie sur Français" "$MSGNC"
    Lang="fr"
    ;;
    3) echo -e "$MSGGREEN" "$SRVMSG" "Language set to English and Français" "$MSGNC"
    Lang="all"
    ;;
    *) echo -e "$MSGRED" "$SRVMSG" "Invalid choice, defaulting to French" "$MSGNC"
    Lang="fr"
    ;;esac

#######################################################
# Install basic tools
#######################################################
echo -e "$MSGYELLOW" "$SRVMSG" "Installing basic tools..." "$MSGNC"
apt-get update -qq
apt-get install -y -qq curl gpg ca-certificates git > /dev/null
if [ $? -eq 0 ]; then
    echo -e "$MSGGREEN" "$SRVMSG" "basic tools installed successfully.${MSGNC}"
else
    echo -e "$MSGRED" "$SRVMSG" "basic tools installation failed.${MSGNC}"
    exit 1
fi


#######################################################
# Add needed repositories
#######################################################
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

#######################################################
# install Docker
#######################################################
echo -e "$MSGYELLOW" "$SRVMSG" "Installing Docker..." "$MSGNC"
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null
if [ $? -eq 0 ]; then
    echo -e "$MSGGREEN" "$SRVMSG" "Docker installed successfully.${MSGNC}"
else
    echo -e "$MSGRED" "$SRVMSG" "failed to install Docker.${MSGNC}"
    exit 1
fi
#######################################################
# kiwix installation
#######################################################
echo -e "$MSGYELLOW" "$SRVMSG" "Installing kiwix..." "$MSGNC"

docker pull ghcr.io/kiwix/kiwix-serve:3.8.2
if [ $? -eq 0 ]; then
    echo -e "$MSGGREEN" "$SRVMSG" "Kiwix installed successfully.${MSGNC}"
else
    echo -e "$MSGRED" "$SRVMSG" "failed to install Kiwix.${MSGNC}"
    exit 1
fi

# Download Wikipedia for kiwix
mkdir /data/kiwix
read -r -p "$SRVMSG Download Wikipedia ? [y/n] : " WikiDown
if [[ "$WikiDown" == "y" ]]; then
    if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
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

    if [[ "$Lang" == "en" ]] || [[ "$Lang" == "all" ]]; then
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
else
    echo -e "$MSGYELLOW" "$SRVMSG" "Skipping Wikipedia download." "$MSGNC"
fi

# kiwix service creation
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

#######################################################
# Rename interfaces
#######################################################
echo -e "$MSGYELLOW" "$SRVMSG" "Renaming network interfaces." "$MSGNC"
# get current interfaces names
ip -br link
read -r -p "$SRVMSG Which interface is the WAN? : " IntWAN
read -r -p "$SRVMSG Which interface is the Access Point? : " IntAP


#######################################################
# Access Point
#######################################################

# Disable wpa_supplicant on wlan0
# should be useless with x64
#echo -e "$SRVMSG" "WiFi Access Point - preparing wlan0 interface..." "$MSGNC"
#systemctl stop wpa_supplicant@wlan0
#systemctl disable wpa_supplicant@wlan0
#if [[ $(systemctl is-active wpa_supplicant@wlan0) == "inactive" ]] && [[ $(systemctl is-enabled wpa_supplicant@wlan0) == "disabled" ]]; then
#    echo -e "$MSGGREEN" "$SRVMSG" "wpa_supplicant disabled on wlan0 successfully.${MSGNC}"
#else
#    echo -e "$MSGRED" "$SRVMSG" "failed to disable wpa_supplicant on wlan0.${MSGNC}"
#    exit 1
#fi

# Install the simple-pi-hotspot container
echo -e "$MSGYELLOW""$SRVMSG" "WiFi Access Point - Installing simple-pi-hotspot container..." "$MSGNC"
docker pull mrdgidgi/simple-pi-hotspot
mkdir -p /etc/ap_config/
cp assets/dnsmasq.conf /etc/ap_config/dnsmasq.conf
cp assets/dnsmasq-hosts.conf /etc/ap_config/dnsmasq-hosts.conf
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

# enable ipv4 routing
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

# Setup IPtables
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

#######################################################
## Apache
#######################################################

if [[ "$Lang" == "en" ]] || [[ "$Lang" == "all" ]]; then
    echo -e "$MSGYELLOW" "$SRVMSG" "installing English survival PDFs..." "$MSGNC"
    mkdir -p /data/enpdf
    git clone https://github.com/mr-dgidgi/RecoveryENPDF.git /data/enpdf
    if [[ -d /data/enpdf ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "English survival PDFs installed successfully.${MSGNC}"
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to install English survival PDFs.${MSGNC}"
        exit 1
    fi
fi

# dump oldu.fr --- Site DOWN !!! forum toujours up + blog aussi. Voir pour récupérer les données du site depuis archive.org si problème persistant
#wget -P /data/ -mkxKE -e robots=off http://oldu.fr/
# This step take a lot of time as we dump all the website

# dump nopanic.fr
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    echo -e "$MSGYELLOW" "$SRVMSG" "Downloading nopanic.fr website..." "$MSGNC"
    wget -P /data/nopanic -r -l 1 -nd -A pdf,html -H -p -k -e robots=off "https://nopanic.fr/bookbank/"
    if [[ $? -eq 0 ]]; then
        echo -e "$MSGGREEN" "$SRVMSG" "nopanic.fr website downloaded successfully.${MSGNC}"
        
    else
        echo -e "$MSGRED" "$SRVMSG" "failed to download nopanic.fr website.${MSGNC}"
        exit 1
    fi
fi

# install + conf apache2
echo -e "$MSGYELLOW" "$SRVMSG" "Installing and configuring Apache2..." "$MSGNC"
apt-get install -y -qq apache2 > /dev/null
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    cp assets/enpdf.conf /etc/apache2/sites-available/enpdf.conf
    a2ensite enpdf.conf
    echo -e "$MSGGREEN" "$SRVMSG" "pdf.recovery.box enabled" "$MSGNC"
fi
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    #cp assets/oldu.fr.conf /etc/apache2/sites-available/oldu.fr.conf
    cp assets/nopanic.conf /etc/apache2/sites-available/nopanic.conf
    #a2ensite oldu
    #echo "$SRVMSG" "oldu.recovery.box enabled"
    a2ensite nopanic
    echo -e "$MSGGREEN" "$SRVMSG" "nopanic.recovery.box enabled" "$MSGNC"
fi
a2dissite 000-default
sed -i 's/Listen 80/ Listen 8080/' /etc/apache2/ports.conf
systemctl restart apache2
if [[ $(systemctl is-active apache2) == "active" ]]; then
    echo -e "$MSGGREEN" "$SRVMSG" "Apache2 configured successfully.${MSGNC}"
else
    echo -e "$MSGRED" "$SRVMSG" "failed to configure Apache2.${MSGNC}"
    exit 1
fi

#######################################################
# Mapping / navigation tools
#######################################################

## Headless server, no need for visual APP
# Install gpxsee
#echo -e "$SRVMSG" "Installing GPXSee..." "$MSGNC"
#apt-get install gpxsee -y -qq > /dev/null
# TODO default map load => opentopomap
# sans doute dans /usr/share/gpxsee/maps

#######################################################
# Radio tools
#######################################################

# Install OpenWebRX Plus
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

# Install the last driver for the rtl-sdr 
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
git clone https://github.com/rtlsdrblog/rtl-sdr-blog
cd rtl-sdr-blog/
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make
make install
cp ../rtl-sdr.rules /etc/udev/rules.d/
ldconfig

#######################################################
# Final message
#######################################################
echo -e "$SRVMSG" "Installation complete! Please reboot the system to apply all changes." "$MSGNC"