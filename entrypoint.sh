CLICK ME

#!/bin/sh

# Global variables

DIR_CONFIG="/etc/xray"

DIR_RUNTIME="/usr/bin"

DIR_TMP="$(mktemp -d)"

curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o ${DIR_TMP}/xray.zip

busybox unzip ${DIR_TMP}/xray.zip -d ${DIR_TMP}

install -m 755 ${DIR_TMP}/xray ${DIR_RUNTIME}

rm -rf ${DIR_TMP}

cat << EOF > ${DIR_CONFIG}/config.json
{
    "log": {
        "loglevel": "none"
    },
    "dns": {
        "servers": [
          "8.8.8.8",
          "8.8.4.4",
          "localhost"
        ],
    "inbounds": [
        {
            "port": ${PORT},
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                      "id": "${id}",
                      "alterId": 0
                    }
                  ]
            }
          },
        {
            "port": ${PORT},
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                     "password": "${password}",
                      "flow": "xtls-rprx-direct"
                    }
                  ]
            }
        },
        {
            "port": ${PORT},
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                      "id": "5783a3e7-e373-51cd-8642-c83782b807c5",
                      "level": 0,

                      "flow": "xtls-rprx-direct"
                    }
                  ],
                  "decryption": "none"
            }
        }
    ],
        "transport": {
          "wsSettings": {
            "path": ""
          },
          "quicSettings": {
            "security": "none",
            "header": {
                "type": "none"
              }
          },
          "grpcSettings": {
            "serviceName": ""
          }
        },
    "outbounds": [
        {
            "protocol": "Freedom"
        }
    ]
}
}
EOF

${DIR_RUNTIME}/xray -config=${DIR_CONFIG}/config.json