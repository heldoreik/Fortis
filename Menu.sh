#!/bin/bash
source ./Ui.sh 
source ./config.conf
source ./RootSSHLogin.sh
source ./PasswordAuth.sh
source ./SSHPort.sh
source ./Backup.sh
source ./AdminUser.sh

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
WHITE=$'\033[1;37m'
BOLD=$'\033[1m'
NC=$'\033[0m'

if [[ $(whoami) != "root" ]]; then
    echo -e "${RED}This script must be run as root.${NC}"
    exit 1
fi

if [[ "$WARNING" == "true" ]]; then
    echo -e "${RED}⚠ WARNING

Fortis will modify your system configuration.

Before continuing, make sure you have:

A backup of important configuration files
A second SSH session available for testing
Access to your server console/recovery environment in case SSH becomes unavailable

DO NOT close your current SSH session until you have successfully established a second SSH connection.

Incorrect configuration of SSH, firewall, or authentication settings may result in loss of access to your server.${NC}"
    read -r -p "Сontinue? [y/N] " warninganswer
    warninganswer="${warninganswer,,}"
    case $warninganswer in
        y|yes)
            :
            ;;
        
        *)
            exit 1
            ;;
        
    esac

fi

while true; do
    echo "╔════════════════════╗"
    echo "║       FORTIS       ║"
    echo "╚════════════════════╝"
    echo
    echo "[+] OS: $OS"
    echo "[+] Current user: $CurrentUSer"
    echo
    echo "Security configuration"
    echo
    echo -e "1. ${CYAN}Root SSH login${NC}              [$RootSSHLoginStatus]"
    echo -e "2. ${CYAN}Password authentication${NC}     [$PasswordAuthStatus]"
    echo -e "3. ${CYAN}SSH port${NC}                    [$SSHPortStatus]"
    echo -e "4. ${CYAN}Administrative user${NC}         [$Adminuser]"
    echo -e "5. ${CYAN}SSH public key${NC}              [${YELLOW}IDK${NC}]"
    echo -e "6. ${CYAN}Firewall${NC}                    [UFW]"
    echo -e "7. ${CYAN}Fail2Ban${NC}                    [ON]"
    echo -e "8. ${CYAN}Automatic updates${NC}           [ON]"
    echo -e "9. ${CYAN}Kernel hardening${NC}            [OFF]"
    echo
    echo -e "10. ${CYAN}Run security audit${NC}"
    echo -e "11. ${CYAN}Confirm successful SSH connection${NC}"
    echo -e "12. ${CYAN}Rollback configuration${NC}"
    echo -e "13. ${RED}Create SSH Backup${NC}"
    echo
    echo -e "q. ${YELLOW}Exit${NC}"
    echo
    echo -ne "${WHITE}Your choice:${NC} "
    read choice

    if [[ "$WARNINGBACKUP" == "true" ]]; then
        if [[ "$backupexists" == "false" ]]; then
            echo -e "${RED}⚠ WARNING${NC}"
            echo
            echo -e "${RED}No backup was found for the configuration you are about to modify.${NC}"
            echo
            echo -e "${RED}Changing this configuration without a backup may result in:${NC}"
            echo
            echo -e     "${RED}* Loss of SSH access${NC}"
            echo -e     "${RED}* Incorrect system configuration${NC}"
            echo -e     "${RED}* Inability to automatically restore the previous configuration${NC}"
            echo
            echo -e "${RED}Fortis strongly recommends creating a backup before continuing.${NC}"

            read -r -p "Do you want to create backup? [y/N] " warningbackupanswer
            warningbackupanswer="${warningbackupanswer,,}"
            case "$warningbackupanswer" in

                y|yes)
                    if [[ ! -d "$BACKUP_DIR" ]]; then
                        mkdir "$BACKUP_DIR" &>/dev/null
                    fi

                    cp /etc/ssh/sshd_config "$BACKUP_DIR"
                    source ./Backup.sh
                    echo -e "${GREEN}Backup has been created successfully${NC}"
                    
                    ;;
                
                *)
                    :
                    ;;
                
            esac

        fi
    fi



    case "$choice" in
        1)
            read -r -p "Do you want to turn on/off Root SSH login? [y/N] " onechoice
            onechoice="${onechoice,,}"
            case $onechoice in
                y|yes)
                    while true; do
                        echo -e "1. ${CYAN}ON${NC}"
                        echo -e "2. ${CYAN}OFF${NC}"
                        echo -e "3. ${CYAN}SSH-key${NC}"
                        read -r -p "Select an option [1-3]: " secondchoice

                        case $secondchoice in 
                            1)
                                NEW_VAL="yes"
                                ;;
                            2)
                                NEW_VAL="no"
                                ;;
                            3)
                                NEW_VAL="prohibit-password"
                                ;;
                            *)
                                echo -e "${YELLOW}Incorrect option${NC}"
                                continue
                                ;;
                        esac

                        if grep -qiE '^[[:space:]]*#?[[:space:]]*permitrootlogin[[:space:]]+' /etc/ssh/sshd_config; then
                            sed -i -E "s/^[[:space:]]*#?[[:space:]]*permitrootlogin[[:space:]]+.*/PermitRootLogin $NEW_VAL/I" /etc/ssh/sshd_config
                        else
                            echo "PermitRootLogin $NEW_VAL" >> /etc/ssh/sshd_config
                        fi

                        source ./RootSSHLogin.sh
                        echo -e "${GREEN}PermitRootLogin has been changed to '$NEW_VAL' successfully${NC}"
                    
                        break
                    done
                    ;;

                n|no)
                    echo "Cancelled"
                    ;;

                *)
                    echo -e "${YELLOW}Incorrect${NC}"
                    ;;
            esac
            ;;
        
        2)
            read -r -p "Do you want to turn on/off Password auth? [y/N] " twochoice
            twochoice="${twochoice,,}"
            case "$twochoice" in
                y|yes)
                    while true; do
                        if [[ "$PasswordAuth" == "yes" ]]; then
                           if grep -qE '^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+' /etc/ssh/sshd_config; then
                                    sed -i -E "s/^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+.*/passwordauthentication no/" /etc/ssh/sshd_config 

                            else 
                                echo "passwordauthentication no" >> /etc/ssh/sshd_config
                            
                            fi

                            source ./PasswordAuth.sh
                            echo -e "${GREEN}PasswordAuth has been changed successfully${NC}"

                        elif [[ "$PasswordAuth" == "no" ]]; then
                            if grep -qE '^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+' /etc/ssh/sshd_config; then
                                    sed -i -E "s/^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+.*/passwordauthentication yes/" /etc/ssh/sshd_config 

                            else 
                                echo "passwordauthentication yes" >> /etc/ssh/sshd_config
                            
                            fi
                            
                            source ./PasswordAuth.sh
                            echo -e "${GREEN}PasswordAuth has been changed successfully${NC}"

                        else 
                            echo -e "${RED}Something went wrong. Idk what exactly${NC}"

                        fi
                        
                        break
                    done
                ;;

                n|no)
                    echo "Cancelled"
                    ;;

                *)
                    echo -e "${YELLOW}Incorrect${NC}"
                    ;;

            esac
            ;;
        3)
            read -r -p "Do you want to change SSH port? [y/N] " threechoice
            threechoice="${threechoice,,}"
            case "$threechoice" in
                y|yes)
                    while true; do
                        read -r -p "Which port do you prefer? " portthreechoice
                        if [[ "$portthreechoice" =~ ^[0-9]+$ ]] && [[ "$portthreechoice" -ge 1 ]] && [[ "$portthreechoice" -le 65535 ]]; then 
                            source ./Ui.sh
                            if echo "$BusyPort" | grep -qww "$portthreechoice"; then
                                echo -e "${YELLOW}This port is already used. Choose another one.${NC} "
                            else
                                if grep -qE '^[[:space:]]*#?[[:space:]]*Port[[:space:]]+' /etc/ssh/sshd_config; then
                                    sed -i -E "s/^[[:space:]]*#?[[:space:]]*Port[[:space:]]+.*/Port $portthreechoice/" /etc/ssh/sshd_config
                                else
                                    echo "Port $portthreechoice" >> /etc/ssh/sshd_config
                                fi
                        
                                source ./SSHPort.sh
                                echo -e "${GREEN}Port has been changed successfully${NC}"
                                break
                            fi
                        else 
                            echo -e "${YELLOW}Incorrect port${NC} "
                        fi
                    done
                ;;

                n|no)
                    echo "Cancelled"
                    ;;

                *)
                    echo -e "${YELLOW}Incorrect${NC}"
                    ;;

            esac
            ;;
    4)
        read -r -p "Do you want to create an administrative user? [y/N] " adminuseranswer
        adminuseranswer="${adminuseranswer,,}"
        case "$adminuseranswer" in
            y|yes)
                while true; do
                    read -r -p "Enter new username: " username
                    if id "$username" &>/dev/null; then
                        echo -e "${YELLOW}User '$username' already exists${NC}"
                    else
                        useradd -m -s /bin/bash "$username"
                        usermod -aG sudo "$username"
                        passwd "$username"
                        source ./AdminUser.sh
                        echo -e "${GREEN}User has been successfully created${NC}"
                    fi
                break
                done
            ;;
            
            n|no)
                echo "Cancelled"
                ;;

            *)
                echo -e "${YELLOW}Incorrect${NC}"
                ;;

            esac
            ;;

    5)
        read -r -p "Do you want to add SSHKey to the sudo user's directory? [y/N] " fourchoice
        fourchoice="${fourchoice,,}"

        case "$fourchoice" in
            y|yes)
                while true; do
                    echo "$SUDO_USERS"
                    read -r -p "Please choose one of sudo users [type name]: " typename
                    if [ -z "$SUDO_USERS" ]; then
                        echo -e "${RED}No sudo users found!${NC}"
                    fi

                    if echo "$SUDO_USERS" | grep -qw "$typename"; then

                        read -r -p "Please enter your public SSH-key. ${RED}NOT A PRIVATE KEY${NC}: " typesshkey

                        if [ ! -d "/home/$typename/.ssh" ]; then
                            mkdir -p /home/$typename/.ssh
                            chmod 700 /home/$typename/.ssh
                            touch /home/$typename/.ssh/authorized_keys
                            chmod 600 /home/$typename/.ssh/authorized_keys
                        elif [ ! -f "/home/$typename/.ssh/authorized_keys" ]; then
                            touch /home/$typename/.ssh/authorized_keys
                            chmod 600 /home/$typename/.ssh/authorized_keys
                        fi

                        echo "$typesshkey" >> /home/$typename/.ssh/authorized_keys
                        echo -e "${GREEN}SSH-key has been added successfully${NC}"
                        break
                    else 
                        echo "${YELLOW}UNKNOWN USER${NC}"
                    fi
                done
                ;;
            n|no)
                echo "Cancelled"
                ;;
            *)
                echo -e "${YELLOW}Incorrect${NC}"
                ;;
        esac
        ;;





    esac
done