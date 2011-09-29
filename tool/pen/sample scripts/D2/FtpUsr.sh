#!/bin/bash
groupadd ftpgroup
useradd -g ftpgroup -d /dev/null -s /etc ftpuser
echo "[*] Setting up FTP user roots\n"
pure-pw useradd roots -u ftpuser -d /ftphome
pure-pw mkdb
cd /etc/pure-ftpd/auth/
ln -s ../conf/PureDB 60pdb
echo "[*] Setting home directory in /ftphome/\n"
mkdir /ftphome
chown -R ftpuser:ftpgroup /ftphome/
echo "[*] Starting FTP server\n"
/etc/init.d/pure-ftpd restart
