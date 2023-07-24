Install_Requirements_Debian() {
    if [[ ! $(command -v gpg) ]]; then
        apt update
        apt install gpg -y
    fi
}

Install_WARP_Client_Debian() {
    Install_Requirements_Debian
    curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bullseye main' | tee /etc/apt/sources.list.d/cloudflare-client.list
    apt update
    apt -y install cloudflare-warp
}

Check_WARP_Client() {
    WARP_Client_Status=$(systemctl is-active warp-svc)
    WARP_Client_SelfStart=$(systemctl is-enabled warp-svc 2>/dev/null)
}

Register_WARP_Account() {
	yes | warp-cli register
    sleep 5
}

Set_WARP_Mode_Proxy() {
    warp-cli set-mode proxy
}

Connect_WARP() {
    warp-cli connect
    warp-cli enable-always-on
}

Install_V2ray_Client() {
	curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh | bash
}



Generate_V2ray_Config_File() {
	cat <<- EOF > /root/v2ray_config.json
	{
		"log": {
			"access": "/var/log/v2ray/access.log",
			"error": "/var/log/v2ray/error.log",
			"loglevel": "warning"
		},
		"inbounds": [{
				"port": 19852,
				"protocol": "vmess",
				"settings": {
					"clients": [{
							"id": "aba00d13-d471-4ec5-907b-a3074bdc1e49",
							"level": 1,
							"alterId": 0
						}
					]
				},
				"streamSettings": {
					"network": "ws"
				},
				"sniffing": {
					 "enabled": true,
					 "destOverride": ["http", "tls"]
				}
			}
		],

		"outbounds": [
			{
				"protocol": "freedom"
			},
			{
				"tag": "warp",
				"protocol": "socks",
				"settings": {
					"servers": [
						{
							"address": "127.0.0.1",
							"port": 40000
						}
					]
				}
			}
		],
		"routing": {
		   "domainStrategy": "AsIs",
		   "rules": [
			{
			  "type": "field",
			  "domain": [
				  
			  ],
			  "outboundTag": "warp"
		   }
		  ]
	  }
	}
	EOF
}

Connect_V2ray() {
	nohup v2ray run -c /root/v2ray_config.json &
}

#Install_WARP_Client_Debian
#Check_WARP_Client
#if [[ ${WARP_Client_Status} = active ]]; then
	#Register_WARP_Account
	#Set_WARP_Mode_Proxy
	#Connect_WARP
#fi
#Install_V2ray_Client
Generate_V2ray_Config_File
if [[ $(command -v v2ray) ]]; then
	Connect_V2ray
fi

