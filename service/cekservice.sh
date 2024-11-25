#!/bin/bash

port=$(netstat -tunlp | grep 'python' | awk '{split($4, a, ":"); print a[2]}')


# // Code for service
export RED='\033[0;31m';
export GREEN='\033[0;32m';
export YELLOW='\033[0;33m';
export BLUE='\033[0;34m';
export PURPLE='\033[0;35m';
export CYAN='\033[0;36m';
export LIGHT='\033[0;37m';
export NC='\033[0m';

# // Export Banner Status Information
export ERROR="[${RED} ERROR ${NC}]";
export INFO="[${YELLOW} INFO ${NC}]";
export OKEY="[${GREEN} OKEY ${NC}]";
export PENDING="[${YELLOW} PENDING ${NC}]";
export SEND="[${YELLOW} SEND ${NC}]";
export RECEIVE="[${YELLOW} RECEIVE ${NC}]";

sleep 1

# NGINX
if [[ $(netstat -ntlp | grep -i nginx | grep -i 0.0.0.0:443 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == '443' ]]; then
    NGINX="${GREEN}Okay${NC}";
else
    NGINX="${RED}Not Okay${NC}";
fi

# FIREWALL
if [[ $(systemctl status ufw | grep -w Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    UFW="${GREEN}Okay${NC}";
else
    UFW="${RED}Not Okay${NC}";
fi

# MARZBAN
if [[ $(netstat -ntlp | grep -i python | grep -i "127.0.0.1:${port}" | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == "${port}" ]]; then
    MARZ="${GREEN}Okay${NC}";
else
    MARZ="${RED}Not Okay${NC}";
fi

# XRAY
if [[ $(netstat -ntlp | grep -i xray | grep -i "127.0.0.1:2023" | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == '2023' ]]; then
    XRAY="${GREEN}Okay${NC}";
else
    XRAY="${RED}Not Okay${NC}";
fi

# DOCKER
if [[ $(systemctl is-active docker) == 'active' ]]; then
    RUNNING_CONTAINERS=$(docker ps -q | wc -l)
    if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
        DOCKER="${GREEN}Okay${NC}";
    else
        DOCKER="${YELLOW}Running No Container${NC}";
    fi
else
    DOCKER="${RED}Not Okay${NC}";
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e "\E[44;1;39m            ⇱ Service Information ⇲             \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e "❇️ Docker Container     : $DOCKER"
echo -e "❇️ Xray Core            : $XRAY"
echo -e "❇️ Nginx                : $NGINX"
echo -e "❇️ Firewall             : $UFW"
echo -e "❇️ Marzban Panel        : $MARZ"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e "          MARZBAN SHARING PORT 443 SAFE"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo ""