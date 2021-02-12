#!/bin/bash
# Thanks for using this script, Enjoy Highspeed OpenVPN Service

#############################
#############################
# Variables (Can be changed depends on your preferred values)
# Script name
MyScriptName='KingKongVPN-Premium Script'

# OpenSSH Ports
SSH_Port1='22'
SSH_Port2='53'
SSH_Port2='80'

# Your SSH Banner
#SSH_Banner='https://raw.githubusercontent.com/xiihaiqal/autoscrip/master/Files/Plugins/issue.net'
#Menu_Banner='https://raw.githubusercontent.com/xiihaiqal/autoscrip/master/Files/Plugins/banner'

# Dropbear Ports
Dropbear_Port1='445'
Dropbear_Port2='442'

# Stunnel Ports
Stunnel_Port1='443' # through Dropbear
Stunnel_Port2='444' # through OpenSSH

# OpenVPN Ports
OpenVPN_TCP_Port='1103'
OpenVPN_UDP_Port='25222'

# Privoxy Ports
Privoxy_Port1='3356'
Privoxy_Port2='8086'

# Squid Ports
Squid_Port1='3128'
Squid_Port2='8080'
Squid_Port3='8888'

# Install DDOS Deflate
cd
apt-get -y install dnsutils dsniff
wget "https://github.com/xiihaiqal/autoscript/raw/master/Files/Others/ddos-deflate-master.zip"
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh
cd
rm -rf ddos-deflate-master.zip

# OpenVPN Config Download Port
OvpnDownload_Port='81' # Before changing this value, please read this document. It contains all unsafe ports for Google Chrome Browser, please read from line #23 to line #89: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc

# Server local time
MyVPS_Time='Asia/Kuala_Lumpur'
#############################


#############################
#############################
## All function used for this script
#############################
## WARNING: Do not modify or edit anything
## if you did'nt know what to do.
## This part is too sensitive.
#############################
#############################

function InstUpdates(){
 export DEBIAN_FRONTEND=noninteractive
 apt-get update
 apt-get upgrade -y
 
 # Removing some firewall tools that may affect other services
 apt-get remove --purge ufw firewalld -y

 
 # Installing some important machine essentials
 apt-get install nano wget curl zip unzip tar gzip p7zip-full bc rc openssl cron net-tools dnsutils dos2unix screen bzip2 ccrypt -y
 
 # Now installing all our wanted services
 apt-get install dropbear stunnel4 privoxy ca-certificates nginx ruby apt-transport-https lsb-release squid -y

 # Installing all required packages to install Webmin
 apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl -y
 apt-get install shared-mime-info jq fail2ban -y

 
 # Installing a text colorizer
 gem install lolcat

 # Trying to remove obsolette packages after installation
 apt-get autoremove -y
 
 # Installing OpenVPN by pulling its repository inside sources.list file 
 rm -rf /etc/apt/sources.list.d/openvpn*
 echo "deb http://build.openvpn.net/debian/openvpn/stable $(lsb_release -sc) main" > /etc/apt/sources.list.d/openvpn.list
 wget -qO - http://build.openvpn.net/debian/openvpn/stable/pubkey.gpg|apt-key add -
 apt-get update
 apt-get install openvpn -y
}

function InstWebmin(){
 # Download the webmin .deb package
 # You may change its webmin version depends on the link you've loaded in this variable(.deb file only, do not load .zip or .tar.gz file):
 WebminFile='http://prdownloads.sourceforge.net/webadmin/webmin_1.960_all.deb'
 wget -qO webmin.deb "$WebminFile"
 
 # Installing .deb package for webmin
 dpkg --install webmin.deb
 
 rm -rf webmin.deb
 
 # Configuring webmin server config to use only http instead of https
 sed -i 's|ssl=1|ssl=0|g' /etc/webmin/miniserv.conf
 
 # Then restart to take effect
 systemctl restart webmin
}

function InstSSH(){
 # Removing some duplicated sshd server configs
 rm -f /etc/ssh/sshd_config*
 
 # Creating a SSH server config using cat eof tricks
 cat <<'MySSHConfig' > /etc/ssh/sshd_config
# My OpenSSH Server config
Port myPORT1
Port myPORT2
AddressFamily inet
ListenAddress 0.0.0.0
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
Banner /etc/issue.net
AcceptEnv LANG LC_*
Subsystem   sftp  /usr/lib/openssh/sftp-server
MySSHConfig

 # Now we'll put our ssh ports inside of sshd_config
 sed -i "s|myPORT1|$SSH_Port1|g" /etc/ssh/sshd_config
 sed -i "s|myPORT2|$SSH_Port2|g" /etc/ssh/sshd_config

 # Download our SSH Banner
 rm -f /etc/issue.net
 wget -qO /etc/issue.net "$SSH_Banner"
 dos2unix -q /etc/issue.net

 # Download our Menu Banner
 rm -f /etc/banner
 wget -qO /etc/banner "$Menu_Banner"
 dos2unix -q /etc/banner

 # My workaround code to remove `BAD Password error` from passwd command, it will fix password-related error on their ssh accounts.
 sed -i '/password\s*requisite\s*pam_cracklib.s.*/d' /etc/pam.d/common-password
 sed -i 's/use_authtok //g' /etc/pam.d/common-password

 # Some command to identify null shells when you tunnel through SSH or using Stunnel, it will fix user/pass authentication error on HTTP Injector, KPN Tunnel, eProxy, SVI, HTTP Proxy Injector etc ssh/ssl tunneling apps.
 sed -i '/\/bin\/false/d' /etc/shells
 sed -i '/\/usr\/sbin\/nologin/d' /etc/shells
 echo '/bin/false' >> /etc/shells
 echo '/usr/sbin/nologin' >> /etc/shells
 
 # Restarting openssh service
 systemctl restart ssh
 
 # Removing some duplicate config file
 rm -rf /etc/default/dropbear*
 
 # creating dropbear config using cat eof tricks
 cat <<'MyDropbear' > /etc/default/dropbear
# My Dropbear Config
NO_START=0
DROPBEAR_PORT=PORT01
DROPBEAR_EXTRA_ARGS="-p PORT02"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
MyDropbear

 # Now changing our desired dropbear ports
 sed -i "s|PORT01|$Dropbear_Port1|g" /etc/default/dropbear
 sed -i "s|PORT02|$Dropbear_Port2|g" /etc/default/dropbear
 
 # Restarting dropbear service
 systemctl restart dropbear
}

