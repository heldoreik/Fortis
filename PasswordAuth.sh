#!/bin/bash
source ./Ui.sh


if [[ "$PasswordAuth" == "yes" ]]; then
    PasswordAuthStatus="${RED}ON${NC}"
else
    PasswordAuthStatus="${GREEN}OFF${NC}"
fi