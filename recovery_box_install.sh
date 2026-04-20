#!/bin/bash

#
#
#
#
#
# monter /data/ avant de lancer le script
#

SRVMSG='\033[0;32m =+= '
NC='\033[0m'

#######################################################
# checks / settings
#######################################################

#check if root
if [[ $(whoami) != root ]]; then 
    echo -e "$SRVMSG" "user is not root" ${NC}
    exit 1
fi
# check if /data exists
if [[ ! -d /data ]]; then
    echo -e "$SRVMSG" "/data does not exist. Please mount/create /data" ${NC}
    echo -e "$SRVMSG" "example: mount /dev/sda1 /data" ${NC}
    exit 1
fi
# check if we are on a debian system
if [[ ! -f /etc/debian_version ]]; then
    echo -e "$SRVMSG" "This script is only for Debian based systems" ${NC}
    exit 1
fi
# check if we are on amd64 architecture
if [[ $(dpkg --print-architecture) != "amd64" ]]; then
    echo -e "$SRVMSG" "This script is only for amd64 architecture" ${NC}
    exit 1
fi

# language settings
echo -e "$SRVMSG" "choose your language / choisissez votre langue :" ${NC}
echo -e "$SRVMSG" "1 = English" ${NC}
echo -e "$SRVMSG" "2 = Français" ${NC}
echo -e "$SRVMSG" "3 = Tout/Both" ${NC}
read -p "$SRVMSG Enter your choice / Entrez votre choix : " lang_choice
case $lang_choice in
    1) echo -e "$SRVMSG" "Language set to English" ${NC}
    Lang="en"
    ;;
    2) echo -e "$SRVMSG" "Langue définie sur Français" ${NC}
    Lang="fr"
    ;;
    3) echo -e "$SRVMSG" "Language set to English and Français" ${NC}
    Lang="all"
    ;;
    *) echo -e "$SRVMSG" "Invalid choice, defaulting to French" ${NC}
    Lang="fr"
    ;;esac

#######################################################
# Install basic tools
#######################################################
echo -e "$SRVMSG" "Installing basic tools..." ${NC}
apt-get update -qq
apt-get install -y -qq curl gpg ca-certificates git > /dev/null


#######################################################
# Add needed repositories
#######################################################
echo -e "$SRVMSG" "Adding repositories..." ${NC}
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
apt-get update -qq

#######################################################
# install Docker
#######################################################
echo -e "$SRVMSG" "Installing Docker..." ${NC}
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null

#######################################################
# kiwix installation
#######################################################
echo -e "$SRVMSG" "Installing kiwix..." ${NC}

docker pull ghcr.io/kiwix/kiwix-serve:3.8.2
# Download Wikipedia for kiwix
mkdir /data/kiwix
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    echo -e "$SRVMSG" "Downloading Wikipedia in French. This step may take some time..." ${NC}
    FileName=$(curl -s "https://download.kiwix.org/zim/wikipedia/" | grep -oP 'wikipedia_fr_all_nopic_\d{4}-\d{2}\.zim' | sort -V | tail -1)
    wget -q --show-progress -P /data/kiwix https://download.kiwix.org/zim/wikipedia/${FileName}
fi
if [[ "$Lang" == "en" ]] || [[ "$Lang" == "all" ]]; then
    echo -e "$SRVMSG" "Downloading Wikipedia in English. This step may take some time..." ${NC}
    FileName=$(curl -s "https://download.kiwix.org/zim/wikipedia/" | grep -oP 'wikipedia_en_all_nopic_\d{4}-\d{2}\.zim' | sort -V | tail -1)
    wget -q --show-progress -P /data/kiwix https://download.kiwix.org/zim/wikipedia/${FileName}
fi

# kiwix service creation
echo -e "$SRVMSG" "Creating kiwix service..." ${NC}
cp assets/kiwix.service /etc/systemd/system/kiwix.service
systemctl enable kiwix
systemctl start kiwix

#######################################################
# Access Point
#######################################################

# Disable wpa_supplicant on wlan0
echo -e "$SRVMSG" "WiFi Access Point - preparing wlan0 interface..." ${NC}
systemctl stop wpa_supplicant@wlan0
systemctl disable wpa_supplicant@wlan0

# Install the simple-pi-hotspot container
echo -e "$SRVMSG" "WiFi Access Point - Installing simple-pi-hotspot container..." ${NC}
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

