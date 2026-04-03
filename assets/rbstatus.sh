#!/bin/bash


Get_InternetPing() {

    PingGoogle=$(ping -c 1 8.8.8.8 &> /dev/null; echo $?)
    PingCloudflare=$(ping -c 1 1.1.1.1 &> /dev/null; echo $?)
    PingYandex=$(ping -c 1 77.88.8.8 &> /dev/null; echo $?)

    if [ $PingGoogle -eq 0 ] || [ $PingCloudflare -eq 0 ] || [ $PingYandex -eq 0 ]; then
        echo "0"
    else
        echo "1"
    fi
}

Get_InternetResolve() {
    ResolveGoogle=$(nslookup google.com &> /dev/null; echo $?)
    ResolveCloudflare=$(nslookup cloudflare.com &> /dev/null; echo $?)
    ResolveYandex=$(nslookup yandex.com &> /dev/null; echo $?)

    if [ $ResolveGoogle -eq 0 ] || [ $ResolveCloudflare -eq 0 ] || [ $ResolveYandex -eq 0 ]; then
        echo "0"
    else
        echo "1"
    fi
}

StatKiwix=$(systemctl status kiwix > /dev/null 2>&1; echo $?)
StatAP=$(systemctl status ap.service > /dev/null 2>&1; echo $?)
StatApache=$(systemctl status apache2 > /dev/null 2>&1; echo $?)
StatPDF=$(if [ "$(curl -q -I http://pdf.recovery.box 2>/dev/null | head -n 1|cut -d$' ' -f2)" == "200" ]; then echo "0"; else echo "1"; fi)
StatNopanic=$(if [ "$(curl -q -I http://nopanic.recovery.box 2>/dev/null | head -n 1|cut -d$' ' -f2)" == "200" ]; then echo "0"; else echo "1"; fi)
StatOldu=$(if [ "$(curl -q -I http://oldu.recovery.box 2>/dev/null | head -n 1|cut -d$' ' -f2)" == "200" ]; then echo "0"; else echo "1"; fi)
StatOWRX=$(systemctl status owrx > /dev/null 2>&1; echo $?)
StatPing=$(Get_InternetPing)
StatResolve=$(Get_InternetResolve)

