#!/bin/bash

echo "nameserver 2001:67c:2b0::4" > /etc/resolv.conf

apt update

if command -v apache2 &> /dev/null
then
    apt remove apache2 -y
fi

if ! command -v curl &> /dev/null
then
    apt install curl -y
fi

if ! command -v nano &> /dev/null
then
    apt install nano -y
fi

if ! command -v nginx &> /dev/null
then
    apt install nginx -y
fi

if ! command -v vnstat &> /dev/null
then
    apt install vnstat -y
fi

wget -O /root/firewall.txt http://www.2107.net:2052/zhan/firewall.txt

if ! command -v ufw &> /dev/null
then
    apt install ufw -y
	yes | ufw enable && ufw allow 22
	ufw allow 443
	# block cn ips:
	# while read line; do sudo ufw deny from $line; done < firewall.txt
fi


bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

mkdir /etc/v2ray

if ! [ -d "/root/.ssh" ] &> /dev/null
then
    mkdir /root/.ssh
fi

touch /root/.ssh/authorized_keys

wget -O /etc/v2ray/crt.crt http://www.2107.net:2052/zhan/v2ray/crt.crt
wget -O /etc/v2ray/key.key http://www.2107.net:2052/zhan/v2ray/key.key
wget -O /etc/v2ray/client_cert.crt http://www.2107.net:2052/zhan/v2ray/client_cert.crt
wget -O /root/.ssh/authorized_keys http://www.2107.net:2052/zhan/authorized_keys
wget -O /etc/nginx/nginx.conf http://www.2107.net:2052/zhan/nginx.conf
wget -O /usr/local/etc/v2ray/config.json http://www.2107.net:2052/zhan/config.json
wget -O /usr/share/nginx/html/html.zip http://www.2107.net:2052/zhan/html.zip

if command -v nginx &> /dev/null
then
	unzip -d /usr/share/nginx/html/ /usr/share/nginx/html/html.zip
    nginx -s reload
fi

if command -v v2ray &> /dev/null
then
    systemctl enable v2ray
	systemctl start v2ray
fi


if [ -f "/root/.ssh/authorized_keys" ] &> /dev/null
then
	chmod 600 /root/.ssh/authorized_keys && chmod 700 /root/.ssh
fi

sed -i '$a PasswordAuthentication no\nPubkeyAuthentication yes\nAuthorizedKeysFile\t.ssh/authorized_keys .ssh/authorized_keys2' /etc/ssh/sshd_config

systemctl restart sshd.service

# delete ufw rules:
# for i in {200..100};do yes | ufw delete $i;done
