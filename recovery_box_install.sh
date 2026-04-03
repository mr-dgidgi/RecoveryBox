#!/bin/bash

#
#
#
#
#
# monter /data/ avant de lancer le script
#

SRVMSG="=+= "

#######################################################
# checks / settings
#######################################################

#check if root
if [[ $(whoami) != root ]]; then 
    echo "$SRVMSG" "user is not root"
    exit 1
fi
# check if /data exists
if [[ ! -d /data ]]; then
    echo "$SRVMSG" "/data does not exist. Please mount/create /data"
    echo "$SRVMSG" "example: mount /dev/sda1 /data"
    exit 1
fi
# check if we are on a debian system
if [[ ! -f /etc/debian_version ]]; then
    echo "$SRVMSG" "This script is only for Debian based systems"
    exit 1
fi
# check if we are on amd64 architecture
if [[ $(dpkg --print-architecture) != "amd64" ]]; then
    echo "$SRVMSG" "This script is only for amd64 architecture"
    exit 1
fi

# language settings
echo "$SRVMSG" "choose your language / choisissez votre langue :"
echo "$SRVMSG" "1 = English"
echo "$SRVMSG" "2 = Français"
echo "$SRVMSG" "2 = Tout/Both"
read -p "$SRVMSG Enter your choice / Entrez votre choix : " lang_choice
case $lang_choice in
    1) echo "$SRVMSG" "Language set to English"
    Lang="en"
    ;;
    2) echo "$SRVMSG" "Langue définie sur Français"
    Lang="fr"
    ;;
    3) echo "$SRVMSG" "Language set to English and Français"
    Lang="all"
    ;;
    *) echo "$SRVMSG" "Invalid choice, defaulting to French"
    Lang="fr"
    ;;esac



#######################################################
# Add needed repositories
#######################################################
echo "$SRVMSG" "Adding repositories..."
apt install -y ca-certificates
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
echo 'deb http://download.opensuse.org/repositories/home:/tumic:/GPXSee/Debian_13/ /' | tee /etc/apt/sources.list.d/home:tumic:GPXSee.list
curl -fsSL https://download.opensuse.org/repositories/home:tumic:GPXSee/Debian_13/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/home_tumic_GPXSee.gpg > /dev/null

apt update

#######################################################
# Git install
#######################################################
echo "$SRVMSG" "Installing Git..."
apt install git -y

#######################################################
# install Docker
#######################################################
echo "$SRVMSG" "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#######################################################
# kiwix installation
#######################################################
echo "$SRVMSG" "Installing kiwix..."

docker pull ghcr.io/kiwix/kiwix-serve:3.8.2
# Download Wikipedia for kiwix
mkdir /data/kiwix
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    echo "$SRVMSG" "Downloading Wikipedia in French. This step may take some time..."
    wget -P /data/kiwix https://download.kiwix.org/zim/wikipedia/wikipedia_fr_all_nopic_2026-02.zim
fi
if [[ "$Lang" == "en" ]] || [[ "$Lang" == "all" ]]; then
    echo "$SRVMSG" "Downloading Wikipedia in English. This step may take some time..."
    wget -P /data/kiwix https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_nopic_2026-03.zim
fi

# kiwix service creation
echo "$SRVMSG" "Creating kiwix service..."
cp assets/kiwix.service /etc/systemd/system/kiwix.service
systemctl enable kiwix
systemctl start kiwix

#######################################################
# Access Point
#######################################################

# Disable wpa_supplicant on wlan0
echo "$SRVMSG" "WiFi Access Point - preparing wlan0 interface..."
systemctl stop wpa_supplicant@wlan0
systemctl disable wpa_supplicant@wlan0

# Install the simple-pi-hotspot container
echo "$SRVMSG" "WiFi Access Point - Installing simple-pi-hotspot container..."
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
echo "$SRVMSG" "Enabling IPv4 routing..."
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# Setup IPtables
echo "$SRVMSG" "Setting up IPtables for NAT and routing..."
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
    echo "$SRVMSG" "Downloading English survival PDFs..."
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
    echo "$SRVMSG" "Downloading nopanic.fr website..."
    wget -P /data/nopanic -r -l 1 -nd -A pdf,html -H -p -k -e robots=off "https://nopanic.fr/bookbank/"
fi

# install + conf apache2
echo "$SRVMSG" "Installing and configuring Apache2..."
apt install -y apache2
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    cp assets/enpdf.conf /etc/apache2/sites-available/enpdf.conf
    a2ensite enpdf.conf
    echo "$SRVMSG" "pdf.recovery.box enabled"
fi
if [[ "$Lang" == "fr" ]] || [[ "$Lang" == "all" ]]; then
    #cp assets/oldu.fr.conf /etc/apache2/sites-available/oldu.fr.conf
    cp assets/nopanic.conf /etc/apache2/sites-available/nopanic.conf
    #a2ensite oldu
    #echo "$SRVMSG" "oldu.recovery.box enabled"
    a2ensite nopanic
    echo "$SRVMSG" "nopanic.recovery.box enabled"
fi
a2dissite 000-default
sed -i 's/Listen 80/ Listen 8080/' /etc/apache2/ports.conf
systemctl restart apache2

#######################################################
# Mapping / navigation tools
#######################################################

# Install gpxsee
echo "$SRVMSG" "Installing GPXSee..."
apt install gpxsee -y
# TODO default map load => opentopomap
# sans doute dans /usr/share/gpxsee/maps

#######################################################
# Radio tools
#######################################################

# Install OpenWebRX Plus
echo "$SRVMSG" "Installing OpenWebRX Plus..."
mkdir -p /etc/owrx/var /etc/owrx/etc /etc/owrx/plugins/{receiver,map}
docker pull slechev/openwebrxplus-softmbe:latest
cp assets/openwebrx.service /etc/systemd/system/openwebrx.service
systemctl daemon-reload
systemctl enable openwebrx.service
systemctl start openwebrx.service

# Install the last driver for the rtl-sdr 
echo "$SRVMSG" "Managing rtl-sdr drivers..."
apt purge rtl-sdr -y
apt purge -y ^librtlsdr
rm -rvf /usr/lib/librtlsdr* 
rm -rvf /usr/include/rtl-sdr* 
rm -rvf /usr/local/lib/librtlsdr* 
rm -rvf /usr/local/include/rtl-sdr* 
rm -rvf /usr/local/include/rtl_* 
rm -rvf /usr/local/bin/rtl_*
apt install libusb-1.0-0-dev git cmake pkg-config build-essential -y
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
echo "$SRVMSG Installation complete! Please reboot the system to apply all changes."