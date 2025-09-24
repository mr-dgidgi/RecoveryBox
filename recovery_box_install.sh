#!/bin/bash

#
#
#
#
#
# monter le disque externe vers /data/ avant de lancer le script
#

#check if root
if [[ $(whoami) != root ]]; then 
    echo "user is not root"
    exit 1
fi
# check if /data exists
if [[ ! -d /data ]]; then
    echo "/data does not exist. Please mount your external drive to /data"
    echo "example: mount /dev/sda1 /data"
    exit 1
fi
# check if we are on a debian system
if [[ ! -f /etc/debian_version ]]; then
    echo "This script is only for Debian based systems"
    exit 1
fi
# check if we are on arm64 architecture
if [[ $(dpkg --print-architecture) != "arm64" ]]; then
    echo "This script is only for arm64 architecture"
    exit 1
fi

# Add needed repositories
apt install -y ca-certificates
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
echo 'deb http://download.opensuse.org/repositories/home:/tumic:/GPXSee/Raspbian_12/ /' | tee /etc/apt/sources.list.d/home:tumic:GPXSee.list
curl -fsSL https://download.opensuse.org/repositories/home:tumic:GPXSee/Raspbian_12/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/home_tumic_GPXSee.gpg > /dev/null

apt update

# Git install
apt install git -y

# kiwix installation
wget https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-armv8-3.7.0.tar.gz
tar -zxvf kiwix-tools_linux-armv8-3.7.0.tar.gz 
mv kiwix-tools_linux-armv8*/* /usr/local/bin/
rm -r kiwix-tools_linux-arm*

# Download Wikipedia for kiwix
mkdir /data/kiwix
wget -P /data/kiwix https://download.kiwix.org/zim/wikipedia/wikipedia_fr_all_nopic_2025-08.zim 
# This step take time

# kiwix service creation
cp assets/kiwix.service /etc/systemd/system/kiwix.service
systemctl enable kiwix
systemctl start kiwix

# install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Disable wpa_supplicant on wlan0
systemctl stop wpa_supplicant@wlan0
systemctl disable wpa_supplicant@wlan0

# Install the simple-pi-hotspot container
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
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# Setup IPtables
mkdir -p /etc/iptables
cp assets/iptables.sh /etc/iptables/iptables.sh
chmod +x /etc/iptables/iptables.sh
cp assets/iptables.service /etc/systemd/system/iptables.service
systemctl daemon-reload
systemctl enable iptables.service
systemctl start iptables.service

# dump oldu.fr
wget -P /data/ -mkxKE -e robots=off http://oldu.fr/
# This step take a lot of time as we dump all the website

# install + conf apache2
apt install -y apache2
cp assets/oldu.fr.conf /etc/apache2/sites-available/oldu.fr.conf
a2ensite oldu.fr
a2dissite 000-default
sed -i 's/Listen 80/ Listen 8080/' /etc/apache2/ports.conf
systemctl restart apache2

# Install gpxsee
apt install gpxsee -y

# TODO default map load => opentopomap
# sans doute dans /usr/share/gpxsee/maps

# Install GQRX
apt purge -y xtrx-dkms
apt install gqrx-sdr -y

# Install the last driver for the rtl-sdr 
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
