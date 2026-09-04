#!/bin/bash
source ./Ui.sh


if [[ -n "$SUDO_USERS" ]]; then
    Adminuser="${GREEN}ON${NC}"
else 
    Adminuser="${RED}ON${NC}"
fi