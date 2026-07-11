#!/bin/bash

ConfigFile="/etc/recoverybox/services.json"
OutputJson="/data/www/rbstatus.json"
Light=false

# --- Fonctions de collecte (écriture JSON) ---

Get_InternetPing() {
    PingGoogle=$(ping -c 1 8.8.8.8 &> /dev/null; echo $?)
    PingCloudflare=$(ping -c 1 1.1.1.1 &> /dev/null; echo $?)
    PingYandex=$(ping -c 1 77.88.8.8 &> /dev/null; echo $?)

    if [ "$PingGoogle" -eq 0 ] || [ "$PingCloudflare" -eq 0 ] || [ "$PingYandex" -eq 0 ]; then
        echo "0"
    else
        echo "1"
    fi
}

Get_InternetResolve() {
    ResolveGoogle=$(nslookup -timeout=3 google.com &> /dev/null; echo $?)
    ResolveCloudflare=$(nslookup -timeout=3 cloudflare.com &> /dev/null; echo $?)
    ResolveYandex=$(nslookup -timeout=3 yandex.com &> /dev/null; echo $?)

    if [ "$ResolveGoogle" -eq 0 ] || [ "$ResolveCloudflare" -eq 0 ] || [ "$ResolveYandex" -eq 0 ]; then
        echo "0"
    else
        echo "1"
    fi
}

Get_ServiceStatus() {
    ServicesJson="["
    First=true

    for Row in $(jq -c '.[]' "$ConfigFile"); do
        Id=$(echo "$Row" | jq -r '.id')
        SvcName=$(echo "$Row" | jq -r '.name')
        SvcType=$(echo "$Row" | jq -r '.type')
        Unit=$(echo "$Row" | jq -r '.unit // empty')
        CheckUrl=$(echo "$Row" | jq -r '.check_url // empty')
        CheckHost=$(echo "$Row" | jq -r '.check_host // empty')
        Activated=$(echo "$Row" | jq -r '.activated // false')

        if $Light; then
            if [[ "$SvcType" == "ping" ]] || [[ "$SvcType" == "dns" ]]; then
                continue
            fi
        fi

        if [[ "$Activated" == "true" ]]; then
            case "$SvcType" in
                systemd)
                    systemctl is-active --quiet "$Unit" && SvcStatus=0 || SvcStatus=1
                    systemctl is-enabled --quiet "$Unit" || SvcStatus=2
                    ;;
                http)
                    HttpCode=$(curl -q -I -H "Host: $CheckHost" "$CheckUrl" 2>/dev/null | head -n 1 | cut -d' ' -f2)
                    [[ "$HttpCode" == "200" ]] && SvcStatus=0 || SvcStatus=1
                    ;;
                ping)
                    SvcStatus=$(Get_InternetPing)
                    ;;
                dns)
                    SvcStatus=$(Get_InternetResolve)
                    ;;
            esac

            [[ "$First" == "true" ]] && First=false || ServicesJson+=","
            ServicesJson+="{\"id\":\"$Id\",\"name\":\"$SvcName\",\"status\":$SvcStatus}"
        fi
    done
    ServicesJson+="]"

    GpsJson=$(Get_GPS)
    SystemJson=$(Get_System)
    jq -n \
        --argjson services "$ServicesJson" \
        --argjson gps "$GpsJson" \
        --argjson system "$SystemJson" \
        '{services: $services, gps: $gps, system: $system}' > "$OutputJson"
}

Get_GPS() {
    GPSData=$(timeout 3s gpspipe -w -n 5 2>/dev/null | grep "TPV" | tail -n 1)

    if [[ -z "$GPSData" ]]; then
        GpsStatus=1
        Fix="none"
        Lat="null"
        Lon="null"
        Alt="null"
    else
        GpsStatus=0
        Mode=$(echo "$GPSData" | jq -r '.mode' 2>/dev/null || echo 0)
        Lat=$(echo "$GPSData" | jq -r '.lat // null' 2>/dev/null)
        Lon=$(echo "$GPSData" | jq -r '.lon // null' 2>/dev/null)
        Alt=$(echo "$GPSData" | jq -r '.alt // null' 2>/dev/null)
        case "$Mode" in
            2) Fix="2D Lock" ;;
            3) Fix="3D Lock" ;;
            *) Fix="No Fix"; GpsStatus=1 ;;
        esac
    fi
    echo "{\"status\":$GpsStatus,\"fix\":\"$Fix\",\"lat\":$Lat,\"lon\":$Lon,\"alt\":$Alt}"
}

Get_System() {
    CpuUsage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 + $6}')
    RamUsage=$(free | awk 'NR==2 {printf "%.1f", ($3/$2) * 100}')
    SwapUsage=$(free | awk 'NR==3 {printf "%.1f", ($3/$2) * 100}')
    Temp0=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
    Temp1=$(($(cat /sys/class/thermal/thermal_zone1/temp) / 1000))
    Temp2=$(($(cat /sys/class/thermal/thermal_zone2/temp) / 1000))
    echo "{\"cpu\":$CpuUsage,\"ram\":$RamUsage,\"swap\":$SwapUsage,\"temp\":[$Temp0,$Temp1,$Temp2]}"
}

