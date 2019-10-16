sudo sysctl -w net.ipv4.ip_forward=1
screen -dmLS openvpn "openvpn --config router.ovpn"
sudo iptables -t filter -I FORWARD -i ${TUN_INTERFACE} -o ${WAN_INTERFACE} -j ACCEPT
sudo iptables -t filter -I FORWARD -i ${WAN_INTERFACE} -o ${TUN_INTERFACE} -j ACCEPT
sudo iptables -t nat -I POSTROUTING -o ${WAN_INTERFACE} -j MASQUERADE