function InsStunnel(){
 StunnelDir=$(ls /etc/default | grep stunnel | head -n1)

 # Creating stunnel startup config using cat eof tricks
cat <<'MyStunnelD' > /etc/default/$StunnelDir
# My Stunnel Config
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
BANNER="/etc/banner"
PPP_RESTART=0
# RLIMITS="-n 4096 -d unlimited"
RLIMITS=""
MyStunnelD

 # Removing all stunnel folder contents
 rm -rf /etc/stunnel/*
 
 # Creating stunnel certifcate using openssl
 openssl req -new -x509 -days 9999 -nodes -subj "/C=PH/ST=NCR/L=Manila/O=$MyScriptName/OU=$MyScriptName/CN=$MyScriptName" -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &> /dev/null
##  > /dev/null 2>&1

 # Creating stunnel server config
 cat <<'MyStunnelC' > /etc/stunnel/stunnel.conf
# My Stunnel Config
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
TIMEOUTclose = 0

[dropbear]
accept = Stunnel_Port1
connect = 127.0.0.1:dropbear_port_c

[openssh]
accept = Stunnel_Port2
connect = 127.0.0.1:openssh_port_c

[openvpn]
accept = 990
connect = 127.0.0.1:1103
MyStunnelC

 # setting stunnel ports
 sed -i "s|Stunnel_Port1|$Stunnel_Port1|g" /etc/stunnel/stunnel.conf
 sed -i "s|dropbear_port_c|$(netstat -tlnp | grep -i dropbear | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf
 sed -i "s|Stunnel_Port2|$Stunnel_Port2|g" /etc/stunnel/stunnel.conf
 sed -i "s|openssh_port_c|$(netstat -tlnp | grep -i ssh | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf

 # Restarting stunnel service
 systemctl restart $StunnelDir

}

function InsOpenVPN(){
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
sndbuf 100000
rcvbuf 100000
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
tls-auth /etc/openvpn/tls-auth.key 0
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
sndbuf 100000
rcvbuf 100000
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
tls-auth /etc/openvpn/tls-auth.key 0
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
MIIEmzCCA4OgAwIBAgIJAITInYiGbcQSMA0GCSqGSIb3DQEBCwUAMIGPMQswCQYD
VQQGEwJDTjEQMA4GA1UECBMHQmVpSmluZzEQMA4GA1UEBxMHQmVpSmluZzELMAkG
A1UEChMCT1AxDDAKBgNVBAsTAzIxSzEOMAwGA1UEAxMFT1AgQ0ExEDAOBgNVBCkT
B0Vhc3lSU0ExHzAdBgkqhkiG9w0BCQEWEDIxa2l4Y0BnbWFpbC5jb20wHhcNMTgw
MjA1MDM0OTQyWhcNMjgwMjAzMDM0OTQyWjCBjzELMAkGA1UEBhMCQ04xEDAOBgNV
BAgTB0JlaUppbmcxEDAOBgNVBAcTB0JlaUppbmcxCzAJBgNVBAoTAk9QMQwwCgYD
VQQLEwMyMUsxDjAMBgNVBAMTBU9QIENBMRAwDgYDVQQpEwdFYXN5UlNBMR8wHQYJ
KoZIhvcNAQkBFhAyMWtpeGNAZ21haWwuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEA3ozjciJpPnjRGDO2n+QC9yfPgban3TKNBPZ1XHvIjn05pk8G
TKJ2kqU7Gr1coDni3cBIUuxG9Gq1Y108vyu4YvQF1y1CpcLyMjQNVC3mUeVzBXt5
L3kUtykykz8kSMICorfDBSwYqR6eF6lMboLEH09Qb1iCe1ynhA83eRDdlElOiz8S
wYWoGO7QfgIvcU1oNm8Wb0HfXS1NDUYzt98RcKibaVRvY2pNPaDW9n4BuwIlluU9
aEVI+PgZuFNADRjkHVhgVwJa7YUQiBICNRf6BIrFg7jY9J68J26ItVpvCsWJjvwN
YpfXAXdIYp6cufPW73GriM1VLjJ8e9B0HzPrAQIDAQABo4H3MIH0MB0GA1UdDgQW
BBTgQPEaLkLIW+mQzK4/dCcpP4pGIjCBxAYDVR0jBIG8MIG5gBTgQPEaLkLIW+mQ
zK4/dCcpP4pGIqGBlaSBkjCBjzELMAkGA1UEBhMCQ04xEDAOBgNVBAgTB0JlaUpp
bmcxEDAOBgNVBAcTB0JlaUppbmcxCzAJBgNVBAoTAk9QMQwwCgYDVQQLEwMyMUsx
DjAMBgNVBAMTBU9QIENBMRAwDgYDVQQpEwdFYXN5UlNBMR8wHQYJKoZIhvcNAQkB
FhAyMWtpeGNAZ21haWwuY29tggkAhMidiIZtxBIwDAYDVR0TBAUwAwEB/zANBgkq
hkiG9w0BAQsFAAOCAQEAws6jLkC3hebT4bphTTm1CCTJ20nzlsg2+mURh5ZqGL+I
YBQBCyCrja9r6jpNIvPBaHJsu4WniJphIZbBKM0HjapjzIZ+9bq7HsXsEFqaLVsd
nW58IJhcv3I2q5FGZpwDODPzj75ZIJIYXHPM0OdXjlWU+r2z08xWwKEWxKU3vt7H
YWz13HDoHSea8oxfeXeGlWbyAWEkbM64nQkLQ0j/4NrtHSx6vLUBmCbOb2PbjQEb
dFizLpHrFqqBYDVEDL4MzFXa5SItgJ978FxiFiRnsOzGP1us5aoT8q6NvtFQ+aaj
pce0Av3y2knjUyKEA5UF4gXC3dpaE1rd0V0FY2qSUA==
-----END CERTIFICATE-----
EOF7
 cat <<'EOF9'> /etc/openvpn/xbarts.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=BeiJing, L=BeiJing, O=OP, OU=21K, CN=OP CA/name=EasyRSA/emailAddress=21kixc@gmail.com
        Validity
            Not Before: Feb  5 03:51:13 2018 GMT
            Not After : Feb  3 03:51:13 2028 GMT
        Subject: C=CN, ST=BeiJing, L=BeiJing, O=OP, OU=21K, CN=server/name=EasyRSA/emailAddress=21kixc@gmail.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:ac:94:bc:c6:6c:64:08:72:b8:36:90:a5:2b:31:
                    42:a0:ac:44:69:a3:7b:67:8e:5f:8b:bb:7d:31:54:
                    d5:30:e2:b6:2c:c1:a9:db:55:4f:ca:18:6d:87:56:
                    bb:64:b9:43:84:aa:38:bb:c4:7b:07:2f:04:f6:20:
                    59:47:db:1b:3f:b5:06:dc:b2:72:49:fd:4f:6f:74:
                    18:94:ce:94:ed:28:b1:54:51:1b:18:f1:62:5b:60:
                    03:44:b4:b9:e1:a0:81:93:27:b5:72:b5:fc:d6:d0:
                    d2:3d:2f:3c:43:2e:58:33:09:b5:ef:b0:e9:7f:6c:
                    81:e3:da:4c:8a:5f:bc:64:f6:55:37:14:ec:01:15:
                    8e:46:45:a3:bb:ce:bd:b1:2c:36:d7:49:c1:ad:7a:
                    c3:e4:4c:46:be:54:8c:3b:24:9a:58:cd:a6:c0:87:
                    13:ae:61:eb:d2:cf:6d:8c:34:54:54:82:03:70:6d:
                    c5:ad:c9:f9:d3:22:3b:7a:8f:81:8d:06:47:1a:70:
                    ec:1b:4f:c6:e1:d4:50:2b:58:8e:96:ec:b5:9c:23:
                    f2:ea:e9:42:ea:00:0c:d2:bc:d4:53:d7:64:92:ec:
                    19:9a:09:8a:10:4e:1d:77:e5:dd:7a:a6:35:6f:b4:
                    30:00:7d:35:e9:ef:79:a2:8c:94:cc:84:56:30:7e:
                    a2:8f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier: 
                23:14:06:F1:AE:B9:B9:0D:CE:68:FF:69:3E:3B:A1:C8:8F:9B:F8:E8
            X509v3 Authority Key Identifier: 
                keyid:E0:40:F1:1A:2E:42:C8:5B:E9:90:CC:AE:3F:74:27:29:3F:8A:46:22
                DirName:/C=CN/ST=BeiJing/L=BeiJing/O=OP/OU=21K/CN=OP CA/name=EasyRSA/emailAddress=21kixc@gmail.com
                serial:84:C8:9D:88:86:6D:C4:12

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
    Signature Algorithm: sha256WithRSAEncryption
         1f:67:31:0d:dd:9e:3d:12:16:1c:09:09:4b:90:22:87:49:b4:
         09:27:08:6d:02:34:04:ca:fb:e2:fa:1d:0c:16:d1:1b:5e:46:
         5f:e6:8e:10:6b:68:95:ef:63:cd:0e:93:49:63:41:36:8c:68:
         44:e5:19:3c:8b:6b:f1:77:21:e6:31:16:ad:63:87:f1:07:99:
         45:7c:ef:b4:dd:b6:14:18:a9:78:99:21:b4:e3:f0:29:25:3b:
         57:86:96:82:cb:ff:85:34:2f:9e:c9:f1:26:12:81:ae:4c:a5:
         9d:f4:cd:f1:7b:1b:b7:33:fd:1f:2d:95:fa:26:b6:2f:68:cd:
         46:12:69:d2:69:2f:06:80:f8:16:1c:17:2e:c6:ca:f9:17:8c:
         83:af:82:4f:71:2f:db:fe:19:5a:f6:1d:2b:72:46:f1:cf:e8:
         a6:1a:18:7d:77:80:97:c7:c3:2e:d2:11:04:31:5f:7c:2b:26:
         dd:b4:68:ed:0d:17:23:18:5c:ab:a4:f1:55:69:fa:0e:88:1f:
         3c:21:47:d4:32:da:db:d8:c4:e1:f8:57:4b:ad:c8:fd:02:4d:
         b2:d3:40:dd:db:d7:7d:67:cb:d8:0b:0c:cd:ec:49:0a:bd:83:
         ec:87:c1:50:82:10:dc:ee:af:25:7c:7d:9f:90:86:85:48:59:
         16:24:13:fb
-----BEGIN CERTIFICATE-----
MIIE/jCCA+agAwIBAgIBATANBgkqhkiG9w0BAQsFADCBjzELMAkGA1UEBhMCQ04x
EDAOBgNVBAgTB0JlaUppbmcxEDAOBgNVBAcTB0JlaUppbmcxCzAJBgNVBAoTAk9Q
MQwwCgYDVQQLEwMyMUsxDjAMBgNVBAMTBU9QIENBMRAwDgYDVQQpEwdFYXN5UlNB
MR8wHQYJKoZIhvcNAQkBFhAyMWtpeGNAZ21haWwuY29tMB4XDTE4MDIwNTAzNTEx
M1oXDTI4MDIwMzAzNTExM1owgZAxCzAJBgNVBAYTAkNOMRAwDgYDVQQIEwdCZWlK
aW5nMRAwDgYDVQQHEwdCZWlKaW5nMQswCQYDVQQKEwJPUDEMMAoGA1UECxMDMjFL
MQ8wDQYDVQQDEwZzZXJ2ZXIxEDAOBgNVBCkTB0Vhc3lSU0ExHzAdBgkqhkiG9w0B
CQEWEDIxa2l4Y0BnbWFpbC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQCslLzGbGQIcrg2kKUrMUKgrERpo3tnjl+Lu30xVNUw4rYswanbVU/KGG2H
VrtkuUOEqji7xHsHLwT2IFlH2xs/tQbcsnJJ/U9vdBiUzpTtKLFUURsY8WJbYANE
tLnhoIGTJ7VytfzW0NI9LzxDLlgzCbXvsOl/bIHj2kyKX7xk9lU3FOwBFY5GRaO7
zr2xLDbXScGtesPkTEa+VIw7JJpYzabAhxOuYevSz22MNFRUggNwbcWtyfnTIjt6
j4GNBkcacOwbT8bh1FArWI6W7LWcI/Lq6ULqAAzSvNRT12SS7BmaCYoQTh135d16
pjVvtDAAfTXp73mijJTMhFYwfqKPAgMBAAGjggFgMIIBXDAJBgNVHRMEAjAAMBEG
CWCGSAGG+EIBAQQEAwIGQDA0BglghkgBhvhCAQ0EJxYlRWFzeS1SU0EgR2VuZXJh
dGVkIFNlcnZlciBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUIxQG8a65uQ3OaP9pPjuh
yI+b+OgwgcQGA1UdIwSBvDCBuYAU4EDxGi5CyFvpkMyuP3QnKT+KRiKhgZWkgZIw
gY8xCzAJBgNVBAYTAkNOMRAwDgYDVQQIEwdCZWlKaW5nMRAwDgYDVQQHEwdCZWlK
aW5nMQswCQYDVQQKEwJPUDEMMAoGA1UECxMDMjFLMQ4wDAYDVQQDEwVPUCBDQTEQ
MA4GA1UEKRMHRWFzeVJTQTEfMB0GCSqGSIb3DQEJARYQMjFraXhjQGdtYWlsLmNv
bYIJAITInYiGbcQSMBMGA1UdJQQMMAoGCCsGAQUFBwMBMAsGA1UdDwQEAwIFoDAN
BgkqhkiG9w0BAQsFAAOCAQEAH2cxDd2ePRIWHAkJS5Aih0m0CScIbQI0BMr74vod
DBbRG15GX+aOEGtole9jzQ6TSWNBNoxoROUZPItr8Xch5jEWrWOH8QeZRXzvtN22
FBipeJkhtOPwKSU7V4aWgsv/hTQvnsnxJhKBrkylnfTN8XsbtzP9Hy2V+ia2L2jN
RhJp0mkvBoD4FhwXLsbK+ReMg6+CT3Ev2/4ZWvYdK3JG8c/ophoYfXeAl8fDLtIR
BDFffCsm3bRo7Q0XIxhcq6TxVWn6DogfPCFH1DLa29jE4fhXS63I/QJNstNA3dvX
fWfL2AsMzexJCr2D7IfBUIIQ3O6vJXx9n5CGhUhZFiQT+w==
-----END CERTIFICATE-----
EOF9
 cat <<'EOF10'> /etc/openvpn/xbarts.key
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCslLzGbGQIcrg2
kKUrMUKgrERpo3tnjl+Lu30xVNUw4rYswanbVU/KGG2HVrtkuUOEqji7xHsHLwT2
IFlH2xs/tQbcsnJJ/U9vdBiUzpTtKLFUURsY8WJbYANEtLnhoIGTJ7VytfzW0NI9
LzxDLlgzCbXvsOl/bIHj2kyKX7xk9lU3FOwBFY5GRaO7zr2xLDbXScGtesPkTEa+
VIw7JJpYzabAhxOuYevSz22MNFRUggNwbcWtyfnTIjt6j4GNBkcacOwbT8bh1FAr
WI6W7LWcI/Lq6ULqAAzSvNRT12SS7BmaCYoQTh135d16pjVvtDAAfTXp73mijJTM
hFYwfqKPAgMBAAECggEAGJGsNktkClfapdn9yaJfq+QacTeW7+0y6P+uGQHMwALm
kISZm+IPU+QaY7QTRYmidRaOsRyNrz4gZLHCRBqLTIyHB5BX+PSZBHLwtO6cAQ9T
/370bp6etAd9L6DS/a4OBFcY29XQwvxDkfZRi/bjE5EEV7VF6KAX9co0L1blyTGU
mTMe76Y2H7/h1xNB5ke2unJLJkJWjmTtyzEQYiRZ8810z+IhiaGvDBZHhxBcndru
pmOy8zxwMJcXdLCmegfFi1kx6TOoxPKYWLJI81l5RXo/mLOk/SfG6sK+ZW0MBJRT
QPWnSGo/VpxFeO/wXLUN4Jb+m6z0XgLtjXg180ht0QKBgQDZ4ETLc7IFe/bQAoez
YmVuzS5UDlMUSNFEueXZj5V8QnAkbuJry4bUYKfjk3YWUgdIgWbhUze7POHBGDlP
rTzLVynsA9cQ/Dyl6EYjY7FKcRs4FBnRwuyu6Ki2zWqW1VcmpXgW1QYLa+zNtIZS
wl6AR9HqE2+F9EkmSYLF6hyuMwKBgQDKx3uO8XPWxWx4xEcRgl8JZK48DYa1yc+D
TblllxHi3wLH67YRT5aIK0WtRoGqxPmXZGYQ/3AScBPOoDwYqsTwurI/9RNansOV
+h+ZTn6EDljD+joFaFujNX0QE10fyqIRtLi8NzvI7WrRnstI5Qz1bLIfeqXs54Tp
Xq8nlYEmNQKBgEJ+KGCzGXSFBakr7IA5ml07b1Ul3gMFyiAgX96K7IM0v4bO9HkT
bz2nlfVlTpe3RxPAskY4IH0bMoa8vtjrNO+V1Wx7K4q6gEPd5HHuffALHtR5hfu3
coZa6QqJHGuWBnf77e+B6ctYj7ejzY66VR7vTEgU0GdgS2bM7oU6UrBzAoGATCib
yVX58cH4OWtOXc8fLoH3xmo2G/SN0XzRkswoVZL4kml+2gWQPdgytR9z99U/AJMe
mme1idc6OTKJH6KTkO4toEPFXxWd06g7UfLfJW3V/NTwEbPeJvAh5nW/Vf9e21OK
xnXgKFiy88O2CcytD0ghph0EUHOrwZJkKnPGK7kCgYEAqghDDtWqkCd1shv3UuY2
7R0jhaui4MsNz+hVI6cD5m0IK+aEBmsEZ+6ifmGVi8HIvLHCtoYcIahCln31h+NR
uS1gtGTLcXL++K7xni9xSZZ8E3tj1d4hHqBGbOkJ6gOVYh8G9/ul6z0cq1NVPVfi
Q+3SubL3Oob8tObE5UdNK/Q=
-----END PRIVATE KEY-----
EOF10
 cat <<'EOF13'> /etc/openvpn/tls-auth.key
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
dedf17ed486c4bb736e5eebaf06e9850
1d26650b0f85099f9daed774880654f8
21fb0cc4c4ee4e20defbe15a488f2d5c
33e3dc7d2a5adaa6f7fe66801332f1a8
b676a12e625e25d354719fddd5df2799
04060ca5c08e10ab3f12b54c60b15e64
a5c500a2a71dcd31b2e88b2be87d43cc
4b73cbfa734eba89858fc91b85dd9feb
6e93a4422116b8fcc0b563c0336a0e1a
3d537dc7a54685fc3faafcf429ad4261
535021c3a96c34e1004cd59579289690
d3be5e4d3a546486a19a8bab192bc096
efa13b6dbcbf9c63e5c5488c36ffa59d
945db353e023ffcbd7467a4f8685a060
40a13da4fb822e1b16e998c5941563fc
82011b788e913235dac30d91bc29759b
-----END OpenVPN Static key V1-----
EOF13
cat <<'EOF14'> /etc/openvpn/dh.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAxoNLELO1dQDFW0ZRRbPG9Cv1ifPSqGQB0tIusmTrn22nMqND06fK
NfJNQhnEahwYlbA2DEXxjZ7gpXWA6mrKUIVTFfnFohmHhLgkb9QUc0m5LwVgcd/w
25s+3JEcV3MJ70Cf64wG+KVHMJeISagDlKlE+2f7MJkkSV1vgvfQOpnVp+DF38tL
L57p4njl0n61NNUnbvH0YEPbvKPk0CJ3EGGQE/uhwKIU+pJt/o9S0wppq9sUrOuD
1eelmMZPuWH3aSVIUqiucEsczGn5GfqIc2KNHAMfJ5JhLOjjJvb1cewD2DpIiI2I
bVexIf9WpjXw+LZrjSifNgQ1Eqfdd3tDiwIBAg==
-----END DH PARAMETERS-----
EOF14

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
 # Script Updated by KingKongVPN
NUovpn

 # setting openvpn server port
 sed -i "s|OVPNTCP|$OpenVPN_TCP_Port|g" /etc/openvpn/server_tcp.conf
 sed -i "s|OVPNUDP|$OpenVPN_UDP_Port|g" /etc/openvpn/server_udp.conf
 
 # Getting some OpenVPN plugins for unix authentication
 cd
 wget -qO /etc/openvpn/b.zip 'https://raw.githubusercontent.com/GakodArmy/teli/main/openvpn_plugin64'
 unzip -qq /etc/openvpn/b.zip -d /etc/openvpn
 rm -f /etc/openvpn/b.zip
 
 # Some workaround for OpenVZ machines for "Startup error" openvpn service
 if [[ "$(hostnamectl | grep -i Virtualization | awk '{print $2}' | head -n1)" == 'openvz' ]]; then
 sed -i 's|LimitNPROC|#LimitNPROC|g' /lib/systemd/system/openvpn*
 systemctl daemon-reload
fi

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

}
function InsProxy(){

 # Removing Duplicate privoxy config
 rm -rf /etc/privoxy/config*
 
 # Creating Privoxy server config using cat eof tricks
 cat <<'privoxy' > /etc/privoxy/config
# My Privoxy Server Config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address 0.0.0.0:Privoxy_Port1
listen-address 0.0.0.0:Privoxy_Port2
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 1
forwarded-connect-retries 1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 0.0.0.0/0 IP-ADDRESS
privoxy

 # Setting machine's IP Address inside of our privoxy config(security that only allows this machine to use this proxy server)
 sed -i "s|IP-ADDRESS|$IPADDR|g" /etc/privoxy/config
 
 # Setting privoxy ports
 sed -i "s|Privoxy_Port1|$Privoxy_Port1|g" /etc/privoxy/config
 sed -i "s|Privoxy_Port2|$Privoxy_Port2|g" /etc/privoxy/config

 # Removing Duplicate Squid config
 rm -rf /etc/squid/squid.con*
 
 # Creating Squid server config using cat eof tricks
 cat <<'mySquid' > /etc/squid/squid.conf
# My Squid Proxy Server Config
acl VPN dst IP-ADDRESS/32
http_access allow VPN
http_access deny all 
http_port 0.0.0.0:Squid_Port1
http_port 0.0.0.0:Squid_Port2
http_port 0.0.0.0:Squid_Port3
### Allow Headers
request_header_access Allow allow all 
request_header_access Authorization allow all 
request_header_access WWW-Authenticate allow all 
request_header_access Proxy-Authorization allow all 
request_header_access Proxy-Authenticate allow all 
request_header_access Cache-Control allow all 
request_header_access Content-Encoding allow all 
request_header_access Content-Length allow all 
request_header_access Content-Type allow all 
request_header_access Date allow all 
request_header_access Expires allow all 
request_header_access Host allow all 
request_header_access If-Modified-Since allow all 
request_header_access Last-Modified allow all 
request_header_access Location allow all 
request_header_access Pragma allow all 
request_header_access Accept allow all 
request_header_access Accept-Charset allow all 
request_header_access Accept-Encoding allow all 
request_header_access Accept-Language allow all 
request_header_access Content-Language allow all 
request_header_access Mime-Version allow all 
request_header_access Retry-After allow all 
request_header_access Title allow all 
request_header_access Connection allow all 
request_header_access Proxy-Connection allow all 
request_header_access User-Agent allow all 
request_header_access Cookie allow all 
request_header_access All allow all
### HTTP Anonymizer Paranoid
reply_header_access Allow allow all 
reply_header_access Authorization allow all 
reply_header_access WWW-Authenticate allow all 
reply_header_access Proxy-Authorization allow all 
reply_header_access Proxy-Authenticate allow all 
reply_header_access Cache-Control allow all 
reply_header_access Content-Encoding allow all 
reply_header_access Content-Length allow all 
reply_header_access Content-Type allow all 
reply_header_access Date allow all 
reply_header_access Expires allow all 
reply_header_access Host allow all 
reply_header_access If-Modified-Since allow all 
reply_header_access Last-Modified allow all 
reply_header_access Location allow all 
reply_header_access Pragma allow all 
reply_header_access Accept allow all 
reply_header_access Accept-Charset allow all 
reply_header_access Accept-Encoding allow all 
reply_header_access Accept-Language allow all 
reply_header_access Content-Language allow all 
reply_header_access Mime-Version allow all 
reply_header_access Retry-After allow all 
reply_header_access Title allow all 
reply_header_access Connection allow all 
reply_header_access Proxy-Connection allow all 
reply_header_access User-Agent allow all 
reply_header_access Cookie allow all 
reply_header_access All deny all
### CoreDump
coredump_dir /var/spool/squid
dns_nameservers 8.8.8.8 8.8.4.4
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname JohnFordTV
mySquid

 # Setting machine's IP Address inside of our Squid config(security that only allows this machine to use this proxy server)
 sed -i "s|IP-ADDRESS|$IPADDR|g" /etc/squid/squid.conf
 
 # Setting squid ports
 sed -i "s|Squid_Port1|$Squid_Port1|g" /etc/squid/squid.conf
 sed -i "s|Squid_Port2|$Squid_Port2|g" /etc/squid/squid.conf
 sed -i "s|Squid_Port3|$Squid_Port3|g" /etc/squid/squid.conf

 # Starting Proxy server
 echo -e "Restarting proxy server..."
 systemctl restart squid
}

function OvpnConfigs(){
 # Creating nginx config for our ovpn config downloads webserver
 cat <<'myNginxC' > /etc/nginx/conf.d/johnfordtv-ovpn-config.conf
# My OpenVPN Config Download Directory
server {
 listen 0.0.0.0:myNginx;
 server_name localhost;
 root /var/www/openvpn;
 index index.html;
}
myNginxC

 # Setting our nginx config port for .ovpn download site
 sed -i "s|myNginx|$OvpnDownload_Port|g" /etc/nginx/conf.d/johnfordtv-ovpn-config.conf

 # Removing Default nginx page(port 80)
 rm -rf /etc/nginx/sites-*

 # Creating our root directory for all of our .ovpn configs
 rm -rf /var/www/openvpn
 mkdir -p /var/www/openvpn

 # Now creating all of our OpenVPN Configs 

cat <<EOF15> /var/www/openvpn/tcp.ovpn
# Thanks for using this script, Enjoy Highspeed OpenVPN Service
client
dev tun
remote $IPADDR $OpenVPN_TCP_Port tcp
http-proxy $IPADDR $Squid_Port2
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
sndbuf 100000
rcvbuf 100000
remote-cert-tls server
key-direction 1
<auth-user-pass>
sam
sam
</auth-user-pass>
EOF15
echo '<ca>' >> /var/www/openvpn/tcp.ovpn
cat /etc/openvpn/ca.crt >> /var/www/openvpn/tcp.ovpn
echo '</ca>' >> /var/www/openvpn/tcp.ovpn
echo '<cert>' >> /var/www/openvpn/tcp.ovpn
cat /etc/openvpn/server.crt >> /var/www/openvpn/tcp.ovpn
echo '</cert>' >> /var/www/openvpn/tcp.ovpn
echo '<key>' >> /var/www/openvpn/tcp.ovpn
cat /etc/openvpn/server.key >> /var/www/openvpn/tcp.ovpn
echo '</key>' >> /var/www/openvpn/tcp.ovpn
echo '<tls-auth>' >> /var/www/openvpn/tcp.ovpn
cat /etc/openvpn/tls-auth.key >> /var/www/openvpn/tcp.ovpn
echo '</tls-auth>' >> /var/www/openvpn/tcp.ovpn

cat <<EOF16> /var/www/openvpn/udp.ovpn
# Credits to GakodX
client
dev tun
proto udp
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
sndbuf 100000
rcvbuf 100000
remote-cert-tls server
key-direction 1
<auth-user-pass>
sam
sam
</auth-user-pass>
EOF16
echo '<ca>' >> /var/www/openvpn/udp.ovpn
cat /etc/openvpn/ca.crt >> /var/www/openvpn/udp.ovpn
echo '</ca>' >> /var/www/openvpn/udp.ovpn
echo '<cert>' >> /var/www/openvpn/udp.ovpn
cat /etc/openvpn/server.crt >> /var/www/openvpn/udp.ovpn
echo '</cert>' >> /var/www/openvpn/udp.ovpn
echo '<key>' >> /var/www/openvpn/udp.ovpn
cat /etc/openvpn/server.key >> /var/www/openvpn/udp.ovpn
echo '</key>' >> /var/www/openvpn/udp.ovpn
echo '<tls-auth>' >> /var/www/openvpn/udp.ovpn
cat /etc/openvpn/tls-auth.key >> /var/www/openvpn/udp.ovpn
echo '</tls-auth>' >> /var/www/openvpn/udp.ovpn


cat <<EOF17> /var/www/openvpn/ssl.ovpn
client
proto tcp-client
dev tun
remote 127.0.0.1 $OpenVPN_TCP_Port
route $IPADDR 255.255.255.255 net_gateway 
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
sndbuf 100000
rcvbuf 100000
remote-cert-tls server
key-direction 1
<auth-user-pass>
sam
sam
</auth-user-pass>
EOF17
echo '<ca>' >> /var/www/openvpn/ssl.ovpn
cat /etc/openvpn/ca.crt >> /var/www/openvpn/ssl.ovpn
echo '</ca>' >> /var/www/openvpn/ssl.ovpn
echo '<cert>' >> /var/www/openvpn/ssl.ovpn
cat /etc/openvpn/server.crt >> /var/www/openvpn/ssl.ovpn
echo '</cert>' >> /var/www/openvpn/ssl.ovpn
echo '<key>' >> /var/www/openvpn/ssl.ovpn
cat /etc/openvpn/server.key >> /var/www/openvpn/ssl.ovpn
echo '</key>' >> /var/www/openvpn/ssl.ovpn
echo '<tls-auth>' >> /var/www/openvpn/ssl.ovpn
cat /etc/openvpn/tls-auth.key >> /var/www/openvpn/ssl.ovpn
echo '</tls-auth>' >> /var/www/openvpn/ssl.ovpn


 # Creating OVPN download site index.html
cat <<'mySiteOvpn' > /var/www/openvpn/index.html
<!DOCTYPE html>
<html lang="en">

<!-- Simple OVPN Download site by KingKongVPN -->

<head><meta charset="utf-8" /><title>KingKongVPN OVPN Config Download</title><meta name="description" content="MyScriptName Server" /><meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport" /><meta name="theme-color" content="#000000" /><link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css"><link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.8.3/css/mdb.min.css" rel="stylesheet"></head><body><div class="container justify-content-center" style="margin-top:9em;margin-bottom:5em;"><div class="col-md"><div class="view"><img src="https://openvpn.net/wp-content/uploads/openvpn.jpg" class="card-img-top"><div class="mask rgba-white-slight"></div></div><div class="card"><div class="card-body"><h5 class="card-title">Config List</h5><br /><ul class="list-group"><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>For Sun <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> UDP Server For TU/CTC/CTU Promos</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/sun-tuudp.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>For Sun <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> TCP+Proxy Server For TU/CTC/CTU Promos</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/sun-tuudp.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>For Globe/TM <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> For EasySURF/GoSURF/GoSAKTO Promos with WNP,SNS,FB and IG freebies</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/gtmwnp.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>For Sun <span class="badge light-blue darken-4">Modem</span><br /><small> Without Promo/Noload (Reconnecting Server, Use Low-latency VPS for fast reconnectivity)</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/sun-noload.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li></ul></div></div></div></div></body></html>
mySiteOvpn
 
 # Setting template's correct name,IP address and nginx Port
 sed -i "s|NGINXPORT|$OvpnDownload_Port|g" /var/www/openvpn/index.html
 sed -i "s|IP-ADDRESS|$IPADDR|g" /var/www/openvpn/index.html

 # Restarting nginx service
 systemctl restart nginx
 
 # Creating all .ovpn config archives
 cd /var/www/openvpn
 zip -qq -r configs.zip *.ovpn
 cd
}

function ip_address(){
  local IP="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipinfo.io/ip )"
  [ ! -z "${IP}" ] && echo "${IP}" || echo
} 
IPADDR="$(ip_address)"

function ConfStartup(){
 # Daily reboot time of our machine
 # For cron commands, visit https://crontab.guru
 echo -e "0 4\t* * *\troot\treboot" > /etc/cron.d/b_reboot_job

 # Creating directory for startup script
 rm -rf /etc/KingKongVPN
 mkdir -p /etc/KingKongVPN
 chmod -R 755 /etc/KingKongVPN
 
 # Creating startup script using cat eof tricks
 cat <<'EOFSH' > /etc/johnfordtv/startup.sh
#!/bin/bash
# Setting server local time
ln -fs /usr/share/zoneinfo/MyVPS_Time /etc/localtime

# Prevent DOS-like UI when installing using APT (Disabling APT interactive dialog)
export DEBIAN_FRONTEND=noninteractive

# Allowing ALL TCP ports for our machine (Simple workaround for policy-based VPS)
iptables -A INPUT -s $(wget -4qO- http://ipinfo.io/ip) -p tcp -m multiport --dport 1:65535 -j ACCEPT

# Allowing OpenVPN to Forward traffic
/bin/bash /etc/openvpn/openvpn.bash

# Deleting Expired SSH Accounts
/usr/local/sbin/delete_expired &> /dev/null
exit 0
EOFSH
 cat <<'FordServ' > /etc/systemd/system/KingKongVPN.service
 
 # Setting server local time every time this machine reboots
 sed -i "s|MyVPS_Time|$MyVPS_Time|g" /etc/KingKongVPN/startup.sh

 # 
 rm -rf /etc/sysctl.d/99*

 # Setting our startup script to run every machine boots 
 cat <<'FordServ' > /etc/systemd/system/KingKongVPN.service
[Unit]
Description=KingKongVPN Startup Script
Before=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/KingKongVPN/startup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
FordServ
 chmod +x /etc/systemd/system/KingKongVPN.service
 systemctl daemon-reload
 systemctl start KingKongVPN
 systemctl enable KingKongVPN &> /dev/null
 systemctl enable fail2ban &> /dev/null
 systemctl start fail2ban &> /dev/null

 # Rebooting cron service
 systemctl restart cron
 systemctl enable cron
 
}
 #Create Admin
 useradd -m admin
 echo "admin:itangsagli" | chpasswd

function ConfMenu(){
echo -e " Creating Menu scripts.."

cd /usr/bin
wget https://github.com/xiihaiqal/autoscript/raw/master/Files/Menu/AutoScript_Menu.tar.gz
tar -xzvf AutoScript_Menu.tar.gz
rm AutoScript_Menu.tar.gz
 sed -i -e 's/\r$//' accounts
 sed -i -e 's/\r$//' bench-network
 sed -i -e 's/\r$//' clearcache
 sed -i -e 's/\r$//' connections
 sed -i -e 's/\r$//' create
 sed -i -e 's/\r$//' create_random
 sed -i -e 's/\r$//' create_trial
 sed -i -e 's/\r$//' delete_expired
 sed -i -e 's/\r$//' diagnose
 sed -i -e 's/\r$//' edit_dropbear
 sed -i -e 's/\r$//' edit_openssh
 sed -i -e 's/\r$//' edit_openvpn
 sed -i -e 's/\r$//' edit_ports
 sed -i -e 's/\r$//' edit_squid3
 sed -i -e 's/\r$//' edit_stunnel4
 sed -i -e 's/\r$//' locked_list
 sed -i -e 's/\r$//' menu
 sed -i -e 's/\r$//' options
 sed -i -e 's/\r$//' ram
 sed -i -e 's/\r$//' reboot_sys
 sed -i -e 's/\r$//' reboot_sys_auto
 sed -i -e 's/\r$//' restart_services
 sed -i -e 's/\r$//' server
 sed -i -e 's/\r$//' set_multilogin_autokill
 sed -i -e 's/\r$//' set_multilogin_autokill_lib
 sed -i -e 's/\r$//' show_ports
 sed -i -e 's/\r$//' speedtest
 sed -i -e 's/\r$//' user_delete
 sed -i -e 's/\r$//' user_details
 sed -i -e 's/\r$//' user_details_lib
 sed -i -e 's/\r$//' user_extend
 sed -i -e 's/\r$//' user_list
 sed -i -e 's/\r$//' user_lock
 sed -i -e 's/\r$//' user_unlock
cd

# Set Permissions
cd /usr/bin
 chmod +x create
 chmod +x accounts
 chmod +x menu
 chmod +x create
 chmod +x create_random
 chmod +x create_trial
 chmod +x user_list
 chmod +x user_details
 chmod +x user_details_lib
 chmod +x user_extend
 chmod +x user_delete
 chmod +x user_lock
 chmod +x user_unlock
 chmod +x connections
 chmod +x delete_expired
 chmod +x locked_list
 chmod +x options
 chmod +x set_multilogin_autokill
 chmod +x set_multilogin_autokill_lib
 chmod +x restart_services
 chmod +x edit_ports
 chmod +x show_ports
 chmod +x edit_openssh
 chmod +x edit_dropbear
 chmod +x edit_stunnel4
 chmod +x edit_openvpn
 chmod +x edit_squid3
 chmod +x reboot_sys
 chmod +x reboot_sys_auto
 chmod +x clearcache
 chmod +x server
 chmod +x ram
 chmod +x diagnose
 chmod +x bench-network
 chmod +x speedtest
cd ~
}

function ScriptMessage(){
 echo -e " [\e[1;32m$MyScriptName VPS Installer\e[0m]"
 echo -e ""
 echo -e " t.me/sigula"
 echo -e " [PAYPAL] huhu86977@gmail.com"
 echo -e ""
}

function InstBadVPN(){
 # Pull BadVPN Binary 64bit or 32bit
if [ "$(getconf LONG_BIT)" == "64" ]; then
 wget -O /usr/bin/badvpn-udpgw "https://github.com/ara-rangers/vps/raw/master/badvpn-udpgw64"
else
 wget -O /usr/bin/badvpn-udpgw "https://github.com/ara-rangers/vps/raw/master/badvpn-udpgw"
fi
 # Set BadVPN to Start on Boot via .profile
 sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /root/.profile
 # Change Permission to make it Executable
 chmod +x /usr/bin/badvpn-udpgw
 # Start BadVPN via Screen
 screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
}

#############################################
#############################################
########## Installation Process##############
#############################################
## WARNING: Do not modify or edit anything
## if you did'nt know what to do.
## This part is too sensitive.
#############################################
#############################################

 # First thing to do is check if this machine is Debian
 source /etc/os-release
if [[ "$ID" != 'debian' ]]; then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script is for Debian only, exiting..." 
 exit 1
fi

 # Now check if our machine is in root user, if not, this script exits
 # If you're on sudo user, run `sudo su -` first before running this script
 if [[ $EUID -ne 0 ]];then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script must be run as root, exiting..."
 exit 1
fi

 # (For OpenVPN) Checking it this machine have TUN Module, this is the tunneling interface of OpenVPN server
 if [[ ! -e /dev/net/tun ]]; then
 echo -e "[\e[1;31mError\e[0m] You cant use this script without TUN Module installed/embedded in your machine, file a support ticket to your machine admin about this matter"
 echo -e "[\e[1;31m-\e[0m] Script is now exiting..."
 exit 1
fi

 # Begin Installation by Updating and Upgrading machine and then Installing all our wanted packages/services to be install.
 ScriptMessage
 InstUpdates
 
 # Configure OpenSSH and Dropbear
 echo -e "Configuring ssh..."
 InstSSH
 
 # Configure Stunnel
 echo -e "Configuring stunnel..."
 InsStunnel
 
 # Configure BadVPN UDPGW
 echo -e "Configuring BadVPN UDPGW..."
 InstBadVPN
 
 # Configure Webmin
 echo -e "Configuring webmin..."
 InstWebmin
 
 # Configure Squid
 echo -e "Configuring proxy..."
 InsProxy
 
 # Configure OpenVPN
 echo -e "Configuring OpenVPN..."
 InsOpenVPN
 
 # Configuring Nginx OVPN config download site
 OvpnConfigs

 # Some assistance and startup scripts
 ConfStartup

 ## DNS maker plugin for SUN users(for vps script usage only)
 wget -qO dnsmaker "https://raw.githubusercontent.com/Bonveio/BonvScripts/master/DNSMaster/debian"
 chmod +x dnsmaker
 ./dnsmaker
 rm -rf dnsmaker
 sed -i "s|http-proxy $IPADDR|http-proxy $(cat /tmp/abonv_mydns)|g" /var/www/openvpn/suntu-dns.ovpn
 sed -i "s|remote $IPADDR|remote $(cat /tmp/abonv_mydns)|g" /var/www/openvpn/sun-tuudp.ovpn
 curl -4sSL "$(cat /tmp/abonv_mydns_domain)" &> /dev/null
 mv /tmp/abonv_mydns /etc/bonveio/my_domain_name
 mv /tmp/abonv_mydns_id /etc/bonveio/my_domain_id
 rm -rf /tmp/abonv*

 # VPS Menu script v1.0
 ConfMenu
 
 # Setting server local time
 ln -fs /usr/share/zoneinfo/$MyVPS_Time /etc/localtime
 
 clear
 cd ~
 
  # Running screenfetch
 wget -O /usr/bin/screenfetch "https://raw.githubusercontent.com/xiihaiqal/autoscrip/master/Files/Plugins/screenfetch"
 chmod +x /usr/bin/screenfetch
 echo "/bin/bash /etc/openvpn/openvpn.bash" >> .profile
 echo "clear" >> .profile
 echo "screenfetch" >> .profile

# grep ports 
opensshport="$(netstat -ntlp | grep -i ssh | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
dropbearport="$(netstat -nlpt | grep -i dropbear | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
stunnel4port="$(netstat -nlpt | grep -i stunnel | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
openvpnport="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
squidport="$(cat /etc/squid/squid.conf | grep -i http_port | awk '{print $2}')"
nginxport="$(netstat -nlpt | grep -i nginx| grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
 
 # Showing script's banner message
 ScriptMessage
 
 # Showing additional information from installating this script
echo -e ""
echo -e "\e[94m[][][]======================================[][][]"
echo -e "\e[0m                                                   "
echo -e "\e[94m           AutoScriptVPS by  KingKongVPN           "
echo -e "\e[94m                                                  "
echo -e "\e[94m                    Services                      "
echo -e "\e[94m                                                  "
echo -e "\e[94m    OpenSSH        :   "$opensshport
echo -e "\e[94m    Dropbear       :   "$dropbearport
echo -e "\e[94m    SSL            :   "$stunnel4port
echo -e "\e[94m    OpenVPN        :   "$openvpnport
echo -e "\e[94m    Port Squid     :   "$squidport
echo -e "\e[94m    Nginx          :   "$nginxport
echo -e "\e[94m                                                  "
echo -e "\e[94m              Other Features Included             "
echo -e "\e[94m    Commands       :   menu | accounts | options | server"
echo -e "\e[94m    Timezone       :   Asia/Kuala_Lumpur  (GMT +8)       "
echo -e "\e[94m    Webmin         :   http://$MYIP:10000/        "
echo -e "\e[94m    Anti-Torrent   :   [ON]                      "
echo -e "\e[94m    Cron Scheduler :   [ON]                       "
echo -e "\e[94m    Fail2Ban       :   [ON]                       "
echo -e "\e[94m    DDOS Deflate   :   [ON]                       "
echo -e "\e[94m    LibXML Parser  :   {ON]                       "
echo -e "\e[0m                                                   "
echo -e "\e[94m[][][]======================================[][][]\e[0m"
echo -e "\e[0m                                                   "
echo -e "\e[94m          Press Any Key To Show Continue          "


 # Clearing all logs from installation
 rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog

rm -f gsp*
exit 1
