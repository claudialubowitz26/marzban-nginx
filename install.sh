#!/bin/bash
colorized_echo() {
    local color=$1
    local text=$2
    
    case $color in
        "red")
        printf "\e[91m${text}\e[0m\n";;
        "green")
        printf "\e[92m${text}\e[0m\n";;
        "yellow")
        printf "\e[93m${text}\e[0m\n";;
        "blue")
        printf "\e[94m${text}\e[0m\n";;
        "magenta")
        printf "\e[95m${text}\e[0m\n";;
        "cyan")
        printf "\e[96m${text}\e[0m\n";;
        *)
            echo "${text}"
        ;;
    esac
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    colorized_echo red "Error: Skrip ini harus dijalankan sebagai root."
    exit 1
fi

# Check supported operating system
supported_os=false

if [ -f /etc/os-release ]; then
    os_name=$(grep -E '^ID=' /etc/os-release | cut -d= -f2)
    os_version=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

    if [ "$os_name" == "debian" ] && [ "$os_version" == "11" ]; then
        supported_os=true
    elif [ "$os_name" == "ubuntu" ] && [ "$os_version" == "20.04" ]; then
        supported_os=true
    fi
fi
apt install sudo curl -y
if [ "$supported_os" != true ]; then
    colorized_echo red "Error: Skrip ini hanya support di Debian 11 dan Ubuntu 20.04. Mohon gunakan OS yang di support."
    exit 1
fi

# Fungsi untuk menambahkan repo Debian 11
addDebian11Repo() {
    echo "#mirror_kambing-sysadmind deb11
deb http://kartolo.sby.datautama.net.id/debian bullseye main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian bullseye-updates main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian-security bullseye-security main contrib non-free" | sudo tee /etc/apt/sources.list > /dev/null
}

# Fungsi untuk menambahkan repo Ubuntu 20.04
addUbuntu2004Repo() {
    echo "#mirror buaya klas 20.04
deb https://buaya.klas.or.id/ubuntu/ focal main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-updates main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-security main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-backports main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-proposed main restricted universe multiverse" | sudo tee /etc/apt/sources.list > /dev/null
}

# Mendapatkan informasi kode negara dan OS
COUNTRY_CODE=$(curl -s https://ipinfo.io/country)
OS=$(lsb_release -si)

# Pemeriksaan IP Indonesia
if [[ "$COUNTRY_CODE" == "ID" ]]; then
    colorized_echo green "IP Indonesia terdeteksi, menggunakan repositories lokal Indonesia"

    # Menanyakan kepada pengguna apakah ingin menggunakan repo lokal atau repo default
    read -p "Apakah Anda ingin menggunakan repo lokal Indonesia? (y/n): " use_local_repo

    if [[ "$use_local_repo" == "y" || "$use_local_repo" == "Y" ]]; then
        # Pemeriksaan OS untuk menambahkan repo yang sesuai
        case "$OS" in
            Debian)
                VERSION=$(lsb_release -sr)
                if [ "$VERSION" == "11" ]; then
                    addDebian11Repo
                else
                    colorized_echo red "Versi Debian ini tidak didukung."
                fi
                ;;
            Ubuntu)
                VERSION=$(lsb_release -sr)
                if [ "$VERSION" == "20.04" ]; then
                    addUbuntu2004Repo
                else
                    colorized_echo red "Versi Ubuntu ini tidak didukung."
                fi
                ;;
            *)
                colorized_echo red "Sistem Operasi ini tidak didukung."
                ;;
        esac
    else
        colorized_echo yellow "Menggunakan repo bawaan VM."
        # Tidak melakukan apa-apa, sehingga repo bawaan VM tetap digunakan
    fi
else
    clear
    colorized_echo yellow "IP bukan indonesia."
    # Lanjutkan dengan repo bawaan OS
fi
mkdir -p /etc/data

#domain
# Fungsi untuk mendapatkan IP dari domain
get_domain_ip() {
    local domain=$1
    dig +short "$domain" | grep '^[.0-9]*$' | head -n 1
}

# Fungsi untuk meminta pengguna memasukkan domain
input_domain() {
    read -rp "Masukkan Domain: " domain
    echo "$domain" > /etc/data/domain
    domain=$(cat /etc/data/domain)
    echo "$domain"
}

