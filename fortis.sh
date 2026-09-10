#!/bin/bash
FORTIS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
WHITE=$'\033[1;37m'
BOLD=$'\033[1m'
NC=$'\033[0m'


source "$FORTIS_ROOT/lib/ui.sh" 
source "$FORTIS_ROOT/config.conf"
source "$FORTIS_ROOT/lib/root-ssh-login.sh"
source "$FORTIS_ROOT/lib/password-auth.sh"
source "$FORTIS_ROOT/lib/ssh-port.sh" 
source "$FORTIS_ROOT/lib/backup.sh" 
source "$FORTIS_ROOT/lib/admin-user.sh" 
source "$FORTIS_ROOT/lib/firewall.sh"
source "$FORTIS_ROOT/lib/ssh-public-key.sh"
source "$FORTIS_ROOT/lib/fail2ban.sh"
source "$FORTIS_ROOT/lib/rollback.sh"



if [[ $(whoami) != "root" ]]; then
    echo -e "${RED}This script must be run as sudo user.${NC}"
    exit 1
fi

if ! command -v sshd &>/dev/null; then
    read -r -p "${YELLOW}openssh-server is not installed. Install it?${NC} [y/N] " installssh
    installssh="${installssh,,}"
    if [[ "$installssh" == "y" || "$installssh" == "yes" ]]; then
        if ! (apt update && apt install -y openssh-server); then
            echo -e "${RED}Install failed. Try manually: sudo apt update && sudo apt install -y openssh-server${NC}"
        else
            source "$FORTIS_ROOT/lib/ui.sh"
        fi
    else
        echo -e "${RED}Fortis hardens the SSH server. Fortis will not work right without it${NC}"
    fi
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
    read -r -p "Continue? [y/N] " warninganswer
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
    echo -e "1. ${CYAN}Root SSH login${NC}              [$RootSSHLoginStatus]"
    echo -e "2. ${CYAN}Password authentication${NC}     [$PasswordAuthStatus]"
    echo -e "3. ${CYAN}SSH port${NC}                    [$SSHPortStatus]"
    echo -e "4. ${CYAN}Administrative user${NC}         [$Adminuser]"
    echo -e "5. ${CYAN}SSH public key${NC}              [$sshkeystatus]"
    echo -e "6. ${CYAN}Firewall${NC}                    [$FirewallStatus]"
    echo -e "7. ${CYAN}Fail2Ban${NC}                    [$fail2banstatus]"
    echo -e "8. ${CYAN}Automatic updates${NC}           [ON]"
    echo -e "9. ${CYAN}Kernel hardening${NC}            [OFF]"
    echo
    echo -e "10. ${CYAN}Run security audit${NC}"
    echo -e "11. ${CYAN}Rollback configuration${NC}"
    echo
    echo -e "12. ${YELLOW}Apply changes${NC}"
    echo
    echo -e "q. ${YELLOW}Exit${NC}"
    echo
    echo -ne "${WHITE}Your choice:${NC} "
    read -r choice

    if [[ "$WARNINGBACKUP" == "true" && "$choice" =~ ^[123]$ ]]; then
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
                    source "$FORTIS_ROOT/lib/backup.sh"
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

                        source "$FORTIS_ROOT/lib/root-ssh-login.sh"
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
            read -r -p "Do you want to turn ${PasswordAuthStatusturn} Password auth? [y/N] " twochoice
            twochoice="${twochoice,,}"
            case "$twochoice" in
                y|yes)
                    while true; do
                        if [[ "$PasswordAuth" == "yes" ]]; then
                           if grep -qiE '^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+' /etc/ssh/sshd_config; then
                                    sed -i -E "s/^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+.*/passwordauthentication no/I" /etc/ssh/sshd_config 

                            else 
                                echo "passwordauthentication no" >> /etc/ssh/sshd_config
                            
                            fi

                            source "$FORTIS_ROOT/lib/password-auth.sh"
                            echo -e "${GREEN}PasswordAuth has been changed successfully${NC}"

                        elif [[ "$PasswordAuth" == "no" ]]; then
                            if grep -qiE '^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+' /etc/ssh/sshd_config; then
                                    sed -i -E "s/^[[:space:]]*#?[[:space:]]*passwordauthentication[[:space:]]+.*/passwordauthentication yes/I" /etc/ssh/sshd_config 

                            else 
                                echo "passwordauthentication yes" >> /etc/ssh/sshd_config
                            
                            fi
                            
                            source "$FORTIS_ROOT/lib/password-auth.sh"
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
                        if [[ -n "$ACTIVE_FW" ]]; then 
                            read -r -p "${RED}PLEASE TURN OFF YOUR FIREWALL BEFORE CHANGING PORT. OKAY? [y/N]${NC} " turnofffw
                            turnofffw="${turnofffw,,}"
                            if [[ "$turnofffw" == "y" || "$turnofffw" == "yes" ]]; then
                                :
                            else 
                                break
                            fi
                        fi
                        read -r -p "Which port do you prefer? " portthreechoice
                        if [[ "$portthreechoice" == "q" || "$portthreechoice" == "Q" ]]; then
                        break
                        fi

                        if [[ "$portthreechoice" =~ ^[0-9]+$ ]] && [[ "$portthreechoice" -ge 1 ]] && [[ "$portthreechoice" -le 65535 ]]; then 
                            source "$FORTIS_ROOT/lib/ui.sh"
                            if echo "$BusyPort" | grep -qw "$portthreechoice"; then
                                echo -e "${YELLOW}This port is already used. Choose another one.${NC} "
                            else
                                if grep -qiE '^[[:space:]]*#?[[:space:]]*Port[[:space:]]+' /etc/ssh/sshd_config; then
                                    sed -i -E "s/^[[:space:]]*#?[[:space:]]*Port[[:space:]]+.*/Port $portthreechoice/I" /etc/ssh/sshd_config
                                else
                                    echo "Port $portthreechoice" >> /etc/ssh/sshd_config
                                fi
                        
                                source "$FORTIS_ROOT/lib/ssh-port.sh"
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
                    if [[ "$username" == "q" || "$username" == "Q" ]]; then
                    break
                    fi

                    if id "$username" &>/dev/null; then
                        echo -e "${YELLOW}User '$username' already exists${NC}"
                    else
                        useradd -m -s /bin/bash "$username"
                        usermod -aG sudo "$username"
                        passwd "$username"
                        source "$FORTIS_ROOT/lib/admin-user.sh"
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
                    if [[ "$typename" == "q" || "$typename" == "Q" ]]; then
                    break

                    fi

                    if [ -z "$SUDO_USERS" ]; then
                        echo -e "${RED}No sudo users found!${NC}"
                        break
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
                        chown -R "$typename:$typename" "/home/$typename/.ssh"
                        source "$FORTIS_ROOT/lib/ssh-public-key.sh"
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

    6)
        echo "What do you want to do with firewall?"
        echo "1. ${CYAN}ENABLE Firewall${NC}"
        echo "2. ${CYAN}DISABLE Firewall${NC}"
        read -r -p "Your choice: " choicefirewall
        case "$choicefirewall" in
            1)
                while true; do
                    if [[ -n "$ACTIVE_FW" ]]; then
                        read -r -p "${RED}Firewall is already running. Continue? [y/N]${NC} " fwrunch
                        fwrunch="${fwrunch,,}"
                        if [[ "$fwrunch" == "y" || "$fwrunch" == "yes" ]]; then
                        :
                        else
                            break
                        fi
                    fi


                    echo "1. ${CYAN}UFW${NC}"
                    echo "2. ${CYAN}iptables${NC}"
                    echo "3. ${CYAN}firewalld${NC}"
                    echo "4. ${CYAN}nftables${NC}"
                    read -r -p "Your choice: " choicefirewalltwo
                    if [[ "$choicefirewalltwo" == "q" || "$choicefirewalltwo" == "Q" ]]; then
                    break
                    fi

                    case "$choicefirewalltwo" in 
                        1)
                            if ! command -v ufw &>/dev/null; then
                                read -r -p "UFW is not installed. Install it? [y/N] " UFWchoice
                                UFWchoice="${UFWchoice,,}"
                                if [[ "$UFWchoice" == "y" || "$UFWchoice" == "yes" ]]; then
                                    if ! (apt update && apt install -y ufw); then
                                        echo -e "${RED}Install failed. Try manually: sudo apt update && sudo apt install -y ufw${NC}"
                                        break
                                    fi
                                else
                                    break
                                fi
                            fi

                            if [[ -n "$SSHPort" ]]; then
                                ufw allow "${SSHPort}/tcp" &>/dev/null
                            else
                                echo -e "${RED}Could not detect SSH port - refusing to enable UFW${NC}"
                                break
                            fi
                            [[ "$ALLOW_HTTP" == "true"  ]] && ufw allow 80/tcp  &>/dev/null
                            [[ "$ALLOW_HTTPS" == "true" ]] && ufw allow 443/tcp &>/dev/null

                            if ufw --force enable; then
                                echo -e "${GREEN}UFW enabled. SSH port $SSHPort is allowed${NC}"
                            else
                                echo -e "${RED}Failed. Try manually: sudo ufw enable${NC}"
                            fi
                            source "$FORTIS_ROOT/lib/firewall.sh"
                            break
                            ;;
                        2)
                            if ! command -v iptables &>/dev/null; then
                                read -r -p "iptables is not installed. Install it? [y/N] " IPTchoice
                                IPTchoice="${IPTchoice,,}"
                                if [[ "$IPTchoice" == "y" || "$IPTchoice" == "yes" ]]; then
                                    if ! (apt update && DEBIAN_FRONTEND=noninteractive apt install -y iptables iptables-persistent); then
                                        echo -e "${RED}Install failed. Try manually: sudo apt update && sudo apt install -y iptables iptables-persistent${NC}"
                                        break
                                    fi
                                else
                                    break
                                fi
                            elif ! command -v netfilter-persistent &>/dev/null; then
                                DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent &>/dev/null || \
                                    echo -e "${YELLOW}No iptables-persistent - rules will be lost on reboot${NC}"
                            fi

                            if [[ -z "$SSHPort" ]]; then
                                echo -e "${RED}Could not detect SSH port - refusing to configure iptables${NC}"
                                break
                            fi

                            iptables -C INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
                            iptables -C INPUT -i lo -j ACCEPT 2>/dev/null || iptables -A INPUT -i lo -j ACCEPT
                            iptables -C INPUT -p tcp --dport "$SSHPort" -j ACCEPT 2>/dev/null || iptables -A INPUT -p tcp --dport "$SSHPort" -j ACCEPT
                            [[ "$ALLOW_HTTP" == "true" ]]  && { iptables -C INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null || iptables -A INPUT -p tcp --dport 80 -j ACCEPT; }
                            [[ "$ALLOW_HTTPS" == "true" ]] && { iptables -C INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || iptables -A INPUT -p tcp --dport 443 -j ACCEPT; }
                            iptables -P INPUT DROP
                            iptables -P FORWARD DROP

                            if command -v netfilter-persistent &>/dev/null; then
                                netfilter-persistent save
                                echo -e "${GREEN}iptables rules applied and saved. SSH port $SSHPort is allowed${NC}"
                            else
                                echo -e "${YELLOW}Rules applied but NOT saved - will be lost on reboot${NC}"
                            fi
                            source "$FORTIS_ROOT/lib/firewall.sh"
                            break
                            ;;
                        3)
                            if ! command -v firewall-cmd &>/dev/null; then
                                read -r -p "firewalld is not installed. Install it? [y/N] " FWDchoice
                                FWDchoice="${FWDchoice,,}"
                                if [[ "$FWDchoice" == "y" || "$FWDchoice" == "yes" ]]; then
                                    if ! (apt update && apt install -y firewalld); then
                                        echo -e "${RED}Install failed. Try manually: sudo apt update && sudo apt install -y firewalld${NC}"
                                        break
                                    fi
                                else
                                    break
                                fi
                            fi

                            if [[ -z "$SSHPort" ]]; then
                                echo -e "${RED}Could not detect SSH port - refusing to enable firewalld${NC}"
                                break
                            fi

                            if systemctl is-active --quiet firewalld; then
                                firewall-cmd --permanent --add-port="${SSHPort}/tcp" &>/dev/null
                                [[ "$ALLOW_HTTP" == "true" ]]  && firewall-cmd --permanent --add-service=http  &>/dev/null
                                [[ "$ALLOW_HTTPS" == "true" ]] && firewall-cmd --permanent --add-service=https &>/dev/null
                                firewall-cmd --reload &>/dev/null
                                echo -e "${GREEN}firewalld rules updated. SSH port $SSHPort is allowed${NC}"
                            else
                                firewall-offline-cmd --add-port="${SSHPort}/tcp" &>/dev/null
                                [[ "$ALLOW_HTTP" == "true" ]]  && firewall-offline-cmd --add-service=http  &>/dev/null
                                [[ "$ALLOW_HTTPS" == "true" ]] && firewall-offline-cmd --add-service=https &>/dev/null
                                if systemctl enable --now firewalld; then
                                    echo -e "${GREEN}firewalld enabled. SSH port $SSHPort is allowed${NC}"
                                else
                                    echo -e "${RED}Failed. Try manually: sudo systemctl enable --now firewalld${NC}"
                                fi
                            fi
                            source "$FORTIS_ROOT/lib/firewall.sh"
                            break
                            ;;
                        4)
                            if ! command -v nft &>/dev/null; then
                                read -r -p "nftables is not installed. Install it? [y/N] " NFTchoice
                                NFTchoice="${NFTchoice,,}"
                                if [[ "$NFTchoice" == "y" || "$NFTchoice" == "yes" ]]; then
                                    if ! (apt update && apt install -y nftables); then
                                        echo -e "${RED}Install failed. Try manually: sudo apt update && sudo apt install -y nftables${NC}"
                                        break
                                    fi
                                else
                                    break
                                fi
                            fi

                            if [[ -z "$SSHPort" ]]; then
                                echo -e "${RED}Could not detect SSH port - refusing to configure nftables${NC}"
                                break
                            fi

                            PORTS="$SSHPort"
                            [[ "$ALLOW_HTTP" == "true" ]]  && PORTS="$PORTS, 80"
                            [[ "$ALLOW_HTTPS" == "true" ]] && PORTS="$PORTS, 443"

                            [[ -f /etc/nftables.conf ]] && cp /etc/nftables.conf "$BACKUP_DIR/nftables.conf"

                            cat > /etc/nftables.conf << EOF
                                    #!/usr/sbin/nft -f
                                    flush ruleset

                                    table inet filter {
                                        chain input {
                                            type filter hook input priority 0; policy drop;
                                            iif "lo" accept
                                            ct state established,related accept
                                            tcp dport { $PORTS } accept
                                        }
                                        chain forward {
                                            type filter hook forward priority 0; policy drop;
                                        }
                                        chain output {
                                            type filter hook output priority 0; policy accept;
                                        }
                                    }
