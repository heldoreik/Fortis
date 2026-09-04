#!/bin/bash
source ./Ui.sh


if [[ "$SSHPort" == "22" ]]; then
    SSHPortStatus="${RED}$SSHPort${NC}"
else 
    SSHPortStatus="${GREEN}$SSHPort${NC}"
fi