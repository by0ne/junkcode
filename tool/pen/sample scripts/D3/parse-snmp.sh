#!/bin/bash

if [$# -ne1]; then
	echo "Usage : S0 <snmpwalk-output-file>"
	exit
fi

echo -e "\n[*] User List\n#####################"
grep '77.1.2.25.1.1' $1 | cut -d" " -f4

echo -e "\n[*] Installed Software\n#####################"
grep 'hrSWInstalledName' $1 | cut -d" " -f4-20

echo -e "\n[*] Running Processes\n#####################"
grep 'hrSWRunName' $1 | cut -d" " -f4

echo -e "\n[*] Tcp Connections\n#####################"
grep 'tcpConnState' $1 | grep listen | cut -d"." -f6 | sort -nu

echo -e "\n[*] Running Services\n#####################"
grep '77.1.2.3.1.1' $1 | cut -d" " -f4-20