# --- Fonctions d'affichage (lecture JSON) ---

Print_ServiceStatus() {
    for Row in $(jq -c '.services[]' "$OutputJson"); do
        SvcName=$(echo "$Row" | jq -r '.name')
        SvcStatus=$(echo "$Row" | jq -r '.status')

        if [[ "$SvcStatus" -eq 0 ]]; then
            Badge="\033[0;32m Running \033[0m"
        elif [[ "$SvcStatus" -eq 1 ]]; then
            Badge="\033[0;31m Critical \033[0m"
        else
            Badge="\033[0;33m Disabled \033[0m"
        fi

        echo -e "=+= $SvcName : \t\t\t\t $Badge"
    done
}

Print_GPS() {
    GpsStatus=$(jq -r '.gps.status' "$OutputJson")
    Fix=$(jq -r '.gps.fix' "$OutputJson")
    Lat=$(jq -r '.gps.lat' "$OutputJson")
    Lon=$(jq -r '.gps.lon' "$OutputJson")
    Alt=$(jq -r '.gps.alt' "$OutputJson")

    if [[ "$GpsStatus" -eq 0 ]]; then
        Badge="\033[0;32m Running \033[0m"
    else
        Badge="\033[0;31m No GPS device \033[0m"
    fi
    echo -e "=+= GPS status: \t\t\t\t $Badge"

    case "$Fix" in
        "2D Lock")
            Badge="\033[0;33m 2D Lock \033[0m"
            Pos="Lat: $Lat\n\t\t\t\t\t\t Lon: $Lon"
            ;;
        "3D Lock")
            Badge="\033[0;32m 3D Lock \033[0m"
            Pos="Lat: $Lat\n\t\t\t\t\t\t Lon: $Lon\n\t\t\t\t\t\t Alt: ${Alt}m"
            ;;
        *)
            Badge="\033[0;31m No Fix \033[0m"
            Pos="Searching..."
            ;;
    esac
    echo -e "=+= GPS fix: \t\t\t\t\t $Badge"

    if [[ "$Fix" == "2D Lock" ]] || [[ "$Fix" == "3D Lock" ]]; then
        echo -e "=+= GPS Position: \t\t\t\t \033[0;34m$Pos\033[0m"
    else
        if [[ "$GpsStatus" -eq 1 ]]; then
            echo -e "=+= GPS Position: \t\t\t\t  \033[0;31mNo GPS device\033[0m"
        else
            echo -e "=+= GPS Position: \t\t\t\t  \033[0;31m$Pos\033[0m"
        fi
    fi
}

Print_System() {
    CpuUsage=$(jq -r '.system.cpu' "$OutputJson")
    RamUsage=$(jq -r '.system.ram' "$OutputJson")
    SwapUsage=$(jq -r '.system.swap' "$OutputJson")
    Temps=($(jq -r '.system.temp[]' "$OutputJson"))

    CpuInt=${CpuUsage%.*}
    if [[ $CpuInt -gt 80 ]]; then
        Color="\033[0;31m"
    elif [[ $CpuInt -gt 60 ]]; then
        Color="\033[0;33m"
    else
        Color="\033[0;32m"
    fi
    echo -e "=+= CPU Usage : \t\t\t\t  ${Color}${CpuUsage}%\033[0m"

    RamInt=${RamUsage%.*}
    if [[ $RamInt -gt 80 ]]; then
        Color="\033[0;31m"
    elif [[ $RamInt -gt 60 ]]; then
        Color="\033[0;33m"
    else
        Color="\033[0;32m"
    fi
    echo -e "=+= RAM Usage : \t\t\t\t  ${Color}${RamUsage}%\033[0m"

    SwapInt=${SwapUsage%.*}
    if [[ $SwapInt -gt 80 ]]; then
        Color="\033[0;31m"
    elif [[ $SwapInt -gt 60 ]]; then
        Color="\033[0;33m"
    else
        Color="\033[0;32m"
    fi
    echo -e "=+= Swap Usage : \t\t\t\t  ${Color}${SwapUsage}%\033[0m"

    for T in "${Temps[@]}"; do
        if [[ $T -gt 80 ]]; then
            Color="\033[0;31m"
        elif [[ $T -gt 60 ]]; then
            Color="\033[0;33m"
        else
            Color="\033[0;32m"
        fi
        echo -e "\t\t\t\t\t\t  ${Color}${T}°C\033[0m"
    done
}

# --- Points d'entrée ---

main() {
    echo -e "#########################################################"
    echo -e "################## RecoveryBox Status ###################"
    echo -e "#########################################################"
    echo -e "\n\n"
    Get_ServiceStatus
    echo -e "#########################################################"
    echo -e "## Services"
    Print_ServiceStatus
    echo -e "#########################################################"
    echo -e "## GPS"
    Print_GPS
    echo -e "#########################################################"
    echo -e "## System"
    Print_System
}

light() {
    Light=true
    Get_ServiceStatus
    Print_ServiceStatus
}

if [[ "$1" == "light" ]]; then
    light
else
    main
fi
