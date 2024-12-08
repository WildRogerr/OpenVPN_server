#!/bin/bash

ip_this_server () {
    if  read -p "Enter IP address this server: "; then _IP1=$REPLY
        
    fi
}

ip_destination_server () {
    if  read -p "Enter IP address destination server: "; then _IP2=$REPLY
        
    fi
}

ip_this_server

ip_destination_server

sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf

mkdir /root/bin/
touch /root/bin/vpn_route.sh

echo '#!/bin/sh' >> /root/bin/vpn_route.sh
echo -e \ >> /root/bin/vpn_route.sh
echo IPA=$_IP1 >> /root/bin/vpn_route.sh
echo IPD=$_IP2 >> /root/bin/vpn_route.sh
echo -e \ >> /root/bin/vpn_route.sh
echo '-P FORWARD DROP' >> /root/bin/vpn_route.sh
echo '-t nat -I PREROUTING -d "$IPA" -p tcp --dport 443 -j DNAT --to "$IPD"' >> /root/bin/vpn_route.sh
echo 'iptables -t nat -I POSTROUTING -d "$IPD" -p tcp --dport 443 -j MASQUERADE' >> /root/bin/vpn_route.sh
echo 'iptables -I FORWARD -d "$IPD" -j ACCEPT' >> /root/bin/vpn_route.sh
echo 'iptables -I FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT' >> /root/bin/vpn_route.sh
echo 'sysctl net.ipv4.ip_forward=1' >> /root/bin/vpn_route.sh

chmod 755 /root/bin/vpn_route.sh

touch /etc/systemd/system/openvpn-server-routing.service

echo '[Unit]' >> /etc/systemd/system/openvpn-server-routing.service
echo 'Description=Routing VPN ON' >> /etc/systemd/system/openvpn-server-routing.service
echo '[Service]' >> /etc/systemd/system/openvpn-server-routing.service
echo 'ExecStart=/root/bin/vpn_route.sh' >> /etc/systemd/system/openvpn-server-routing.service
echo '[Install]' >> /etc/systemd/system/openvpn-server-routing.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/openvpn-server-routing.service

systemctl enable openvpn-server-routing


echo Done!