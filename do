#!/bin/bash

# requirement
apt-get -y update && apt-get -y upgrade
apt-get -y install curl

# initializing IP
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# configure rc.local
cat <<EOF >/etc/rc.local
#!/bin/sh -e
exit 0
EOF
chmod +x /etc/rc.local
systemctl daemon-reload
systemctl start rc-local

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# add DNS server ipv4
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
sed -i '$ i\echo "nameserver 8.8.8.8" > /etc/resolv.conf' /etc/rc.local
sed -i '$ i\echo "nameserver 8.8.4.4" >> /etc/resolv.conf' /etc/rc.local

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# set repo
echo 'deb http://download.webmin.com/download/repository sarge contrib' >> /etc/apt/sources.list.d/webmin.list
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

# OpenVPN Ports
OpenVPN_TCP_Port='1103'
OpenVPN_UDP_Port='25222'

# set time GMT +2
ln -fs /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# update
apt-get update; apt-get -y upgrade;

# install essential package
apt-get -y install nano iptables-persistent dnsutils screen whois ngrep unzip unrar
apt-get -y install build-essential
apt-get -y install libio-pty-perl libauthen-pam-perl apt-show-versions libnet-ssleay-perl

apt-get update
apt-get install openvpn -y

# install screenfetch
cd
wget -O /usr/bin/screenfetch "https://raw.githubusercontent.com/gatotx/AutoScriptDebian9/main/Res/Screenfetch/screenfetch"
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

# install webserver
apt-get -y install nginx libexpat1-dev libxml-parser-perl

# install essential package
apt-get -y install nano iptables-persistent dnsutils screen whois ngrep unzip unrar

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/ara-rangers/vps/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>SETUP BY ARA PM +601126996292</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/azalea910512/gemik/main/vps.conf"


