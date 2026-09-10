#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"

if [[ "$1" == "EXEC" ]]; then
    echo "Fortis auto-rollback fired"

    if sshd -t -f "$BACKUP_DIR/sshd_config" 2>/dev/null; then
        cp "$BACKUP_DIR/sshd_config" /etc/ssh/sshd_config
        if systemctl is-active --quiet ssh.socket; then
            systemctl restart ssh.socket && echo "sshd_config restored, ssh.socket restarted"
        else
            systemctl reload ssh && echo "sshd_config restored and reloaded"
        fi 
    else
        echo "WARNING: backup sshd_config is INVALID, not restored"
    fi

    command -v ufw &>/dev/null && ufw disable
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    command -v netfilter-persistent &>/dev/null && netfilter-persistent save
    systemctl disable --now firewalld 2>/dev/null
    systemctl disable --now nftables 2>/dev/null
    nft flush ruleset

    rm -f /run/fortis/armed.env
    echo "All firewalls disabled"
    exit 0
fi

STATE_DIR="/run/fortis"

rollback_arm() {
    systemctl stop fortis-rollback.timer 2>/dev/null
    systemd-run --unit=fortis-rollback \
        --on-active="${ROLLBACK_TIMEOUT:-600}" \
        --description="Fortis auto-rollback" \
        /bin/bash "$FORTIS_ROOT/lib/rollback.sh" EXEC || return 1
    mkdir -p "$STATE_DIR"
    echo "ARM_TS=$(date +%s)" > "$STATE_DIR/armed.env"
}

rollback_disarm() {
    systemctl stop fortis-rollback.timer 2>/dev/null
    rm -f "$STATE_DIR/armed.env"
}

rollback_status() {
    if systemctl is-active --quiet fortis-rollback.timer && [[ -f "$STATE_DIR/armed.env" ]]; then
        source "$STATE_DIR/armed.env"
        REMAINING=$(( ARM_TS + ${ROLLBACK_TIMEOUT:-600} - $(date +%s) ))
        (( REMAINING < 0 )) && REMAINING=0
        return 0
    fi
    return 1
}