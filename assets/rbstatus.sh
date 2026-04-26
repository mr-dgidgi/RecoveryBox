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

Print_Status() {
	Name="$2"
	if [[ "$1" -eq 0 ]]; then
		Status="\033[0;32m Running \033[0m"
	else
		Status="\033[0;31m Critical \033[0m"
	fi

	echo -e "=+= $Name : \t\t\t\t $Status"
}

Print_GPSstatus() {
	if [[ $(gpspipe -w -n 5 | grep -q "caca") -eq 0 ]] then
		Status="\033[0;32m Running \033[0m"
	else
		Status="\033[0;31m Reception error \033[0m"
	fi

	echo -e "=+= GPS localization: \t\t\t\t $Status"
}

StatKiwix=$(systemctl is-active kiwix)
StatAP=$(systemctl is-active ap.service)
StatApache=$(systemctl is-active apache2 > /dev/null 2>&1; echo $?)
StatPDF=$(if [[ "$(curl -q -I http://pdf.recovery.box 2>/dev/null | head -n 1|cut -d$' ' -f2)" == "200" ]]; then echo "0"; else echo "1"; fi)
StatNopanic=$(if [[ "$(curl -q -I http://nopanic.recovery.box 2>/dev/null | head -n 1|cut -d$' ' -f2)" == "200" ]]; then echo "0"; else echo "1"; fi)
StatOWRX=$(systemctl is-active owrx > /dev/null 2>&1; echo $?)
StatPing=$(Get_InternetPing)
StatResolve=$(Get_InternetResolve)
StatChrony=$(systemctl is-active chrony.service > /dev/null 2>&1; echo $?)

Print_Temp() {
    # On initialise les valeurs
    Temp[0]=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
    Temp[1]=$(($(cat /sys/class/thermal/thermal_zone1/temp) / 1000))
    Temp[2]=$(($(cat /sys/class/thermal/thermal_zone2/temp) / 1000))
    
    # On utilise l'index (0, 1, 2) pour boucler et modifier le tableau
    for k in "${!Temp[@]}"; do
        val=${Temp[$k]}
        if [[ $val -gt 80 ]]; then
            color="\033[0;31m"
        elif [[ $val -gt 60 ]]; then
            color="\033[0;33m"
        else
            color="\033[0;32m"
        fi
        Temp[$k]="${color}${val}°C\033[0m"
    done

    echo -e "=+= System Temp : \t\t\t\t  ${Temp[0]}"
    echo -e "\t\t\t\t\t\t  ${Temp[1]}"
    echo -e "\t\t\t\t\t\t  ${Temp[2]}"
}

main() {
	Print_Status "$StatPing" "Interet Access"
	Print_Status "$StatResolve" "Web Resolver"
	Print_Status "$StatChrony" "Time Sync"
	Print_Status "$StatAP" "AccessPoint"
	Print_Status "$StatApache" "Apache server"
	Print_Status "$StatPDF" "Web English PDF"
	Print_Status "$StatNopanic" "Web French PDF"
	Print_Status "$StatKiwix" "Kiwix Server"
	Print_Status "$StatOWRX" "OpenWebRX"
	Print_GPSstatus
	Print_Temp
}

main