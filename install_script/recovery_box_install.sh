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


# ajout des repos nécessaires
echo 'deb http://download.opensuse.org/repositories/home:/tumic:/GPXSee/Raspbian_12/ /' | sudo tee /etc/apt/sources.list.d/home:tumic:GPXSee.list
curl -fsSL https://download.opensuse.org/repositories/home:tumic:GPXSee/Raspbian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_tumic_GPXSee.gpg > /dev/null

sudo apt update

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
cp kiwix.service /etc/systemd/system/kiwix.service
systemctl enable kiwix
systemctl start kiwix

# wlan0 IP conf
cp wlan /etc/network/interfaces.d/wlan0

# dnsmasq installation + config
apt install -y dnsmasq
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cp dnsmasq.conf /etc/dnsmasq.conf

# dnsmasq service
systemctl daemon-reload
systemctl enable dnsmasq
systemctl start dnsmasq

# hostapd install + config
apt install -y hostapd
cp hostapd.conf /etc/hostapd/hostapd.conf

#hostapd service
systemctl daemon-reload
systemctl unmask hostapd
systemctl enable hostapd
systemctl start hostapd

# enable ipv4 routing
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# NAT traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -S > /etc/iptables/iptables.ipv4.nat
# à confirmer
echo 'iptables-restore < /etc/iptables/iptables.ipv4.nat' >> /etc/rc.local


# dump oldu.fr
wget -P /data/ -mkxKE -e robots=off http://oldu.fr/
# This step take a lot of time as we dump all the website

# install + conf apache2
apt install -y apache2
# missing file !!!
cp oldu.fr.conf /etc/apache2/sites-available/oldu.fr.conf
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