# Checking if openvpn folder is accidentally deleted or purged
 if [[ ! -e /etc/openvpn ]]; then
  mkdir -p /etc/openvpn
 fi

 # Removing all existing openvpn server files
 rm -rf /etc/openvpn/*

 # Creating server.conf, ca.crt, server.crt and server.key
 cat <<'myOpenVPNconf' > /etc/openvpn/server_tcp.conf
# OpenVPN TCP
port OVPNTCP
proto tcp
dev tun
dev-type tun
sndbuf 0
rcvbuf 0
crl-verify crl.pem
ca ca.crt
cert server.crt
key server.key
tls-auth tls-auth.key 0
dh dh.pem
topology subnet
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
auth SHA256
comp-lzo
user nobody
group nogroup
persist-tun
status openvpn-status.log
verb 2
mute 3
plugin /etc/openvpn/openvpn-auth-pam.so /etc/pam.d/login
verify-client-cert none
username-as-common-name
myOpenVPNconf

cat <<'myOpenVPNconf2' > /etc/openvpn/server_udp.conf
# OpenVPN UDP
port OVPNUDP
proto udp
dev tun
dev-type tun
sndbuf 0
rcvbuf 0
crl-verify crl.pem
ca ca.crt
cert server.crt
key server.key
tls-auth tls-auth.key 0
dh dh.pem
topology subnet
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
auth SHA256
comp-lzo
user nobody
group nogroup
persist-tun
status openvpn-status.log
verb 2
mute 3
plugin /etc/openvpn/openvpn-auth-pam.so /etc/pam.d/login
verify-client-cert none
username-as-common-name
myOpenVPNconf2

 cat <<'EOF7'> /etc/openvpn/ca.crt
-----BEGIN CERTIFICATE-----
MIIDVDCCAjygAwIBAgIUUZx2hyFj1NP/HlSye43fEx71aqwwDQYJKoZIhvcNAQEL
BQAwGTEXMBUGA1UEAwwOdnBuLmY1bGFicy5kZXYwHhcNMjEwMTE0MDI0OTQxWhcN
MzEwMTEyMDI0OTQxWjAZMRcwFQYDVQQDDA52cG4uZjVsYWJzLmRldjCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBALGs+GFrp7+dPlhmxUP0nVqY1Na3sb+/
NUcAdncurs6hBzqOuDlTx7ZcWRNBbrgPvzHTYJGBaYiSlOrt7h2dghBEpDq1OP29
9wpMHhRgheSrsmFL5GfuCs+SyJi34wq/D3b09vmlhecGcK5n8QzcNEiacTVRCia9
TbvPXBZvyDY4trSEuKnTsL/r1UcacDJuPAZ7UoJbEZrxZu6xqLHFP/yr99y6X2qz
joGZlBx4pId2pAnfb1rcqAb5tvXxHXNK0EyUgMCwdHS+aVtmXJfj9wZlk3Z+8b7f
BhwURApWTcFz70gwEYmArIY5w49TMHcNIAN+AumYv/SJNOgt2oeE8k8CAwEAAaOB
kzCBkDAdBgNVHQ4EFgQU/Ga3V1iPk7I6YR5DeNQuQ+9e5DUwVAYDVR0jBE0wS4AU
/Ga3V1iPk7I6YR5DeNQuQ+9e5DWhHaQbMBkxFzAVBgNVBAMMDnZwbi5mNWxhYnMu
ZGV2ghRRnHaHIWPU0/8eVLJ7jd8THvVqrDAMBgNVHRMEBTADAQH/MAsGA1UdDwQE
AwIBBjANBgkqhkiG9w0BAQsFAAOCAQEAThvfXeUiYDGumhn4ILOxm1y7ZT3EUhtT
iDaThgKfSYjTLvuG9uTMC3DmZUjC/JXRW0g2waY9/MMJ7+3VUolsaaxLe+233jc5
uqKlmMBWalXBJCVapAoGSVviyiTP0VTxlaprVgbgrWT6oScoMwHFq6+MS5FW3MhU
wVrvF2ed4bDFc4hwr2UEp2aNxpl8veGewhqNhUVZLTnm9FeJ9mLCLWvZvWA/8dpn
4yyYPnSeLub6qM4KuWdD+LKxO7/kj1QhOi7aSx3NrE/G3iKl5afttgrOq8VATdMM
j/N7c5oIS2l/ID5us17zVJT9tA0OQlOWp3JlnFmm/9q2VWvpKh/mSQ==
-----END CERTIFICATE-----
EOF7
 cat <<'EOF9'> /etc/openvpn/client.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            3b:80:8e:a6:3a:d9:39:e4:ff:e0:0f:04:0f:bb:ad:dd
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=vpn.f5labs.dev
        Validity
            Not Before: Jan 14 02:53:35 2021 GMT
            Not After : Apr 19 02:53:35 2023 GMT
        Subject: CN=client.f5labs.dev
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:d0:db:2a:46:68:84:d4:9c:0a:a3:33:40:37:f2:
                    f4:60:dd:7a:e5:5d:c0:c2:49:35:bb:9c:18:98:8c:
                    79:41:42:d9:2d:c4:e7:83:95:ef:65:ae:9c:a5:80:
                    3b:be:22:85:7a:38:81:70:64:0d:49:88:77:87:6a:
                    9d:12:6c:17:28:84:55:97:b4:f7:b3:fd:ec:dc:b8:
                    16:43:01:3c:06:f3:3b:f7:c6:c0:00:8b:c8:bd:03:
                    1f:cf:ef:3b:fa:a7:7e:4f:3a:ec:15:e3:b5:b7:ed:
                    3f:38:9f:3d:8c:4f:02:4e:d8:b6:85:1d:2c:f1:37:
                    f8:b6:3d:08:14:6f:57:5d:17:3f:40:4b:e3:05:0d:
                    39:34:7f:4e:b4:e7:0c:e1:95:56:ae:2b:7b:ab:d4:
                    26:69:5e:27:c3:81:58:cb:79:40:5e:d5:70:52:97:
                    fd:8d:8f:89:3f:61:a1:ff:5f:54:05:e9:6c:54:e4:
                    f4:ca:ac:d4:3a:fa:78:dd:27:e8:68:c4:3c:89:54:
                    3d:92:7d:f8:aa:64:d3:3b:e0:b5:c1:95:10:58:78:
                    87:8f:c3:4c:37:3d:a0:76:36:a8:22:00:f2:c2:fc:
                    19:6e:7f:18:41:fe:70:71:e3:c5:ef:96:da:d9:b8:
                    80:5f:1b:98:4f:81:f0:c0:4c:9f:38:d1:bf:1e:07:
                    7e:e7
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                FC:2C:7A:13:E6:8B:6E:2E:6B:B3:D9:47:4C:A6:4E:18:11:EA:26:4B
            X509v3 Authority Key Identifier: 
                keyid:FC:66:B7:57:58:8F:93:B2:3A:61:1E:43:78:D4:2E:43:EF:5E:E4:35
                DirName:/CN=vpn.f5labs.dev
                serial:51:9C:76:87:21:63:D4:D3:FF:1E:54:B2:7B:8D:DF:13:1E:F5:6A:AC

            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
            X509v3 Key Usage: 
                Digital Signature
    Signature Algorithm: sha256WithRSAEncryption
         57:33:02:49:cb:42:0f:82:7a:d8:bb:54:d8:36:d1:ad:4d:a0:
         8f:5a:3f:7d:49:0f:4b:2f:22:bd:08:5c:9e:78:79:e9:8c:0e:
         1a:d9:54:08:58:98:23:b6:0b:53:7d:f8:4c:fe:63:63:3d:74:
         74:d8:3f:84:f4:91:4a:65:11:41:cd:6b:1b:ea:d2:50:df:f0:
         c3:d5:07:88:c2:7d:45:fb:9a:59:56:02:c5:17:f5:13:86:e2:
         a8:db:1c:61:33:f3:53:26:51:a6:a2:9e:9d:4a:71:b1:01:bd:
         0e:70:2a:a1:5d:7c:37:eb:81:40:f3:0b:c6:ce:be:39:83:2b:
         53:d0:0f:54:51:90:31:3c:9e:ba:ec:d9:46:6c:98:ab:b9:ca:
         7c:56:71:c6:74:0b:b5:30:98:8d:e7:eb:e4:0d:cf:f4:43:28:
         09:63:f5:12:67:4a:1d:0f:cf:61:4d:c7:2e:6e:21:9f:09:62:
         06:1f:16:8b:a0:8d:2f:fa:a5:16:52:41:57:29:ac:99:4e:a4:
         4a:0f:76:4a:80:9b:88:1f:05:e9:9b:90:da:75:f3:bc:fa:c5:
         86:b2:70:95:05:24:74:50:b2:3a:ab:f7:05:84:22:93:11:d5:
         c9:00:48:4c:40:84:d4:7b:30:17:35:9b:02:d9:a3:79:c6:ab:
         16:fe:b4:de
-----BEGIN CERTIFICATE-----
MIIDZTCCAk2gAwIBAgIQO4COpjrZOeT/4A8ED7ut3TANBgkqhkiG9w0BAQsFADAZ
MRcwFQYDVQQDDA52cG4uZjVsYWJzLmRldjAeFw0yMTAxMTQwMjUzMzVaFw0yMzA0
MTkwMjUzMzVaMBwxGjAYBgNVBAMMEWNsaWVudC5mNWxhYnMuZGV2MIIBIjANBgkq
hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0NsqRmiE1JwKozNAN/L0YN165V3Awkk1
u5wYmIx5QULZLcTng5XvZa6cpYA7viKFejiBcGQNSYh3h2qdEmwXKIRVl7T3s/3s
3LgWQwE8BvM798bAAIvIvQMfz+87+qd+TzrsFeO1t+0/OJ89jE8CTti2hR0s8Tf4
tj0IFG9XXRc/QEvjBQ05NH9OtOcM4ZVWrit7q9QmaV4nw4FYy3lAXtVwUpf9jY+J
P2Gh/19UBelsVOT0yqzUOvp43SfoaMQ8iVQ9kn34qmTTO+C1wZUQWHiHj8NMNz2g
djaoIgDywvwZbn8YQf5wcePF75ba2biAXxuYT4HwwEyfONG/Hgd+5wIDAQABo4Gl
MIGiMAkGA1UdEwQCMAAwHQYDVR0OBBYEFPwsehPmi24ua7PZR0ymThgR6iZLMFQG
A1UdIwRNMEuAFPxmt1dYj5OyOmEeQ3jULkPvXuQ1oR2kGzAZMRcwFQYDVQQDDA52
cG4uZjVsYWJzLmRldoIUUZx2hyFj1NP/HlSye43fEx71aqwwEwYDVR0lBAwwCgYI
KwYBBQUHAwIwCwYDVR0PBAQDAgeAMA0GCSqGSIb3DQEBCwUAA4IBAQBXMwJJy0IP
gnrYu1TYNtGtTaCPWj99SQ9LLyK9CFyeeHnpjA4a2VQIWJgjtgtTffhM/mNjPXR0
2D+E9JFKZRFBzWsb6tJQ3/DD1QeIwn1F+5pZVgLFF/UThuKo2xxhM/NTJlGmop6d
SnGxAb0OcCqhXXw364FA8wvGzr45gytT0A9UUZAxPJ667NlGbJirucp8VnHGdAu1
MJiN5+vkDc/0QygJY/USZ0odD89hTccubiGfCWIGHxaLoI0v+qUWUkFXKayZTqRK
D3ZKgJuIHwXpm5DadfO8+sWGsnCVBSR0ULI6q/cFhCKTEdXJAEhMQITUezAXNZsC
2aN5xqsW/rTe
-----END CERTIFICATE-----
EOF9
 cat <<'EOF10'> /etc/openvpn/client.key
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDQ2ypGaITUnAqj
M0A38vRg3XrlXcDCSTW7nBiYjHlBQtktxOeDle9lrpylgDu+IoV6OIFwZA1JiHeH
ap0SbBcohFWXtPez/ezcuBZDATwG8zv3xsAAi8i9Ax/P7zv6p35POuwV47W37T84
nz2MTwJO2LaFHSzxN/i2PQgUb1ddFz9AS+MFDTk0f0605wzhlVauK3ur1CZpXifD
gVjLeUBe1XBSl/2Nj4k/YaH/X1QF6WxU5PTKrNQ6+njdJ+hoxDyJVD2SffiqZNM7
4LXBlRBYeIePw0w3PaB2NqgiAPLC/BlufxhB/nBx48XvltrZuIBfG5hPgfDATJ84
0b8eB37nAgMBAAECggEBALNUe+gYtnUXxsp6pxljMxI5Gdz3sxsfYVPFpBjYBQVU
MMZr253Qj83vL/GrOaD4Y0OeYQXv4rjQxFEx6cx3oyrW9eddK5MQ5OBf8D14QeJ1
13fY3+OYIrSoihgwgn+mcX32SeBBtTZIL5CeqmpfLMwmqBGEC6LTPGq93MIvGASE
84Lf28gVk69nPdj3ZHw7zjG5Rb5gmnVnj8HeiYKixFG7Ev0ttdczZ9g+XmEoCLDo
XQFUjgrllrJSJpV1GK1N4fntrDSrZ+GyM2R9dNcpgSEZ077QdIljjqHcfHgABjkB
Asbcjb0cQy9aIE3BwOkh39FPM71pcnRcXVlJsuGTIgECgYEA9ySHXI52hfqmMt1B
u/grY0LUb+mUrLh2GKAOPTzzN2zTzvBy6b7DvKbTmsOTiMVQ2j3rVIw/qLrIm4wg
TNoCIBBkM/gJ4MtbaR0tWhE8CIG//OiN+bVSIuojZ+6csNo4EgpXRhosaX5n9gw6
JWpCGGELKYkzBoqXMxALxYTDh1cCgYEA2Fdd5f/c9gYeMsUiKUxCq4PDZS6aNBO+
w5zxWGc7+gDJDTg3Cue4g65KYHm16ZCWLZittaV6xjcAU8hsgIq5mR/9nwd1DiFy
kmot5JWkQc23yqseq2lHwDKRCc6Fh77zpvt80WI5iD6v7kc4P1JViZtLJpVC1Rxi
JMzO8gzT2vECgYAQARmS8NbUDks89/8NwSBuKSHArYunM7rSFWtWo9/MMwv0VrXa
VTQvv03ss8WWEdEOkPvwWbS1pILhL83XrDZ/BRC4HNPm7sRYpj8NmhgdJOnd4uFu
zkMnZ6orTNRwz3DaGjlUnNVLb5gj4t7RFXR6R66FXhEj1027TMq2W8aduQKBgQCw
VR2ivxaxrLDmfslmUdMxixczHHXxpnphZEVO4e3/yq4UyVIL4G0DX4cd9XYxZnkR
txU3LibQ8rmgkIbniqrWRT3qZiChoN+KuWKootOcEvoQBcPcwNYLsOuIy70ItLpR
yz+kRmRQSZAKLiCJdClmHJ53V0d+/kB8cDbpEU2IcQKBgCZCfKbUevhQ37iN1AJZ
tNDQjCed/MMhcBQBCkWXin5lxgyctIPgZiNlk2w7nooNWFAYymKJ6HuAtetOYssS
i0AXVmVVagNwIw7b5Q5Z2jGBQ0W5H1s6qQ832zTlokWuwVpzq2HpGPIq0P5z4Omb
UG4rLe+2IINXbG3ry8s254N5
-----END PRIVATE KEY-----
EOF10
 cat <<'EOF18'> /etc/openvpn/tls-auth.key
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
930c4ccae2e0713f1b1b83821ba956e8
a22ac9824f01af42cc816ceb4a12afa0
ccabb752d5d62c97aaabb2c0a8d7f0b8
081f4fe2c9af33ad1ebb32b85e6d5471
11675bc0af428b38d427852ef2694da9
3cffc4535040e6fd02498c986a5fb9e2
6ac4b411288481114cb83695052cb8ea
0c9763c1ff28316f42da1aae62516d27
b32a9ab71e85f47b07e4be5dd8113553
f212f49d018b0c9d95a1329fd864935f
b3f24a270322a7abe617cb85817d3fc2
d2f2d9030c6d24ccbb8911047bef97c9
294463a9d98c5f59654f74e7a8eb4af6
175a3ffbc5cbc384137c52f0ef01a1f4
f20dbce3ba0a5f18d4ff9d952583b846
6dc7f535bacd958427d3e61ab3a512d1
-----END OpenVPN Static key V1-----
EOF18
 cat <<'EOF107'> /etc/openvpn/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            46:f7:43:78:91:24:bc:19:66:7f:0e:84:08:c1:f1:69
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=vpn.f5labs.dev
        Validity
            Not Before: Jan 14 02:51:17 2021 GMT
            Not After : Apr 19 02:51:17 2023 GMT
        Subject: CN=vpn.f5labs.dev
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:de:42:c3:78:d2:f2:96:f4:03:78:ed:ca:45:19:
                    73:74:28:88:69:73:48:10:c7:12:9c:22:3e:09:41:
                    7b:87:d5:fc:b6:ef:11:4d:15:97:ca:d9:7e:b2:90:
                    aa:97:ec:5f:56:2b:76:60:e4:e4:25:e6:b5:96:7a:
                    d2:80:86:cc:fc:41:dc:45:6d:ae:1a:78:f0:21:54:
                    79:61:78:22:f1:3d:54:f9:d9:13:d3:0e:4c:38:71:
                    65:85:6a:f2:22:31:d6:59:f5:51:82:18:23:ea:d5:
                    13:f5:b7:43:5d:a7:f7:9e:e3:59:8f:ea:cc:6a:a2:
                    89:e8:de:79:d9:57:7e:03:a5:2d:f8:3e:19:ac:b8:
                    3c:2f:cf:4a:a7:62:b0:11:22:b0:ec:9b:5e:38:cb:
                    db:f0:b3:d4:47:7e:7d:97:42:6b:91:36:2e:e5:be:
                    9c:9a:9c:9b:c2:14:99:c4:49:a9:0d:1a:98:5b:b7:
                    a1:37:03:82:be:9f:e5:1e:43:b1:08:f8:46:6f:f3:
                    77:13:11:5a:9f:d2:d4:f9:c7:92:e4:55:75:27:35:
                    18:55:5d:ef:87:b0:fa:46:f4:d1:c4:a5:4d:f8:e2:
                    2a:b8:ba:22:e7:57:ec:fe:93:88:61:e4:e9:ec:c3:
                    c1:52:4d:88:61:a5:e4:8c:4b:5a:99:01:6c:6c:ff:
                    d9:61
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                65:2A:ED:A2:C4:CF:21:2B:EE:CD:7E:53:D8:EE:DA:77:AD:FF:56:46
            X509v3 Authority Key Identifier: 
                keyid:FC:66:B7:57:58:8F:93:B2:3A:61:1E:43:78:D4:2E:43:EF:5E:E4:35
                DirName:/CN=vpn.f5labs.dev
                serial:51:9C:76:87:21:63:D4:D3:FF:1E:54:B2:7B:8D:DF:13:1E:F5:6A:AC

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:vpn.f5labs.dev
    Signature Algorithm: sha256WithRSAEncryption
         21:d9:86:a5:ca:99:07:2c:ef:17:b5:45:ba:ae:4f:a0:a8:c6:
         81:ca:b4:b1:6c:45:b8:f1:23:5a:9c:4a:e1:ee:9a:b6:34:b0:
         7d:d2:69:4d:54:69:7a:e4:1f:11:0a:fd:73:6e:4a:e5:cf:35:
         28:09:93:2c:7c:ff:9d:53:8d:3a:e4:cf:cb:08:21:a2:be:ae:
         c5:ed:f6:d3:43:c4:92:3c:5a:65:86:c3:26:86:b7:0f:8f:24:
         08:38:d4:b2:59:d0:dc:8e:ed:ca:ac:65:06:9e:84:0b:bb:13:
         ef:1c:e8:94:63:a7:e4:ff:43:d0:ed:8f:ab:bf:63:0f:09:b2:
         87:17:24:ec:c2:9e:2d:a5:fa:70:d8:17:16:ab:46:39:86:84:
         bb:90:63:3f:3b:55:22:30:ac:ec:c7:1a:b0:19:af:72:9e:5a:
         a2:64:39:66:e4:79:cc:14:d6:9d:a1:32:9a:0f:2a:42:e2:32:
         4f:f4:3d:65:bf:9f:8c:6f:1b:d2:a5:22:e3:34:ce:84:c0:43:
         a6:c9:e0:7f:6f:fc:24:5a:02:b1:41:bc:30:e2:0c:2f:48:74:
         c0:f1:71:2b:15:e4:8c:cc:c9:da:e0:ba:b8:f9:b4:12:a2:0b:
         5a:c3:2a:7b:84:41:95:17:31:9d:7c:6d:50:cb:15:9f:bf:a2:
         b1:be:cf:bf
-----BEGIN CERTIFICATE-----
MIIDfTCCAmWgAwIBAgIQRvdDeJEkvBlmfw6ECMHxaTANBgkqhkiG9w0BAQsFADAZ
MRcwFQYDVQQDDA52cG4uZjVsYWJzLmRldjAeFw0yMTAxMTQwMjUxMTdaFw0yMzA0
MTkwMjUxMTdaMBkxFzAVBgNVBAMMDnZwbi5mNWxhYnMuZGV2MIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3kLDeNLylvQDeO3KRRlzdCiIaXNIEMcSnCI+
CUF7h9X8tu8RTRWXytl+spCql+xfVit2YOTkJea1lnrSgIbM/EHcRW2uGnjwIVR5
YXgi8T1U+dkT0w5MOHFlhWryIjHWWfVRghgj6tUT9bdDXaf3nuNZj+rMaqKJ6N55
2Vd+A6Ut+D4ZrLg8L89Kp2KwESKw7JteOMvb8LPUR359l0JrkTYu5b6cmpybwhSZ
xEmpDRqYW7ehNwOCvp/lHkOxCPhGb/N3ExFan9LU+ceS5FV1JzUYVV3vh7D6RvTR
xKVN+OIquLoi51fs/pOIYeTp7MPBUk2IYaXkjEtamQFsbP/ZYQIDAQABo4HAMIG9
MAkGA1UdEwQCMAAwHQYDVR0OBBYEFGUq7aLEzyEr7s1+U9ju2net/1ZGMFQGA1Ud
IwRNMEuAFPxmt1dYj5OyOmEeQ3jULkPvXuQ1oR2kGzAZMRcwFQYDVQQDDA52cG4u
ZjVsYWJzLmRldoIUUZx2hyFj1NP/HlSye43fEx71aqwwEwYDVR0lBAwwCgYIKwYB
BQUHAwEwCwYDVR0PBAQDAgWgMBkGA1UdEQQSMBCCDnZwbi5mNWxhYnMuZGV2MA0G
CSqGSIb3DQEBCwUAA4IBAQAh2YalypkHLO8XtUW6rk+gqMaByrSxbEW48SNanErh
7pq2NLB90mlNVGl65B8RCv1zbkrlzzUoCZMsfP+dU4065M/LCCGivq7F7fbTQ8SS
PFplhsMmhrcPjyQIONSyWdDcju3KrGUGnoQLuxPvHOiUY6fk/0PQ7Y+rv2MPCbKH
FyTswp4tpfpw2BcWq0Y5hoS7kGM/O1UiMKzsxxqwGa9ynlqiZDlm5HnMFNadoTKa
DypC4jJP9D1lv5+MbxvSpSLjNM6EwEOmyeB/b/wkWgKxQbww4gwvSHTA8XErFeSM
zMna4Lq4+bQSogtawyp7hEGVFzGdfG1QyxWfv6Kxvs+/
-----END CERTIFICATE-----
EOF107
 cat <<'EOF113'> /etc/openvpn/server.key
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDeQsN40vKW9AN4
7cpFGXN0KIhpc0gQxxKcIj4JQXuH1fy27xFNFZfK2X6ykKqX7F9WK3Zg5OQl5rWW
etKAhsz8QdxFba4aePAhVHlheCLxPVT52RPTDkw4cWWFavIiMdZZ9VGCGCPq1RP1
t0Ndp/ee41mP6sxqoono3nnZV34DpS34PhmsuDwvz0qnYrARIrDsm144y9vws9RH
fn2XQmuRNi7lvpyanJvCFJnESakNGphbt6E3A4K+n+UeQ7EI+EZv83cTEVqf0tT5
x5LkVXUnNRhVXe+HsPpG9NHEpU344iq4uiLnV+z+k4hh5Onsw8FSTYhhpeSMS1qZ
AWxs/9lhAgMBAAECggEBAM4YFm2ZHb1/8yBVTvQYD4isdSFi9nYoQkdpMSEgCU4B
zN5MfDyAQ0qjtuoZXzaUxip/Drv2QuAqOEObDEqFtNpMr9XpSEHf1rrxO8R3w97y
QjOTaOCSJ3dHHx5B9thiYiL0aWo6vENq5aE5GExmDiTVKB1dWcOfiEXY1iAFEyKI
c989eHcS+D9KY5tNhRRUJboUeMpytaJSs1jxRU2W8xnVaAJ7dzNkgH9a9GRrQN8j
ehyteuQG0H3AMT3jODaavozgz0GiEGYPUs39a2pWSqUh1SLPJx94WIlIjERNLORk
atZiyBZt+TIIRaf5uOoEYgcECvjgfkmJZg3zXhQXkakCgYEA8C7zGOiTEJ7pfPwE
GDvRx1iVvOPvKhMc2xrUyk3UQTqfH9xZaWGAOYwK9i6MsTgybXtwUSaQ8cPhqCjg
gu+tHwzGWErZQ0BqqtN+AWpbkkbJbxOhZY2jQmVXaBR5CMdhwV+AWEv9F9Lbxerv
BULjMhcP2si/CgsTEs6PN5tSZtsCgYEA7OWr/siyewxf9xSjQ++Ht9oGtqBlbVsZ
Qx2YlEuYNEslgSGg4I9LKS5y55ZhRWai4+BOOSZWY+b3XYNiS4U3asppvTMP4tUi
LmPs3kGlenT/QuNFlW6z7kjRs5t9y8eMkFy/xGJKZY22swl+kC9i0kxx5cofxPP0
pyq7Wpdvf3MCgYBeAdJOVoFxSPGUZMNphMhX4PlCpGgwrKhnrbnJsOq52Sr8+m7Y
izv3yjNkJdYVayx5o43ThWfH6OZCvjUZqpu1AngDiNA+vVDCqeKwxSMwPpqK6kEK
kYRr8WRjrVeuMvO1Dx8Z8CwQjgxNC+Yfxg1MxrAC7v2u/aSqgMSXfCilbwKBgA6s
+8bA8C2nSpqn8KVYxXOiUiAmN6Jarmn1/2nQdRFoRl6Fks3WkrVuZzfpnQULorOz
RaVMtrVhrZlhdklva0t2Vq6d5zIKOh/dmOL79iBr9xRRuBHV1dfBMxyJWXWyWwbm
eArWe/1mlhbpU6njBaA5lCTELMuqwVFJ2Gl4UDP5AoGAJWCTpUftWEFHkGLDN1Zs
bzchAN6mXKKqr9Jg12xkgt8sVKNn+ntA5bJi9Ib7n1lafyIQ8Gn1h6kG76OY02PP
/CDy368Q8XPzxrNLueJDNeS5JBNGXKkjqz3pc/c2CQ0QBxv1ar9RNa2AZxr2k5Ii
jNGLcR0Tmt2DaoPHClr/D8Y=
-----END PRIVATE KEY-----
EOF113
 cat <<'EOF13'> /etc/openvpn/dh.pem
-----BEGIN DH PARAMETERS-----
MIICCAKCAgEA4n16aZpGsqucktU0QAkocQGie3E0rjbaanO+8HWea4Uf6XvKokA+
iXZl/pPHg/ItVjkFZViWMzZ9Xa0/Y2JKVuYCnguC8xSdN+xlo2gQ+PwK1ExrB0lR
PoCWa/KzJIQI5VWHNUDh0qkdmGgpxfAIKNZXzbxW3ktZi1oX0TI8vPFejbtWEGoE
H4HDhF6376o2NvHPILEVNzmWp9hRpmU+luxFQaoDD5iDkrpL1zdGvBhmGilYQwRo
0jt5uIm6N/S/jFvwMhn4QFKaDOppFwTwH+sH9/EiDH93xlmGv6B5SiI2aP1w1YKj
ytDXm680EMzfYP1XYcd/6u+9xHI1BsJAWvcjOhPujAUy8krWe/+PjpYypLwx9gj7
zuHxsyrGvt8xPyRJfNbRn5Bvw4T+7RMbHGUehdy40qORJ4+ahd/+MhW/RDgx1EBf
njX9j2mSXEHW8AlEQlGaEDiUQqKZQmYDvkVMfjgl7c4HJxRSK/bl5UqLY6n1m744
fHzoDeQYl57JKTpgz026Gs/XXiZptI9H+fEHjHHcKgEreOA7tDiiqgrNvkPsRB+L
j2UJ0Ap3iVdPtCGii39p6i3B8jRnRiFcGoT+W15zjwEwD/tl699hZc1IMdeAod27
n7VpX6UPkLnqGE3HWh8eDnFndCYS+OKoRtIQZoJkzJA/Lq3o1YCdjFMCAQI=
-----END DH PARAMETERS-----
EOF13
 cat <<'EOF103'> /etc/openvpn/crl.pem
-----BEGIN X509 CRL-----
MIIBvDCBpQIBATANBgkqhkiG9w0BAQsFADAZMRcwFQYDVQQDDA52cG4uZjVsYWJz
LmRldhcNMjEwMTE0MDI1MTIzWhcNMzEwMTEyMDI1MTIzWqBYMFYwVAYDVR0jBE0w
S4AU/Ga3V1iPk7I6YR5DeNQuQ+9e5DWhHaQbMBkxFzAVBgNVBAMMDnZwbi5mNWxh
YnMuZGV2ghRRnHaHIWPU0/8eVLJ7jd8THvVqrDANBgkqhkiG9w0BAQsFAAOCAQEA
qv7+B4WNPqRI4WAiTnCtE/vQlQeKnn39NvDEbjfpJjNZAadQxaTeYtO58TOCu5R4
qwF42g0E2mUQvwUEmUeVulnDjEz5e6KOkgllWsrZGwlUObuKNNKrCHqvXxbH/rHk
76/4Jfu7IvqTk4a9c+MV5r5eSA7plRzdJhqgkBWCmD/46UlP2imkgNGg4FeAamuc
kiLEVXPwjRK30L3uUcWXzvXmXtLlvaadPHKPS5YA41WKS0xZ9iELIz0eUHXl8pgd
jrZFH4tMHWZ+mBTRA/76xsbBGWtkxND932g1vAc281EHv9+4iyW1SdvUTJNzZObh
6GJJ6ESQE6h3vJJpVeoFCg==
-----END X509 CRL-----
EOF103

 # Getting all dns inside resolv.conf then use as Default DNS for our openvpn server
 grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read -r line; do
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server_tcp.conf
done

 # Creating a New update message in server.conf
 cat <<'NUovpn' > /etc/openvpn/server.conf
 # New Update are now released, OpenVPN Server
 # are now running both TCP and UDP Protocol. (Both are only running on IPv4)
 # But our native server.conf are now removed and divided
 # Into two different configs base on their Protocols:
 #  * OpenVPN TCP (located at /etc/openvpn/server_tcp.conf
 #  * OpenVPN UDP (located at /etc/openvpn/server_udp.conf
 # 
 # Also other logging files like
 # status logs and server logs
 # are moved into new different file names:
 #  * OpenVPN TCP Server logs (/etc/openvpn/tcp.log)
 #  * OpenVPN UDP Server logs (/etc/openvpn/udp.log)
 #  * OpenVPN TCP Status logs (/etc/openvpn/tcp_stats.log)
 #  * OpenVPN UDP Status logs (/etc/openvpn/udp_stats.log)
 #
 # Server ports are configured base on env vars
 # executed/raised from this script (OpenVPN_TCP_Port/OpenVPN_UDP_Port)
 #
 # Enjoy the new update
 # Script Updated by SigulaDev
NUovpn

 # setting openvpn server port
 sed -i "s|OVPNTCP|$OpenVPN_TCP_Port|g" /etc/openvpn/server_tcp.conf
 sed -i "s|OVPNUDP|$OpenVPN_UDP_Port|g" /etc/openvpn/server_udp.conf
 
 # Getting some OpenVPN plugins for unix authentication
 wget -qO /etc/openvpn/b.zip 'https://raw.githubusercontent.com/GakodArmy/teli/main/openvpn_plugin64'
 unzip -qq /etc/openvpn/b.zip -d /etc/openvpn
 rm -f /etc/openvpn/b.zip

 echo ipv4 >> /etc/modules
 echo ipv6 >> /etc/modules
 sysctl -w net.ipv4.ip_forward=1
 sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
 sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
 sysctl -p
 clear

sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.up.rules
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/ara-rangers/vps/master/iptables"
chmod +x /etc/network/if-up.d/iptables
sed -i 's|LimitNPROC|#LimitNPROC|g' /lib/systemd/system/openvpn@.service
systemctl daemon-reload
/etc/init.d/openvpn restart
wget -qO /etc/openvpn/openvpn.bash "https://raw.githubusercontent.com/sumailranger93/sumail/main/openvpn.bash"
chmod +x /etc/openvpn/openvpn.bash
bash /etc/openvpn/openvpn.bash
 
 # Starting OpenVPN server
 systemctl start openvpn@server_tcp
 systemctl enable openvpn@server_tcp
 systemctl start openvpn@server_udp
 systemctl enable openvpn@server_udp

 # Creating our root directory for all of our .ovpn configs
# rm -rf /var/www/openvpn
 mkdir -p /home/vps/public_html

 # Creating our root directory for all of our .ovpn configs
 rm -rf /var/www/openvpn
 mkdir -p /var/www/openvpn
# Now creating all of our OpenVPN Configs 
cat <<EOF152> /home/vps/public_html/tcp.ovpn
client
dev tun
setenv FRIENDLY_NAME "I'M MASTA GAKOD"
remote $IPADDR $OpenVPN_TCP_Port tcp
http-proxy $IPADDR $Squid_Port1
http-proxy-retry
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
comp-lzo
cipher AES-256-CBC
auth SHA256
push "redirect-gateway def1 bypass-dhcp"
verb 3
push-peer-info
ping 10
ping-restart 60
hand-window 70
server-poll-timeout 4
reneg-sec 2592000
sndbuf 0
rcvbuf 0
remote-cert-tls server
key-direction 1

<auth-user-pass>
sam
sam
</auth-user-pass>
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/client.crt)
</cert>
<key>
$(cat /etc/openvpn/client.key)
</key>
<tls-auth>
$(cat /etc/openvpn/tls-auth.key)
</tls-auth>
EOF152

cat <<EOF16> /home/vps/public_html/udp.ovpn
# Credits to GakodX
client
dev tun
proto udp
setenv FRIENDLY_NAME "I'M MASTA GAKOD"
remote $IPADDR $OpenVPN_UDP_Port
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
comp-lzo
cipher AES-256-CBC
auth SHA256
push "redirect-gateway def1 bypass-dhcp"
verb 3
push-peer-info
ping 10
ping-restart 60
hand-window 70
server-poll-timeout 4
reneg-sec 2592000
sndbuf 0
rcvbuf 0
remote-cert-tls server
key-direction 1
<auth-user-pass>
sam
sam
</auth-user-pass>
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/client.crt)
</cert>
<key>
$(cat /etc/openvpn/client.key)
</key>
<tls-auth>
$(cat /etc/openvpn/tls-auth.key)
</tls-auth>
EOF16

cat <<EOF17> /home/vps/public_html/ssl.ovpn
client
proto tcp-client
dev tun
setenv FRIENDLY_NAME "I'M MASTA GAKOD"
remote 127.0.0.1 443
route $IPADDR 255.255.255.255 net_gateway 
http-proxy $IPADDR 8080
http-proxy-retry
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
comp-lzo
cipher AES-256-CBC
auth SHA256
push "redirect-gateway def1 bypass-dhcp"
verb 3
push-peer-info
ping 10
ping-restart 60
hand-window 70
server-poll-timeout 4
reneg-sec 2592000
sndbuf 0
rcvbuf 0
remote-cert-tls server
key-direction 1
<auth-user-pass>
sam
sam
</auth-user-pass>
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/client.crt)
</cert>
<key>
$(cat /etc/openvpn/client.key)
</key>
<tls-auth>
$(cat /etc/openvpn/tls-auth.key)
</tls-auth>
EOF17

# Setting UFW
apt-get install ufw
ufw allow ssh
ufw allow 1103/tcp
sed -i 's|DEFAULT_INPUT_POLICY="DROP"|DEFAULT_INPUT_POLICY="ACCEPT"|' /etc/default/ufw
sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|' /etc/default/ufw
cat > /etc/ufw/before.rules <<-END
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to eth0
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
END
ufw status
ufw disable

# set ipv4 forward
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# OpenVPN monitoring
apt-get install -y gcc libgeoip-dev python-virtualenv python-dev geoip-database-extra uwsgi uwsgi-plugin-python
wget -O /srv/openvpn-monitor.tar "https://raw.githubusercontent.com/gatotx/AutoScriptDebian9/main/Res/Panel/openvpn-monitor.tar"
cd /srv
tar xf openvpn-monitor.tar
cd openvpn-monitor
virtualenv .
. bin/activate
pip install -r requirements.txt
wget -O /etc/uwsgi/apps-available/openvpn-monitor.ini "https://raw.githubusercontent.com/gatotx/AutoScriptDebian9/main/Res/Panel/openvpn-monitor.ini"
ln -s /etc/uwsgi/apps-available/openvpn-monitor.ini /etc/uwsgi/apps-enabled/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/gatotx/AutoScriptDebian9/main/Res/BadVPN/badvpn-udpgw64"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# setting port ssh
sed -i '/#Port 22/a Port 143' /etc/ssh/sshd_config
sed -i '/#Port 22/a Port  90' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port  22/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=442/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
/etc/init.d/dropbear restart

# install squid
apt-get -y install squid
cat > /etc/squid/squid.conf <<-END
acl server dst xxxxxxxxx/32 localhost
acl checker src 188.93.95.137
acl ports_ port 14 22 53 21 8080 8081 8000 3128 1193 1194 440 441 442 443 80
http_port 3128
http_port 8000
http_port 8080
http_port 8888
access_log none
cache_log /dev/null
logfile_rotate 0
http_access allow server
http_access allow checker
http_access deny all
forwarded_for off
via off
request_header_access Host allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access All deny all
hierarchy_stoplist cgi-bin ?
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname dopekid.tk
END
sed -i $MYIP2 /etc/squid/squid.conf;
service squid restart


# xml parser
cd
apt-get install -y libxml-parser-perl

# download script
cd
wget https://raw.githubusercontent.com/gatotx/AutoScriptDebian9/main/Res/Menu/install-premiumscript.sh -O - -o /dev/null|sh

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/stunnel4 restart
service squid restart
/etc/init.d/webmin restart

# clearing history
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# remove unnecessary files
apt -y autoremove
apt -y autoclean
apt -y clean

# info
clear
echo " "
echo "INSTALLATION COMPLETE!"
echo " "
echo "------------------------- Configuration Setup Server ------------------------"
echo "                    Copyright https://t.me/Jo3k3r                           "
echo "                             Created By JokerTeam                          "
echo "-----------------------------------------------------------------------------"
echo ""  | tee -a log-install.txt
echo "Server Information"  | tee -a log-install.txt
echo "   - Timezone    : Africa/Johannesburg (GMT +2)"  | tee -a log-install.txt
echo "   - Fail2Ban    : [ON]"  | tee -a log-install.txt
echo "   - Dflate      : [ON]"  | tee -a log-install.txt
echo "   - IPtables    : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot : [OFF]"  | tee -a log-install.txt
echo "   - IPv6        : [OFF]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Application & Port Information"  | tee -a log-install.txt
echo "   - OpenVPN     : TCP 443"  | tee -a log-install.txt
echo "   - OpenSSH     : 22, 90, 143"  | tee -a log-install.txt
echo "   - Stunnel4    : 444"  | tee -a log-install.txt
echo "   - Dropbear    : 80, 109, 110, 442"  | tee -a log-install.txt
echo "   - Squid Proxy : 3128, 8000, 8080, 8888"  | tee -a log-install.txt
echo "   - Badvpn      : 7300"  | tee -a log-install.txt
echo "   - Nginx       : 85"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Server Tools"  | tee -a log-install.txt
echo "   - htop"  | tee -a log-install.txt
echo "   - iftop"  | tee -a log-install.txt
echo "   - mtr"  | tee -a log-install.txt
echo "   - nethogs"  | tee -a log-install.txt
echo "   - screenfetch"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Premium Script Information"  | tee -a log-install.txt
echo "   To display list of commands: menu"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   Explanation of scripts and VPS setup" | tee -a log-install.txt
echo "Important Information"  | tee -a log-install.txt
echo "   - Download Config OpenVPN : http://$MYIP:85/Dopekid.ovpn"  | tee -a log-install.txt
echo "   - Mirror (*.tar.gz)       : http://$MYIP:85/DopekidVPN.tar.gz"  | tee -a log-install.txt
echo "   - Simple Panel            : http://$MYIP:85/"  | tee -a log-install.txt
echo "   - Openvpn Monitor         : http://$MYIP:89/"  | tee -a log-install.txt
echo "   - Webmin                  : http://$MYIP:10000/"  | tee -a log-install.txt
echo "   - Installation Log        : cat /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "----------------- Script By JokerTeam(t.me/Jo3k3r)  -----------------"
echo "                              Script By JokerTeam                             "
echo "-----------------------------------------------------------------------------"
