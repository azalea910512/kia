#!/bin/bash
# ******************************************
# Program: Autoscript Setup VPS 2019
# Developer: ARAMAITI
# Nickname: ARA
# Modify : @aramaiti85 
# Date: 11-05-2016
# Last Updated: 20-01-2019
# ******************************************
# START SCRIPT ( RANGERSVPN )

# initializing var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# company name details
country=MY
state=MY
locality=Malaysia
organization=Personal
organizationalunit=Personal
commonname=RangersVPN
email=rangersvpn@gmail.com

if [ $USER != 'root' ]; then
echo "Sorry, for run the script please using root user"
exit 1
fi
if [[ "$EUID" -ne 0 ]]; then
echo "Sorry, you need to run this as root"
exit 2
fi
if [[ ! -e /dev/net/tun ]]; then
echo "TUN is not available"
exit 3
fi
echo "
AUTOSCRIPT BY RANGERSVPN

PLEASE CANCEL ALL PACKAGE POPUP

TAKE NOTE !!!"
clear
echo "START AUTOSCRIPT"
clear
echo "SET TIMEZONE KUALA LUMPUT GMT +8"
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime;
clear
echo "
ENABLE IPV4 AND IPV6

COMPLETE 1%
"
echo ipv4 >> /etc/modules
echo ipv6 >> /etc/modules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sysctl -p
clear
echo "
REMOVE SPAM PACKAGE

COMPLETE 10%
"
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove postfix*;
apt-get -y --purge remove bind*;
apt-get -y install wget curl

clear
echo "
UPDATE AND UPGRADE PROCESS

PLEASE WAIT TAKE TIME 1-5 MINUTE
"
# set repo
echo 'deb http://download.webmin.com/download/repository sarge contrib' >> /etc/apt/sources.list.d/webmin.list
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
apt-get update
apt-get -y install nginx
apt-get -y install nano iptables-persistent dnsutils screen whois ngrep unzip unrar
echo "
INSTALLER PROCESS PLEASE WAIT

TAKE TIME 5-10 MINUTE
"
# script
wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/ara-rangers/vps/master/menu"
wget -O /usr/local/bin/m "https://raw.githubusercontent.com/ara-rangers/vps/master/menu"
wget -O /usr/local/bin/autokill "https://raw.githubusercontent.com/ara-rangers/vps/master/autokill"
wget -O /usr/local/bin/user-generate "https://raw.githubusercontent.com/ara-rangers/vps/master/user-generate"
wget -O /usr/local/bin/speedtest "https://raw.githubusercontent.com/ara-rangers/vps/master/speedtest"
wget -O /usr/local/bin/user-lock "https://raw.githubusercontent.com/ara-rangers/vps/master/user-lock"
wget -O /usr/local/bin/user-unlock "https://raw.githubusercontent.com/ara-rangers/vps/master/user-unlock"
wget -O /usr/local/bin/auto-reboot "https://raw.githubusercontent.com/ara-rangers/vps/master/auto-reboot"
wget -O /usr/local/bin/user-password "https://raw.githubusercontent.com/ara-rangers/vps/master/user-password"
wget -O /usr/local/bin/trial "https://raw.githubusercontent.com/ara-rangers/vps/master/trial"
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/ara-rangers/vps/master/common-password"
chmod +x /etc/pam.d/common-password
chmod +x /usr/local/bin/menu
chmod +x /usr/local/bin/m
chmod +x /usr/local/bin/autokill 
chmod +x /usr/local/bin/user-generate 
chmod +x /usr/local/bin/speedtest 
chmod +x /usr/local/bin/user-unlock
chmod +x /usr/local/bin/user-lock
chmod +x /usr/local/bin/auto-reboot
chmod +x /usr/local/bin/user-password
chmod +x /usr/local/bin/trial

# fail2ban & exim & protection
apt-get install -y grepcidr
apt-get install -y libxml-parser-perl
apt-get -y install tcpdump fail2ban sysv-rc-conf dnsutils dsniff zip unzip;
wget https://github.com/jgmdev/ddos-deflate/archive/master.zip;unzip master.zip;
cd ddos-deflate-master && ./install.sh
service exim4 stop;sysv-rc-conf exim4 off;

