$IPTABLES -A INPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

$IPTABLES -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

$IPTABLES -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP

$IPTABLES -A INPUT -p tcp -i eth0 -m state --state NEW -m recent --set
$IPTABLES -A INPUT -p tcp -i eth0 -m state --state NEW -m recent --update --seconds 30 --hitcount 10 -j DROP
$IPTABLES -A FORWARD -p tcp -i eth0 -m state --state NEW -m recent --set
$IPTABLES -A FORWARD -p tcp -i eth0 -m state --state NEW -m recent --update --seconds 30 --hitcount 10 -j DROP

# Allow most ICMP packets to be received (so people can check our
# presence), but restrict the flow to avoid ping flood attacks
iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -p icmp -m icmp -m limit --limit 1/second -j ACCEPT 

# Drop invalid packets immediately
iptables -A INPUT   -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A OUTPUT  -m state --state INVALID -j DROP
# Protect against SYN floods by rate limiting the number of new
# connections from any host to 60 per second.  This does *not* do rate
# limiting overall, because then someone could easily shut us down by
# saturating the limit.
iptables -A INPUT -m state --state NEW -p tcp -m tcp --syn \
    -m recent --name synflood --set
iptables -A INPUT -m state --state NEW -p tcp -m tcp --syn \
    -m recent --name synflood --update --seconds 1 --hitcount 60 -j DROP

# Anyone who tried to portscan us is locked out for an entire day.
iptables -A INPUT   -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP

# Once the day has passed, remove them from the portscan list
iptables -A INPUT   -m recent --name portscan --remove
iptables -A FORWARD -m recent --name portscan --remove

# These rules add scanners to the portscan list, and log the attempt.
iptables -A INPUT   -p tcp -m tcp --dport 139 \
    -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
iptables -A INPUT   -p tcp -m tcp --dport 139 \
    -m recent --name portscan --set -j DROP

iptables -A FORWARD -p tcp -m tcp --dport 139 \
    -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
iptables -A FORWARD -p tcp -m tcp --dport 139 \
    -m recent --name portscan --set -j DROP

###################
      # Null scan
      # Log attack
      iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> Null scan "
      # Drop and blacklist for 60 seconds IP of attacker
      iptables -A INPUT -p tcp --tcp-flags ALL NONE  -m recent --name blacklist_60 --set -m comment --comment "Drop/Blacklist Null scan" -j DROP

      # xmas
      # Log attacks
      iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS scan "
      iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS-PSH scan "
      iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS-ALL scan "
      # Drop and blacklist for 60 seconds IP of attacker
      iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m recent --name blacklist_60 --set  -m comment --comment "Drop/Blacklist Xmas/PSH scan" -j DROP # Xmas-PSH scan
      iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -m recent --name blacklist_60 --set  -m comment --comment "Drop/Blacklist Xmas scan" -j DROP # Against nmap -sX (Xmas tree scan)
      iptables -A INPUT -p tcp --tcp-flags ALL ALL -m recent --name blacklist_60 --set  -m comment --comment "Drop/Blacklist Xmas/All scan" -j DROP # Xmas All scan
# trapped 
      # log  probable sS and full connect tcp scan
      iptables -A INPUT -p tcp  -m multiport --dports 23,79 --tcp-flags ALL SYN -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall>SYN scan trap:"
      iptables -A  INPUT -p tcp  -m multiport --dports 23,79 --tcp-flags ALL SYN -m recent --name blacklist_180 --set -j DROP

ptables -N external

iptables -A external -i eth0 -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH

iptables -A external -i eth0 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 600 --hitcount 4 --rttl --name SSH -j LOG --log-prefix "SSH BRUTE FORCE PROTECTION "

iptables -A external -i eth0 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 600 --hitcount 4 --rttl --name SSH -j DROP 
