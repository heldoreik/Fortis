#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

OS=$(source /etc/os-release && echo "$PRETTY_NAME")                                     #Ubuntu 26.04 LTS
#CurrentUSer=$USER                                                                      #kragua
RootSSHLogin=$(sudo sshd -T | grep -i "^permitrootlogin" | awk '{print $2}')            #prohibit-password
PasswordAuth=$(sudo sshd -T | grep -i "^passwordauthentication" | awk '{print $2}')     #yes
SSHPort=$(sudo sshd -T | grep -i "^port" | awk '{print $2}')                            #22
AdminUser=$(groups $USER | awk '{print $6}' | grep -i "^sudo")                          #sudo #временно

if [[ "$PasswordAuth" == "yes" ]]; then
    PasswordAuthStatus="${RED}ON${NC}"
else
    PasswordAuthStatus="${GREEN}OFF${NC}"
fi

if [[ "$RootSSHLogin" == "prohibit-password" ]]; then
    RootSSHLoginStatus="${RED}OFF${NC}"
else
    RootSSHLoginStatus="{GREEN}ON${NC}"
fi