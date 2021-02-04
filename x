#!/bin/sh

wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg|apt-key add -
sleep 2
echo "deb http://build.openvpn.net/debian/openvpn/release/2.4 stretch main" > /etc/apt/sources.list.d/openvpn-aptrepo.list
#Requirement
apt update
apt upgrade -y
apt install openvpn nginx php7.0-fpm stunnel4 squid3 dropbear easy-rsa vnstat ufw build-essential fail2ban zip -y

# initializing var
MYIP=`ifconfig eth0 | awk 'NR==2 {print $2}'`
MYIP2="s/xxxxxxxxx/$MYIP/g";
cd /root
wget "https://raw.githubusercontent.com/Gugun09/VPSauto/master/tool/plugin.tgz"
wget "https://raw.githubusercontent.com/Gugun09/VPSauto/master/tool/premiummenu.zip"

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6


# set time GMT +8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# install webmin
cd
wget "https://raw.githubusercontent.com/Gugun09/premscript/master/webmin_1.801_all.deb"
dpkg --install webmin_1.801_all.deb;
apt-get -y -f install;
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
rm /root/webmin_1.801_all.deb
service webmin restart

# install screenfetch
cd
wget -O /usr/bin/screenfetch "https://raw.githubusercontent.com/Gugun09/VPSauto/master/tool/screenfetch"
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

# install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=442/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells

# install squid
apt-get -y install squid
cat > /etc/squid/squid.conf <<-END
acl server dst xxxxxxxxx/32 localhost
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
via on
request_header_access X-Forwarded-For deny all
request_header_access user-agent  deny all
reply_header_access X-Forwarded-For deny all
reply_header_access user-agent  deny all
http_port 8080
http_port 3128
http_port 8000
http_port 8888
acl all src 0.0.0.0/0
http_access allow all
access_log /var/log/squid/access.log
visible_hostname TD-LTE/FDD-LTE(nb110.cn)
cache_mgr Welcome_to_use_OpenVPN
#
END
sed -i $MYIP2 /etc/squid/squid.conf;
service squid restart

# setting banner
rm /etc/issue.net
wget -O /etc/issue.net "https://raw.githubusercontent.com/Gugun09/premscript/master/issue.net"
sed -i 's@#Banner@Banner@g' /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
service ssh restart
service dropbear restart

#install OpenVPN
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys

# replace bits
sed -i 's|export KEY_COUNTRY="US"|export KEY_COUNTRY="PH"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_PROVINCE="CA"|export KEY_PROVINCE="Rizal"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_CITY="SanFrancisco"|export KEY_CITY="Antipolo"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_ORG="Fort-Funston"|export KEY_ORG="EZ"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_EMAIL="me@myhost.mydomain"|export KEY_EMAIL="ezvpn@gmail.com"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU="MyOrganizationalUnit"|export KEY_OU="EZvpn"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_NAME="EasyRSA"|export KEY_NAME="EZvpn"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU=changeme|export KEY_OU=EZvpn|' /etc/openvpn/easy-rsa/vars
#Create Diffie-Helman Pem
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
# Create PKI
cd /etc/openvpn/easy-rsa
cp openssl-1.0.0.cnf openssl.cnf
. ./vars
./clean-all
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca $*
# create key server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server
# setting KEY CN
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" client
cd
#cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key} /etc/openvpn
cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn/server.crt
cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn/server.key
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/ca.crt
chmod +x /etc/openvpn/ca.crt

