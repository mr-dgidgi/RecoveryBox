#!/bin/bash

# Color codes for console output
SRVMSG=' =+= '
MSGGREEN='\033[0;32m'
MSGYELLOW='\033[0;33m'
MSGRED='\033[0;31m'
MSGNC='\033[0m'
CURRENTSERVICE=""

# Convert user input to yes/no values (1=yes, 0=no, 99=invalid)
yes_no_check () {
	if [ "$1" = "Y" ] || [ "$1" = "y" ] || [ "$1" = "Yes" ] || [ "$1" = "yes" ] || [ "$1" = "Oui" ] || [ "$1" = "OUI" ] || [ "$1" = "oui" ] || [ "$1" = "O" ]; then
		echo 1

	elif [ "$1" = "N" ] || [ "$1" = "n" ] || [ "$1" = "No" ] || [ "$1" = "no" ] || [ "$1" = "Non" ] || [ "$1" = "NON" ] || [ "$1" = "non" ] || [ "$1" = "N" ]; then
		echo 0

	else
		echo 99

	fi
}

# Verify script is running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "$MSGRED" "$SRVMSG" "This script must be run as root. Please run with sudo or as root user." "$MSGNC"
        exit 1
    fi
}

# Pause execution and wait for user to press Enter
continue_enter() {
    read -rp "Press Enter to continue"
    clear
}


##############################


show_service_status () {
    echo -e "#########################################################"
    echo -e "################### Services Status #####################"
    echo -e "#########################################################"
    echo -e "\n\n"
    /usr/local/bin/rbstatus light
    echo -e "\n"
    continue_enter
}

select_service () {
    while true; do
        echo -e "#########################################################"
        echo -e "################### Select a Service ####################"
        echo -e "#########################################################"
        echo -e "\n\n"
        echo -e "1. Chrony (Time Sync)"
        echo -e "2. AccessPoint"
        echo -e "3. Apache server"
        echo -e "4. Web Console"
        echo -e "5. Kiwix Server"
        echo -e "6. OpenWebRX"
        echo -e "7. Brouter"
        echo -e "8. Tileserver"
        read -rp "Choose a service : " ServiceChoosed
        case $ServiceChoosed in
            1) 
                CURRENTSERVICE="chrony.service"
                break
                ;;
            2) 
                CURRENTSERVICE="ap.service" 
                break
                ;;
            3) 
                CURRENTSERVICE="apache2.service"
                break
                ;;
            4) 
                CURRENTSERVICE="shellinabox.service"
                break
                ;;
            5) 
                CURRENTSERVICE="kiwix.service"
                break
                ;;
            6) 
                CURRENTSERVICE="openwebrx.service"
                break
                ;;
            7) 
                CURRENTSERVICE="brouter.service"
                break
                ;;
            8) 
                CURRENTSERVICE="tileserver-gl.service"
                break
                ;;
            *) 
                echo -e "$MSGRED" "$SRVMSG" "Invalid option. Please choose a valid service number." "$MSGNC"
                ;;
        esac
    done
}

start_service () {
    echo -e "$MSGYELLOW" "$SRVMSG" "Starting $CURRENTSERVICE..." "$MSGNC"
    systemctl start "$CURRENTSERVICE"
    sleep 5
    if systemctl is-active --quiet "$CURRENTSERVICE"; then
        echo -e "$MSGGREEN" "$SRVMSG" "$CURRENTSERVICE started successfully." "$MSGNC"
    else
        echo -e "$MSGRED" "$SRVMSG" "Failed to start $CURRENTSERVICE. Please check the service logs for more details." "$MSGNC"
        systemctl status "$CURRENTSERVICE"
    fi
}

stop_service () {
    echo -e "$MSGYELLOW" "$SRVMSG" "Stopping $CURRENTSERVICE..." "$MSGNC"
    systemctl stop "$CURRENTSERVICE"
    sleep 5
    if ! systemctl is-active --quiet "$CURRENTSERVICE"; then
        echo -e "$MSGGREEN" "$SRVMSG" "$CURRENTSERVICE stopped successfully." "$MSGNC"
    else
        echo -e "$MSGRED" "$SRVMSG" "Failed to stop $CURRENTSERVICE. Please check the service logs for more details." "$MSGNC"
        systemctl status "$CURRENTSERVICE"
    fi
}

restart_service () {
    echo -e "$MSGYELLOW" "$SRVMSG" "Restarting $CURRENTSERVICE..." "$MSGNC"
    systemctl restart "$CURRENTSERVICE"
    sleep 5
    if systemctl is-active --quiet "$CURRENTSERVICE"; then
        echo -e "$MSGGREEN" "$SRVMSG" "$CURRENTSERVICE restarted successfully." "$MSGNC"
    else
        echo -e "$MSGRED" "$SRVMSG" "Failed to restart $CURRENTSERVICE. Please check the service logs for more details." "$MSGNC"
        systemctl status "$CURRENTSERVICE"
    fi
}

enable_service () {
    echo -e "$MSGYELLOW" "$SRVMSG" "Enabling $CURRENTSERVICE to start on boot..." "$MSGNC"
    systemctl enable "$CURRENTSERVICE"
    if systemctl is-enabled --quiet "$CURRENTSERVICE"; then
        echo -e "$MSGGREEN" "$SRVMSG" "$CURRENTSERVICE enabled successfully." "$MSGNC"
    else
        echo -e "$MSGRED" "$SRVMSG" "Failed to enable $CURRENTSERVICE. Please check the service logs for more details." "$MSGNC"
        systemctl status "$CURRENTSERVICE"
    fi
}

disable_service () {
    echo -e "$MSGYELLOW" "$SRVMSG" "Disabling $CURRENTSERVICE from starting on boot..." "$MSGNC"
    systemctl disable "$CURRENTSERVICE"
    if ! systemctl is-enabled --quiet "$CURRENTSERVICE"; then
        echo -e "$MSGGREEN" "$SRVMSG" "$CURRENTSERVICE disabled successfully." "$MSGNC"
    else
        echo -e "$MSGRED" "$SRVMSG" "Failed to disable $CURRENTSERVICE. Please check the service logs for more details." "$MSGNC"
        systemctl status "$CURRENTSERVICE"
    fi
}

# Main interactive menu
main() {
    while true; do
        echo -e "#########################################################"
        echo -e "################### Services Manager ####################"
        echo -e "#########################################################"
        echo -e "\n\n"
        echo -e "1. Services status"
        echo -e "2. Start service"
        echo -e "3. Stop service"
        echo -e "4. Restart service"
        echo -e "5. Enable service"
        echo -e "6. Disable service"
        echo -e "7. Exit"
        read -rp "Choose an option : " OptionChoosed
        case $OptionChoosed in
            1)
                show_service_status
                ;;
            2)
                select_service
                start_service
                continue_enter
                ;;
            3)
                select_service
                stop_service
                continue_enter
                ;;
            4)
                select_service
                restart_service
                continue_enter
                ;;
            5)
                select_service
                enable_service
                continue_enter
                ;;
            6)
                select_service
                disable_service
                continue_enter
                ;;
            
            7)
                echo -e "$MSGGREEN" "$SRVMSG" "Exiting..." "$MSGNC"
                exit 0
                ;;
            *)
                echo -e "$MSGRED" "$SRVMSG" "Invalid option. Please choose 1, 2, 3, 4, 5 or 6." "$MSGNC"
                ;;
        esac
    done
}

check_root
main
