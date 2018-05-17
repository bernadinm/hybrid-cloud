config t
line vty 0 4
exec-timeout 3 50
configure terminal
crypto ikev2 profile default
match identity remote fqdn domain cisco.com
identity local fqdn ${local_hostname}.cisco.com
authentication remote pre-share key ${remote_pre_share_key}
authentication local pre-share key ${local_pre_share_key}
interface Tunnel0
ip address ${tunnel_ip_local_site} 255.255.255.252
tunnel source GigabitEthernet1
tunnel destination ${public_ip_remote_site}
tunnel protection ipsec profile default
crypto ikev2 dpd 10 2 on-demand
int gi2
no shut
ip route ${private_ip_remote_site} 255.255.0.0 ${tunnel_ip_remote_site}