# enable ipv4 routing
echo -e "$SRVMSG" "Enabling IPv4 routing..." ${NC}
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# Setup IPtables
echo -e "$SRVMSG" "Setting up IPtables for NAT and routing..." ${NC}
mkdir -p /etc/iptables
cp assets/iptables.sh /etc/iptables/iptables.sh
chmod +x /etc/iptables/iptables.sh
cp assets/iptables.service /etc/systemd/system/iptables.service
systemctl daemon-reload
systemctl enable iptables.service
systemctl start iptables.service

#######################################################
## Apache
#######################################################

if [[ "$Lang" == "en" ]] || [[ "$Lang" == "all" ]]; then
    echo -e "$SRVMSG" "Downloading English survival PDFs..." ${NC}
    TPDir="/data/enpdf"
    mkdir -p "$TPDir"
    cd "$TPDir" || exit
    curl -sL "https://trueprepper.com/survival-pdfs-downloads/" | grep -oP 'https?://[^"]+\.pdf' | sort -u > pdf_list.txt
    wget -i pdf_list.txt -A pdf -nc -nv --wait=1 --random-wait
    cat <<EOF > "$INDEX_FILE"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Survival PDF Archive</title>
    <style>
        body { font-family: sans-serif; background: #1a1a1a; color: #eee; padding: 20px; }
        h1 { color: #ffcc00; border-bottom: 2px solid #333; }
        ul { list-style: none; padding: 0; }
        li { margin: 8px 0; padding: 10px; background: #2a2a2a; border-radius: 4px; }
        a { color: #44ff44; text-decoration: none; word-break: break-all; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>True Prepper PDFs</h1>
    <p>Total : $(ls -1 *.pdf | wc -l) files</p>
    <ul>
EOF

    #PDF link creation
    for file in *.pdf; do
        echo "        <li><a href=\"$file\" target=\"_blank\">$file</a></li>" >> "$INDEX_FILE"
    done

    cat <<EOF >> "$INDEX_FILE"
</ul>
</body>
</html>
EOF

fi

# dump oldu.fr --- Site DOWN !!! forum toujours up + blog aussi. Voir pour récupérer les données du site depuis archive.org si problème persistant
wget -P /data/ -mkxKE -e robots=off http://oldu.fr/
# This step take a lot of time as we dump all the website

# dump nopanic.fr
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    echo -e "$SRVMSG" "Downloading nopanic.fr website..." ${NC}
    wget -P /data/nopanic -r -l 1 -nd -A pdf,html -H -p -k -e robots=off "https://nopanic.fr/bookbank/"
fi

# install + conf apache2
echo -e "$SRVMSG" "Installing and configuring Apache2..." ${NC}
apt-get install -y -qq apache2 > /dev/null
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    cp assets/enpdf.conf /etc/apache2/sites-available/enpdf.conf
    a2ensite enpdf.conf
    echo -e "$SRVMSG" "pdf.recovery.box enabled" ${NC}
fi
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    #cp assets/oldu.fr.conf /etc/apache2/sites-available/oldu.fr.conf
    cp assets/nopanic.conf /etc/apache2/sites-available/nopanic.conf
    #a2ensite oldu
    #echo "$SRVMSG" "oldu.recovery.box enabled"
    a2ensite nopanic
    echo -e "$SRVMSG" "nopanic.recovery.box enabled" ${NC}
fi
a2dissite 000-default
sed -i 's/Listen 80/ Listen 8080/' /etc/apache2/ports.conf
systemctl restart apache2

#######################################################
# Mapping / navigation tools
#######################################################

# Install gpxsee
echo -e "$SRVMSG" "Installing GPXSee..." ${NC}
apt-get install gpxsee -y -qq > /dev/null
# TODO default map load => opentopomap
# sans doute dans /usr/share/gpxsee/maps

#######################################################
# Radio tools
#######################################################

# Install OpenWebRX Plus
echo -e "$SRVMSG" "Installing OpenWebRX Plus..." ${NC}
mkdir -p /etc/owrx/var /etc/owrx/etc /etc/owrx/plugins/{receiver,map}
docker pull slechev/openwebrxplus-softmbe:latest
cp assets/openwebrx.service /etc/systemd/system/openwebrx.service
systemctl daemon-reload
systemctl enable openwebrx.service
systemctl start openwebrx.service

# Install the last driver for the rtl-sdr 
echo -e "$SRVMSG" "Managing rtl-sdr drivers..." ${NC}
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
echo -e "$SRVMSG" "Installation complete! Please reboot the system to apply all changes." ${NC}