current_ip=$(curl -s https://ipinfo.io/ip)
if [ -z "$current_ip" ]; then
    echo "Tidak dapat menemukan IP publik saat ini."
    exit 1
fi
while true; do
    # Minta pengguna memasukkan domain
    domain=$(input_domain)

    # Dapatkan IP dari domain
    domain_ip=$(get_domain_ip "$domain")

    if [ -z "$domain_ip" ]; then
        clear
        colorized_echo red "Tidak dapat menemukan IP untuk domain: $domain"
    elif [ "$domain_ip" != "$current_ip" ]; then
        clear
        colorized_echo yellow "IP domain ($domain_ip) tidak sama dengan IP publik saat ini ($current_ip)."
    else
        colorized_echo green "IP domain ($domain_ip) sama dengan IP publik saat ini ($current_ip)."
        colorized_echo green "Domain berhasil digunakan."
        break
    fi

    echo "Silakan masukkan ulang domain."
done

BRANCH=master
USER_GITHUB=claudialubowitz26
REPO=marzban-nginx

#Preparation
cd;
apt-get update;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendma
il*;
apt-get -y --purge remove bind9*;

#install bbr
echo 'fs.file-max = 500000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max = 4000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward = 1
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p;

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav -y

#Install Marzban
sudo bash -c "$(curl -sL https://github.com/${USER_GITHUB}/Marzban-scripts/raw/master/marzban.sh)" @ install

#Install Subs
wget -N -P /var/lib/marzban/templates/subscription/ https://raw.githubusercontent.com/MuhammadAshouri/marzban-templates/master/template-01/index.html

#install env
wget -O /opt/marzban//.env https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/env

#install core Xray & Assets folder
mkdir -p /var/lib/marzban/assets
mkdir -p /var/lib/marzban/core
wget -O /var/lib/marzban/core/xray.zip "https://github.com/XTLS/Xray-core/releases/download/v24.11.21/Xray-linux-64.zip"  
cd /var/lib/marzban/core && unzip xray.zip && chmod +x xray
cd /var/lib/marzban/assets

latest_geo=$(curl -s https://api.github.com/repos/malikshi/v2ray-rules-dat/releases/latest | grep tag_name | cut -d '"' -f 4)
wget -O geoip.dat https://github.com/malikshi/v2ray-rules-dat/releases/download/${latest_geo}/GeoIP.dat
wget -O geosite.dat https://github.com/malikshi/v2ray-rules-dat/releases/download/${latest_geo}/GeoSite.dat
wget -O /var/lib/marzban/xray_config.json "https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/xray/xray_config.json"
cd

#profile
echo -e 'profile' >> /root/.profile
wget -O /usr/bin/profile "https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/profile";
chmod +x /usr/bin/profile

#updategeo
wget -O /usr/bin/updategeo "https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/service/updategeo.sh"
chmod +x /usr/bin/updategeo

#cekservice
apt install neofetch -y
wget -O /usr/bin/cekservice "https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/service/cekservice.sh"
chmod +x /usr/bin/cekservice

#install compose
wget -O /opt/marzban/docker-compose.yml "https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/docker-compose.yml"

#Install VNSTAT
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://github.com/${USER_GITHUB}/${REPO}/raw/${BRANCH}/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install 
cd
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz 
rm -rf /root/vnstat-2.6

#Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

#install nginx
mkdir -p /var/log/nginx
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log

wget -O /opt/marzban/nginx.conf "https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/nginx/nginx.conf"
wget -O /opt/marzban/xray.conf "https://raw.githubusercontent.com/${USER_GITHUB}/${REPO}/${BRANCH}/nginx/xray.conf"
sed -i "s/\$domain/$domain/g" "/opt/marzban/xray.conf"
mkdir -p /var/www/html
echo "<pre>Hello World!</pre>" > /var/www/html/index.html

#install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#install cert
mkdir -p /var/lib/marzban/certs/$domain
curl https://get.acme.sh | sh -s
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m helpers@lumine.my.id --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/certs/$domain/fullchain.cer --keypath /var/lib/marzban/certs/$domain/privkey.key --ecc


#install firewall
apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 4001/tcp
sudo ufw allow 4001/udp
yes | sudo ufw enable

#install database
wget -O /var/lib/marzban/db.sqlite3 "https://github.com/${USER_GITHUB}/${REPO}/raw/${BRANCH}/db.sqlite3"


#update host marzban config
apt install sqlite3 -y

cd /var/lib/marzban

# Nama database
DB_NAME="db.sqlite3"

if [ ! -f "$DB_NAME" ]; then
  echo "Database $DB_NAME tidak ditemukan!"
  exit 1
fi

SQL_QUERY="UPDATE hosts SET address = '$domain' WHERE address = 'subdomain.lumine.my.id'; UPDATE hosts SET host = '$domain' WHERE host = 'subdomain.lumine.my.id'; UPDATE hosts SET sni = '$domain' WHERE sni = 'subdomain.lumine.my.id';"

sqlite3 "$DB_NAME" "$SQL_QUERY"

#install WARP Proxy
wget -O /root/warp "https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh"
sudo chmod +x /root/warp
sudo bash /root/warp -y 



#restart marzban
cd /opt/marzban
docker compose down && docker compose up -d
cd

#finishing
apt autoremove -y
apt clean
clear


profile
echo "Lumine VPN"
echo "-=================================-"
echo "Untuk Tambahkan Admin Panel ketik : "
echo "marzban cli admin create --sudo"
echo "URL Panel : https://${domain}/dashboard"
echo "-=================================-"
echo "Terimakasih"
echo "-=================================-"
echo ""
colorized_echo green "Script telah berhasil di install"
echo ""

#Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

rm /root/install.sh

read -rp $'\e[1;31m[WARNING]\e[0m Apakah Ingin Reboot [Default y] (y/n)? ' answer
answer=${answer:-y}

if [[ "$answer" == "${answer#[Yy]}" ]]; then
    exit 0
else
    cat /dev/null > ~/.bash_history && history -c && sudo reboot
fi