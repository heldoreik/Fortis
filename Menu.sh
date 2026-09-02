#!/bin/bash
source ./Ui.sh 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

while true; do
    echo "╔════════════════════╗"
    echo "║       FORTIS       ║"
    echo "╚════════════════════╝"
    echo
    echo "[+] OS: $OS"
    echo "[+] Current user: $USER"
    echo
    echo "Security configuration"
    echo
    echo -e "1. ${CYAN}Root SSH login${NC}              [$RootSSHLoginStatus]"
    echo -e "2. ${CYAN}Password authentication${NC}     [$PasswordAuthStatus]"
    echo -e "3. ${CYAN}SSH port${NC}                    [${YELLOW}$SSHPort${NC}]"
    echo -e "4. ${CYAN}Administrative user${NC}         [PERHAPS]"
    echo -e "5. ${CYAN}SSH public key${NC}              [ON]"
    echo -e "6. ${CYAN}Firewall${NC}                    [UFW]"
    echo -e "7. ${CYAN}Fail2Ban${NC}                    [ON]"
    echo -e "8. ${CYAN}Automatic updates${NC}           [ON]"
    echo -e "9. ${CYAN}Kernel hardening${NC}            [OFF]"
    echo
    echo -e "10. ${CYAN}Run security audit${NC}"
    echo -e "11. ${CYAN}Confirm successful SSH connection${NC}"
    echo -e "12. ${CYAN}Rollback configuration${NC}"
    echo
    echo -e "q. ${YELLOW}Exit${NC}"
    echo
    echo -ne "${WHITE}Your choice:${NC} "
    read choice

    case $choice in
        1)
            echo -n "Do you want to turn on/off Root SSH login? [y/N] "
            read onechoice
            case $onechoice in
                y) 
                    echo "It works"
                ;;

                n)
                    echo "It works"
                ;;

                *)
                    echo "It ALSO works"
                ;;
            esac
            ;;
        
        2)
            echo -n "Do you want to turn on/off Password auth? [y/N] "
            read twochoice
            case $twochoice in
                y) 
                    echo "It works"
                ;;

                n)
                    echo "It works"
                ;;

                *)
                    echo "It ALSO works"
                ;;

            esac
            ;;
        3)
            echo -n "Do you want to change SSH port? [y/N] "
            read threechoice
            case $threechoice in
                y) 
                    echo "It works"
                ;;

                n)
                    echo "It works"
                ;;

                *)
                    echo "It ALSO works"
                ;;

            esac
            ;;

    esac
done