#!/bin/bash

#
#
#
#
#
# Faire un lien symbolique du disque externe vers /data/ avant de lancer le script
#

# ajout des repos nécessaires
echo 'deb http://download.opensuse.org/repositories/home:/tumic:/GPXSee/Raspbian_10/ /' | tee /etc/apt/sources.list.d/home:tumic:GPXSee.list
curl -fsSL https://download.opensuse.org/repositories/home:tumic:GPXSee/Raspbian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_tumic_GPXSee.gpg > /dev/null

sudo apt update


# kiwix installation
wget https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-armhf.tar.gz
tar -zxvf kiwix-tools_linux-armhf.tar.gz
mv kiwix-tools_linux-armhf*/* /usr/local/bin/
rm -r kiwix-tools_linux-armhf*

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

########
# TODO 
# Modifier la ligne DAEMON_CONF de /etc/default/hostapd
sed -i 's|DAEMON_CONF|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

#hostapd service
sudo systemctl daemon-reload
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

# enable ipv4 routing
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# NAT traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -S > /etc/iptables/iptables.ipv4.nat
# à confirmer
echo 'iptables-restore < /etc/iptables/iptables.ipv4.nat' >> /etc/rc.local


# dump oldu.fr
wget -P /data/ -mkxKE -e robots=off http://oldu.fr/

# install + conf apache2
apt install -y apache2
cp oldu.fr.conf /etc/apache2/sites-available/oldu.fr.conf
ln -s /etc/apache2/sites-enabled/oldu.fr.conf /etc/apache2/sites/available/oldu.fr.conf
sed -i 's/LISTEN 80/ LISTEN 80 8080/'

# Install gpxsee
apt install gpxsee

# TODO default map load => opentopomap
# sans doute dans /usr/share/gpxsee/maps

# Install GQRX
apt install gqrx-sdr
# Install the last driver for the rtl-sdr 
apt remove rtl-sdr
git clone https://github.com/osmocom/rtl-sdr.git
apt install build-essential cmake usbutils libusb-1.0-0-dev
cd rtl-sdr
mkdir build
cd build
cmake -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON ../
ldconfig
cd ../..
cp rtlsdr-blacklist.conf /etc/modprobe.d/rtlsdr-blacklist.conf