# webmin
apt-get -y install webmin
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
# ssh
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
wget -O /etc/issue.net "https://raw.githubusercontent.com/ara-rangers/vps/master/banner"

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=444/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart

# install squid
apt-get -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/ara-rangers/vps/master/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
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
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/ara-rangers/vps/master/vps.conf"

#  openvpn
apt-get -y install openvpn
# Checking if openvpn folder is accidentally deleted or purged
 if [[ ! -e /etc/openvpn ]]; then
  mkdir -p /etc/openvpn
 fi

 # Removing all existing openvpn server files
 rm -rf /etc/openvpn/*

 # Creating server.conf, ca.crt, server.crt and server.key
 cat <<'myOpenVPNconf1' > /etc/openvpn/server_tcp.conf
# LODIxyrussScript

port 1103
proto tcp
dev tun
dev-type tun
sndbuf 100000
rcvbuf 100000
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
myOpenVPNconf1
cat <<'myOpenVPNconf2' > /etc/openvpn/server_udp.conf
# LODIxyrussScript

port 25000
proto udp
dev tun
dev-type tun
sndbuf 0
rcvbuf 0
crl-verify crl.pem
ca ca.crt
cert server.crt
key server.key
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
MIIETTCCArWgAwIBAgIJALdz0i1x0KEyMA0GCSqGSIb3DQEBCwUAMB4xHDAaBgNV
BAMME2NuX1RaR0RrV21zWTdwaEVkcGowHhcNMTgwMTI1MTc1NDA0WhcNMjgwMTIz
MTc1NDA0WjAeMRwwGgYDVQQDDBNjbl9UWkdEa1dtc1k3cGhFZHBqMIIBojANBgkq
hkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAtXH29l8WlnKUcrMLACuy0+/tgLweHjnw
ajs01aYRmTKCKAqYmu6URpkowumttiyEuntLDg5YR2yhMu1dEI0vFkyNFyMPZTde
fVZ/HKOQV/SVFWJIJlZC7enT5VwwB22u3Joge3//pT7CbK8pv4I/1As+pdy4K0T0
ki3Vkd4TUPwnQlnsRwmG7530ih0ZOUDIuaWeQKnE+Eit5alqLMolkMIIFYDXsyAF
FZf9k16VEOQh+swlQwKTvcX9iUpubCJnZ37Z4M72GkoAEHHdaFOuTFm0GR9Z9efM
DJt8eh+oKq7nL1Iy7qH9ccm0lO3duiTE9ls3Oo1TlYdG0fo4D+WJExnPt1UVdaxQ
2BN+VuWcdnYs6hK0buAaOUvEX39BiHwP4KhYmBxSxDHWV0LYMefsvTMU/BfG2MSc
303ymVmkR5B+JUa0Ya9AaAf0lcEZR9Ygv4NFbUPTCSNHJ0qKi5vCzNb1aKCZ7lhb
c2fnHXNhOoeeKMDrSfPgUw6frM2mYMPZAgMBAAGjgY0wgYowHQYDVR0OBBYEFEiB
b69ceISKDqHOjvIhppheewazME4GA1UdIwRHMEWAFEiBb69ceISKDqHOjvIhpphe
ewazoSKkIDAeMRwwGgYDVQQDDBNjbl9UWkdEa1dtc1k3cGhFZHBqggkAt3PSLXHQ
oTIwDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAQYwDQYJKoZIhvcNAQELBQADggGB
AAzGnQr7zHeFZYrwI2a7asrjiM/KbABN69Fk4DRPk861y7Sunw768wRPDgcrpJui
xoTZDh2okzsa7Ypiz63hdn42ERW9VKydtT7paoKl5hEeoipaKlefkaC2zC57sid9
fVLSsAAMy3lNLtXly7+glLKd+YuRQozLsgp8B/JyjrlNDTEeo4V5T7cirlXkcN31
C3YwSX7b6SKeaypcDlGL7nl2JTUHRVuhW78BloYeU2oc16PbzKlYwLkSX1puA3HW
C1qfbImYpQAudE6c1nWehPPCNvbaoJ/Isw4hfYLsEwhVhaadbklHZF7eGOlVXlLV
wfo84cwPdE0bvNwsMibmy72NTNgDRN1sPeHN3vyA5sW5x/a+vnpzKoQLBYwMKPpz
wqbEngGEtTQckXOiSqa9dX6JXTVuZtegdEenpVLncYnI3Ns50G5x8BIGY+OXu1bv
sLAxjojallMfVm0vdV1xZhyrt0uwUl7X0lGKMLXI1+8LhTYyqVICclqrHpe3tacc
Ew==
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
40240d75e68c0c904997178f1e02bb26
e0e749654be32a0b7adc37cfc70be68c
1483fa0c9427eec41fd6492b68fa67cd
7fbccce05ed92e02bdf5e94aa028afa6
e1aec19a2f22082409695c958100fd94
d667cb2f9b4ef1294e1fcf8307ad52e0
a2f0ac7d1f64d32bad1b00b502272d87
4d05c2851a09578585d3fcc2626275c2
4b3d98220506b9b1c4b726e2fe8ff0fa
1a0b194e55ce517740c6f9e399808ca2
2017adbb8c0695eaa1686cc64cd5c3cd
3210ca0f3283233be7dc18a5e535adc9
c87fc49ee32b97b6c925014b464ae52d
e6d7b99a22b84f1620d7c94af927c8bb
0ed52d61c9ca821be4e9deb94bc00cb8
29b8d1b0a13e173b68e3b835c46a4a38
-----END OpenVPN Static key V1-----
EOF18
 cat <<'EOF107'> /etc/openvpn/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            51:3f:14:0e:2d:0c:38:91:eb:c3:cd:61:41:9d:27:cb
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=cn_TZGDkWmsY7phEdpj
        Validity
            Not Before: Jan 25 17:56:35 2018 GMT
            Not After : Jan 23 17:56:35 2028 GMT
        Subject: CN=server_ADBtkp0yL46HLXPb
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (3072 bit)
                Modulus:
                    00:ce:57:b1:a9:2f:ae:7a:cd:80:47:5a:91:43:9c:
                    51:30:48:15:99:d7:ce:c5:cd:7f:5e:bd:29:73:e6:
                    48:3c:6c:b2:79:e7:20:c3:72:34:a9:e4:fc:16:95:
                    ca:1c:33:0e:76:7d:33:1f:f9:01:18:b9:29:f7:a7:
                    0a:d4:9c:05:04:a4:d4:8a:4b:e7:eb:db:c7:d3:b8:
                    ac:80:80:d7:d3:49:c9:e6:08:4a:72:da:99:7c:5d:
                    87:fd:3e:7c:0e:10:33:db:3e:8d:68:5b:82:7a:73:
                    17:e4:78:e8:f3:fb:97:ce:0f:24:c5:c1:62:cb:58:
                    89:ac:8c:16:ac:f3:fc:32:05:a0:69:6f:c3:04:73:
                    69:4b:c5:8c:c6:bc:64:47:90:30:97:20:60:86:62:
                    bf:09:54:e6:62:00:4a:8a:8e:cc:c5:04:65:96:f5:
                    fb:08:ae:f3:5b:54:a9:42:15:3a:63:c7:06:9f:70:
                    5c:0d:3b:f2:37:8a:41:0b:87:dc:40:7e:c9:a2:c8:
                    ba:1b:a4:e3:84:19:64:90:96:8a:11:1b:10:6a:61:
                    ef:ca:a4:a4:82:69:db:cd:d1:62:b4:cd:4f:2d:a7:
                    ac:4e:43:d9:9e:f7:61:ea:75:1c:2d:cf:bc:ad:b9:
                    bd:8c:19:9a:69:33:35:a5:20:e7:d7:4c:9b:24:f8:
                    ca:9d:11:8b:15:17:2b:92:e2:5a:08:04:43:81:cf:
                    7c:38:24:15:c1:79:cb:cd:88:92:be:d5:3f:4a:2c:
                    77:81:b5:6f:81:70:8f:37:dc:63:0e:7e:e9:bb:05:
                    8d:f5:83:05:e0:23:57:98:9f:a5:a9:32:3d:e0:54:
                    da:97:7b:6e:af:44:0f:ef:77:6d:81:21:98:59:a1:
                    2f:85:79:55:9a:87:6f:28:86:4d:b3:96:b4:fd:10:
                    07:bf:a4:34:7d:f6:59:34:0c:da:68:e9:b7:c9:aa:
                    c0:8d:92:05:70:4a:60:8b:18:19:ca:15:2a:7c:b4:
                    18:40:8f:35:f5:20:09:21:c3:03
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                16:A6:D1:D3:89:39:AF:C6:16:99:7E:6A:60:AF:44:E9:E9:57:F6:2D
            X509v3 Authority Key Identifier: 
                keyid:48:81:6F:AF:5C:78:84:8A:0E:A1:CE:8E:F2:21:A6:98:5E:7B:06:B3
                DirName:/CN=cn_TZGDkWmsY7phEdpj
                serial:B7:73:D2:2D:71:D0:A1:32

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:server_ADBtkp0yL46HLXPb
    Signature Algorithm: sha256WithRSAEncryption
         a5:2c:94:99:ca:29:19:0e:b2:1a:3f:12:db:ba:a3:00:c5:fb:
         0e:cf:e7:c4:02:17:de:90:86:2e:86:97:54:94:1c:06:d6:62:
         b0:8b:90:96:bf:80:2d:ae:7f:7c:94:f6:26:69:1b:1c:e9:32:
         58:c3:da:52:c2:e5:d5:c6:09:57:2a:9b:23:68:80:7e:d6:08:
         7f:34:10:0c:cf:c2:3e:5b:53:73:f0:fa:26:78:2a:68:4d:29:
         da:05:c6:80:43:e3:56:0e:38:38:16:26:dc:c9:af:13:33:51:
         2f:01:58:8c:ca:52:be:78:17:6d:4a:f3:f2:24:a6:44:bc:ab:
         8a:69:e6:63:e1:fe:8c:70:b6:3a:be:61:df:77:e9:b4:b5:a5:
         aa:d7:57:05:78:ae:4e:63:6e:fd:44:8c:a2:c8:5e:90:22:e7:
         95:49:f7:3d:e2:2f:1a:b3:d8:7a:49:b8:30:6b:be:2b:7e:34:
         16:6b:25:a8:8c:34:ff:aa:53:3f:65:5d:de:0b:cd:47:b7:57:
         f7:e5:84:de:33:41:13:33:4b:11:9b:01:20:37:5e:69:61:df:
         26:80:25:a2:c2:21:54:c2:84:d9:80:2c:27:68:83:bf:06:ba:
         66:13:7e:a9:4e:0b:95:a9:7a:96:a2:f1:0d:8e:ed:df:2c:e6:
         32:2c:3f:a4:7b:d1:8d:7c:97:52:8c:ab:00:6c:63:87:dc:72:
         0c:0a:ef:f5:84:6f:45:61:58:3b:53:16:8a:e5:fd:62:37:e5:
         1d:0d:00:b7:0a:47:2f:e8:f6:e0:df:74:cc:97:4e:1a:02:1c:
         b5:6d:46:49:c8:f9:da:c4:15:3b:b2:4d:d8:12:c4:48:46:aa:
         1f:3b:1d:7b:61:22:08:d5:46:69:de:4f:9e:ce:3f:30:33:2a:
         20:80:f2:c5:8f:ba:62:01:9d:ad:a7:39:85:a4:dd:97:b3:f1:
         b5:a0:c0:42:e2:2c:f9:b7:76:14:12:5b:cc:aa:8b:f1:ee:d6:
         88:c8:f4:0f:f4:4b
-----BEGIN CERTIFICATE-----
MIIEjjCCAvagAwIBAgIQUT8UDi0MOJHrw81hQZ0nyzANBgkqhkiG9w0BAQsFADAe
MRwwGgYDVQQDDBNjbl9UWkdEa1dtc1k3cGhFZHBqMB4XDTE4MDEyNTE3NTYzNVoX
DTI4MDEyMzE3NTYzNVowIjEgMB4GA1UEAwwXc2VydmVyX0FEQnRrcDB5TDQ2SExY
UGIwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQDOV7GpL656zYBHWpFD
nFEwSBWZ187FzX9evSlz5kg8bLJ55yDDcjSp5PwWlcocMw52fTMf+QEYuSn3pwrU
nAUEpNSKS+fr28fTuKyAgNfTScnmCEpy2pl8XYf9PnwOEDPbPo1oW4J6cxfkeOjz
+5fODyTFwWLLWImsjBas8/wyBaBpb8MEc2lLxYzGvGRHkDCXIGCGYr8JVOZiAEqK
jszFBGWW9fsIrvNbVKlCFTpjxwafcFwNO/I3ikELh9xAfsmiyLobpOOEGWSQlooR
GxBqYe/KpKSCadvN0WK0zU8tp6xOQ9me92HqdRwtz7ytub2MGZppMzWlIOfXTJsk
+MqdEYsVFyuS4loIBEOBz3w4JBXBecvNiJK+1T9KLHeBtW+BcI833GMOfum7BY31
gwXgI1eYn6WpMj3gVNqXe26vRA/vd22BIZhZoS+FeVWah28ohk2zlrT9EAe/pDR9
9lk0DNpo6bfJqsCNkgVwSmCLGBnKFSp8tBhAjzX1IAkhwwMCAwEAAaOBwzCBwDAJ
BgNVHRMEAjAAMB0GA1UdDgQWBBQWptHTiTmvxhaZfmpgr0Tp6Vf2LTBOBgNVHSME
RzBFgBRIgW+vXHiEig6hzo7yIaaYXnsGs6EipCAwHjEcMBoGA1UEAwwTY25fVFpH
RGtXbXNZN3BoRWRwaoIJALdz0i1x0KEyMBMGA1UdJQQMMAoGCCsGAQUFBwMBMAsG
A1UdDwQEAwIFoDAiBgNVHREEGzAZghdzZXJ2ZXJfQURCdGtwMHlMNDZITFhQYjAN
BgkqhkiG9w0BAQsFAAOCAYEApSyUmcopGQ6yGj8S27qjAMX7Ds/nxAIX3pCGLoaX
VJQcBtZisIuQlr+ALa5/fJT2JmkbHOkyWMPaUsLl1cYJVyqbI2iAftYIfzQQDM/C
PltTc/D6JngqaE0p2gXGgEPjVg44OBYm3MmvEzNRLwFYjMpSvngXbUrz8iSmRLyr
imnmY+H+jHC2Or5h33fptLWlqtdXBXiuTmNu/USMoshekCLnlUn3PeIvGrPYekm4
MGu+K340FmslqIw0/6pTP2Vd3gvNR7dX9+WE3jNBEzNLEZsBIDdeaWHfJoAlosIh
VMKE2YAsJ2iDvwa6ZhN+qU4Llal6lqLxDY7t3yzmMiw/pHvRjXyXUoyrAGxjh9xy
DArv9YRvRWFYO1MWiuX9YjflHQ0AtwpHL+j24N90zJdOGgIctW1GScj52sQVO7JN
2BLESEaqHzsde2EiCNVGad5Pns4/MDMqIIDyxY+6YgGdrac5haTdl7PxtaDAQuIs
+bd2FBJbzKqL8e7WiMj0D/RL
-----END CERTIFICATE-----
EOF107
 cat <<'EOF113'> /etc/openvpn/server.key
-----BEGIN PRIVATE KEY-----
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
dr3Szfw/1BrXI2OgvFxke2i6hA==
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
# Getting some OpenVPN plugins for unix authentication
cd
 # Getting some OpenVPN plugins for unix authentication
 wget -qO /etc/openvpn/b.zip 'https://raw.githubusercontent.com/GakodArmy/teli/main/openvpn_plugin64'
 unzip -qq /etc/openvpn/b.zip -d /etc/openvpn
 rm -f /etc/openvpn/b.zip

# wget -O /etc/rc.local "https://raw.githubusercontent.com/guardeumvpn/Qwer77/master/rc.local"
# chmod +x /etc/rc.local

 # Allow IPv4 Forwarding
 sed -i '/net.ipv4.ip_forward.*/d' /etc/sysctl.conf
 sed -i '/net.ipv4.ip_forward.*/d' /etc/sysctl.d/*.conf
 echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/20-openvpn.conf
 sysctl --system &> /dev/null

 # Iptables Rule for OpenVPN server
 cat <<'EOFipt' > /etc/openvpn/openvpn.bash
#!/bin/bash
PUBLIC_INET="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
IPCIDR='10.200.0.0/16'
IPCIDR2='10.201.0.0/16'
iptables -I FORWARD -s $IPCIDR -j ACCEPT
iptables -I FORWARD -s $IPCIDR2 -j ACCEPT
iptables -t nat -A POSTROUTING -o $PUBLIC_INET -j MASQUERADE
iptables -t nat -A POSTROUTING -s $IPCIDR -o $PUBLIC_INET -j MASQUERADE
iptables -t nat -A POSTROUTING -s $IPCIDR2 -o $PUBLIC_INET -j MASQUERADE
EOFipt
 chmod +x /etc/openvpn/openvpn.bash
 bash /etc/openvpn/openvpn.bash

 # Enabling IPv4 Forwarding
 echo 1 > /proc/sys/net/ipv4/ip_forward
 
 # Starting OpenVPN server
 systemctl start openvpn@server_tcp
 systemctl enable openvpn@server_tcp
 systemctl start openvpn@server_udp
 systemctl enable openvpn@server_udp

mkdir -p /home/vps/public_html
cat > /home/vps/public_html/sam.ovpn <<EOF1
# Thanks for using this script, Enjoy Highspeed OpenVPN Service

client
dev tun
proto tcp
setenv FRIENDLY_NAME "Mac Quan Inc - VPN UDP"
remote $MYIP 1103
http-proxy $MYIP 8080
http-proxy-retry
route-method exe
resolv-retry infinite
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
auth-user-pass
EOF1
echo '<ca>' >> /home/vps/public_html/sam.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/sam.ovpn
echo '</ca>' >> /home/vps/public_html/sam.ovpn
echo '<cert>' >> /home/vps/public_html/sam.ovpn
cat /etc/openvpn/server.crt >> /home/vps/public_html/sam.ovpn
echo '</cert>' >> /home/vps/public_html/sam.ovpn
echo '<key>' >> /home/vps/public_html/sam.ovpn
cat /etc/openvpn/server.key >> /home/vps/public_html/sam.ovpn
echo '</key>' >> /home/vps/public_html/sam.ovpn
echo '<tls-auth>' >> /home/vps/public_html/sam.ovpn
cat /etc/openvpn/tls-auth.key >> /home/vps/public_html/sam.ovpn
echo '</tls-auth>' >> /home/vps/public_html/sam.ovpn

cat > /home/vps/public_html/udp.ovpn <<EOF2
# Thanks for using this script, Enjoy Highspeed OpenVPN Service

client
dev tun
proto udp
setenv FRIENDLY_NAME "Mac Quan Inc - VPN UDP"
remote $MYIP 25000
route-method exe
resolv-retry infinite
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
auth-user-pass
<auth-user-pass>
sam
sam
</auth-user-pass>
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/server.crt)
</cert>
<key>
$(cat /etc/openvpn/server.key)
</key>
EOF2
# echo '<ca>' >> /home/vps/public_html/udp.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/udp.ovpn
# echo '</ca>' >> /home/vps/public_html/udp.ovpn
# echo '<cert>' >> /home/vps/public_html/udp.ovpn
# cat /etc/openvpn/server.crt >> /home/vps/public_html/udp.ovpn
# echo '</cert>' >> /home/vps/public_html/udp.ovpn
# echo '<key>' >> /home/vps/public_html/udp.ovpn
# cat /etc/openvpn/server.key >> /home/vps/public_html/udp.ovpn
# echo '</key>' >> /home/vps/public_html/udp.ovpn
# echo '<tls-auth>' >> /home/vps/public_html/udp.ovpn
# cat /etc/openvpn/tls-auth.key >> /home/vps/public_html/udp.ovpn
# echo '</tls-auth>' >> /home/vps/public_html/udp.ovpn

cat <<EOF162> /home/vps/public_html/udpp.ovpn
# Mac Quan Inc
# Thanks for using this script, Enjoy Highspeed OpenVPN Service
client
dev tun
proto udp
setenv FRIENDLY_NAME "Mac Quan Inc - VPN UDP"
remote $MYIP 25000
remote-cert-tls server
resolv-retry infinite
float
fast-io
nobind
persist-key
persist-remote-ip
persist-tun
auth-user-pass
auth none
auth-nocache
cipher none
comp-lzo
redirect-gateway def1
setenv CLIENT_CERT 0
reneg-sec 0
verb 1
<auth-user-pass>
sam
sam
</auth-user-pass>
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/server.crt)
</cert>
<key>
$(cat /etc/openvpn/server.key)
</key>
EOF162


/etc/init.d/openvpn restart

# install badvpn
cd
#apt-get install cmake -y
#apt-get install screen wget gcc build-essential g++ make -y
#wget https://github.com/trngkn/badvpn/raw/main/badvpn-1.999.130.tar.gz
#tar xf badvpn-1.999.130.tar.gz
#cd badvpn-1.999.130/
#cmake /home/pi/badvpn-1.999.130 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
#make install
#echo "Thiet lap BADVPN tai cong 7300"
#badvpn-udpgw --listen-addr 127.0.0.1:7300 > /dev/null &
#rm /root/badupd
#echo "Thanh Cong!!"
#echo "Yahhh"
#install badvpn deb/ubun
apt-get install cmake make gcc -y
cd
wget https://github.com/ambrop72/badvpn/archive/1.999.130.tar.gz
tar xzf 1.999.130.tar.gz
mkdir badvpn-build
cd badvpn-build
cmake ~/badvpn-1.999.130 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7000 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &' /etc/rc.local
chmod +x /usr/local/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7000 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 1000 --max-connections-for-client 1000 > /dev/null &

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 444
connect = 127.0.0.1:442

[openvpn]
accept = 587
connect = 127.0.0.1:1101

END

# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# configure stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
cd /etc/stunnel/
wget -O /etc/stunnel/ssl.conf "https://raw.githubusercontent.com/thekakw/jubake/main/ssl.conf"
sed -i $MYIP2 /etc/stunnel/ssl.conf;
cp ssl.conf /home/vps/public_html/
cd

echo "UPDATE AND INSTALL COMPLETE COMPLETE 99% BE PATIENT"
rm *.sh;rm *.txt;rm *.tar;rm *.deb;rm *.asc;rm *.zip;rm ddos*;

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/webmin restart
/etc/init.d/stunnel4 restart
/etc/init.d/squid start
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# grep ports 
opensshport="$(netstat -ntlp | grep -i ssh | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
dropbearport="$(netstat -nlpt | grep -i dropbear | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
stunnel4port="$(netstat -nlpt | grep -i stunnel | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
openvpnport="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
squidport="$(cat /etc/squid/squid.conf | grep -i http_port | awk '{print $2}')"
nginxport="$(netstat -nlpt | grep -i nginx| grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"

# END SCRIPT ( RANGERSVPN )
echo "========================================"  | tee -a log-install.txt
echo "Service Autoscript VPS (RANGERSVPN)"  | tee -a log-install.txt
echo "----------------------------------------"  | tee -a log-install.txt
echo "POWER BY RANGERSVPN CALL +601126996292"  | tee -a log-install.txt
echo "nginx : http://$MYIP:80"   | tee -a log-install.txt
echo "Webmin : http://$MYIP:10000/"  | tee -a log-install.txt
echo "OpenVPN  : TCP 443 (client config : http://$MYIP/client.ovpn)"  | tee -a log-install.txt
echo "Badvpn UDPGW : 7300"   | tee -a log-install.txt
echo "Stunnel SSL/TLS : 442"   | tee -a log-install.txt
echo "Squid3 : 3128,3129,8080,8000,9999"  | tee -a log-install.txt
echo "OpenSSH : 22"  | tee -a log-install.txt
echo "Dropbear : 444"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "AntiDDOS : [on]"  | tee -a log-install.txt
echo "Modify(@aramaiti85)AntiTorrent : [on]"  | tee -a log-install.txt
echo "Timezone : Asia/Kuala_Lumpur"  | tee -a log-install.txt
echo "Menu : type menu to check menu script"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "RADIUS Authentication Settings:"  | tee -a log-install.txt
echo "Radius Server Hostname: 127.0.0.1"  | tee -a log-install.txt
echo "Radius Port: 1812 (UDP)"  | tee -a log-install.txt
echo "Shared Secret: testing123"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "SoftEtherVPN Port: 8888"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "----------------------------------------"
echo "LOG INSTALL  --> /root/log-install.txt"
echo "----------------------------------------"
echo "========================================"  | tee -a log-install.txt
echo "      PLEASE REBOOT TAKE EFFECT !"
echo "========================================"  | tee -a log-install.txt
cat /dev/null > ~/.bash_history && history -c
