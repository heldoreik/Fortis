#!/bin/bash
source ./Ui.sh

ACTIVE_FW=""

if command -v ufw &>/dev/null && ufw status 2>/dev/null | grep -q "Status: active"; then
    ACTIVE_FW="ufw"
elif systemctl is-active --quiet firewalld 2>/dev/null; then
    ACTIVE_FW="firewalld"
elif systemctl is-active --quiet nftables 2>/dev/null; then
    ACTIVE_FW="nftables"
elif iptables -S 2>/dev/null | grep -q "^-P INPUT DROP"; then
    ACTIVE_FW="iptables"
fi

if [[ -z "$ACTIVE_FW" ]]; then
    FirewallStatus="${RED}OFF${NC}"
else
    FirewallStatus="${GREEN}${ACTIVE_FW}${NC}"
fi