EOF

                            if nft -c -f /etc/nftables.conf &>/dev/null && nft -f /etc/nftables.conf; then
                                systemctl enable --now nftables &>/dev/null
                                echo -e "${GREEN}nftables enabled. SSH port $SSHPort is allowed${NC}"
                            else
                                echo -e "${RED}Config invalid - old rules kept. Check /etc/nftables.conf${NC}"
                            fi
                            source "$FORTIS_ROOT/lib/firewall.sh"
                            break
                            ;;
                    esac
                done
                ;;
            
            2)
                if [[ -z "$ACTIVE_FW" ]]; then
                    echo -e "${YELLOW}No active firewall found${NC}"
                else
                    read -r -p "${RED}Active firewall:$ACTIVE_FW. Disable it? [y/N]${NC} " fwdis
                    fwdis="${fwdis,,}"
                    if [[ "$fwdis" == "y" || "$fwdis" == "yes" ]]; then
                        if [[ "$ACTIVE_FW" == *ufw* ]]; then
                            ufw disable && echo -e "${GREEN}UFW disabled${NC}"
                        fi
                        if [[ "$ACTIVE_FW" == *firewalld* ]]; then
                            systemctl disable --now firewalld && echo -e "${GREEN}firewalld disabled${NC}"
                        fi
                        if [[ "$ACTIVE_FW" == *nftables* ]]; then
                            nft flush ruleset
                            systemctl disable --now nftables
                            echo -e "${GREEN}nftables disabled${NC}"
                        fi
                        if [[ "$ACTIVE_FW" == *iptables* ]]; then
                            iptables -P INPUT ACCEPT
                            iptables -P FORWARD ACCEPT
                            iptables -P OUTPUT ACCEPT
                            iptables -F
                            command -v netfilter-persistent &>/dev/null && netfilter-persistent save
                            echo -e "${GREEN}iptables rules flushed${NC}"
                        fi
                        source "$FORTIS_ROOT/lib/firewall.sh"
                    else
                        echo "Cancelled"
                    fi
                fi
                ;;
        esac
        ;;

    7)
        while true; do
            echo -e "1. ${CYAN}Turn ON${NC}"
            echo -e "2. ${CYAN}Turn OFF${NC}"
            echo -e "3. ${CYAN}Set standard settings${NC}"
            read -r -p "What do you want to do with fail2ban? " fail2banchoice
            case "$fail2banchoice" in
                1)
                    if ! command -v fail2ban-client &>/dev/null; then
                        read -r -p "${YELLOW}Fail2ban is not installed. Install?${NC} [y/N] " fail2bantwo
                        fail2bantwo="${fail2bantwo,,}"
                        if [[ "$fail2bantwo" == "y" || "$fail2bantwo" == "yes" ]]; then
                            if ! (apt update && apt install -y fail2ban); then
                                echo -e "${RED}Install failed. Try manually: sudo apt update && sudo apt install -y fail2ban${NC}"
                                break
                            fi
                            echo -e "${GREEN}Installed successfully${NC}"
                        else
                            break
                        fi
                    fi
                    if systemctl enable --now fail2ban; then
                        echo -e "${GREEN}Fail2ban enabled successfully${NC}"
                    else
                        echo -e "${RED}Enable failed. Try: sudo systemctl enable --now fail2ban${NC}"
                    fi
                    source "$FORTIS_ROOT/lib/fail2ban.sh"
                    break
                    ;;
                2)
                    if ! command -v fail2ban-client &>/dev/null; then
                        echo -e "${YELLOW}Fail2ban is not installed - nothing to disable${NC}"
                    else
                        if systemctl disable --now fail2ban; then
                            echo -e "${GREEN}Fail2ban disabled successfully${NC}"
                        else
                            echo -e "${RED}Disable failed. Try manually${NC}"
                        fi
                        source "$FORTIS_ROOT/lib/fail2ban.sh"
                    fi
                    break
                    ;;
                3)
                    if ! command -v fail2ban-client &>/dev/null; then
                        read -r -p "${YELLOW}Fail2ban is not installed. Install?${NC} [y/N] " fail2bantwo
                        fail2bantwo="${fail2bantwo,,}"
                        if [[ "$fail2bantwo" == "y" || "$fail2bantwo" == "yes" ]]; then
                            if ! (apt update && apt install -y fail2ban); then
                                echo -e "${RED}Install failed${NC}"
                                break
                            fi
                        else
                            break
                        fi
                    fi
                    if grep -q '^\[sshd\]' /etc/fail2ban/jail.local 2>/dev/null; then
                        echo -e "${YELLOW}sshd jail is already configured${NC}"
                    else
                        {
                            echo "[sshd]"
                            echo "enabled = true"
                        } >> /etc/fail2ban/jail.local
                    fi
                    if systemctl restart fail2ban; then
                        echo -e "${GREEN}Standard settings applied${NC}"
                    else
                        echo -e "${RED}Restart failed - check config: sudo fail2ban-client -t${NC}"
                    fi
                    source "$FORTIS_ROOT/lib/fail2ban.sh"
                    break
                    ;;
                q|Q)
                    break
                    ;;
                *)
                    echo -e "${YELLOW}Incorrect option${NC}"
                    ;;
            esac
        done
        ;;
    
    11)
        while true; do
            echo "1. ${CYAN}Create backup${NC}"
            echo "2. ${CYAN}Restore backup${NC}"
            echo "3. ${YELLOW}Rollback activate${NC}"
            echo "4. ${CYAN}Disarm rollback${NC}"
            echo
            echo "q. ${YELLOW}Back${NC}"
            read -r -p "${WHITE}Your choice:${NC} " rollbackchoice
            case "$rollbackchoice" in
                1)
                    if [[ ! -d "$BACKUP_DIR" ]]; then
                        mkdir "$BACKUP_DIR" &>/dev/null
                    fi

                    if [[ -e "$BACKUP_DIR"/sshd_config ]]; then
                        read -r -p "${YELLOW}SSH backup is already exists. Replace it?${NC}[y/N] " backupreplace
                        backupreplace="${backupreplace,,}"
                        case "$backupreplace" in
                            y|yes)
                                cp /etc/ssh/sshd_config "$BACKUP_DIR"
                                source "$FORTIS_ROOT/lib/backup.sh"
                                echo -e "${GREEN}SSH backup has been created successfully${NC}"
                                break
                                ;;
                            *)
                                break
                                ;;
                        esac
                    else
                        cp /etc/ssh/sshd_config "$BACKUP_DIR"
                        source "$FORTIS_ROOT/lib/backup.sh"
                        echo -e "${GREEN}SSH backup has been created successfully${NC}"
                        break
                    fi
                    ;;
                2)
                    if [[ ! -e "$BACKUP_DIR/sshd_config" ]]; then
                        echo -e "${RED}No backup found. Create one first${NC}"
                        break
                    fi
                    if ! sshd -t -f "$BACKUP_DIR/sshd_config" 2>/dev/null; then
                        echo -e "${RED}Backup config is INVALID. Refusing to restore${NC}"
                        break
                    fi
                    if cp "$BACKUP_DIR/sshd_config" /etc/ssh/sshd_config; then
                        source "$FORTIS_ROOT/lib/root-ssh-login.sh"
                        source "$FORTIS_ROOT/lib/password-auth.sh"
                        source "$FORTIS_ROOT/lib/ssh-port.sh"
                        echo -e "${GREEN}Backup restored. Press 12 to apply${NC}"
                    else
                        echo -e "${RED}Restore failed${NC}"
                    fi
                    break
                    ;;
                3)
                    if rollback_status; then 
                        echo -e "${YELLOW}Rollback is already armed (${REMAINING}s left)${NC}"
                    elif [[ ! -e "$BACKUP_DIR/sshd_config" ]]; then
                        echo -e "${RED}No backup found. Create one first${NC}"
                    else
                        rollback_arm && echo -e "${GREEN}Rollback armed: ${ROLLBACK_TIMEOUT:-600}s. On fire: sshd_config restored, ALL firewalls disabled${NC}" || echo -e "${RED}Failed to arm${NC}"
                    fi
                    break
                    ;;
                4)
                    if rollback_status; then
                        rollback_disarm
                        echo -e "${GREEN}Rollback disarmed — changes kept${NC}"
                    else
                        echo -e "${YELLOW}Rollback is not armed${NC}"
                    fi
                    break
                    ;;
                
                q|Q)
                    break
                    ;;

                *)
                    echo -e "${YELLOW}Incorrect option${NC}"
                    ;;

            esac
        done
        ;;



    12)
        if [[ "$backupexists" = false ]]; then 
            read -r -p "${RED}Do you want to apply changes without backup?${NC} [y/N] " twobackupexistsanswer
            twobackupexistsanswer="${twobackupexistsanswer,,}"
            case "$twobackupexistsanswer" in
                y|yes)
                    :
                    ;;
                n|no)
                    if [[ ! -d "$BACKUP_DIR" ]]; then
                        mkdir "$BACKUP_DIR" &>/dev/null
                    fi

                    cp /etc/ssh/sshd_config "$BACKUP_DIR"
                    source "$FORTIS_ROOT/lib/backup.sh"
                    echo -e "${GREEN}Backup has been created successfully${NC}"
                    
                    ;;
                *)
                    exit 1
                    ;;
            esac

        fi

        if ! sshd -t; then
            echo -e "${RED}Config invalid. NOT applied.${NC}"
            if [[ -f "$BACKUP_DIR/sshd_config" ]]; then
                cp "$BACKUP_DIR/sshd_config" /etc/ssh/sshd_config
                echo -e "${GREEN}Backup restored${NC}"
            else
                echo -e "${RED}No backup to restore. Fix /etc/ssh/sshd_config manually!${NC}"
            fi
            continue
        fi
        systemctl reload ssh && echo -e "${GREEN}Applied${NC}" || echo -e "${RED}Reload failed${NC}"
        ;;


    
    q|Q)
        exit 0
        ;;





    esac
done