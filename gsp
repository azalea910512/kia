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
 cat <<'EOF9'> /etc/openvpn/server.crt
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
EOF9
 cat <<'EOF10'> /etc/openvpn/server.key
-----BEGIN PRIVATE KEY-----
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
dr3Szfw/1BrXI2OgvFxke2i6hA==
-----END PRIVATE KEY-----
EOF10
 cat <<'EOF13'> /etc/openvpn/tls-auth.key
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
EOF13
cat <<'EOF14'> /etc/openvpn/dh.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA2w2E4Ppnc89jXP4tBsMizxtRPmpwJkYoBpF9EVN5QO/ws96/x8Te
hAg2mD6ZzoPFm4KhjD9YrD+M3c05j2kCLMnPc81i+EQ6M+xG6hzbPl5D8upe3W3/
RoYadS85yIEJPs+SFToO3tXZlCklbU9+MVm8FaWohC32j4O3dNTDvKIQtSWjU0WC
m1OVQAgdv4TZtcF5/FSGFbbcGY1arrrX0JK4+0ThW9XktTL9LPCNM/0UqSAqSB89
LvFFlL47ek5JPMh76ulEBxWco2FHbnSsIWd12rYMGRn7G/EqbR1pQi+3UNMQpAIz
5JnupCKu4GFS6KU5q1WKg0q1IBvhNroRwwIBAg==
-----END DH PARAMETERS-----
EOF14
 cat <<'EOF114'> /etc/openvpn/crl.pem
-----BEGIN X509 CRL-----
MIIBsDCBmQIBATANBgkqhkiG9w0BAQsFADATMREwDwYDVQQDDAhSYWR6IFZQThcN
MTkwODA4MDM1NDI1WhcNMjAwMjA0MDM1NDI1WqBSMFAwTgYDVR0jBEcwRYAUpZcJ
dK9kVRcXepwjPkZbQahd+YKhF6QVMBMxETAPBgNVBAMMCFJhZHogVlBOghQHkI1U
FC2+EYQoi9jXsAtjsYTrHzANBgkqhkiG9w0BAQsFAAOCAQEAauCvXzfFxGk1x1sz
UKTjrG4A1QG3nD/5V9Zd2N0uClXGwHUi7wn4BDT7ckGtdNyl37SQ+WK+C73lUbz8
u6Pj40k8/YOMD3IasInHYG74ZulVCg0KbXxCgi6TXl5/c1XT+sSSuO46XNpRWkV3
lRhj31D3Uh5jbrCJ6bCyWU+nv/DA1QsFXXo2BfcMU7a6XoJ6n/zrogwzrXvPpYkh
CuZEyGkEZO8Wd0KYGm7pT2nsFzmUqES2W5LLZkVtgYziKG7/5Lcw4u1OOd/R3Jqy
NDJboL0lnAK6QLMspx3OThLdusI2Kn/cEQiSdhC9RExBibS83N2Fti+3lom0rjdX
j+cNXw==
-----END X509 CRL-----
EOF114

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
