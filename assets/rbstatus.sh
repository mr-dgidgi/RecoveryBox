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
    if [[ $(gpspipe -w -n 5 | grep -c "TPV") -ge 1 ]]; then
        Status="\033[0;32m Running \033[0m"
    else
        Status="\033[0;31m Reception error \033[0m"
    fi

    echo -e "=+= GPS status: \t\t\t\t $Status"
}

Print_GPSloc() {
    local GPSData=$(gpspipe -w -n 5 | grep "TPV" | tail -n 1)
    local mode=$(echo "$gps_json" | jq -r '.mode')
    local Lat=$(echo "$GPSData" | jq -r '.lat')
    local Lon=$(echo "$GPSData" | jq -r '.lon')
    local Alt=$(echo "$GPSData" | jq -r '.alt')

    case "$mode" in
        2)
            Status="\033[0;33m 2D Lock \033[0m"
            Pos="Lat: $Lat, Lon: $Lon"
            ;;
        3)
            Status="\033[0;32m 3D Lock \033[0m"
            Pos="Lat: $Lat, Lon: $Lon, Alt: ${Alt}m"
            ;;
        *)
            Status="\033[0;31m No Fix \033[0m"
            Pos="Searching..."
            ;;
    esac
    echo -e "=+= GPS fix: \t\t\t\t\t $Status"
    if [[ "$mode" -ge 2 ]]; then
        echo -e "=+= GPS Position: \t\t\t\t \033[0;34m$Pos\033[0m"
    else
        echo -e "=+= GPS Position: \t\t\t\t  \033[0;31mUnknown\033[0m"
    fi
}

StatKiwix=$(systemctl is-active kiwix)
StatAP=$(systemctl is-active ap.service)
StatApache=$(systemctl is-active apache2 > /dev/null 2>&1; echo $?)
StatPDF=$(if [[ "$(curl -q -I -H "Host: pdf.recovery.box" http://127.0.0.1 2>/dev/null | head -n 1 | cut -d' ' -f2)" == "200" ]]; then echo "0"; else echo "1"; fi)
StatNopanic=$(if [[ "$(curl -q -I -H "Host: nopanic.recovery.box" http://127.0.0.1 2>/dev/null | head -n 1|cut -d$' ' -f2)" == "200" ]]; then echo "0"; else echo "1"; fi)
StatOWRX=$(systemctl is-active openwebrx.service > /dev/null 2>&1; echo $?)
StatPing=$(Get_InternetPing)
StatResolve=$(Get_InternetResolve)
StatChrony=$(systemctl is-active chrony.service > /dev/null 2>&1; echo $?)

Print_Temp() {
    # On initialise les valeurs
    local Temp[0]=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
    local Temp[1]=$(($(cat /sys/class/thermal/thermal_zone1/temp) / 1000))
    local Temp[2]=$(($(cat /sys/class/thermal/thermal_zone2/temp) / 1000))
    
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

Print_CpuUsage() {
    local CpuUsage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 + $6}')
    local CpuInt=${CpuUsage%.*}
    if [[ $CpuInt -gt 80 ]]; then
        color="\033[0;31m"
    elif [[ $CpuInt -gt 60 ]]; then
        color="\033[0;33m"
    else
        color="\033[0;32m"
    fi
    echo -e "=+= CPU Usage : \t\t\t\t  ${color}${CpuUsage}%\033[0m"
}

Print_RamUsage() {
    local RamUsage=$(free | awk 'NR==2 {printf "%.1f", ($3/$2) * 100}')
    local RamInt=${RamUsage%.*}
    if [[ $RamInt -gt 80 ]]; then
        color="\033[0;31m"
    elif [[ $RamInt -gt 60 ]]; then
        color="\033[0;33m"
    else
        color="\033[0;32m"
    fi
    echo -e "=+= RAM Usage : \t\t\t\t  ${color}${RamUsage}%\033[0m"
}

Print_SwapUsage() {
    local SwapUsage=$(free | awk 'NR==3 {printf "%.1f", ($3/$2) * 100}')
    local SwapInt=${SwapUsage%.*}
    if [[ $SwapInt -gt 80 ]]; then
        color="\033[0;31m"
    elif [[ $SwapInt -gt 60 ]]; then
        color="\033[0;33m"
    else
        color="\033[0;32m"
    fi
    echo -e "=+= Swap Usage : \t\t\t\t  ${color}${SwapUsage}%\033[0m"
}

main() {
    echo -e "#########################################################"
    echo -e "################## RecoveryBox Status ###################"
    echo -e "#########################################################"
    echo -e "\n\n"
    echo -e "#########################################################"
    echo -e "## Services"
    Print_Status "$StatPing" "Interet Access"
    Print_Status "$StatResolve" "Web Resolver"
    Print_Status "$StatChrony" "Time Sync"
    Print_Status "$StatAP" "AccessPoint"
    Print_Status "$StatApache" "Apache server"
    Print_Status "$StatPDF" "Web English PDF"
    Print_Status "$StatNopanic" "Web French PDF"
    Print_Status "$StatKiwix" "Kiwix Server"
    Print_Status "$StatOWRX" "OpenWebRX"
    echo -e "#########################################################"
    echo -e "## GPS"

    Print_GPSstatus
    Print_GPSloc
    echo -e "#########################################################"
    echo -e "## System"
    Print_CpuUsage
    Print_RamUsage
    Print_SwapUsage
    Print_Temp
}

main