# Setting Server
tar -xzvf /root/plugin.tgz -C /usr/lib/openvpn/
chmod +x /usr/lib/openvpn/*
cat > /etc/openvpn/server.conf <<-END
port 1147
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
verify-client-cert none
username-as-common-name
plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so login
server 192.168.10.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log openvpn.log
verb 3
ncp-disable
cipher none
auth none

END
systemctl start openvpn@server
#Create OpenVPN Config
mkdir -p /home/vps/public_html
cat > /home/vps/public_html/tcp.ovpn <<-END

# Gakod
client
dev tun
proto tcp
remote $MYIP 1147
persist-key
persist-tun
pull
resolv-retry infinite
nobind
user nobody
comp-lzo
remote-cert-tls server
verb 3
mute 2
connect-retry 5 5
connect-retry-max 8080
mute-replay-warnings
redirect-gateway def1
script-security 2
cipher none
auth none
http-proxy $MYIP 8080
http-proxy-retry
<auth-user-pass>
sam
sam
</auth-user-pass>
END
echo '<ca>' >> /home/vps/public_html/tcp.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/tcp.ovpn
echo '</ca>' >> /home/vps/public_html/tcp.ovpn
echo '<cert>' >> /home/vps/public_html/tcp.ovpn
cat /etc/openvpn/server.crt >> /home/vps/public_html/tcp.ovpn
echo '</cert>' >> /home/vps/public_html/tcp.ovpn
echo '<key>' >> /home/vps/public_html/tcp.ovpn
cat /etc/openvpn/server.key >> /home/vps/public_html/tcp.ovpn
echo '</key>' >> /home/vps/public_html/tcp.ovpn

cat > /home/vps/public_html/ssl.ovpn <<-END

# Gakod
client
dev tun
proto tcp
remote 127.0.0.1 1147
route $MYIP 255.255.255.255 net_gateway
persist-key
persist-tun
pull
resolv-retry infinite
nobind
user nobody
comp-lzo
remote-cert-tls server
verb 3
mute 2
connect-retry 5 5
connect-retry-max 8080
mute-replay-warnings
redirect-gateway def1
script-security 2
cipher none
auth none
<auth-user-pass>
sam
sam
</auth-user-pass>
END
echo '<ca>' >> /home/vps/public_html/ssl.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/ssl.ovpn
echo '</ca>' >> /home/vps/public_html/ssl.ovpn
echo '<cert>' >> /home/vps/public_html/ssl.ovpn
cat /etc/openvpn/server.crt >> /home/vps/public_html/ssl.ovpn
echo '</cert>' >> /home/vps/public_html/ssl.ovpn
echo '<key>' >> /home/vps/public_html/ssl.ovpn
cat /etc/openvpn/server.key >> /home/vps/public_html/ssl.ovpn
echo '</key>' >> /home/vps/public_html/ssl.ovpn

cat > /home/vps/public_html/stunnel.conf <<-END

client = yes
debug = 6

[openvpn]
accept = 127.0.0.1:1147
connect = $MYIP:587
TIMEOUTclose = 0
verify = 0
sni = m.facebook.com
END

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

#pivpn
curl https://raw.githubusercontent.com/pivpn/pivpn/master/auto_install/install.sh | bash

#Shadowsocks
wget -N --no-check-certificate -c -t3 -T60 -O ss-plugins.sh https://git.io/fjlbl
chmod +x ss-plugins.sh

#v2ray
source <(curl -sL https://multi.netlify.com/v2ray.sh) --zh

#obfs proxy
wget -O /etc/openvpn/ "https://raw.githubusercontent.com/HRomie/obfs4proxy-openvpn/master/obfs4proxy-openvpn"
chmod +x /etc/openvn/obfs4proxy-openvpn

# Configure Stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -sha256 -subj '/CN=127.0.0.1/O=localhost/C=PH' -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem
cat > /etc/stunnel/stunnel.conf <<-END

sslVersion = all
pid = /stunnel.pid
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no

[openvpn]
accept = 587
connect = 127.0.0.1:1147
cert = /etc/stunnel/stunnel.pem

[dropbear]
accept = 443
connect = 127.0.0.1:442
cert = /etc/stunnel/stunnel.pem

END

#Setting UFW
ufw allow ssh
ufw allow 1147/tcp
sed -i 's|DEFAULT_INPUT_POLICY="DROP"|DEFAULT_INPUT_POLICY="ACCEPT"|' /etc/default/ufw
sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|' /etc/default/ufw

# set ipv4 forward
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

#Setting IPtables
cat > /etc/iptables.up.rules <<-END
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -j SNAT --to-source xxxxxxxxx
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:fail2ban-ssh - [0:0]
-A INPUT -p tcp -m multiport --dports 22 -j fail2ban-ssh
-A INPUT -p ICMP --icmp-type 8 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 22  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 80  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 143  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 442  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 443  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 587  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 1147  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 1147  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 3128  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 3128  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8080  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 8080  -m state --state NEW -j ACCEPT 
-A INPUT -p tcp --dport 10000  -m state --state NEW -j ACCEPT
-A fail2ban-ssh -j RETURN
COMMIT
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
END
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules


# Install BadVPN
apt-get -y install cmake make gcc
wget https://raw.githubusercontent.com/GegeEmbrie/autosshvpn/master/file/badvpn-1.999.127.tar.bz2
tar xf badvpn-1.999.127.tar.bz2
mkdir badvpn-build
cd badvpn-build
cmake ~/badvpn-1.999.127 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install
screen badvpn-udpgw --listen-addr 127.0.0.1:7300 > /dev/null &
cd

# install ddos deflate
apt-get -y install dnsutils dsniff
wget https://raw.githubusercontent.com/abehake/script/master/ddos-deflate-master.zip
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh

# Configure Nginx
sed -i 's/\/var\/www\/html;/\/home\/vps\/public_html\/;/g' /etc/nginx/sites-enabled/default
cp /var/www/html/index.nginx-debian.html /home/vps/public_html/index.html
mkdir -p /home/vps/public_html
cat > /home/vps/public_html/index.html <<-END
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Embex VPN</title>
        <meta name="description" content="Use Embex VPN for free!" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!--Bootstrap 4-->
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <link rel="stylesheet" href="https://raw.githubusercontent.com/radzvpn/TNTNOLOADDNS/master/animate.min.css">
        <!--icons-->
        <link rel="stylesheet" href="https://raw.githubusercontent.com/radzvpn/TNTNOLOADDNS/master/ionicons.min.css" />
    </head>
    <body>
        <!--header-->
        <nav class="navbar navbar-expand-md navbar-dark fixed-top sticky-navigation">
            <button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
                <span class="ion-grid icon-sm"></span>
            </button>
            <a class="navbar-brand hero-heading" href="#">Embex VPN</a>
            <div class="collapse navbar-collapse" id="navbarCollapse">
                <ul class="navbar-nav ml-auto">
                    <li class="nav-item mr-3">
                        <a class="nav-link page-scroll" href="#main">Home<span class="sr-only">(current)</span></a>
                    </li>
                    <li class="nav-item mr-3">
                        <a class="nav-link page-scroll" href="#features">Features</a>
                    </li>
                    <li class="nav-item mr-3">
                        <a class="nav-link page-scroll" href="#configs">Configs</a>
                    </li>
                    <li class="nav-item mr-3">
                        <a class="nav-link page-scroll" href="#download">VPN App</a>
                    </li>
					<li class="nav-item mr-3">
                        <a class="nav-link page-scroll" href="#team">Our Team</a>
                    </li>
                    <li class="nav-item mr-3">
                        <a class="nav-link page-scroll" href="#links">Links</a>
                    </li>
                    <li class="nav-item mr-3">
                        <a class="nav-link page-scroll" href="#contact">Contact</a>
                    </li>
                </ul>
            </div>
        </nav>

        <!--main section-->
        <section class="bg-texture hero" id="main">
            <div class="container">
                <div class="row d-md-flex brand">
                    <div class="col-md-6 hidden-sm-down wow fadeIn">
                        <img class="img-fluid mx-auto d-block" src="img/product.png"/>
                    </div>
                    <div class="col-md-6 col-sm-12 text-white wow fadeIn">
                        <h2 class="pt-4">Experience <b class="text-primary-light">Embex VPN </b> for FREE</h2>
                        <p class="mt-5">
                            The best gets even better. With our swift and fastest low ping private server, you'll not being worried again with our vpn services.
                        </p>
                        <p class="mt-5">
                            <a href="#configs" class="btn btn-primary mr-2 mb-2 page-scroll">Try Now</a>
                            <a href="#download" class="btn btn-white mb-2 page-scroll">Download App</a>
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <!--features-->
        <section class="bg-light" id="features">
            <div class="container">
                <div class="row mb-3">
                    <div class="col-md-6 col-sm-8 mx-auto text-center wow fadeIn">
                        <h2 class="text-primary">Amazing Features of Embex VPN</h2>
                        <p class="lead mt-4">
                            A plenty of awesome features to <br/>wow the users.
                        </p>
                    </div>
                </div>
                <div class="row mt-5 text-center">
                    <div class="col-md-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <div class="icon-box">
                                    <em class="ion-ios-game-controller-b-outline icon-md"></em>
                                </div>
                                <h6>Unlimited Gaming</h6>
                                <p>
                                    Low ping & Optimized server for your best unlimited gaming experience. 
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <div class="icon-box">
                                    <em class="ion-android-wifi icon-md"></em>
                                </div>
                                <h6>Cloudflare DNS</h6>
                                <p>
                                    With the best DNS installed in our server to keep your connection at stable, streaming faster, download accelerated, & uploading boosted. 
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <div class="icon-box">
                                    <em class="ion-ios-settings icon-md"></em>
                                </div>
                                <h6>Advanced Configs</h6>
                                <p>
                                    All our SSH/OVPN/DROPBEAR/SSL are highly configurable to meet your VPN experience & satisfaction. 
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <div class="icon-box">
                                    <em class="ion-ios-cloud-upload-outline icon-md"></em>
                                </div>
                                <h6>Unlimited Bandwidth</h6>
                                <p>
                                    No capping and you can download/stream/browse all what you want without limitations. 
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <div class="icon-box">
                                    <em class="ion-ios-locked-outline icon-md"></em>
                                </div>
                                <h6>Highly Secure</h6>
                                <p>
                                    Our server is from best VPS Cloud service, with anti-torrent & anti-ddos installed for our servers go for a longer last. 
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <div class="icon-box">
                                    <em class="ion-android-color-palette icon-md"></em>
                                </div>
                                <h6>More Features & Colors</h6>
                                <p>
                                    With more future plans coming to keep this server colored and beautiful. 
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="bg-white p-0">
            <div class="container-fluid">
                <div class="row d-md-flex mt-5">
                    <div class="col-sm-6 p-0 wow fadeInLeft">
                        <img class="img-fluid" src="img/whyus.png" alt="Why we Choose us">
                    </div>
                    <div class="col-sm-6 pl-5 pr-5 pt-5 pb-4 wow fadeInRight">
                        <h3><a href="#"></a></h3>
                        <p class="lead pt-4">VPN (virtual private network) is a technology that could make internet access you comfortable with eliminating prevention in accessing all sites. Giving new anonymous identity, disguise your original location and encrypts all traffic, such things make all data access and secure internet. Internet service provider or network operator, even the government, will not be able to check or filter your activity on the web.</p>
						Why you choose Embex VPN?
                        <ul class="pt-4 pb-3 list-default">
                            <li><font color="green"><b>FREE at all</b></font></li>
                            <li>Anonymous</li>
                            <li>Safe</li>
                            <li>Fast</li>
                            <li>Low Ping</li>
                            <li>Smooth</li>
                            <li>The best of the BEST!</li>
                        </ul>
                        <a href="#configs" class="btn btn-primary mr-2 page-scroll">Get Started with Embex VPN</a>
                    </div>
                </div>
            </div>
        </section>

        <!--pricing-->
        <section class="bg-light" id="configs">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 offset-md-3 col-sm-8 offset-sm-2 col-xs-12 text-center">
                        <h2 class="text-primary">Configs</h2>
                        <p class="lead pt-3">
                            Our OpenVPN configs.
                        </p>
                    </div>
                </div>
                <div class="row d-md-flex mt-4 text-center">
                    <div class="col-sm-4 mt-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title pt-4 text-orange">OpenVPN</h5>
                                <h3 class="card-title text-primary pt-4">TCP</h3>
                                <p class="card-text text-muted pb-3 border-bottom">Default Config</p>
                                <ul class="list-unstyled pricing-list">
                                    <li>Port: 1153</li>
                                    <li>TCP Connection</li>
                                    <li>Stable</li>
                                    <li>Fast &amp; Smooth</li>
                                </ul>
                                <a href="/client.ovpn" class="btn btn-primary btn-radius">Download</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4 mt-0 wow fadeIn">
                        <div class="card pt-4 pb-4">
                            <div class="card-body">
                                <h5 class="card-title pt-4 text-orange">OpenVPN</h5>
                                <h3 class="card-title text-primary pt-4"><sup></sup>SSL</h3>
                                <p class="card-text text-muted pb-3 border-bottom">Default config</p>
                                <ul class="list-unstyled pricing-list">
                                    <li>Port: 443</li>
                                    <li>OpenVPN over SSL</li>
                                    <li>Stable</li>
                                    <li>Fast &amp; Smooth</li>
                                </ul>
                                <a href="/clientssl.ovpn" class="btn btn-primary btn-radius">Download</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4 mt-4 wow fadeIn">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title pt-4 text-orange">OpenVPN Package <small class="badge bg-primary small-xs">HOT</small></h5>
                                <h3 class="card-title text-primary pt-4"><sup></sup>Combo</h3>
                                <p class="card-text text-muted pb-3 border-bottom">zip packed</p>
                                <ul class="list-unstyled pricing-list">
                                    <li>TCP &amp; SSL</li>
                                    <li>With stunnel.conf</li>
                                    <li>For modem used</li>
                                    <li>Zip packed</li>
                                </ul>
                                <a href="/openvpn.zip" class="btn btn-primary btn-radius">Download</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!--download-->
        <section class="bg-orange pt-0" id="download">
            <div class="container">
                <div class="row d-md-flex text-center wow fadeIn">
                    <div class="col-md-6 offset-md-3 col-sm-10 offset-sm-1 col-xs-12">
                        <h5 class="text-primary">Download Our Mobile App</h5>
                        <p class="mt-4">
                            Download our provided apps for free for your android phone & pc.
                            
                        <p class="mt-5">
                            RADZ VPN<br><a href="https://play.google.com/store/apps/details?id=youpz.vpn.ssh" class="mr-2" target="_blank"><img src="img/google-play.png" class="store-img"/></a><br>
                            WENZ VPN<br><a href="https://play.google.com/store/apps/details?id=wenz.soft.dev.wenzvpn" class="mr-2" target="_blank"><img src="img/google-play.png" class="store-img"/></a><br>
                            Configs PH<br><a href="https://play.google.com/store/apps/details?id=fb.com.nicanor03" class="mr-2" target="_blank"><img src="img/google-play.png" class="store-img"/></a><br>
							<br>FOR PC<br><a href="https://www.phcorner.net/threads/685100/" target="_blank">Uni OVPN (&#169; JustPlaying)</a>
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <!--team-->
        <section class="bg-white" id="team">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 col-sm-8 mx-auto text-center">
                        <h2 class="text-primary">Our Team</h2>
                        <p class="lead pt-3">
                            Meet our awesome team.
                        </p>
                    </div>
                </div>
                <div class="row d-md-flex mt-5 text-center">
                    <div class="team col-sm-3 mt-2 wow fadeInLeft">
                        <img src="img/team-1.gif" alt="Owner" class="img-team img-fluid rounded-circle"/>
                        <h5>Embex | KDS</h5>
                        <p>Developer, Owner</p>
                    </div>
                    <div class="team col-sm-3 mt-2 wow fadeIn">
                        <img src="img/team-2.jpg" alt="Team Epiphany" class="img-team img-fluid rounded-circle"/>
                        <h5>Team Epiphany</h5>
                        <p>Our Official Group Name</p>
                    </div>
                    <div class="team col-sm-3 mt-2 wow fadeIn">
                        <img src="img/team-3.gif" alt="Embex" class="img-team img-fluid rounded-circle"/>
                        <h5>EMBEX TEAM</h5>
                        <p>Partner Team</p>
                    </div>
                    <div class="team col-sm-3 mt-2 wow fadeInRight">
                        <img src="img/team-4.png" alt="Team Unstoppable" class="img-team img-fluid rounded-circle"/>
                        <h5>Team Unstoppable</h5>
                        <p>Partner Team</p>
                    </div>
                </div>
            </div>
        </section>

        <!--blog-->
        <section class="bg-light" id="links">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 offset-md-3 col-sm-8 offset-sm-2 col-xs-12 text-center">
                        <h2 class="text-primary">Links</h2>
                        <p class="lead pt-3">
                            Our recommended and partner sites.
                        </p>
                    </div>
                </div>
                <div class="row d-md-flex mt-5">
                    <div class="col-sm-4 mt-2 wow fadeIn">
                        <div class="card">
                            <img class="card-img-top" src="img/pt.png" alt="PinoyThread">
                            <div class="card-body">
                                <p class="card-text text-muted small-xl">
                                    <em class="ion-ios-calendar-outline"></em>&nbsp;&nbsp;
                                    <em class="ion-ios-person-outline"></em>  &nbsp;&nbsp;
                                    <em class="ion-ios-time-outline"></em>
                                </p>
                                <h5 class="card-title"><a href="https://www.pinoythread.com" target="_blank">Join PinoyThread Forum!</a></h5>
                                <p class="card-text">Welcome to PinoyThread. Come and join discuss about the pinoy cyber world.<br>FREE VPNs<br>Giveaways<br>Droplets<br>more...</p>
                            </div>
                            <div class="card-body text-right">
                                <a href="https://www.pinoythread.com" class="card-link" target="_blank"><strong>Join now</strong></a>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4 mt-2 wow fadeIn">
                        <div class="card">
                            <img class="card-img-top" src="img/radz.png" alt="RADZ VPN">
                            <div class="card-body">
                                <p class="card-text text-muted small-xl">
                                    <em class="ion-ios-calendar-outline"></em> &nbsp;&nbsp;
                                    <em class="ion-ios-person-outline"></em> &nbsp;&nbsp;
                                    <em class="ion-ios-time-outline"></em>
                                </p>
                                <h5 class="card-title"><a href="https://radzvpn.ml/" target="_blank">Finally! RADZ VPN</a></h5>
                                <p class="card-text">New Web Design<br>
								Can create up to 50 accounts every server per day<br>
								3 VIP Fast Servers Available<br>
								Fast and Easy to create account<br>
								Customer Service Chat Box Plugins<br>
								You can able to check your account info</p>
                            </div>
                            <div class="card-body text-right">
                                <a href="https://radzvpn.ml/" class="card-link"target="_blank"><strong>Visit now</strong></a>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4 mt-2 wow fadeIn">
                        <div class="card">
                            <img class="card-img-top" src="img/te.jpg" alt="Our Discord server">
                            <div class="card-body">
                                <p class="card-text text-muted small-xl">
                                    <em class="ion-ios-calendar-outline"></em>&nbsp;&nbsp;
                                    <em class="ion-ios-person-outline"></em> &nbsp;&nbsp;
                                    <em class="ion-ios-time-outline"></em>
                                </p>
                                <h5 class="card-title"><a href="https://discord.gg/EHq4XjH" target="_blank">The TEAM Epiphany</a></h5>
                                <p class="card-text"><b>TEAM Epiphany<b> is now live on Discord with...<br>
								VPN Scripts<br>
								Daily Giveaways<br>
								Friendly members<br>
								VPN Configs<br>
								Source Codes<br>
								Bins & VPS<br>
								A tons of richness of features<br>
								that you can't find here!</p>
                            </div>
                            <div class="card-body text-right">
                                <a href="https://discord.gg/EHq4XjH" class="card-link" target="_blank"><strong>Connect to them</strong></a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!--contact-->
        <section class="bg-texture-collage p-0" id="contact">
            <div class="container">
                <div class="row d-md-flex text-white text-center wow fadeIn">
                    <div class="col-sm-4 p-5">
                        <p><em class="ion-ios-telephone-outline icon-md"></em></p>
                        <p class="lead"><a href="https://discord.gg/EHq4XjH" target="_blank"><font color="#0000EE">Discord</font></a></p>
                    </div>
                    <div class="col-sm-4 p-5">
                        <p><em class="ion-ios-email-outline icon-md"></em></p>
                        <p class="lead">Embex@embex.online</p>
                    </div>
                    <div class="col-sm-4 p-5">
                        <p><em class="ion-ios-location-outline icon-md"></em></p>
                        <p class="lead">Jakarta, ID</p>
                    </div>
                </div>
            </div>
        </section>

        <!--footer-->
        <section class="bg-footer" id="connect">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 offset-md-3 col-sm-8 offset-sm-2 col-xs-12 text-center wow fadeIn">
                        <h1>Embex VPN</h1>
			<br>
			<iframe src="https://discordapp.com/widget?id=499555022078607360&amp;theme=dark" width="350" height="500" allowtransparency="true" frameborder="0"></iframe>
			<br>
                        <p class="mt-4">
                            <a href="https://discord.gg/EHq4XjH" target="_blank"><img src="img/discord.png" alt="Our Discord server"/></a>   
                            <a href="https://www.facebook.com/RADZ-VPN-260317881583057" target="_blank"><img src="img/facebook.png" alt="Our Facebook"/></a>
                           
                        </p>
                        <p class="pt-2 text-muted">
                            &copy; 2019 <a href="http://www.phcorner.net/members/446411/" target="_blank">Embex</a>
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <script src="https://raw.githubusercontent.com/radzvpn/TNTNOLOADDNS/master/jquery-3.1.1.min.js></script>
        <script src="https://raw.githubusercontent.com/radzvpn/TNTNOLOADDNS/master/umdpopper.min.js"></script>
        <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js"></script>
        <script src="https://raw.githubusercontent.com/radzvpn/TNTNOLOADDNS/master//jquery.easing.min.js"></script>
        <script src="https://raw.githubusercontent.com/radzvpn/TNTNOLOADDNS/master/wow.js"></script>
        <script src="js/scripts.js"></script>
    </body>
</html>
END

# Unpack Embex homepage
cd /home/vps/public_html
wget "https://raw.githubusercontent.com/radzvpn/TNTNOLOADDNS/master/hiratechihomepage.zip"
unzip hiratechihomepage.zip
rm hiratechihomepage.zip
cd


# Create and Configure rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e

exit 0
END
chmod +x /etc/rc.local
sed -i '$ i\echo "nameserver 8.8.8.8" > /etc/resolv.conf' /etc/rc.local
sed -i '$ i\echo "nameserver 8.8.4.4" >> /etc/resolv.conf' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local

# Configure menu
apt-get install unzip
cd /usr/local/bin/
wget "https://raw.githubusercontent.com/Gugun09/VPSauto/master/tool/premiummenu.zip" 
unzip premiummenu.zip
chmod +x /usr/local/bin/*

# add eth0 to vnstat
vnstat -u -i eth0

# compress configs
cd /home/vps/public_html
zip configs.zip client.ovpn OpenVPN-Stunnel.ovpn stunnel.conf

# install libxml-parser
apt-get install -y libxml-parser-perl

# finalizing
vnstat -u -i eth0
apt-get -y autoremove
chown -R www-data:www-data /home/vps/public_html
service nginx start
service php7.0-fpm start
service vnstat restart
service openvpn restart
service dropbear restart
service fail2ban restart
service squid restart

#clearing history
history -c
rm -rf /root/*
cd /root
# info
clear
echo " "
echo "Installation has been completed!!"
echo "DEVICE WILL REBOOT IN 10 SECONDS"
echo "PLEASE WAIT PATIENTLY AND RELOGIN TO YOUR VPS"
echo " "
echo "--------------------------- Configuration Setup Server -------------------------"
echo "                         Copyright HostingTermurah.net                          "
echo "                                Modified by wangzki                        "
echo "--------------------------------------------------------------------------------"
echo ""  | tee -a log-install.txt
echo "Server Information"  | tee -a log-install.txt
echo "   - Timezone    : Asia/Manila (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban    : [ON]"  | tee -a log-install.txt
echo "   - IPtables    : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot : [OFF]"  | tee -a log-install.txt
echo "   - IPv6        : [OFF]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Application & Port Information"  | tee -a log-install.txt
echo "   - OpenVPN		: TCP 1147 "  | tee -a log-install.txt
echo "   - OpenVPN-Stunnel	: 587 "  | tee -a log-install.txt
echo "   - Dropbear		: 442"  | tee -a log-install.txt
echo "   - Stunnel	: 443"  | tee -a log-install.txt
echo "   - Squid Proxy	: 3128, 8080 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Nginx		: 80"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Premium Script Information"  | tee -a log-install.txt
echo "   To display list of commands: menu"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Important Information"  | tee -a log-install.txt
echo "   - Download Config OpenVPN : http://$MYIP/configs.zip"  | tee -a log-install.txt
echo "   - Installation Log        : cat /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   - Webmin                  : http://$MYIP:10000/"  | tee -a log-install.txt
echo ""
echo "------------------------------ Modified by Gugun -----------------------------"
echo "-----Rebooting your VPS -----"
sleep 5